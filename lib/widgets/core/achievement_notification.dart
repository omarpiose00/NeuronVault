// 🏆 NEURONVAULT ACHIEVEMENT NOTIFICATION WIDGET - PHASE 3.3 SPECTACULAR ENHANCED
// lib/widgets/core/achievement_notification.dart
// Revolutionary spectacular unlock animations + Audio integration + Multi-stage celebrations

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:math' as math;
import '../../core/state/state_models.dart';
import '../../core/providers/providers_main.dart';
import '../../core/theme/neural_theme_system.dart';

/// 🏆 Achievement Notification - PHASE 3.3 SPECTACULAR ENHANCED
/// Revolutionary multi-stage celebration + Neural particle explosions + Audio sync
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

  // 🎨 PHASE 3.3: MULTI-STAGE CELEBRATION ANIMATIONS
  late AnimationController _entryController;
  late AnimationController _celebrationController;
  late AnimationController _particleExplosionController;
  late AnimationController _glowPulseController;
  late AnimationController _textShimmerController;
  late AnimationController _iconBounceController;
  late AnimationController _exitController;

  // 🎭 SPECTACULAR ANIMATIONS
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _celebrationAnimation;
  late Animation<double> _particleExplosionAnimation;
  late Animation<double> _glowPulseAnimation;
  late Animation<double> _textShimmerAnimation;
  late Animation<double> _iconBounceAnimation;
  late Animation<double> _fadeAnimation;

  // 🎊 CELEBRATION STATE
  bool _isCelebrating = false;
  bool _hasPlayedSound = false;
  List<ParticleData> _explosionParticles = [];
  Timer? _autoHideTimer;

  @override
  void initState() {
    super.initState();
    _initializeSpectacularAnimations();
    _generateExplosionParticles();
    _startSpectacularSequence();
    _startAutoHideTimer();
  }

  void _initializeSpectacularAnimations() {
    // 🚀 ENTRY ANIMATION (800ms)
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // 🎊 CELEBRATION SEQUENCE (2000ms)
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // 💥 PARTICLE EXPLOSION (1500ms)
    _particleExplosionController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // ✨ GLOW PULSE (3000ms - repeating)
    _glowPulseController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // 🌟 TEXT SHIMMER (1200ms)
    _textShimmerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // 🎯 ICON BOUNCE (600ms)
    _iconBounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // 🚪 EXIT ANIMATION (400ms)
    _exitController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _setupSpectacularAnimations();
  }

  void _setupSpectacularAnimations() {
    // 🚀 ENTRY ANIMATIONS
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.2, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutBack,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: Curves.elasticOut,
    ));

    // 🎊 CELEBRATION ANIMATIONS
    _celebrationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.easeOutCubic,
    ));

    // 💥 PARTICLE EXPLOSION
    _particleExplosionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleExplosionController,
      curve: Curves.easeOut,
    ));

    // ✨ GLOW PULSE
    _glowPulseAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowPulseController,
      curve: Curves.easeInOut,
    ));

    // 🌟 TEXT SHIMMER
    _textShimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _textShimmerController,
      curve: Curves.easeInOut,
    ));

    // 🎯 ICON BOUNCE
    _iconBounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _iconBounceController,
      curve: Curves.elasticOut,
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
      final velocity = 50 + random.nextDouble() * 100;
      final size = 2 + random.nextDouble() * 6;
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
    // 🚀 STAGE 1: DRAMATIC ENTRY (800ms)
    _entryController.forward();

    // 🔊 PLAY ENTRY SOUND
    await Future.delayed(const Duration(milliseconds: 200));
    _playSpectacularSound('entry');

    // 🎊 STAGE 2: CELEBRATION START (after 400ms)
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      _isCelebrating = true;
    });

    _celebrationController.forward();
    _glowPulseController.repeat(reverse: true);

    // 💥 STAGE 3: PARTICLE EXPLOSION (after 200ms)
    await Future.delayed(const Duration(milliseconds: 200));
    _particleExplosionController.forward();
    _playSpectacularSound('explosion');

    // 🌟 STAGE 4: TEXT SHIMMER (after 300ms)
    await Future.delayed(const Duration(milliseconds: 300));
    _textShimmerController.forward();

    // 🎯 STAGE 5: ICON BOUNCE (after 100ms)
    await Future.delayed(const Duration(milliseconds: 100));
    _iconBounceController.forward();
    _playSpectacularSound('achievement');

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

    // 🌟 FINAL SHIMMER
    _textShimmerController.forward();
    await Future.delayed(const Duration(milliseconds: 100));

    // 🚪 SPECTACULAR EXIT
    _exitController.forward().then((_) {
      widget.onDismiss?.call();
    });

    _playSpectacularSound('exit');
  }

  // 🔊 PLAY SPECTACULAR SOUNDS
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
        case 'achievement':
        // audioService.playNeuralSound('achievement_unlock_${rarity.name}', volume: _getSoundVolume(rarity));
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
    _entryController.dispose();
    _celebrationController.dispose();
    _particleExplosionController.dispose();
    _glowPulseController.dispose();
    _textShimmerController.dispose();
    _iconBounceController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = NeuralThemeSystem().currentTheme;
    final achievement = widget.notification.achievement;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _entryController,
        _celebrationController,
        _particleExplosionController,
        _glowPulseController,
        _textShimmerController,
        _iconBounceController,
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
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 💥 SPECTACULAR PARTICLE EXPLOSION BACKGROUND
                    if (_isCelebrating)
                      Positioned.fill(
                        child: _buildSpectacularParticleExplosion(theme, achievement),
                      ),

                    // 🌟 CELEBRATION AURA
                    if (_isCelebrating)
                      _buildCelebrationAura(theme, achievement),

                    // 🏆 MAIN NOTIFICATION PANEL
                    _buildSpectacularNotificationPanel(theme, achievement),

                    // ❌ ENHANCED DISMISS BUTTON
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildSpectacularDismissButton(theme),
                    ),

                    // 🎊 RARITY BURST EFFECTS
                    if (_isCelebrating)
                      _buildRarityBurstPowers(theme, achievement),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 💥 BUILD SPECTACULAR PARTICLE EXPLOSION
  Widget _buildSpectacularParticleExplosion(NeuralThemeData theme, Achievement achievement) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _particleExplosionAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: SpectacularParticleExplosionPainter(
              progress: _particleExplosionAnimation.value,
              particles: _explosionParticles,
              rarity: achievement.rarity,
              centerX: 150, // Approximate center
              centerY: 50,
            ),
          );
        },
      ),
    );
  }

  // 🌟 BUILD CELEBRATION AURA
  Widget _buildCelebrationAura(NeuralThemeData theme, Achievement achievement) {
    return Positioned(
      left: -20,
      top: -20,
      right: -20,
      bottom: -20,
      child: AnimatedBuilder(
        animation: _celebrationAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: achievement.rarity.color.withOpacity(
                      _celebrationAnimation.value * _glowPulseAnimation.value * 0.4
                  ),
                  blurRadius: 40 * _celebrationAnimation.value,
                  spreadRadius: 10 * _celebrationAnimation.value,
                ),
                BoxShadow(
                  color: theme.colors.primary.withOpacity(
                      _celebrationAnimation.value * _glowPulseAnimation.value * 0.2
                  ),
                  blurRadius: 60 * _celebrationAnimation.value,
                  spreadRadius: 15 * _celebrationAnimation.value,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🏆 BUILD SPECTACULAR NOTIFICATION PANEL
  Widget _buildSpectacularNotificationPanel(NeuralThemeData theme, Achievement achievement) {
    return AnimatedBuilder(
      animation: _glowPulseAnimation,
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
                  0.4 + (_glowPulseAnimation.value * 0.4)
              ),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: achievement.rarity.color.withOpacity(_glowPulseAnimation.value * 0.4),
                blurRadius: 25 * _glowPulseAnimation.value,
                spreadRadius: 3,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Row(
                children: [
                  // 🏆 SPECTACULAR ACHIEVEMENT ICON
                  _buildSpectacularAchievementIcon(theme, achievement),

                  const SizedBox(width: 20),

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

  // 🏆 BUILD SPECTACULAR ACHIEVEMENT ICON
  Widget _buildSpectacularAchievementIcon(NeuralThemeData theme, Achievement achievement) {
    return AnimatedBuilder(
      animation: _iconBounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _iconBounceAnimation.value,
          child: Container(
            width: 70,
            height: 70,
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
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: achievement.rarity.color.withOpacity(_glowPulseAnimation.value * 0.6),
                  blurRadius: 20 * _glowPulseAnimation.value,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 🎯 MAIN ICON
                Icon(
                  achievement.icon,
                  size: 35,
                  color: achievement.rarity.color,
                ),

                // ✨ SHIMMER OVERLAY
                if (_isCelebrating)
                  AnimatedBuilder(
                    animation: _textShimmerAnimation,
                    builder: (context, child) {
                      return ClipOval(
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(-1.0 + _textShimmerAnimation.value, -1.0),
                              end: Alignment(1.0 + _textShimmerAnimation.value, 1.0),
                              colors: [
                                Colors.transparent,
                                Colors.white.withOpacity(0.4),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 📝 BUILD SPECTACULAR ACHIEVEMENT INFO
  Widget _buildSpectacularAchievementInfo(NeuralThemeData theme, Achievement achievement) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 🎊 "ACHIEVEMENT UNLOCKED!" TEXT
        AnimatedBuilder(
          animation: _textShimmerAnimation,
          builder: (context, child) {
            return Stack(
              children: [
                Text(
                  'ACHIEVEMENT UNLOCKED!',
                  style: TextStyle(
                    color: theme.colors.onSurface.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                if (_isCelebrating)
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        begin: Alignment(-1.0 + _textShimmerAnimation.value, 0.0),
                        end: Alignment(1.0 + _textShimmerAnimation.value, 0.0),
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.8),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ).createShader(bounds);
                    },
                    child: Text(
                      'ACHIEVEMENT UNLOCKED!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),

        const SizedBox(height: 6),

        // 🏆 ACHIEVEMENT TITLE
        AnimatedBuilder(
          animation: _textShimmerAnimation,
          builder: (context, child) {
            return Stack(
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    color: theme.colors.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_isCelebrating)
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        begin: Alignment(-1.0 + _textShimmerAnimation.value, 0.0),
                        end: Alignment(1.0 + _textShimmerAnimation.value, 0.0),
                        colors: [
                          Colors.transparent,
                          achievement.rarity.color.withOpacity(0.8),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ).createShader(bounds);
                    },
                    child: Text(
                      achievement.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),

        const SizedBox(height: 6),

        // 📝 ACHIEVEMENT DESCRIPTION
        Text(
          achievement.description,
          style: TextStyle(
            color: theme.colors.onSurface.withOpacity(0.8),
            fontSize: 14,
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 10),

        // 💎 SPECTACULAR RARITY BADGE
        _buildSpectacularRarityBadge(theme, achievement),
      ],
    );
  }

  // 💎 BUILD SPECTACULAR RARITY BADGE
  Widget _buildSpectacularRarityBadge(NeuralThemeData theme, Achievement achievement) {
    return AnimatedBuilder(
      animation: _celebrationAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                achievement.rarity.color.withOpacity(0.3),
                achievement.rarity.color.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: achievement.rarity.color.withOpacity(0.6),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: achievement.rarity.color.withOpacity(
                    _celebrationAnimation.value * _glowPulseAnimation.value * 0.4
                ),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getRarityIcon(achievement.rarity),
                color: achievement.rarity.color,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                '${achievement.rarity.displayName.toUpperCase()} • ${_getRarityPoints(achievement.rarity)} PTS',
                style: TextStyle(
                  color: achievement.rarity.color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🎊 BUILD RARITY BURST POWERS
  Widget _buildRarityBurstPowers(NeuralThemeData theme, Achievement achievement) {
    if (achievement.rarity == AchievementRarity.legendary) {
      return Positioned.fill(
        child: AnimatedBuilder(
          animation: _celebrationAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: LegendaryBurstPainter(
                progress: _celebrationAnimation.value,
                glowIntensity: _glowPulseAnimation.value,
                color: achievement.rarity.color,
              ),
            );
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // ❌ BUILD SPECTACULAR DISMISS BUTTON
  Widget _buildSpectacularDismissButton(NeuralThemeData theme) {
    return GestureDetector(
      onTap: _startSpectacularExit,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              theme.colors.surface.withOpacity(0.9),
              theme.colors.surface.withOpacity(0.7),
            ],
          ),
          border: Border.all(
            color: theme.colors.onSurface.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Icon(
              Icons.close,
              size: 18,
              color: theme.colors.onSurface.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }

  // 🎯 UTILITY METHODS
  int _getParticleCount(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return 15;
      case AchievementRarity.rare:
        return 25;
      case AchievementRarity.epic:
        return 40;
      case AchievementRarity.legendary:
        return 60;
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

// 💥 SPECTACULAR PARTICLE EXPLOSION PAINTER
class SpectacularParticleExplosionPainter extends CustomPainter {
  final double progress;
  final List<ParticleData> particles;
  final AchievementRarity rarity;
  final double centerX;
  final double centerY;

  SpectacularParticleExplosionPainter({
    required this.progress,
    required this.particles,
    required this.rarity,
    required this.centerX,
    required this.centerY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      final currentProgress = (progress * particle.life).clamp(0.0, 1.0);
      if (currentProgress <= 0) continue;

      final distance = particle.velocity * currentProgress;
      final x = centerX + math.cos(particle.angle) * distance;
      final y = centerY + math.sin(particle.angle) * distance;

      final opacity = (1.0 - currentProgress) * 0.9;
      paint.color = particle.color.withOpacity(opacity);

      // Particle size changes over time
      final currentSize = particle.size * (1.0 + currentProgress * 0.5);

      canvas.drawCircle(
        Offset(x, y),
        currentSize,
        paint,
      );

      // Add sparkle effect for legendary
      if (rarity == AchievementRarity.legendary && currentProgress > 0.3) {
        _drawSparkle(canvas, Offset(x, y), currentSize, paint);
      }
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    final sparklePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw cross sparkle
    canvas.drawLine(
      center + Offset(-size, 0),
      center + Offset(size, 0),
      sparklePaint,
    );
    canvas.drawLine(
      center + Offset(0, -size),
      center + Offset(0, size),
      sparklePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 🌟 LEGENDARY BURST PAINTER
class LegendaryBurstPainter extends CustomPainter {
  final double progress;
  final double glowIntensity;
  final Color color;

  LegendaryBurstPainter({
    required this.progress,
    required this.glowIntensity,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.stroke;

    // Draw multiple expanding rings
    for (int i = 0; i < 3; i++) {
      final ringProgress = (progress - (i * 0.2)).clamp(0.0, 1.0);
      if (ringProgress <= 0) continue;

      final radius = ringProgress * (size.width / 2 + 50);
      final opacity = (1.0 - ringProgress) * glowIntensity * 0.6;

      paint
        ..color = color.withOpacity(opacity)
        ..strokeWidth = 3.0 - (ringProgress * 2.0);

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 💫 PARTICLE DATA CLASS
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

/// 🌟 Achievement Notification Overlay - PHASE 3.3 ENHANCED
/// Enhanced notification queue management + Achievement sidebar
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

  // 📜 ACHIEVEMENT SIDEBAR STATE
  bool _showAchievementSidebar = false;
  late AnimationController _sidebarController;
  late Animation<Offset> _sidebarAnimation;

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
      ref.listen<AsyncValue<AchievementNotification>>(
        achievementNotificationStreamProvider,
            (previous, next) {
          next.whenData((notification) {
            if (mounted) {
              setState(() {
                _activeNotifications.add(notification);
                _notificationHistory.insert(0, notification);

                // Keep only last 20 in history
                if (_notificationHistory.length > 20) {
                  _notificationHistory.removeLast();
                }
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
    _sidebarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🏆 ACTIVE NOTIFICATIONS
        if (_activeNotifications.isNotEmpty)
          Positioned(
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

  // 📜 BUILD SIDEBAR TOGGLE BUTTON
  Widget _buildSidebarToggleButton() {
    final theme = NeuralThemeSystem().currentTheme;

    return GestureDetector(
      onTap: _toggleAchievementSidebar,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              theme.colors.primary.withOpacity(0.3),
              theme.colors.primary.withOpacity(0.1),
            ],
          ),
          border: Border.all(
            color: theme.colors.primary.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colors.primary.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.history,
                  color: theme.colors.primary,
                  size: 20,
                ),
                if (_notificationHistory.isNotEmpty)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${_notificationHistory.length > 9 ? '9+' : _notificationHistory.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 📜 BUILD ACHIEVEMENT SIDEBAR
  Widget _buildAchievementSidebar() {
    final theme = NeuralThemeSystem().currentTheme;

    return Positioned(
      top: 0,
      right: 0,
      bottom: 0,
      child: SlideTransition(
        position: _sidebarAnimation,
        child: Container(
          width: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colors.surface.withOpacity(0.95),
                theme.colors.surface.withOpacity(0.9),
              ],
            ),
            border: Border(
              left: BorderSide(
                color: theme.colors.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(-5, 0),
              ),
            ],
          ),
          child: ClipRect(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                children: [
                  // 📊 SIDEBAR HEADER
                  Container(
                    padding: const EdgeInsets.all(20),
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
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Recent Achievements',
                          style: TextStyle(
                            color: theme.colors.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _toggleAchievementSidebar,
                          child: Icon(
                            Icons.close,
                            color: theme.colors.onSurface.withOpacity(0.7),
                            size: 20,
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
                      padding: const EdgeInsets.all(16),
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
        ),
      ),
    );
  }

  // 🚫 BUILD EMPTY HISTORY
  Widget _buildEmptyHistory(NeuralThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            color: theme.colors.onSurface.withOpacity(0.3),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'No achievements yet',
            style: TextStyle(
              color: theme.colors.onSurface.withOpacity(0.6),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep exploring to unlock achievements!',
            style: TextStyle(
              color: theme.colors.onSurface.withOpacity(0.4),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 🏆 BUILD HISTORY ITEM
  Widget _buildHistoryItem(NeuralThemeData theme, AchievementNotification notification, int index) {
    final achievement = notification.achievement;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            achievement.rarity.color.withOpacity(0.1),
            achievement.rarity.color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement.rarity.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 🏆 ACHIEVEMENT ICON
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: achievement.rarity.color.withOpacity(0.2),
            ),
            child: Icon(
              achievement.icon,
              color: achievement.rarity.color,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // 📝 ACHIEVEMENT INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    color: theme.colors.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    color: theme.colors.onSurface.withOpacity(0.7),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatHistoryDate(notification.timestamp),
                  style: TextStyle(
                    color: achievement.rarity.color.withOpacity(0.8),
                    fontSize: 10,
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

// 🎯 EXTENSION per Achievement Rarity Colors (Enhanced)
extension AchievementRarityColors on AchievementRarity {
  Color get color {
    switch (this) {
      case AchievementRarity.common:
        return const Color(0xFF9E9E9E); // Grey
      case AchievementRarity.rare:
        return const Color(0xFF2196F3); // Blue
      case AchievementRarity.epic:
        return const Color(0xFF9C27B0); // Purple
      case AchievementRarity.legendary:
        return const Color(0xFFFF9800); // Orange
    }
  }
}