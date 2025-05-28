// ⏳ NEURONVAULT - ENTERPRISE LOADING SCREEN
// Professional loading experience with neural animations
// Part of PHASE 2.5 - QUANTUM STATE MANAGEMENT

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  final String message;
  final String? subtitle;
  final VoidCallback? onCancel;
  final bool showProgress;
  final double? progress;

  const LoadingScreen({
    super.key,
    required this.message,
    this.subtitle,
    this.onCancel,
    this.showProgress = false,
    this.progress,
  });

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen>
    with TickerProviderStateMixin {

  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // 💫 Pulse animation for neural network effect
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // 🔄 Rotation animation for loading indicator
    _rotateController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.linear,
    ));

    // ✨ Fade animation for text
    _fadeAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _pulseController.repeat(reverse: true);
    _rotateController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.background,
              theme.colorScheme.background.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 🎨 Header with logo
              _buildHeader(theme),

              // 🔄 Main loading content
              Expanded(
                child: _buildLoadingContent(theme),
              ),

              // 🔗 Footer with cancel option
              if (widget.onCancel != null)
                _buildFooter(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          // 🧠 Neural logo with pulse animation
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: _getPrimaryGradient(),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 16),

          // 📱 App title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NeuronVault',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              Text(
                'Enterprise AI Platform',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContent(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 🎭 Neural network animation
          _buildNeuralAnimation(theme),

          const SizedBox(height: 48),

          // 📝 Loading message
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Column(
                  children: [
                    Text(
                      widget.message,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onBackground,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // 📊 Progress indicator
          if (widget.showProgress)
            _buildProgressIndicator(theme),
        ],
      ),
    );
  }

  Widget _buildNeuralAnimation(ThemeData theme) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 🌀 Outer rotating ring
          AnimatedBuilder(
            animation: _rotateAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotateAnimation.value * 2 * math.pi,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 2,
                      color: theme.colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: CustomPaint(
                    painter: NeuralNetworkPainter(
                      color: theme.colorScheme.primary,
                      animation: _rotateAnimation.value,
                    ),
                  ),
                ),
              );
            },
          ),

          // 🧠 Inner pulsing core
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value * 0.5 + 0.5,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _getPrimaryGradient(),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.4),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.memory,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    return Column(
      children: [
        // 📊 Progress bar
        Container(
          width: 200,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: theme.colorScheme.onBackground.withOpacity(0.1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: widget.progress,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 📈 Progress percentage
        if (widget.progress != null)
          Text(
            '${(widget.progress! * 100).toInt()}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: TextButton(
        onPressed: widget.onCancel,
        style: TextButton.styleFrom(
          foregroundColor: theme.colorScheme.onBackground.withOpacity(0.7),
        ),
        child: Text(
          'Cancel',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  LinearGradient _getPrimaryGradient() {
    return const LinearGradient(
      colors: [
        Color(0xFF6366F1),
        Color(0xFF8B5CF6),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

// 🎨 NEURAL NETWORK PAINTER
class NeuralNetworkPainter extends CustomPainter {
  final Color color;
  final double animation;

  const NeuralNetworkPainter({
    required this.color,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw neural network connections
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45 + animation * 360) * math.pi / 180;
      final startAngle = angle - 0.5;
      final endAngle = angle + 0.5;

      final startX = center.dx + (radius - 20) * math.cos(startAngle);
      final startY = center.dy + (radius - 20) * math.sin(startAngle);
      final endX = center.dx + (radius - 20) * math.cos(endAngle);
      final endY = center.dy + (radius - 20) * math.sin(endAngle);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );

      // Draw nodes
      canvas.drawCircle(
        Offset(startX, startY),
        2,
        Paint()..color = color.withOpacity(0.6),
      );
    }
  }

  @override
  bool shouldRepaint(NeuralNetworkPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

// 🔧 LOADING SCREEN VARIANTS
class InitializingScreen extends LoadingScreen {
  const InitializingScreen({super.key})
      : super(
    message: 'Initializing NeuronVault',
    subtitle: 'Setting up enterprise AI orchestration',
  );
}

class ConnectingScreen extends LoadingScreen {
  const ConnectingScreen({super.key})
      : super(
    message: 'Connecting to AI Models',
    subtitle: 'Establishing secure connections',
  );
}

class ProcessingScreen extends LoadingScreen {
  @override
  final double? progress;

  const ProcessingScreen({
    super.key,
    this.progress,
  }) : super(
    message: 'Processing Request',
    subtitle: 'AI models are generating response',
    showProgress: true,
    progress: progress,
  );
}

// 📱 RESPONSIVE LOADING VARIATIONS
class CompactLoadingScreen extends ConsumerWidget {
  final String message;
  final bool showCancel;
  final VoidCallback? onCancel;

  const CompactLoadingScreen({
    super.key,
    required this.message,
    this.showCancel = false,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // 🔄 Compact spinner
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            ),
          ),

          const SizedBox(width: 12),

          // 📝 Message
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.8),
              ),
            ),
          ),

          // ❌ Cancel button
          if (showCancel && onCancel != null)
            IconButton(
              onPressed: onCancel,
              icon: const Icon(Icons.close, size: 18),
              iconSize: 18,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
        ],
      ),
    );
  }
}

// 🎯 LOADING OVERLAY
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String message;
  final Color? backgroundColor;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message = 'Loading...',
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withOpacity(0.5),
            child: LoadingScreen(message: message),
          ),
      ],
    );
  }
}