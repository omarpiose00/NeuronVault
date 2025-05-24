// lib/widgets/core/chat_input_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/design_system.dart';
import '../../core/accessibility/accessibility_manager.dart';

/// 💬 CHAT INPUT BAR
/// Barra input per messaggi con AI - COMPONENTE MANCANTE ESSENZIALE
class ChatInputBar extends StatefulWidget {
  final ValueChanged<String> onMessageSent;
  final VoidCallback? onVoiceInput;
  final VoidCallback? onFileUpload;
  final bool isTyping;
  final String? typingIndicatorText;

  const ChatInputBar({
    Key? key,
    required this.onMessageSent,
    this.onVoiceInput,
    this.onFileUpload,
    this.isTyping = false,
    this.typingIndicatorText,
  }) : super(key: key);

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocus = FocusNode();

  late AnimationController _sendButtonController;
  late Animation<double> _sendButtonScale;
  late AnimationController _typingController;
  late Animation<double> _typingAnimation;

  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupTextListener();
  }

  void _initializeAnimations() {
    // Send button animation
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _sendButtonScale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sendButtonController,
      curve: Curves.elasticOut,
    ));

    // Typing indicator animation
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _typingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _typingController,
      curve: Curves.easeInOut,
    ));

    if (widget.isTyping) {
      _typingController.repeat(reverse: true);
    }
  }

  void _setupTextListener() {
    _textController.addListener(() {
      final hasText = _textController.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() {
          _hasText = hasText;
        });

        if (hasText) {
          _sendButtonController.forward();
        } else {
          _sendButtonController.reverse();
        }
      }
    });
  }

  @override
  void didUpdateWidget(ChatInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isTyping != widget.isTyping) {
      if (widget.isTyping) {
        _typingController.repeat(reverse: true);
      } else {
        _typingController.stop();
        _typingController.reset();
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocus.dispose();
    _sendButtonController.dispose();
    _typingController.dispose();
    super.dispose();
  }

  /// 📤 Send Message
  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      widget.onMessageSent(text);
      _textController.clear();

      AccessibilityManager().announce('Message sent');
      HapticFeedback.mediumImpact();

      // Reset animations
      _sendButtonController.reverse();
      setState(() {
        _hasText = false;
      });
    }
  }

  /// 🎙️ Voice Input
  void _handleVoiceInput() {
    if (widget.onVoiceInput != null) {
      widget.onVoiceInput!();
      AccessibilityManager().announce('Voice input activated');
      HapticFeedback.lightImpact();
    }
  }

  /// 📎 File Upload
  void _handleFileUpload() {
    if (widget.onFileUpload != null) {
      widget.onFileUpload!();
      AccessibilityManager().announce('File upload opened');
      HapticFeedback.lightImpact();
    }
  }

  /// 🎨 Build Action Button
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    String? tooltip,
  }) {
    final ds = DesignSystem.instance.current;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }

  /// ⌨️ Build Typing Indicator
  Widget _buildTypingIndicator(DesignSystemData ds) {
    if (!widget.isTyping) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _typingAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: ds.colors.colorScheme.surfaceContainer.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.psychology,
                color: ds.colors.neuralPrimary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                widget.typingIndicatorText ?? 'AI is thinking...',
                style: ds.typography.caption.copyWith(
                  color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 8),
              ...List.generate(3, (index) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ds.colors.neuralPrimary.withOpacity(
                      0.3 + (0.7 * ((_typingAnimation.value + index * 0.3) % 1)),
                    ),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ds.colors.colorScheme.surface.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: ds.colors.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: ds.colors.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Typing Indicator
          _buildTypingIndicator(ds),

          // Input Row
          Row(
            children: [
              // File Upload Button
              if (widget.onFileUpload != null)
                _buildActionButton(
                  icon: Icons.attach_file,
                  onTap: _handleFileUpload,
                  color: ds.colors.neuralAccent,
                  tooltip: 'Upload file',
                ),

              if (widget.onFileUpload != null) const SizedBox(width: 12),

              // Text Input Field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: ds.colors.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _textFocus.hasFocus
                          ? ds.colors.neuralPrimary
                          : ds.colors.colorScheme.outline.withOpacity(0.3),
                      width: _textFocus.hasFocus ? 2 : 1,
                    ),
                  ),
                  child: TextField(
                    controller: _textController,
                    focusNode: _textFocus,
                    enabled: !widget.isTyping,
                    decoration: InputDecoration(
                      hintText: widget.isTyping
                          ? 'AI is responding...'
                          : 'Ask anything to the AI models...',
                      hintStyle: ds.typography.body1.copyWith(
                        color: ds.colors.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    style: ds.typography.body1.copyWith(
                      color: ds.colors.colorScheme.onSurface,
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Voice Input Button
              if (widget.onVoiceInput != null)
                _buildActionButton(
                  icon: Icons.mic,
                  onTap: _handleVoiceInput,
                  color: ds.colors.neuralSecondary,
                  tooltip: 'Voice input',
                ),

              if (widget.onVoiceInput != null) const SizedBox(width: 12),

              // Send Button
              AnimatedBuilder(
                animation: _sendButtonScale,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _sendButtonScale.value,
                    child: GestureDetector(
                      onTap: _hasText && !widget.isTyping ? _sendMessage : null,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: _hasText && !widget.isTyping
                              ? LinearGradient(
                            colors: [
                              ds.colors.neuralPrimary,
                              ds.colors.neuralSecondary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                              : null,
                          color: _hasText && !widget.isTyping
                              ? null
                              : ds.colors.colorScheme.outline.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: _hasText && !widget.isTyping
                              ? [
                            BoxShadow(
                              color: ds.colors.neuralPrimary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                              : null,
                        ),
                        child: Icon(
                          Icons.send,
                          color: _hasText && !widget.isTyping
                              ? ds.colors.colorScheme.onPrimary
                              : ds.colors.colorScheme.onSurface.withOpacity(0.5),
                          size: 24,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}