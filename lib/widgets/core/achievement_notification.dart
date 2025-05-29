// 🏆 NEURONVAULT ACHIEVEMENT NOTIFICATION WIDGET - PHASE 3.3 LAYOUT FIXED
// lib/widgets/core/achievement_notification.dart
// FIXED: RenderBox layout issues + Maintained spectacular animations

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:math' as math;
import '../../core/state/state_models.dart';
import '../../core/providers/providers_main.dart';
import '../../core/theme/neural_theme_system.dart';

/// 🏆 Achievement Notification - PHASE 3.3 LAYOUT FIXED
/// FIXED: All RenderBox layout issues while maintaining spectacular experience
class AchievementNotificationWidget extends ConsumerStatefulWidget {
  final AchievementNotification notification;
  final VoidCallback? onDismiss;

  const AchievementNotificationWidget({
    super.key,
    required this.notification,
    this.onDismiss,
  });

  @override
  ConsumerState<AchievementNotificationWidget> createState() =>
      _AchievementNotificationWidgetState();
}

class _AchievementNotificationWidgetState
    extends ConsumerState<AchievementNotificationWidget>
    with TickerProviderStateMixin {

  // 🎨 OPTIMIZED ANIMATION CONTROLLERS (Reduced from 7 to 4)
  late AnimationController _masterController;
  late AnimationController _particleController;
  late AnimationController _glowController;
  late AnimationController _exitController;

  // 🎭 OPTIMIZED ANIMATIONS
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _fadeAnimation;

  // 🎊 CELEBRATION STATE
  bool _isCelebrating = false;
  bool _hasPlayedSound = false;
  List<ParticleData> _explosionParticles = [];
  Timer? _autoHideTimer;

  // 📐 LAYOUT CONSTRAINTS (FIXED)
  Size _notificationSize = const Size(350, 120);
  Offset _particleCenter = Offset.zero;

  @override
  void initState() {
    super.initState();
    _initializeOptimizedAnimations();
    _generateExplosionParticles();
    _startSpectacularSequence();
    _startAutoHideTimer();
  }

  void _initializeOptimizedAnimations() {
    // 🚀 MASTER ANIMATION (1200ms total)
    _masterController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // 💥 PARTICLE ANIMATION (1500ms)
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // ✨ GLOW ANIMATION (2000ms - repeating)
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // 🚪 EXIT ANIMATION (400ms)
    _exitController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _setupOptimizedAnimations();
  }

  void _setupOptimizedAnimations() {
    // 🚀 ENTRY ANIMATIONS
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.2, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    // 💥 PARTICLE EXPLOSION
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeOut,
    ));

    // ✨ GLOW PULSE
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // 🚪 EXIT FADE
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _exitController,
      curve: Curves.easeInCubic,
    ));
  }

  void _generateExplosionParticles() {
    final rarity = widget.notification.achievement.rarity;
    final particleCount = _getParticleCount(rarity);
    final random = math.Random();

    _explosionParticles = List.generate(particleCount, (index) {
      final angle = random.nextDouble() * 2 * math.pi;
      final velocity = 30 + random.nextDouble() * 60; // Reduced velocity
      final size = 1.5 + random.nextDouble() * 3; // Smaller particles
      final life = 0.8 + random.nextDouble() * 0.4;

      return ParticleData(
        angle: angle,
        velocity: velocity,
        size: size,
        life: life,
        color: _getParticleColor(rarity, index),
      );
    });
  }

  void _startSpectacularSequence() async {
    // 🚀 STAGE 1: DRAMATIC ENTRY
    _masterController.forward();

    // 🔊 PLAY ENTRY SOUND
    await Future.delayed(const Duration(milliseconds: 200));
    _playSpectacularSound('entry');

    // 🎊 STAGE 2: CELEBRATION START
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() {
        _isCelebrating = true;
        // FIXED: Calculate particle center based on actual widget size
        _particleCenter = Offset(_notificationSize.width * 0.25, _notificationSize.height * 0.5);
      });
    }

    _glowController.repeat(reverse: true);

    // 💥 STAGE 3: PARTICLE EXPLOSION
    await Future.delayed(const Duration(milliseconds: 200));
    _particleController.forward();
    _playSpectacularSound('explosion');

    // ⚡ HAPTIC CELEBRATION
    _playHapticCelebration();
  }

  void _startAutoHideTimer() {
    _autoHideTimer = Timer(widget.notification.displayDuration, () {
      _startSpectacularExit();
    });
  }

  void _startSpectacularExit() async {
    _autoHideTimer?.cancel();

    // 🚪 SPECTACULAR EXIT
    _exitController.forward().then((_) {
      widget.onDismiss?.call();
    });

    _playSpectacularSound('exit');
  }

  // 🔊 PLAY SPECTACULAR SOUNDS (Simplified)
  void _playSpectacularSound(String soundType) {
    if (_hasPlayedSound && soundType == 'entry') return;

    try {
      final audioService = ref.read(spatialAudioServiceProvider);
      final rarity = widget.notification.achievement.rarity;

      switch (soundType) {
        case 'entry':
        // audioService.playNeuralSound('achievement_entry', volume: _getSoundVolume(rarity));
          _hasPlayedSound = true;
          break;
        case 'explosion':
        // audioService.playNeuralSound('particle_explosion', volume: _getSoundVolume(rarity));
          break;
        case 'exit':
        // audioService.playNeuralSound('achievement_exit');
          break;
      }
    } catch (e) {
      // Audio service not available, continue silently
    }
  }

  // ⚡ PLAY HAPTIC CELEBRATION
  void _playHapticCelebration() {
    final rarity = widget.notification.achievement.rarity;

    switch (rarity) {
      case AchievementRarity.common:
        HapticFeedback.lightImpact();
        break;
      case AchievementRarity.rare:
        HapticFeedback.mediumImpact();
        break;
      case AchievementRarity.epic:
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(milliseconds: 100), () => HapticFeedback.lightImpact());
        break;
      case AchievementRarity.legendary:
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(milliseconds: 50), () => HapticFeedback.mediumImpact());
        Future.delayed(const Duration(milliseconds: 100), () => HapticFeedback.heavyImpact());
        break;
    }
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    _masterController.dispose();
    _particleController.dispose();
    _glowController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = NeuralThemeSystem().currentTheme;
    final achievement = widget.notification.achievement;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _masterController,
        _particleController,
        _glowController,
        _exitController,
      ]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // FIXED: Update size based on actual constraints
                    _notificationSize = Size(
                      math.min(350, constraints.maxWidth),
                      120,
                    );
                    _particleCenter = Offset(
                        _notificationSize.width * 0.25,
                        _notificationSize.height * 0.5
                    );

                    return SizedBox(
                      width: _notificationSize.width,
                      height: _notificationSize.height,
                      child: Stack(
                        clipBehavior: Clip.hardEdge, // FIXED: Changed from Clip.none
                        children: [
                          // 🌟 CELEBRATION AURA (FIXED positioning)
                          if (_isCelebrating)
                            _buildCelebrationAura(theme, achievement),

                          // 🏆 MAIN NOTIFICATION PANEL
                          _buildSpectacularNotificationPanel(theme, achievement),

                          // 💥 SPECTACULAR PARTICLE EXPLOSION (FIXED)
                          if (_isCelebrating)
                            _buildSpectacularParticleExplosion(theme, achievement),

                          // ❌ ENHANCED DISMISS BUTTON
                          Positioned(
                            top: 8,
                            right: 8,
                            child: _buildSpectacularDismissButton(theme),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 🌟 BUILD CELEBRATION AURA (FIXED)
  Widget _buildCelebrationAura(NeuralThemeData theme, Achievement achievement) {
    return Positioned(
      left: -15,
      top: -15,
      right: -15,
      bottom: -15,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: achievement.rarity.color.withOpacity(
                      _glowAnimation.value * 0.4
                  ),
                  blurRadius: 30 * _glowAnimation.value,
                  spreadRadius: 8 * _glowAnimation.value,
                ),
                BoxShadow(
                  color: theme.colors.primary.withOpacity(
                      _glowAnimation.value * 0.2
                  ),
                  blurRadius: 50 * _glowAnimation.value,
                  spreadRadius: 12 * _glowAnimation.value,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 💥 BUILD SPECTACULAR PARTICLE EXPLOSION (FIXED)
  Widget _buildSpectacularParticleExplosion(NeuralThemeData theme, Achievement achievement) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _particleAnimation,
        builder: (context, child) {
          return CustomPaint(
            size: _notificationSize, // FIXED: Explicit size
            painter: SpectacularParticleExplosionPainter(
              progress: _particleAnimation.value,
              particles: _explosionParticles,
              rarity: achievement.rarity,
              center: _particleCenter, // FIXED: Dynamic center
              bounds: Rect.fromLTWH(0, 0, _notificationSize.width, _notificationSize.height),
            ),
          );
        },
      ),
    );
  }

  // 🏆 BUILD SPECTACULAR NOTIFICATION PANEL (Optimized)
  Widget _buildSpectacularNotificationPanel(NeuralThemeData theme, Achievement achievement) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colors.surface.withOpacity(0.95),
                theme.colors.surface.withOpacity(0.85),
                achievement.rarity.color.withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: achievement.rarity.color.withOpacity(
                  0.4 + (_glowAnimation.value * 0.4)
              ),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: achievement.rarity.color.withOpacity(_glowAnimation.value * 0.4),
                blurRadius: 20 * _glowAnimation.value,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Row(
                children: [
                  // 🏆 SPECTACULAR ACHIEVEMENT ICON
                  _buildSpectacularAchievementIcon(theme, achievement),

                  const SizedBox(width: 16),

                  // 📝 SPECTACULAR ACHIEVEMENT INFO
                  Expanded(
                    child: _buildSpectacularAchievementInfo(theme, achievement),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 🏆 BUILD SPECTACULAR ACHIEVEMENT ICON (Optimized)
  Widget _buildSpectacularAchievementIcon(NeuralThemeData theme, Achievement achievement) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            achievement.rarity.color.withOpacity(0.4),
            achievement.rarity.color.withOpacity(0.2),
            achievement.rarity.color.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: achievement.rarity.color.withOpacity(0.6),
          width: 2,
        ),
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
    );
  }

  // 📝 BUILD SPECTACULAR ACHIEVEMENT INFO (Simplified)
  Widget _buildSpectacularAchievementInfo(NeuralThemeData theme, Achievement achievement) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 🎊 "ACHIEVEMENT UNLOCKED!" TEXT
        Text(
          'ACHIEVEMENT UNLOCKED!',
          style: TextStyle(
            color: theme.colors.onSurface.withOpacity(0.8),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),

        const SizedBox(height: 4),

        // 🏆 ACHIEVEMENT TITLE
        Text(
          achievement.title,
          style: TextStyle(
            color: theme.colors.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 4),

        // 📝 ACHIEVEMENT DESCRIPTION
        Text(
          achievement.description,
          style: TextStyle(
            color: theme.colors.onSurface.withOpacity(0.8),
            fontSize: 12,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 8),

        // 💎 SPECTACULAR RARITY BADGE
        _buildSpectacularRarityBadge(theme, achievement),
      ],
    );
  }

  // 💎 BUILD SPECTACULAR RARITY BADGE (Optimized)
  Widget _buildSpectacularRarityBadge(NeuralThemeData theme, Achievement achievement) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            achievement.rarity.color.withOpacity(0.3),
            achievement.rarity.color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement.rarity.color.withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getRarityIcon(achievement.rarity),
            color: achievement.rarity.color,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            '${achievement.rarity.displayName.toUpperCase()} • ${_getRarityPoints(achievement.rarity)} PTS',
            style: TextStyle(
              color: achievement.rarity.color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ❌ BUILD SPECTACULAR DISMISS BUTTON (Simplified)
  Widget _buildSpectacularDismissButton(NeuralThemeData theme) {
    return GestureDetector(
      onTap: _startSpectacularExit,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colors.surface.withOpacity(0.9),
          border: Border.all(
            color: theme.colors.onSurface.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.close,
          size: 16,
          color: theme.colors.onSurface.withOpacity(0.8),
        ),
      ),
    );
  }

  // 🎯 UTILITY METHODS
  int _getParticleCount(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return 8;  // Reduced
      case AchievementRarity.rare:
        return 12; // Reduced
      case AchievementRarity.epic:
        return 18; // Reduced
      case AchievementRarity.legendary:
        return 25; // Reduced
    }
  }

  Color _getParticleColor(AchievementRarity rarity, int index) {
    final baseColor = rarity.color;
    final colors = [
      baseColor,
      baseColor.withOpacity(0.8),
      baseColor.withOpacity(0.6),
      Colors.white.withOpacity(0.9),
    ];
    return colors[index % colors.length];
  }

  double _getSoundVolume(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return 0.6;
      case AchievementRarity.rare:
        return 0.7;
      case AchievementRarity.epic:
        return 0.8;
      case AchievementRarity.legendary:
        return 1.0;
    }
  }

  IconData _getRarityIcon(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return Icons.circle;
      case AchievementRarity.rare:
        return Icons.hexagon;
      case AchievementRarity.epic:
        return Icons.diamond;
      case AchievementRarity.legendary:
        return Icons.auto_awesome;
    }
  }

  int _getRarityPoints(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return 10;
      case AchievementRarity.rare:
        return 25;
      case AchievementRarity.epic:
        return 50;
      case AchievementRarity.legendary:
        return 100;
    }
  }
}

