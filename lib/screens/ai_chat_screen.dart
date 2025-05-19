// lib/screens/ai_chat_screen_updated.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../models/ai_agent.dart';
import '../services/api_service.dart';
import '../widgets/messaging/multimodal_message_bubble.dart';
import '../widgets/input/photo_input_button.dart';
import '../models/conversation_mode.dart';

class AiChatScreenUpdated extends StatefulWidget {
  const AiChatScreenUpdated({super.key});

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

    _animationController.forward();

    // Aggiungi listener per rilevare lo scroll
    _scrollController.addListener(() {
      setState(() {
        _isScrolled = _scrollController.offset > 10;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _animationController.dispose();
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
    );
  }

  Widget _buildWelcomeSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(24),
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

        return MultimodalMessageBubble(
          agent: aiAgent,
          text: message.message,
          selectable: true,
          mediaUrl: message.mediaUrl,
          mediaType: message.mediaType,
          timestamp: message.timestamp,
        );
      },
    );
  }

  Widget _buildInputSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
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
                        ? Colors.grey.shade800
                        : Colors.grey.shade100,
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