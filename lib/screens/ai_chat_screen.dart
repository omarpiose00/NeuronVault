// lib/screens/ai_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:io';
import '../models/ai_agent.dart';
import '../services/api_service.dart';
import '../widgets/multimodal_message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/error_message_widget.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final SpeechToText _speechToText = SpeechToText();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _isListening = false;
  List<AiConversationMessage> _conversation = [];
  String _conversationId = DateTime.now().millisecondsSinceEpoch.toString();
  ConversationMode _currentMode = ConversationMode.chat;

  // Controllori per le animazioni
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Animazione del pulsante invio
  late AnimationController _sendButtonPulseController;
  late Animation<double> _sendButtonPulseAnimation;

  // Animazione modalità
  OverlayEntry? _modeBannerOverlay;

  @override
  void initState() {
    super.initState();
    _initSpeech();

    // Inizializza le animazioni principali
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuad),
    );

    _animationController.forward();

    // Animazione del pulsante di invio
    _sendButtonPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _sendButtonPulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _sendButtonPulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Ascolta i cambiamenti nel campo di testo per animare il pulsante
    _controller.addListener(() {
      if (_controller.text.trim().isNotEmpty && !_sendButtonPulseController.isAnimating) {
        _sendButtonPulseController.repeat(reverse: true);
      } else if (_controller.text.trim().isEmpty) {
        _sendButtonPulseController.stop();
        _sendButtonPulseController.reset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    _sendButtonPulseController.dispose();
    _modeBannerOverlay?.remove();
    super.dispose();
  }

  void _initSpeech() async {
    await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize(
        onStatus: (status) {
          if (status == 'done') {
            setState(() {
              _isListening = false;
            });
          }
        },
        onError: (errorNotification) {
          setState(() {
            _isListening = false;
          });
        },
      );

      if (available) {
        setState(() {
          _isListening = true;
        });
        _speechToText.listen(
          onResult: (result) {
            setState(() {
              _controller.text = result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() {
        _isListening = false;
        _speechToText.stop();
      });
    }
  }

  void _sendPrompt() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _isLoading = true;
      // Aggiungiamo il messaggio dell'utente subito
      _conversation.add(AiConversationMessage(agent: 'user', message: prompt));
      _controller.clear();
    });

    // Interrompi l'animazione del pulsante di invio
    _sendButtonPulseController.stop();
    _sendButtonPulseController.reset();

    // Scorrimento automatico verso il basso
    _scrollToBottom();

    try {
      final aiResp = await ApiService.askAgents(
        prompt,
        conversationId: _conversationId,
        mode: _currentMode,
      );
      setState(() {
        _conversation = aiResp.conversation;
        _isLoading = false;
      });

      // Assicurati che scorra in basso dopo aver ricevuto la risposta
      _scrollToBottom();
    } catch (e) {
      // Formatta l'errore in modo più user-friendly
      String errorMessage = 'Si è verificato un errore';

      if (e.toString().contains('OpenAI')) {
        errorMessage = 'Errore: Problema di connessione con GPT. Riprova più tardi.';
      } else if (e.toString().contains('Claude') || e.toString().contains('Anthropic')) {
        errorMessage = 'Errore: Problema di connessione con Claude. Riprova più tardi.';
      } else if (e.toString().contains('DeepSeek')) {
        errorMessage = 'Errore: Problema di connessione con DeepSeek. Riprova più tardi.';
      } else if (e.toString().contains('quota') || e.toString().contains('exceeded')) {
        errorMessage = 'Errore: Hai raggiunto il limite di utilizzo. Controlla il tuo piano.';
      } else if (e.toString().contains('connessione')) {
        errorMessage = e.toString();
      }

      setState(() {
        _conversation.add(AiConversationMessage(agent: 'system', message: errorMessage));
        _isLoading = false;
      });

      // Mostra anche un feedback visivo
      if (mounted) {
        _showErrorSnackbar('Errore di comunicazione con i servizi AI');
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
          textColor: Colors.white,
        ),
        animation: CurvedAnimation(
          parent: const AlwaysStoppedAnimation(1),
          curve: Curves.elasticOut,
        ),
      ),
    );
  }

  void _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      String prompt = _controller.text.trim().isEmpty
          ? "Descrivi questa immagine"
          : _controller.text.trim();

      setState(() {
        _isLoading = true;
        _conversation.add(AiConversationMessage(
          agent: 'user',
          message: prompt,
          mediaUrl: image.path,
          mediaType: 'image/jpeg',
        ));
        _controller.clear();
      });

      // Reset dell'animazione pulsante invio
      _sendButtonPulseController.stop();
      _sendButtonPulseController.reset();

      // Scorrimento automatico
      _scrollToBottom();

      try {
        final aiResp = await ApiService.uploadImage(
          prompt,
          File(image.path),
          conversationId: _conversationId,
        );
        setState(() {
          _conversation = aiResp.conversation;
          _isLoading = false;
        });

        _scrollToBottom();
      } catch (e) {
        // Formatta l'errore per immagini
        String errorMessage = 'Errore: Impossibile elaborare l\'immagine';

        if (e.toString().contains('size')) {
          errorMessage = 'Errore: L\'immagine è troppo grande. Prova con un\'immagine più piccola.';
        } else if (e.toString().contains('format')) {
          errorMessage = 'Errore: Formato immagine non supportato. Usa JPEG, PNG o GIF.';
        }

        setState(() {
          _conversation.add(AiConversationMessage(agent: 'system', message: errorMessage));
          _isLoading = false;
        });

        _showErrorSnackbar('Errore durante l\'elaborazione dell\'immagine');
      }
    }
  }

  void _resetChat() {
    // Animazione per la pulizia della chat
    _animationController.reverse().then((_) {
      setState(() {
        _conversation.clear();
        _controller.clear();
        _conversationId = DateTime.now().millisecondsSinceEpoch.toString();
      });
      _animationController.forward();
    });
  }

  void _changeMode(ConversationMode mode) {
    if (_currentMode == mode) return;

    // Animazione di transizione
    _animationController.reverse().then((_) {
      setState(() {
        _currentMode = mode;
      });
      _animationController.forward();
    });

    // Mostra un messaggio che spiega la modalità con un banner animato
    String modeTitle = "";
    String modeExplanation = "";
    IconData modeIcon;

    switch(mode) {
      case ConversationMode.chat:
        modeTitle = "Modalità Chat";
        modeExplanation = "Le AI risponderanno una dopo l'altra alle tue domande.";
        modeIcon = Icons.chat_bubble_outline;
        break;
      case ConversationMode.debate:
        modeTitle = "Modalità Dibattito";
        modeExplanation = "Le AI discuteranno il tema proposto, ciascuna offrendo un punto di vista diverso.";
        modeIcon = Icons.compare_arrows;
        break;
      case ConversationMode.brainstorm:
        modeTitle = "Modalità Brainstorming";
        modeExplanation = "Le AI collaboreranno per generare idee creative sul tema proposto.";
        modeIcon = Icons.lightbulb_outline;
        break;
    }

    // Mostra il banner animato con l'informazione sulla modalità
    _showModeBanner(modeTitle, modeExplanation, modeIcon);
  }

  void _showModeBanner(String title, String description, IconData icon) {
    // Rimuovi eventuale overlay precedente
    _modeBannerOverlay?.remove();

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    // Crea il nuovo overlay
    _modeBannerOverlay = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: 100,
          left: (MediaQuery.of(context).size.width - 300) / 2,
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              tween: Tween<double>(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - value) * -50),
                    child: Container(
                      width: 300,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(
                                icon,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              onEnd: () {
                Future.delayed(const Duration(seconds: 3), () {
                  _modeBannerOverlay?.remove();
                  _modeBannerOverlay = null;
                });
              },
            ),
          ),
        );
      },
    );

    overlay.insert(_modeBannerOverlay!);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Team AI'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _currentMode == ConversationMode.chat
                    ? 'Chat'
                    : (_currentMode == ConversationMode.debate
                    ? 'Dibattito'
                    : 'Brainstorming'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          PopupMenuButton<ConversationMode>(
            icon: Icon(
              Icons.mode_edit,
              color: theme.colorScheme.primary,
            ),
            onSelected: _changeMode,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: ConversationMode.chat,
                child: Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: _currentMode == ConversationMode.chat
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Modalità Chat'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ConversationMode.debate,
                child: Row(
                  children: [
                    Icon(
                      Icons.compare_arrows,
                      color: _currentMode == ConversationMode.debate
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Modalità Dibattito'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ConversationMode.brainstorm,
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: _currentMode == ConversationMode.brainstorm
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Modalità Brainstorming'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            color: theme.colorScheme.primary,
            onPressed: _resetChat,
            tooltip: 'Nuova conversazione',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Area della conversazione
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.black : Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation as Animation<Offset>, // Cast esplicito
                        child: child,
                      ),
                    );
                  },
                  child: _conversation.isEmpty && !_isLoading
                      ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _currentMode == ConversationMode.chat
                                ? Icons.chat_outlined
                                : (_currentMode == ConversationMode.debate
                                ? Icons.compare_arrows
                                : Icons.lightbulb_outline),
                            size: 48,
                            color: theme.colorScheme.primary.withOpacity(0.7),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _getModeWelcomeText(),
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Scrivi la tua richiesta per iniziare',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                      : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: _conversation.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, i) {
                      // Mostra lo spinner di caricamento come ultimo elemento se isLoading
                      if (_isLoading && i == _conversation.length) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Column(
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 12),
                                Text(
                                  "Le AI stanno pensando...",
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: isDark ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final message = _conversation[i];
                      final aiAgent = message.toAiAgent();

                      return MultimodalMessageBubble(
                        agent: aiAgent,
                        text: message.message,
                        selectable: true,
                        mediaUrl: message.mediaUrl,
                        mediaType: message.mediaType,
                      );
                    },
                  ),
                ),
              ),
            ),

            // Area di input migliorata
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Indicatore modalità
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _currentMode == ConversationMode.chat
                              ? Icons.chat_bubble_outline
                              : (_currentMode == ConversationMode.debate
                              ? Icons.compare_arrows
                              : Icons.lightbulb_outline),
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _currentMode == ConversationMode.chat
                              ? 'Modalità Chat'
                              : (_currentMode == ConversationMode.debate
                              ? 'Modalità Dibattito'
                              : 'Modalità Brainstorming'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Campo di input con pulsanti
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          enabled: !_isLoading,
                          decoration: InputDecoration(
                            hintText: _getModePlaceholderText(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            prefixIcon: IconButton(
                              icon: Icon(
                                Icons.image,
                                color: theme.colorScheme.secondary,
                              ),
                              onPressed: _isLoading ? null : _pickImage,
                              tooltip: 'Allega immagine',
                            ),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _isListening ? Icons.mic : Icons.mic_none,
                                    color: _isListening
                                        ? Colors.red
                                        : theme.colorScheme.secondary,
                                  ),
                                  onPressed: _isLoading ? null : _startListening,
                                  tooltip: 'Input vocale',
                                ),
                                AnimatedBuilder(
                                  animation: _sendButtonPulseController,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: 1.0 + (_sendButtonPulseAnimation.value * 0.2),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.send,
                                          color: _controller.text.trim().isNotEmpty
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.primary.withOpacity(0.5),
                                        ),
                                        onPressed: _isLoading || _controller.text.trim().isEmpty
                                            ? null
                                            : _sendPrompt,
                                        tooltip: 'Invia messaggio',
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          onSubmitted: (_) => _controller.text.trim().isNotEmpty ? _sendPrompt() : null,
                          maxLines: 3,
                          minLines: 1,
                          textInputAction: TextInputAction.send,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getModeWelcomeText() {
    switch (_currentMode) {
      case ConversationMode.chat:
        return 'Inizia una conversazione con il team AI';
      case ConversationMode.debate:
        return 'Proponi un tema per un dibattito tra le AI';
      case ConversationMode.brainstorm:
        return 'Avvia una sessione di brainstorming creativo';
    }
  }

  String _getModePlaceholderText() {
    switch (_currentMode) {
      case ConversationMode.chat:
        return 'Chiedi qualcosa al team AI...';
      case ConversationMode.debate:
        return 'Inserisci un tema per il dibattito...';
      case ConversationMode.brainstorm:
        return 'Su cosa vuoi fare brainstorming?';
    }
  }
}