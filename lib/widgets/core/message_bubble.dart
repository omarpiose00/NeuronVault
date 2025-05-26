// lib/widgets/core/message_bubble.dart
// 💬 MESSAGE BUBBLE - LUXURY UPGRADED VERSION
// Enhanced version of your existing message_bubble.dart with premium effects

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

import '../../core/design_system.dart';
import '../../core/accessibility/accessibility_manager.dart';

/// 💬 MESSAGE BUBBLE - LUXURY UPGRADED
/// Enhanced version with glassmorphism, neural glow, and premium animations
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

class _MessageBubbleState extends State<MessageBubble>
    with TickerProviderStateMixin {

  late AnimationController _entryController;
  late AnimationController _typingController;
  late AnimationController _glowController;
  late AnimationController _hoverController;

  late Animation<double> _entryAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<int> _typingAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;

  String _displayedText = '';
  bool _isTypingComplete = false;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startEntryAnimation();
    _startTypingEffect();
  }

  void _initializeAnimations() {
    // Entry animation
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _entryAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.elasticOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: !widget.isFromAI ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    // Typing animation
    _typingController = AnimationController(
      duration: Duration(milliseconds: widget.message.length * 50 + 1000),
      vsync: this,
    );

    _typingAnimation = IntTween(
      begin: 0,
      end: widget.message.length,
    ).animate(CurvedAnimation(
      parent: _typingController,
      curve: Curves.easeOut,
    ));

    // Glow animation for AI responses
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Hover/Scale animation
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOut,
    ));

    // Setup typing animation listener
    _typingAnimation.addListener(() {
      if (mounted) {
        setState(() {
          _displayedText = widget.message.substring(0, _typingAnimation.value);
        });

        if (_typingAnimation.value == widget.message.length && !_isTypingComplete) {
          _isTypingComplete = true;

          // Announce completion for accessibility
          AccessibilityManager().announce(
            'Message complete: ${widget.message}',
            assertive: false,
          );

          HapticFeedback.selectionClick();
        }
      }
    });

    // Start glow animation for AI messages
    if (widget.isFromAI) {
      _glowController.repeat(reverse: true);
    }
  }

  void _startEntryAnimation() {
    _entryController.forward();
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
    _entryController.dispose();
    _typingController.dispose();
    _glowController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovering) {
    setState(() {
      _isHovering = isHovering;
    });

    if (isHovering) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  /// 📋 Copy Message to Clipboard
  void _copyMessage() {
    Clipboard.setData(ClipboardData(text: widget.message));
    AccessibilityManager().announce('Message copied to clipboard');
    HapticFeedback.lightImpact();

    // Show copy feedback
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Message copied to clipboard'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  /// 📤 Share Message
  void _shareMessage() {
    AccessibilityManager().announce('Sharing message');
    HapticFeedback.mediumImpact();

    if (widget.onShare != null) {
      widget.onShare!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final isUser = !widget.isFromAI;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _scaleAnimation,
            _glowAnimation,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: MouseRegion(
                onEnter: (_) => _handleHover(true),
                onExit: (_) => _handleHover(false),
                child: Container(
                  margin: EdgeInsets.only(
                    left: isUser ? 40 : 0,
                    right: isUser ? 0 : 40,
                    bottom: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // AI Avatar
                      if (!isUser) ...[
                        _buildAIAvatar(ds),
                        const SizedBox(width: 12),
                      ],

                      // Message Bubble
                      Flexible(
                        child: Column(
                          crossAxisAlignment: isUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            // AI Model Badge
                            if (!isUser && widget.aiModel != null)
                              _buildModelBadge(ds),

                            const SizedBox(height: 4),

                            // Message Container
                            _buildMessageContainer(ds),

                            // Action Buttons (shown on hover)
                            if (_isHovering && _isTypingComplete)
                              _buildActionButtons(ds),
                          ],
                        ),
                      ),

                      // User Avatar
                      if (isUser) ...[
                        const SizedBox(width: 12),
                        _buildUserAvatar(ds),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 🤖 Build AI Avatar
  Widget _buildAIAvatar(DesignSystemData ds) {
    final modelColor = _getModelColor(widget.aiModel ?? '');

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                modelColor,
                modelColor.withOpacity(0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: modelColor.withOpacity(0.4 * _glowAnimation.value),
                blurRadius: 12 * _glowAnimation.value,
                spreadRadius: 2 * _glowAnimation.value,
              ),
            ],
          ),
          child: Icon(
            _getModelIcon(widget.aiModel ?? ''),
            color: Colors.white,
            size: 20,
          ),
        );
      },
    );
  }

  /// 👤 Build User Avatar
  Widget _buildUserAvatar(DesignSystemData ds) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            ds.colors.neuralPrimary,
            ds.colors.neuralSecondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: ds.colors.neuralPrimary.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  /// 🏷️ Build AI Model Badge
  Widget _buildModelBadge(DesignSystemData ds) {
    final modelColor = _getModelColor(widget.aiModel ?? '');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            modelColor.withOpacity(0.2),
            modelColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: modelColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getModelIcon(widget.aiModel ?? ''),
            color: modelColor,
            size: 12,
          ),
          const SizedBox(width: 6),
          Text(
            widget.aiModel?.toUpperCase() ?? 'AI',
            style: ds.typography.caption.copyWith(
              color: modelColor,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  /// 💬 Build Message Container
  Widget _buildMessageContainer(DesignSystemData ds) {
    final isUser = !widget.isFromAI;

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: isUser
                ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ds.colors.neuralPrimary,
                ds.colors.neuralSecondary,
              ],
            )
                : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ds.colors.colorScheme.surfaceContainer.withOpacity(0.8),
                ds.colors.colorScheme.surfaceContainer.withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(20).copyWith(
              bottomRight: isUser ? const Radius.circular(4) : null,
              bottomLeft: isUser ? null : const Radius.circular(4),
            ),
            border: Border.all(
              color: isUser
                  ? Colors.transparent
                  : ds.colors.colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isUser
                    ? ds.colors.neuralPrimary.withOpacity(0.2)
                    : ds.colors.colorScheme.shadow.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              if (!isUser)
                BoxShadow(
                  color: _getModelColor(widget.aiModel ?? '')
                      .withOpacity(0.1 * _glowAnimation.value),
                  blurRadius: 20 * _glowAnimation.value,
                  spreadRadius: 2 * _glowAnimation.value,
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20).copyWith(
              bottomRight: isUser ? const Radius.circular(4) : null,
              bottomLeft: isUser ? null : const Radius.circular(4),
            ),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message Text with Typing Effect
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: _displayedText,
                            style: ds.typography.body1.copyWith(
                              color: isUser
                                  ? Colors.white
                                  : ds.colors.colorScheme.onSurface,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ),

                      // Typing Indicator
                      if (!_isTypingComplete && widget.showTypingEffect)
                        _buildTypingIndicator(ds),
                    ],
                  ),

                  // Message Footer
                  if (_isTypingComplete) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.timestamp,
                          style: ds.typography.caption.copyWith(
                            color: isUser
                                ? Colors.white.withOpacity(0.7)
                                : ds.colors.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),

                        // Quick Actions
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isUser) ...[
                              _buildQuickAction(
                                icon: Icons.thumb_up_outlined,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                },
                                ds: ds,
                              ),
                              const SizedBox(width: 8),
                            ],
                            _buildQuickAction(
                              icon: Icons.copy_outlined,
                              onTap: widget.onCopy ?? _copyMessage,
                              ds: ds,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// ⌨️ Build Typing Indicator
  Widget _buildTypingIndicator(DesignSystemData ds) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _typingController,
            builder: (context, child) {
              final animationValue = _typingController.value + index * 0.3;
              final opacity = 0.3 + 0.7 * (math.sin(animationValue * math.pi * 2).abs());

              return Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: ds.colors.neuralPrimary.withOpacity(opacity),
                  shape: BoxShape.circle,
                ),
              );
            },
          );
        }),
      ),
    );
  }

  /// ⚡ Build Quick Action
  Widget _buildQuickAction({
    required IconData icon,
    required VoidCallback onTap,
    required DesignSystemData ds,
  }) {
    return AccessibleWidget(
      semanticLabel: icon == Icons.copy_outlined ? 'Copy message' : 'Like message',
      semanticHint: icon == Icons.copy_outlined ? 'Copy this message to clipboard' : 'Like this message',
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: ds.colors.colorScheme.surfaceContainer.withOpacity(0.7),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 14,
            color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  /// ⚡ Build Action Buttons
  Widget _buildActionButtons(DesignSystemData ds) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionButton(
            icon: Icons.copy,
            label: 'Copy',
            onTap: widget.onCopy ?? _copyMessage,
            ds: ds,
          ),

          if (widget.onShare != null) ...[
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.share,
              label: 'Share',
              onTap: widget.onShare ?? _shareMessage,
              ds: ds,
            ),
          ],
        ],
      ),
    );
  }

  /// 🔘 Build Action Button
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required DesignSystemData ds,
  }) {
    return AccessibleWidget(
      semanticLabel: label,
      semanticHint: '$label this message',
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: ds.colors.colorScheme.surfaceContainer.withOpacity(0.8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: ds.colors.colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: ds.typography.caption.copyWith(
                  color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🎨 Get Model Color
  Color _getModelColor(String model) {
    switch (model.toLowerCase()) {
      case 'claude':
        return const Color(0xFFFF6B35);
      case 'gpt':
      case 'gpt-4':
        return const Color(0xFF10B981);
      case 'gemini':
        return const Color(0xFFF59E0B);
      case 'deepseek':
        return const Color(0xFF8B5CF6);
      case 'mistral':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  /// 📱 Get Model Icon
  IconData _getModelIcon(String model) {
    switch (model.toLowerCase()) {
      case 'claude':
        return Icons.psychology;
      case 'gpt':
      case 'gpt-4':
        return Icons.auto_awesome;
      case 'gemini':
        return Icons.diamond;
      case 'deepseek':
        return Icons.explore;
      case 'mistral':
        return Icons.speed;
      default:
        return Icons.smart_toy;
    }
  }
}