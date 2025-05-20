// lib/widgets/ui/mode_icon.dart - Nuovo file per icone di modalità animate

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/conversation_mode.dart';

class AnimatedModeIcon extends StatefulWidget {
  final ConversationMode mode;
  final bool isSelected;
  final double size;

  const AnimatedModeIcon({
    Key? key,
    required this.mode,
    this.isSelected = false,
    this.size = 28,
  }) : super(key: key);

  @override
  State<AnimatedModeIcon> createState() => _AnimatedModeIconState();
}

class _AnimatedModeIconState extends State<AnimatedModeIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _rotateAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isSelected) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedModeIcon oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Gestisci i cambiamenti nello stato di selezione
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (widget.mode) {
      case ConversationMode.chat:
        return _buildChatIcon(isDark);
      case ConversationMode.debate:
        return _buildDebateIcon(isDark);
      case ConversationMode.brainstorm:
        return _buildBrainstormIcon(isDark);
    }
  }

  // Icona modalità Chat
  Widget _buildChatIcon(bool isDark) {
    final baseColor = isDark
        ? const Color(0xFF6A98F0)
        : const Color(0xFF2979FF);
    final glowColor = isDark
        ? const Color(0xFF90CAF9)
        : const Color(0xFFBBDEFB);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isSelected ? _scaleAnimation.value : 1.0,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  glowColor,
                  baseColor,
                ],
                stops: const [0.1, 1.0],
                focal: Alignment.topLeft,
                focalRadius: 0.6,
              ),
              boxShadow: widget.isSelected ? [
                BoxShadow(
                  color: baseColor.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ] : null,
            ),
            child: Center(
              child: Icon(
                Icons.chat_bubble_outline,
                color: Colors.white.withOpacity(
                    widget.isSelected ? _opacityAnimation.value : 0.9),
                size: widget.size * 0.6,
              ),
            ),
          ),
        );
      },
    );
  }

  // Icona modalità Dibattito
  Widget _buildDebateIcon(bool isDark) {
    final baseColor = isDark
        ? const Color(0xFFE57373)
        : const Color(0xFFF44336);
    final glowColor = isDark
        ? const Color(0xFFFFCCBC)
        : const Color(0xFFFFCDD2);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: widget.isSelected ? _rotateAnimation.value : 0,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  glowColor,
                  baseColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: widget.isSelected ? [
                BoxShadow(
                  color: baseColor.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ] : null,
            ),
            child: Center(
              child: Transform.scale(
                scale: widget.isSelected ? _scaleAnimation.value * 0.9 : 1.0,
                child: Icon(
                  Icons.compare_arrows,
                  color: Colors.white.withOpacity(
                      widget.isSelected ? _opacityAnimation.value : 0.9),
                  size: widget.size * 0.6,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Icona modalità Brainstorming
  Widget _buildBrainstormIcon(bool isDark) {
    final baseColor = isDark
        ? const Color(0xFFFFB74D)
        : const Color(0xFFFF9800);
    final glowColor = isDark
        ? const Color(0xFFFFE082)
        : const Color(0xFFFFECB3);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Effetto glow pulsante
            if (widget.isSelected)
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: glowColor.withOpacity(0.5),
                  ),
                ),
              ),

            // Icona principale
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    glowColor,
                    baseColor,
                  ],
                  stops: const [0.2, 1.0],
                  focal: Alignment.topCenter,
                  focalRadius: 0.6,
                ),
                boxShadow: widget.isSelected ? [
                  BoxShadow(
                    color: baseColor.withOpacity(0.6),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ] : null,
              ),
              child: Center(
                child: Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white.withOpacity(
                      widget.isSelected ? _opacityAnimation.value : 0.9),
                  size: widget.size * 0.6,
                ),
              ),
            ),

            // Particelle intorno all'icona quando selezionata
            if (widget.isSelected)
              ..._buildParticles(glowColor),
          ],
        );
      },
    );
  }

  // Particelle per il brainstorming
  List<Widget> _buildParticles(Color color) {
    final List<Widget> particles = [];
    const int count = 4;

    for (int i = 0; i < count; i++) {
      final double angle = (i / count) * 2 * math.pi;
      final double offsetX = widget.size * 0.7 * math.cos(angle + _controller.value * math.pi);
      final double offsetY = widget.size * 0.7 * math.sin(angle + _controller.value * math.pi);

      particles.add(
        Positioned(
          left: widget.size / 2 + offsetX - 2,
          top: widget.size / 2 + offsetY - 2,
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return particles;
  }
}

// Estensione per migliorare il codice esistente
extension ConversationModeIconData on ConversationMode {
  // Colori per le icone di modalità
  Color getBaseColor(bool isDark) {
    switch (this) {
      case ConversationMode.chat:
        return isDark ? const Color(0xFF6A98F0) : const Color(0xFF2979FF);
      case ConversationMode.debate:
        return isDark ? const Color(0xFFE57373) : const Color(0xFFF44336);
      case ConversationMode.brainstorm:
        return isDark ? const Color(0xFFFFB74D) : const Color(0xFFFF9800);
    }
  }

  Color getGlowColor(bool isDark) {
    switch (this) {
      case ConversationMode.chat:
        return isDark ? const Color(0xFF90CAF9) : const Color(0xFFBBDEFB);
      case ConversationMode.debate:
        return isDark ? const Color(0xFFFFCCBC) : const Color(0xFFFFCDD2);
      case ConversationMode.brainstorm:
        return isDark ? const Color(0xFFFFE082) : const Color(0xFFFFECB3);
    }
  }
}