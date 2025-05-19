// lib/widgets/dynamic_background.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class DynamicBackground extends StatefulWidget {
  final Widget child;

  const DynamicBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<DynamicBackground> createState() => _DynamicBackgroundState();
}

class _DynamicBackgroundState extends State<DynamicBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Sfondo dinamico
            Positioned.fill(
              child: CustomPaint(
                painter: BackgroundPainter(
                  progress: _controller.value,
                  isDark: isDark,
                  primaryColor: theme.colorScheme.primary,
                  secondaryColor: theme.colorScheme.secondary,
                ),
              ),
            ),
            // Contenuto principale
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  final Color primaryColor;
  final Color secondaryColor;

  BackgroundPainter({
    required this.progress,
    required this.isDark,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Colore di sfondo base
    final paint = Paint();

    // Sfondo base
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      Paint()..color = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
    );

    // Primo gradiente di blur
    final gradient1 = RadialGradient(
      center: Alignment(
        0.7 + math.sin(progress * 2 * math.pi) * 0.3,
        -0.3 + math.cos(progress * 2 * math.pi) * 0.3,
      ),
      radius: 0.7,
      colors: [
        primaryColor.withOpacity(isDark ? 0.1 : 0.05),
        Colors.transparent,
      ],
      stops: const [0.0, 1.0],
    );

    paint.shader = gradient1.createShader(Rect.fromLTWH(0, 0, width, height));
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);

    // Secondo gradiente di blur
    final gradient2 = RadialGradient(
      center: Alignment(
        -0.5 + math.cos((progress + 0.3) * 2 * math.pi) * 0.3,
        0.8 + math.sin((progress + 0.3) * 2 * math.pi) * 0.3,
      ),
      radius: 0.8,
      colors: [
        secondaryColor.withOpacity(isDark ? 0.1 : 0.05),
        Colors.transparent,
      ],
      stops: const [0.0, 1.0],
    );

    paint.shader = gradient2.createShader(Rect.fromLTWH(0, 0, width, height));
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);
  }

  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}