// lib/widgets/core/message_bubble.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/design_system.dart';
import '../../core/accessibility/accessibility_manager.dart';

/// 💬 MESSAGE BUBBLE
/// Bubble messaggio con typing effects e supporto accessibilità
class MessageBubble extends StatefulWidget {
  final String message;
  final bool isFromAI;
  final String? aiModel;
  final String timestamp;
  final bool showTypingEffect;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isFromAI,
    this.aiModel,
    required this.timestamp,
    this.showTypingEffect = false,
    this.onCopy,
    this.onShare,
  }) : super(key: key);

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> with TickerProviderStateMixin {
  late AnimationController _typingController;
  late Animation<int> _typingAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  String _displayedText = '';
  bool _isTypingComplete = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startTypingEffect();
  }

  void _initializeAnimations() {
    // Typing animation
    _typingController = AnimationController(
      duration: Duration(milliseconds: widget.message.length * 30 + 500),
      vsync: this,
    );

    _typingAnimation = IntTween(
      begin: 0,
      end: widget.message.length,
    ).animate(CurvedAnimation(
      parent: _typingController,
      curve: Curves.easeOut,
    ));

    // Scale animation for interactions
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _typingAnimation.addListener(() {
      if (mounted) {
        setState(() {
          _displayedText = widget.message.substring(0, _typingAnimation.value);
        });

        // Announce progress for screen readers
        if (_typingAnimation.value == widget.message.length && !_isTypingComplete) {
          _isTypingComplete = true;
          AccessibilityManager().announce(
            'Message complete: ${widget.message}',
            assertive: false,
          );
        }
      }
    });
  }

  void _startTypingEffect() {
    if (widget.showTypingEffect && widget.isFromAI) {
      _typingController.forward();
    } else {
      _displayedText = widget.message;
      _isTypingComplete = true;
    }
  }

  @override
  void dispose() {
    _typingController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  /// 📋 Copy Message to Clipboard
  void _copyMessage() {
    Clipboard.setData(ClipboardData(text: widget.message));
    AccessibilityManager().announce('Message copied to clipboard');
    HapticFeedback.lightImpact();

    // Visual feedback
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
  }

  /// 📤 Share Message
  void _shareMessage() {
    // Implement sharing logic here
    AccessibilityManager().announce('Sharing message');
    HapticFeedback.mediumImpact();
  }

  /// 🎨 Build AI Model Badge
  Widget _buildAIModelBadge(DesignSystemData ds) {
    if (!widget.isFromAI || widget.aiModel == null) return const SizedBox.shrink();

    final modelColor = _getModelColor(widget.aiModel!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: modelColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: modelColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getModelIcon(widget.aiModel!),
            color: modelColor,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            widget.aiModel!,
            style: ds.typography.caption.copyWith(
              color: modelColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 🎨 Get Model Color
  Color _getModelColor(String model) {
    switch (model.toLowerCase()) {
      case 'claude':
        return const Color(0xFF6366F1);
      case 'gpt-4':
      case 'gpt':
        return const Color(0xFF10B981);
      case 'gemini':
        return const Color(0xFFF59E0B);
      case 'deepseek':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  /// 📱 Get Model Icon
  IconData _getModelIcon(String model) {
    switch (model.toLowerCase()) {
      case 'claude':
        return Icons.psychology;
      case 'gpt-4':
      case 'gpt':
        return Icons.auto_awesome;
      case 'gemini':
        return Icons.diamond;
      case 'deepseek':
        return Icons.explore;
      default:
        return Icons.smart_toy;
    }
  }

  /// ⚡ Build Action Buttons
  Widget _buildActionButtons(DesignSystemData ds) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AccessibleWidget(
          semanticLabel: 'Copy message',
          semanticHint: 'Copy this message to clipboard',
          onTap: widget.onCopy ?? _copyMessage,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: ds.colors.colorScheme.surfaceContainer.withOpacity(0.7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.copy,
              size: 14,
              color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),

        if (widget.onShare != null) ...[
          const SizedBox(width: 8),
          AccessibleWidget(
            semanticLabel: 'Share message',
            semanticHint: 'Share this message',
            onTap: widget.onShare ?? _shareMessage,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: ds.colors.colorScheme.surfaceContainer.withOpacity(0.7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.share,
                size: 14,
                color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// 🎭 Build Typing Indicator
  Widget _buildTypingIndicator(DesignSystemData ds) {
    if (_isTypingComplete || !widget.showTypingEffect) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _typingController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(left: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...List.generate(3, (index) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ds.colors.neuralPrimary.withOpacity(
                      0.3 + (0.7 * ((_typingController.value + index) % 1)),
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
    final isUser = !widget.isFromAI;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: EdgeInsets.only(
              left: isUser ? 40 : 0,
              right: isUser ? 0 : 40,
              bottom: 12,
            ),
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Message Header
                if (widget.isFromAI) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildAIModelBadge(ds),
                        const SizedBox(width: 8),
                        Text(
                          widget.timestamp,
                          style: ds.typography.caption.copyWith(
                            color: ds.colors.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Message Bubble
                Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? LinearGradient(
                      colors: [
                        ds.colors.neuralPrimary,
                        ds.colors.neuralSecondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                        : null,
                    color: isUser ? null : ds.colors.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomRight: isUser ? const Radius.circular(4) : null,
                      bottomLeft: isUser ? null : const Radius.circular(4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ds.colors.colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message Text
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              _displayedText,
                              style: ds.typography.body1.copyWith(
                                color: isUser
                                    ? ds.colors.colorScheme.onPrimary
                                    : ds.colors.colorScheme.onSurface,
                                height: 1.5,
                              ),
                            ),
                          ),
                          _buildTypingIndicator(ds),
                        ],
                      ),

                      // Message Footer
                      if (_isTypingComplete) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.timestamp,
                              style: ds.typography.caption.copyWith(
                                color: isUser
                                    ? ds.colors.colorScheme.onPrimary.withOpacity(0.7)
                                    : ds.colors.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            _buildActionButtons(ds),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
          );
        }
      }


