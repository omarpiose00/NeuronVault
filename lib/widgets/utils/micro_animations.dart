// lib/widgets/utils/micro_animations.dart
import 'package:flutter/material.dart';

class MicroAnimations {
  /// Crea un'animazione di pulsazione per elementi interattivi
  static Widget pulse({
    required Widget child,
    required bool isActive,
    double maxScale = 1.15,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 1.0,
        end: isActive ? maxScale : 1.0,
      ),
      duration: duration,
      curve: Curves.easeInOut,
      builder: (context, value, childWidget) {
        return Transform.scale(
          scale: value,
          child: childWidget,
        );
      },
      child: child,
    );
  }

  /// Crea un effetto di hover animato
  static Widget hover({
    required Widget child,
    required bool isHovering,
    double elevation = 4.0,
    Duration duration = const Duration(milliseconds: 200),
  }) {
    return AnimatedContainer(
      duration: duration,
      curve: Curves.easeOutQuad,
      transform: isHovering
          ? Matrix4.translationValues(0, -8, 0)
          : Matrix4.translationValues(0, 0, 0),
      decoration: BoxDecoration(
        boxShadow: isHovering
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: elevation * 2,
            spreadRadius: 1,
            offset: Offset(0, elevation),
          ),
        ]
            : [],
      ),
      child: child,
    );
  }

  /// Crea un'animazione di espansione/contrazione
  static Widget expand({
    required Widget child,
    required bool isExpanded,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return AnimatedContainer(
      duration: duration,
      curve: Curves.easeInOut,
      height: isExpanded ? null : 0,
      // Qui c'era il parametro opacity che non è supportato in AnimatedContainer
      // Usiamo Opacity con AnimatedOpacity invece
      child: AnimatedOpacity(
        opacity: isExpanded ? 1.0 : 0.0,
        duration: duration,
        child: child,
      ),
    );
  }

  /// Crea un effetto di ripple quando si verifica un'azione
  static Widget ripple({
    required Widget child,
    required bool triggerRipple,
    Duration duration = const Duration(milliseconds: 700),
    Color rippleColor = Colors.white,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        if (triggerRipple)
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: duration,
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: 1.0 - value,
                child: Transform.scale(
                  scale: value * 2,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: rippleColor.withOpacity(0.5),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}