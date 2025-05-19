// lib/widgets/messaging/multimodal_message_bubble.dart
import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/ai_agent.dart';

class MultimodalMessageBubble extends StatefulWidget {
  /// Agente AI associato al messaggio (se presente)
  final AiAgent? agent;

  /// Testo del messaggio
  final String text;

  /// Indica se il testo è selezionabile
  final bool selectable;

  /// URL del contenuto multimediale (se presente)
  final String? mediaUrl;

  /// Tipo MIME del contenuto multimediale
  final String? mediaType;

  /// Indica se l'agente sta ancora pensando
  final bool isThinking;

  /// Timestamp del messaggio
  final DateTime? timestamp;

  const MultimodalMessageBubble({
    Key? key,
    this.agent,
    required this.text,
    this.selectable = false,
    this.mediaUrl,
    this.mediaType,
    this.isThinking = false,
    this.timestamp,
  }) : super(key: key);

  @override
  State<MultimodalMessageBubble> createState() => _MultimodalMessageBubbleState();
}

class _MultimodalMessageBubbleState extends State<MultimodalMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

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

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  String _getFormattedTimestamp() {
    if (widget.timestamp == null) return '';

    final now = DateTime.now();
    final timestamp = widget.timestamp!;
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'ora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min fa';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ore fa';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} giorni fa';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Determine background and style based on agent
    Color bgColor;
    Color textColor;
    Color borderColor;
    BorderRadius borderRadius;

    if (widget.agent == null) {
      // User message
      bgColor = isDarkMode
          ? theme.colorScheme.primary.withOpacity(0.2)
          : theme.colorScheme.primary.withOpacity(0.1);
      textColor = isDarkMode ? Colors.white : Colors.black;
      borderColor = theme.colorScheme.primary.withOpacity(0.3);
      borderRadius = const BorderRadius.only(
        topLeft: Radius.circular(4),
        topRight: Radius.circular(24),
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      );
    } else {
      // AI agent message
      switch (widget.agent) {
        case AiAgent.claude:
          bgColor = isDarkMode
              ? const Color(0xFF5D4777).withOpacity(0.3)
              : const Color(0xFFE0BBE4).withOpacity(0.3);
          borderColor = const Color(0xFFD0BCFF).withOpacity(0.5);
          break;
        case AiAgent.gpt:
          bgColor = isDarkMode
              ? const Color(0xFF004D40).withOpacity(0.3)
              : const Color(0xFFB2DFDB).withOpacity(0.3);
          borderColor = const Color(0xFF00BFA5).withOpacity(0.5);
          break;
        case AiAgent.deepseek:
          bgColor = isDarkMode
              ? const Color(0xFF827717).withOpacity(0.3)
              : const Color(0xFFFFF59D).withOpacity(0.3);
          borderColor = const Color(0xFFFFEB3B).withOpacity(0.5);
          break;
        default:
          bgColor = isDarkMode
              ? Colors.grey.shade800
              : Colors.grey.shade200;
          borderColor = Colors.grey.withOpacity(0.3);
      }

      textColor = isDarkMode ? Colors.white : Colors.black;
      borderRadius = const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(4),
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      );
    }

    // Check if it's an error message
    final bool isErrorMessage = widget.agent == null &&
        (widget.text.toLowerCase().contains('errore:') ||
            widget.text.toLowerCase().contains('error:'));

    if (isErrorMessage) {
      bgColor = isDarkMode
          ? Colors.red.shade900.withOpacity(0.3)
          : Colors.red.shade50;
      borderColor = isDarkMode
          ? Colors.red.shade800
          : Colors.red.shade300;
    }

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: widget.agent == null ? 64 : 16,
          right: widget.agent == null ? 16 : 64,
        ),
        child: Column(
          crossAxisAlignment: widget.agent == null
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // Message bubble
            Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: borderRadius,
                border: Border.all(
                  color: borderColor,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Agent header if AI
                  if (widget.agent != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 12,
                        bottom: 8,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: agentIcon(widget.agent!, size: 32),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            agentName(widget.agent!),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: textColor.withOpacity(0.9),
                            ),
                          ),
                          const Spacer(),
                          if (widget.timestamp != null)
                            Text(
                              _getFormattedTimestamp(),
                              style: TextStyle(
                                fontSize: 12,
                                color: textColor.withOpacity(0.6),
                              ),
                            ),
                        ],
                      ),
                    ),

                  // Media content
                  if (widget.mediaUrl != null && widget.mediaType != null)
                    _buildMediaContent(),

                  // Message content
                  Padding(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: widget.agent != null ? 0 : 12,
                      bottom: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thinking indicator
                        if (widget.isThinking)
                          Row(
                            children: [
                              Text(
                                "Sta pensando",
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: textColor.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildTypingDots(),
                            ],
                          )
                        else if (isErrorMessage)
                          _buildErrorMessage()
                        else
                        // Regular message
                          widget.selectable
                              ? SelectableText(
                            widget.text,
                            style: TextStyle(color: textColor),
                          )
                              : Text(
                            widget.text,
                            style: TextStyle(color: textColor),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Timestamp for user messages
            if (widget.agent == null && widget.timestamp != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, right: 8),
                child: Text(
                  _getFormattedTimestamp(),
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingDots() {
    return SizedBox(
      width: 40,
      height: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          3,
              (index) => _buildPulsatingDot(index * 300),
        ),
      ),
    );
  }

  Widget _buildPulsatingDot(int delayMillis) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.5, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
      builder: (context, double value, child) {
        return Container(
          width: 6 * value,
          height: 6 * value,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.text.replaceAll("Errore: ", ""),
              style: TextStyle(
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaContent() {
    if (widget.mediaUrl == null) return const SizedBox.shrink();

    // Handle images
    if (widget.mediaType?.startsWith('image/') == true) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GestureDetector(
          onTap: _toggleExpanded,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isExpanded ? 300 : 180,
              width: double.infinity,
              child: widget.mediaUrl!.startsWith('http')
                  ? Image.network(
                widget.mediaUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.broken_image, size: 48),
                ),
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
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.broken_image, size: 48),
                ),
              ),
            ),
          ),
        ),
      );
    }
    // Handle audio (placeholder for now)
    else if (widget.mediaType?.startsWith('audio/') == true) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.headphones,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text("Registrazione audio"),
            ),
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () {
                // Audio playback implementation
              },
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}