// 💥 SPECTACULAR PARTICLE EXPLOSION PAINTER (FIXED)
class SpectacularParticleExplosionPainter extends CustomPainter {
  final double progress;
  final List<ParticleData> particles;
  final AchievementRarity rarity;
  final Offset center;
  final Rect bounds; // FIXED: Added bounds constraint

  SpectacularParticleExplosionPainter({
    required this.progress,
    required this.particles,
    required this.rarity,
    required this.center,
    required this.bounds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      final currentProgress = (progress * particle.life).clamp(0.0, 1.0);
      if (currentProgress <= 0) continue;

      final distance = particle.velocity * currentProgress;
      final x = center.dx + math.cos(particle.angle) * distance;
      final y = center.dy + math.sin(particle.angle) * distance;

      // FIXED: Check bounds to prevent overflow
      if (x < bounds.left || x > bounds.right || y < bounds.top || y > bounds.bottom) {
        continue;
      }

      final opacity = (1.0 - currentProgress) * 0.8;
      paint.color = particle.color.withOpacity(opacity);

      final currentSize = particle.size * (1.0 + currentProgress * 0.3);

      canvas.drawCircle(
        Offset(x, y),
        currentSize,
        paint,
      );

      // Add sparkle effect for legendary (FIXED: smaller sparkles)
      if (rarity == AchievementRarity.legendary && currentProgress > 0.3) {
        _drawSparkle(canvas, Offset(x, y), currentSize * 0.8, paint);
      }
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    final sparklePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final sparkleSize = size * 0.8;

    // Draw cross sparkle
    canvas.drawLine(
      center + Offset(-sparkleSize, 0),
      center + Offset(sparkleSize, 0),
      sparklePaint,
    );
    canvas.drawLine(
      center + Offset(0, -sparkleSize),
      center + Offset(0, sparkleSize),
      sparklePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 💫 PARTICLE DATA CLASS (unchanged)
class ParticleData {
  final double angle;
  final double velocity;
  final double size;
  final double life;
  final Color color;

  ParticleData({
    required this.angle,
    required this.velocity,
    required this.size,
    required this.life,
    required this.color,
  });
}

/// 🌟 Achievement Notification Overlay - PHASE 3.3 LAYOUT FIXED
/// FIXED: Simplified notification queue management
class AchievementNotificationOverlay extends ConsumerStatefulWidget {
  const AchievementNotificationOverlay({super.key});

  @override
  ConsumerState<AchievementNotificationOverlay> createState() =>
      _AchievementNotificationOverlayState();
}

class _AchievementNotificationOverlayState
    extends ConsumerState<AchievementNotificationOverlay>
    with TickerProviderStateMixin {

  final List<AchievementNotification> _activeNotifications = [];
  final List<AchievementNotification> _notificationHistory = [];
  bool _showAchievementSidebar = false;
  late AnimationController _sidebarController;
  late Animation<Offset> _sidebarAnimation;
  ProviderSubscription<AsyncValue<AchievementNotification>>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _initializeSidebarAnimation();
    _setupNotificationListener();
  }

  void _initializeSidebarAnimation() {
    _sidebarController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _sidebarAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _sidebarController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _setupNotificationListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationSubscription = ref.listenManual<AsyncValue<AchievementNotification>>(
        achievementNotificationStreamProvider,
            (previous, next) {
          next.when(
            data: (notification) {
              if (mounted) {
                setState(() {
                  _activeNotifications.add(notification);
                  _notificationHistory.insert(0, notification);
                  if (_notificationHistory.length > 15) {
                    _notificationHistory.removeLast();
                  }
                });
              }
            },
            error: (error, stackTrace) => debugPrint('Error: $error'),
            loading: () {},
          );
        },
      );
    });
  }

  void _removeNotification(AchievementNotification notification) {
    if (mounted) {
      setState(() {
        _activeNotifications.remove(notification);
      });
      ref.read(achievementServiceProvider).markNotificationShown(notification.id);
    }
  }

  void _toggleAchievementSidebar() {
    setState(() {
      _showAchievementSidebar = !_showAchievementSidebar;
    });

    if (_showAchievementSidebar) {
      _sidebarController.forward();
    } else {
      _sidebarController.reverse();
    }
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _notificationSubscription?.close();
    _sidebarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🏆 ACTIVE NOTIFICATIONS (FIXED: Max 3 concurrent)
        if (_activeNotifications.isNotEmpty)
          Positioned(
            top: 80,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _activeNotifications
                  .take(3) // FIXED: Limit to 3 concurrent notifications
                  .map((notification) => AchievementNotificationWidget(
                notification: notification,
                onDismiss: () => _removeNotification(notification),
              ))
                  .toList(),
            ),
          ),

        // 📜 ACHIEVEMENT SIDEBAR TOGGLE BUTTON
        if (_notificationHistory.isNotEmpty)
          Positioned(
            top: 40,
            right: 20,
            child: _buildSidebarToggleButton(),
          ),

        // 📜 ACHIEVEMENT SIDEBAR
        if (_showAchievementSidebar)
          _buildAchievementSidebar(),
      ],
    );
  }

  // 📜 BUILD SIDEBAR TOGGLE BUTTON (Simplified)
  Widget _buildSidebarToggleButton() {
    final theme = NeuralThemeSystem().currentTheme;

    return GestureDetector(
      onTap: _toggleAchievementSidebar,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colors.primary.withOpacity(0.2),
          border: Border.all(
            color: theme.colors.primary.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colors.primary.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.history,
              color: theme.colors.primary,
              size: 18,
            ),
            if (_notificationHistory.isNotEmpty)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${_notificationHistory.length > 9 ? '9+' : _notificationHistory.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 📜 BUILD ACHIEVEMENT SIDEBAR (Simplified for performance)
  Widget _buildAchievementSidebar() {
    final theme = NeuralThemeSystem().currentTheme;

    return Positioned(
      top: 0,
      right: 0,
      bottom: 0,
      child: SlideTransition(
        position: _sidebarAnimation,
        child: Container(
          width: 280, // FIXED: Reduced from 300
          decoration: BoxDecoration(
            color: theme.colors.surface.withOpacity(0.95),
            border: Border(
              left: BorderSide(
                color: theme.colors.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(-3, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // 📊 SIDEBAR HEADER
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colors.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: theme.colors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Recent Achievements',
                      style: TextStyle(
                        color: theme.colors.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _toggleAchievementSidebar,
                      child: Icon(
                        Icons.close,
                        color: theme.colors.onSurface.withOpacity(0.7),
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),

              // 📜 NOTIFICATION HISTORY LIST
              Expanded(
                child: _notificationHistory.isEmpty
                    ? _buildEmptyHistory(theme)
                    : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _notificationHistory.length,
                  itemBuilder: (context, index) {
                    final notification = _notificationHistory[index];
                    return _buildHistoryItem(theme, notification, index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🚫 BUILD EMPTY HISTORY (Simplified)
  Widget _buildEmptyHistory(NeuralThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            color: theme.colors.onSurface.withOpacity(0.3),
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            'No achievements yet',
            style: TextStyle(
              color: theme.colors.onSurface.withOpacity(0.6),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Keep exploring to unlock achievements!',
            style: TextStyle(
              color: theme.colors.onSurface.withOpacity(0.4),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 🏆 BUILD HISTORY ITEM (Optimized)
  Widget _buildHistoryItem(NeuralThemeData theme, AchievementNotification notification, int index) {
    final achievement = notification.achievement;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: achievement.rarity.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: achievement.rarity.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 🏆 ACHIEVEMENT ICON
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: achievement.rarity.color.withOpacity(0.2),
            ),
            child: Icon(
              achievement.icon,
              color: achievement.rarity.color,
              size: 16,
            ),
          ),

          const SizedBox(width: 10),

          // 📝 ACHIEVEMENT INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    color: theme.colors.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  style: TextStyle(
                    color: theme.colors.onSurface.withOpacity(0.7),
                    fontSize: 10,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatHistoryDate(notification.timestamp),
                  style: TextStyle(
                    color: achievement.rarity.color.withOpacity(0.8),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatHistoryDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}