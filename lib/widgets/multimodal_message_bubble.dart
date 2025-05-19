// lib/widgets/multimodal_message_bubble.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:io';
import '../models/ai_agent.dart';
import 'markdown_renderer.dart';
import 'error_message_widget.dart';
import 'typing_indicator.dart';

class MultimodalMessageBubble extends StatefulWidget {
  final AiAgent? agent;
  final String text;
  final bool selectable;
  final String? mediaUrl;
  final String? mediaType;
  final bool isThinking;

  const MultimodalMessageBubble({
    super.key,
    this.agent,
    required this.text,
    this.selectable = false,
    this.mediaUrl,
    this.mediaType,
    this.isThinking = false,
  });

  @override
  State<MultimodalMessageBubble> createState() => _MultimodalMessageBubbleState();
}

class _MultimodalMessageBubbleState extends State<MultimodalMessageBubble> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Determine background color based on agent
    Color bg;
    Color borderColor;
    Color textColor;

    if (widget.agent == null) {
      // User message
      bg = isDarkMode
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.primaryContainer.withOpacity(0.7);
      borderColor = theme.colorScheme.primary.withOpacity(0.3);
      textColor = isDarkMode ? Colors.white : Colors.black87;
    } else {
      switch (widget.agent) {
        case AiAgent.claude:
          bg = isDarkMode
              ? const Color(0xFF5D4777).withOpacity(0.7)
              : const Color(0xFFE0BBE4).withOpacity(0.7);
          borderColor = const Color(0xFFD0BCFF).withOpacity(0.5);
          textColor = isDarkMode ? Colors.white : Colors.black87;
          break;
        case AiAgent.gpt:
          bg = isDarkMode
              ? const Color(0xFF004D40).withOpacity(0.7)
              : const Color(0xFFB2DFDB).withOpacity(0.7);
          borderColor = const Color(0xFF00BFA5).withOpacity(0.5);
          textColor = isDarkMode ? Colors.white : Colors.black87;
          break;
        case AiAgent.deepseek:
          bg = isDarkMode
              ? const Color(0xFF827717).withOpacity(0.7)
              : const Color(0xFFFFF59D).withOpacity(0.7);
          borderColor = const Color(0xFFFFEB3B).withOpacity(0.5);
          textColor = isDarkMode ? Colors.white : Colors.black87;
          break;
        default:
          bg = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
          borderColor = Colors.grey.withOpacity(0.3);
          textColor = isDarkMode ? Colors.white : Colors.black87;
      }
    }

    // Controlla se è un messaggio di errore
    final bool isErrorMessage = widget.agent == null && widget.text.toLowerCase().contains('errore:');

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isErrorMessage
                    ? (isDarkMode ? Colors.red.shade900.withOpacity(0.2) : Colors.red.shade50)
                    : bg,
                borderRadius: BorderRadius.circular(18),
                // Effetto Glassmorphism
                border: Border.all(
                  color: isErrorMessage
                      ? (isDarkMode ? Colors.red.shade800 : Colors.red.shade300)
                      : (isDarkMode ? Colors.white.withOpacity(0.1) : borderColor),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar con container animato
                      widget.agent == null
                          ? Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isErrorMessage
                              ? (isDarkMode ? Colors.red.shade800 : Colors.red.shade100)
                              : (isDarkMode
                              ? theme.colorScheme.primary.withOpacity(0.3)
                              : theme.colorScheme.primary.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          isErrorMessage ? Icons.error_outline : Icons.person,
                          color: isErrorMessage
                              ? (isDarkMode ? Colors.red.shade200 : Colors.red.shade800)
                              : (isDarkMode
                              ? Colors.white.withOpacity(0.9)
                              : theme.colorScheme.primary),
                          size: 24,
                        ),
                      )
                          : widget.agent != null ? agentIcon(widget.agent!) : SizedBox(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nome dell'agente
                            if (widget.agent != null || isErrorMessage)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  children: [
                                    Text(
                                      isErrorMessage ? "Sistema" : agentName(widget.agent!),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: isErrorMessage
                                            ? (isDarkMode ? Colors.red.shade300 : Colors.red.shade700)
                                            : textColor,
                                      ),
                                    ),
                                    if (widget.isThinking)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: TypingIndicator(
                                          dotColor: textColor.withOpacity(0.7),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                            // Contenuto multimediale (immagine, audio, ecc.)
                            if (widget.mediaUrl != null && widget.mediaType != null && !isErrorMessage)
                              _buildMediaContent(context),

                            // Testo con supporto markdown
                            const SizedBox(height: 8),

                            // Controlla se è un messaggio di errore
                            if (isErrorMessage)
                              ErrorMessageWidget(
                                errorMessage: widget.text,
                                onRetry: null, // Implementare la logica di retry se necessario
                              )
                            else
                              DefaultTextStyle(
                                style: TextStyle(color: textColor),
                                child: widget.selectable
                                    ? AiMarkdownRenderer(
                                  data: widget.text,
                                  selectable: true,
                                )
                                    : AiMarkdownRenderer(
                                  data: widget.text,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Pulsanti di azione (rispondi, copia, ecc.)
                  if (widget.agent != null && !isErrorMessage && !widget.isThinking)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildActionButton(
                            icon: Icons.content_copy,
                            tooltip: 'Copia testo',
                            color: textColor.withOpacity(0.7),
                            onTap: () {
                              // Implementare la funzionalità di copia
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.reply,
                            tooltip: 'Rispondi',
                            color: textColor.withOpacity(0.7),
                            onTap: () {
                              // Implementare la funzionalità di risposta
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.thumb_up_outlined,
                            tooltip: 'Mi piace',
                            color: textColor.withOpacity(0.7),
                            onTap: () {
                              // Implementare la funzionalità di like
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMediaContent(BuildContext context) {
    if (widget.mediaUrl == null) return const SizedBox.shrink();

    // Gestione immagini
    if (widget.mediaType?.startsWith('image/') == true) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: widget.mediaUrl!.startsWith('http')
                  ? Image.network(
                widget.mediaUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Text('Impossibile caricare l\'immagine'),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              )
                  : Image.file(
                File(widget.mediaUrl!),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Text('Impossibile caricare l\'immagine'),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      );
    }
    // Gestione audio
    else if (widget.mediaType?.startsWith('audio/') == true) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade800
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () {
                // Implementare la riproduzione audio
              },
            ),
            const Expanded(
              child: Text("Registrazione audio"),
            ),
            Text(
              "0:00",
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Tooltip(
            message: tooltip,
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}