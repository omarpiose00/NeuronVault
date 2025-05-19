// lib/screens/ai_chat_screen.dart - Versione completa corretta con animazioni

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math' as math;

import '../models/ai_agent.dart';
import '../models/conversation_mode.dart';
import '../services/api_service.dart';
import '../widgets/messaging/multimodal_message_bubble.dart';
import '../widgets/input/photo_input_button.dart';
import '../widgets/utils/demo_messages.dart';
import '../widgets/ui/glass_container.dart';
import '../widgets/ui/dynamic_background.dart';

class AiChatScreenUpdated extends StatefulWidget {
  final bool showDemoMessages;

  const AiChatScreenUpdated({
    super.key,
    this.showDemoMessages = false,
  });

  @override
  State<AiChatScreenUpdated> createState() => _AiChatScreenUpdatedState();
}

class _AiChatScreenUpdatedState extends State<AiChatScreenUpdated> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool _isScrolled = false;
  List<AiConversationMessage> _conversation = [];
  String _conversationId = DateTime.now().millisecondsSinceEpoch.toString();
  ConversationMode _currentMode = ConversationMode.chat;

  // Controllori per le animazioni
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Controllori per le nuove animazioni
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _rotateController;
  late Animation<double> _rotateAnimation;

  late AnimationController _backgroundAnimController;
  late Animation<double> _backgroundAnimation;

  // Indice della modalità attiva per animazioni tra tab
  int _activeTabIndex = 0;

  @override
  void initState() {
    super.initState();

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

    // Inizializza animazione di pulsazione
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Avvia la pulsazione dopo l'inizializzazione
    _pulseController.repeat(reverse: true);

    // Inizializza animazione di rotazione
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
    );

    // Avvia la rotazione dopo l'inizializzazione
    _rotateController.repeat();

    // Inizializza animazione di background
    _backgroundAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    _backgroundAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _backgroundAnimController, curve: Curves.easeInOut),
    );

    // Avvia l'animazione dopo l'inizializzazione
    _backgroundAnimController.repeat(reverse: true);

    _animationController.forward();

    // Imposta l'indice attivo iniziale in base alla modalità corrente
    _activeTabIndex = _currentMode.index;

    // Aggiungi listener per rilevare lo scroll
    _scrollController.addListener(() {
      setState(() {
        _isScrolled = _scrollController.offset > 10;
      });
    });

    // Carica i messaggi demo se richiesto
    if (widget.showDemoMessages) {
      _loadDemoMessages();
    }
  }

  /// Carica i messaggi demo per la modalità corrente
  void _loadDemoMessages() {
    setState(() {
      _conversation = DemoMessages.getForMode(_currentMode);
    });

    // Scorrimento automatico dopo un breve delay per dare tempo al layout di renderizzare
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _backgroundAnimController.dispose();
    super.dispose();
  }

  void _sendPrompt() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _isLoading = true;
      // Aggiungiamo il messaggio dell'utente subito
      _conversation.add(
          AiConversationMessage(
            agent: 'user',
            message: prompt,
            timestamp: DateTime.now(),
          )
      );
      _controller.clear();
    });

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
      setState(() {
        _conversation.add(AiConversationMessage(
          agent: 'system',
          message: 'Errore: Si è verificato un problema durante la comunicazione con i servizi AI. Riprova più tardi.',
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });

      // Mostra anche un feedback visivo
      if (mounted) {
        _showErrorSnackbar('Errore di comunicazione con i servizi AI');
      }
    }
  }

  void _handlePhotoSelected(XFile photo) async {
    String prompt = _controller.text.trim().isEmpty
        ? "Descrivi questa immagine"
        : _controller.text.trim();

    setState(() {
      _isLoading = true;
      _conversation.add(AiConversationMessage(
        agent: 'user',
        message: prompt,
        mediaUrl: photo.path,
        mediaType: 'image/jpeg',
        timestamp: DateTime.now(),
      ));
      _controller.clear();
    });

    // Scorrimento automatico
    _scrollToBottom();

    try {
      final aiResp = await ApiService.uploadImage(
        prompt,
        File(photo.path),
        conversationId: _conversationId,
      );
      setState(() {
        _conversation = aiResp.conversation;
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _conversation.add(AiConversationMessage(
          agent: 'system',
          message: 'Errore: Impossibile elaborare l\'immagine.',
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });

      _showErrorSnackbar('Errore durante l\'elaborazione dell\'immagine');
    }
  }

  void _resetChat() {
    // Animazione per la pulizia della chat
    _animationController.reverse().then((_) {
      setState(() {
        // Se la modalità demo è attiva, carica i messaggi demo per la modalità corrente
        if (widget.showDemoMessages) {
          _conversation = DemoMessages.getForMode(_currentMode);
        } else {
          _conversation.clear();
        }
        _controller.clear();
        _conversationId = DateTime.now().millisecondsSinceEpoch.toString();
      });
      _animationController.forward();

      // Scrolling dopo un breve delay
      if (widget.showDemoMessages) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollToBottom();
        });
      }
    });
  }

  void _changeMode(ConversationMode mode) {
    if (_currentMode == mode) return;

    // Salva l'indice della precedente modalità per l'animazione
    final newIndex = mode.index;

    // Animazione di transizione
    _animationController.reverse().then((_) {
      setState(() {
        _currentMode = mode;
        _activeTabIndex = newIndex;

        // Carica i messaggi demo per la nuova modalità se l'opzione è attiva
        if (widget.showDemoMessages) {
          _conversation = DemoMessages.getForMode(mode);
        } else {
          _conversation.clear();
        }
      });
      _animationController.forward();

      // Scrolling dopo un breve delay
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom();
      });
    });
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
      ),
    );
  }

  // NUOVO METODO: Costruisce il selettore di modalità dinamico
  Widget _buildDynamicModeSelector() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 20,
      blur: 10,
      backgroundColor: isDark
          ? theme.colorScheme.primary.withOpacity(0.1)
          : theme.colorScheme.primary.withOpacity(0.05),
      border: Border.all(
        color: theme.colorScheme.primary.withOpacity(0.2),
        width: 1.5,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Stack(
          children: [
            // Indicatore animato che scorre tra le opzioni
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutQuint,
              left: (_activeTabIndex * (MediaQuery.of(context).size.width - 60)) / 3,
              width: (MediaQuery.of(context).size.width - 60) / 3,
              top: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? theme.colorScheme.primary.withOpacity(0.3)
                                : theme.colorScheme.primaryContainer.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                ),
              ),
            ),

            // Opzioni del selettore
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildModeOption(
                  ConversationMode.chat,
                  'Chat',
                  Icons.chat_bubble_outline,
                ),
                _buildModeOption(
                  ConversationMode.debate,
                  'Dibattito',
                  Icons.compare_arrows,
                ),
                _buildModeOption(
                  ConversationMode.brainstorm,
                  'Brainstorm',
                  Icons.lightbulb_outline,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // NUOVO METODO: Costruisce un'opzione del selettore di modalità
  Widget _buildModeOption(ConversationMode mode, String label, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _currentMode == mode;

    return GestureDetector(
      onTap: () {
        if (_currentMode != mode) {
          _changeMode(mode);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icona
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? (isDark ? Colors.white : theme.colorScheme.onPrimaryContainer)
                  : theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 8),
            // Testo con animazione di fade quando cambia
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isSelected ? 14 : 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? (isDark ? Colors.white : theme.colorScheme.onPrimaryContainer)
                    : theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  // Metodo per creare un effetto particelle in background
  Widget _buildBackgroundParticles() {
    return AnimatedBuilder(
      animation: _backgroundAnimController,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlesPainter(
            progress: _backgroundAnimController.value,
            isDark: Theme.of(context).brightness == Brightness.dark,
            primaryColor: Theme.of(context).colorScheme.primary,
          ),
          child: Container(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DynamicBackground(
      child: Stack(
        children: [
          // Effetto particelle in background
          Positioned.fill(child: _buildBackgroundParticles()),

          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Row(
                children: [
                  // Logo animato che pulsa quando si caricano dati
                  AnimatedBuilder(
                      animation: _isLoading ? _pulseController : const AlwaysStoppedAnimation(0),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _isLoading ? (_pulseAnimation.value * 0.1 + 0.9) : 1.0,
                          child: const Text('Team AI'),
                        );
                      }
                  ),
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
              backgroundColor: isDark
                  ? theme.colorScheme.surface.withOpacity(0.8)
                  : theme.colorScheme.surface,
              elevation: 0,
              actions: [
                // Pulsante reset
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
                  // Mode Selector animato
                  _buildDynamicModeSelector(),

                  // Area della conversazione
                  Expanded(
                    child: GlassContainer(
                      borderRadius: 24,
                      blur: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      backgroundColor: isDark
                          ? Colors.black.withOpacity(0.2)
                          : Colors.white.withOpacity(0.15),
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: child,
                            ),
                          );
                        },
                        child: _conversation.isEmpty && !_isLoading
                            ? _buildWelcomeSection()
                            : _buildConversationList(),
                      ),
                    ),
                  ),

                  // Area di input migliorata
                  _buildInputSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(24),
        borderRadius: 16,
        backgroundColor: isDark
            ? theme.colorScheme.surface.withOpacity(0.5)
            : theme.colorScheme.surface.withOpacity(0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icona modalità con animazione di pulse
            AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Icon(
                      _currentMode == ConversationMode.chat
                          ? Icons.chat_outlined
                          : (_currentMode == ConversationMode.debate
                          ? Icons.compare_arrows
                          : Icons.lightbulb_outline),
                      size: 48,
                      color: theme.colorScheme.primary.withOpacity(0.7),
                    ),
                  );
                }
            ),
            const SizedBox(height: 16),
            Text(
              _getModeWelcomeText(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Scrivi la tua richiesta per iniziare',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationList() {
    return ListView.builder(
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
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final message = _conversation[i];
        final aiAgent = message.toAiAgent();

        // Animazione per i messaggi
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: 1.0,
          child: MultimodalMessageBubble(
            agent: aiAgent,
            text: message.message,
            selectable: true,
            mediaUrl: message.mediaUrl,
            mediaType: message.mediaType,
            timestamp: message.timestamp,
          ),
        );
      },
    );
  }

  // Indicatore di digitazione animato
  Widget _buildTypingIndicator(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : Colors.black54,
          ),
        ),
        const SizedBox(width: 8),
        ...List.generate(
          3,
              (index) => Container(
            margin: const EdgeInsets.only(right: 4),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 0,
      blur: 8,
      backgroundColor: isDark
          ? theme.colorScheme.surface.withOpacity(0.7)
          : theme.colorScheme.surface.withOpacity(0.8),
      child: Row(
        children: [
          // Pulsante selezione foto
          PhotoInputButton(
            onPhotoSelected: _handlePhotoSelected,
            isLoading: _isLoading,
          ),
          const SizedBox(width: 12),

          // Campo di testo
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
                    ? Colors.grey.shade800.withOpacity(0.6)
                    : Colors.grey.shade100.withOpacity(0.8),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              maxLines: 3,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendPrompt(),
            ),
          ),
          const SizedBox(width: 12),

          // Pulsante invio
          GestureDetector(
            onTap: _controller.text.trim().isNotEmpty ? _sendPrompt : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: _controller.text.trim().isNotEmpty
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
                boxShadow: _controller.text.trim().isNotEmpty
                    ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ]
                    : [],
              ),
              child: Icon(
                Icons.send,
                color: theme.colorScheme.onPrimary,
                size: 24,
              ),
            ),
          ),
        ],
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

// Painter per effetto particelle in background
class ParticlesPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  final Color primaryColor;

  ParticlesPainter({
    required this.progress,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final particleCount = 30; // Numero ridotto di particelle
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < particleCount; i++) {
      final seed = i * 0.1;
      // Calcoli semplificati per le posizioni
      final x = (math.sin(seed + progress * math.pi) * 0.5 + 0.5) * size.width;
      final y = (math.cos(seed * 1.5 + progress * math.pi) * 0.5 + 0.5) * size.height;

      // Dimensione fissa per evitare calcoli complessi
      final particleSize = 2.0;

      // Opacità fissa per evitare calcoli complessi
      paint.color = primaryColor.withOpacity(0.1);

      canvas.drawCircle(
        Offset(x, y),
        particleSize,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) => true;
}