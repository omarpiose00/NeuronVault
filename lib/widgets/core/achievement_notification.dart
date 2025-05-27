// 🏆 NEURONVAULT ACHIEVEMENT NOTIFICATION WIDGET - CORRECTED VERSION
// lib/widgets/core/achievement_notification.dart
// Neural luxury achievement notification with glassmorphism and animations

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;
import 'dart:async';
import '../../core/state/state_models.dart';
import '../../core/providers/providers_main.dart';
import '../../core/theme/neural_theme_system.dart';

/// 🏆 Achievement Notification - Animated popup for unlocked achievements
class AchievementNotificationWidget extends ConsumerStatefulWidget {
  final AchievementNotification notification;
  final VoidCallback? onDismiss;

  const AchievementNotificationWidget({
    Key? key,
    required this.notification,
    this.onDismiss,
  }) : super(key: key);

  @override
  ConsumerState<AchievementNotificationWidget> createState() =>
      _AchievementNotificationWidgetState();
}

class _AchievementNotificationWidgetState
    extends ConsumerState<AchievementNotificationWidget>
    with TickerProviderStateMixin {

  late AnimationController _slideController;
  late AnimationController _glowController;
  late AnimationController _particleController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _particleAnimation;

  Timer? _autoHideTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _startAutoHideTimer();
  }

  void _initializeAnimations() {
    // Slide in animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Glow pulse animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Particle burst animation
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Setup animations
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeOut,
    ));
  }

  void _startAnimations() {
    _slideController.forward();
    _glowController.repeat(reverse: true);
    _particleController.forward();
  }

  void _startAutoHideTimer() {
    _autoHideTimer = Timer(widget.notification.displayDuration, () {
      _dismiss();
    });
  }

  void _dismiss() {
    _autoHideTimer?.cancel();
    _slideController.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    _slideController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = NeuralThemeSystem().currentTheme;
    final achievement = widget.notification.achievement;

    return AnimatedBuilder(
      animation: Listenable.merge([_slideController, _glowController, _particleController]),
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Stack(
                children: [
                  // Background particles
                  _buildParticleBackground(theme),

                  // Main notification panel
                  _buildNotificationPanel(theme, achievement),

                  // Dismiss button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _buildDismissButton(theme),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticleBackground(NeuralThemeData theme) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _particleAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: _AchievementParticlePainter(
              progress: _particleAnimation.value,
              colors: [
                theme.colors.primary,
                theme.colors.secondary,
                theme.colors.accent,
              ],
              rarity: widget.notification.achievement.rarity,
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationPanel(NeuralThemeData theme, Achievement achievement) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colors.surface.withOpacity(0.1),
        border: Border.all(
          color: achievement.rarity.color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: achievement.rarity.color.withOpacity(_glowAnimation.value * 0.3),
            blurRadius: 20 * _glowAnimation.value,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              // Achievement icon with glow
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: achievement.rarity.color.withOpacity(0.2),
                  boxShadow: [
                    BoxShadow(
                      color: achievement.rarity.color.withOpacity(_glowAnimation.value * 0.5),
                      blurRadius: 15 * _glowAnimation.value,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  achievement.icon,
                  size: 30,
                  color: achievement.rarity.color,
                ),
              ),

              const SizedBox(width: 16),

              // Achievement info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Achievement unlocked text
                    Text(
                      'Achievement Unlocked!',
                      style: TextStyle(
                        color: theme.colors.onSurface.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Achievement title
                    Text(
                      achievement.title,
                      style: TextStyle(
                        color: theme.colors.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Achievement description
                    Text(
                      achievement.description,
                      style: TextStyle(
                        color: theme.colors.onSurface.withOpacity(0.8),
                        fontSize: 13,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Rarity badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: achievement.rarity.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: achievement.rarity.color.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        achievement.rarity.displayName.toUpperCase(),
                        style: TextStyle(
                          color: achievement.rarity.color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDismissButton(NeuralThemeData theme) {
    return GestureDetector(
      onTap: _dismiss,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colors.surface.withOpacity(0.3),
          border: Border.all(
            color: theme.colors.onSurface.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Icon(
              Icons.close,
              size: 16,
              color: theme.colors.onSurface.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }
}

/// 🎨 Achievement Particle Painter - Custom particles for notifications
class _AchievementParticlePainter extends CustomPainter {
  final double progress;
  final List<Color> colors;
  final AchievementRarity rarity;

  _AchievementParticlePainter({
    required this.progress,
    required this.colors,
    required this.rarity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Generate particles based on rarity
    final particleCount = _getParticleCount();

    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * 3.14159;
      final radius = progress * (size.width * 0.3) * (1 + (i % 3) * 0.2);

      final x = size.width / 2 + radius * 0.8 * (1 - progress) *
          (i.isEven ? 1 : -1) * (0.5 + 0.5 * (i / particleCount));
      final y = size.height / 2 + radius * 0.6 * (1 - progress) *
          (i % 3 == 0 ? 1 : -1) * (0.5 + 0.5 * (i / particleCount));

      final particleSize = (3 + (i % 4)) * (1 - progress * 0.5);
      final opacity = (1 - progress) * 0.8;

      paint.color = colors[i % colors.length].withOpacity(opacity);

      canvas.drawCircle(
        Offset(x, y),
        particleSize,
        paint,
      );
    }
  }

  int _getParticleCount() {
    switch (rarity) {
      case AchievementRarity.common:
        return 8;
      case AchievementRarity.rare:
        return 12;
      case AchievementRarity.epic:
        return 16;
      case AchievementRarity.legendary:
        return 24;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 🌟 Achievement Notification Overlay - Manages multiple notifications
class AchievementNotificationOverlay extends ConsumerStatefulWidget {
  const AchievementNotificationOverlay({Key? key}) : super(key: key);

  @override
  ConsumerState<AchievementNotificationOverlay> createState() =>
      _AchievementNotificationOverlayState();
}

class _AchievementNotificationOverlayState
    extends ConsumerState<AchievementNotificationOverlay> {

  final List<AchievementNotification> _activeNotifications = [];

  @override
  void initState() {
    super.initState();

    // ✅ CORRETTO: ref.listen direttamente in initState con provider reale
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen<AsyncValue<AchievementNotification>>(
        achievementNotificationStreamProvider,
            (previous, next) {
          next.whenData((notification) {
            if (mounted) {
              setState(() {
                _activeNotifications.add(notification);
              });
            }
          });
        },
      );
    });
  }

  void _removeNotification(AchievementNotification notification) {
    if (mounted) {
      setState(() {
        _activeNotifications.remove(notification);
      });

      // ✅ CORRETTO: Provider esiste davvero e metodo corretto
      ref.read(achievementServiceProvider).markNotificationShown(notification.id); // Changed line
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_activeNotifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 80,
      right: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _activeNotifications
            .map((notification) => AchievementNotificationWidget(
          notification: notification,
          onDismiss: () => _removeNotification(notification),
        ))
            .toList(),
      ),
    );
  }
}

// 🎯 EXTENSION per Achievement Rarity Colors
extension AchievementRarityColors on AchievementRarity {
  Color get color {
    switch (this) {
      case AchievementRarity.common:
        return Colors.grey;
      case AchievementRarity.rare:
        return Colors.blue;
      case AchievementRarity.epic:
        return Colors.purple;
      case AchievementRarity.legendary:
        return Colors.orange;
    }
  }
}