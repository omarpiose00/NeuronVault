// lib/core/accessibility/accessible_widget.dart
import 'package:flutter/material.dart';

class AccessibleWidget extends StatelessWidget {
  final Widget child;
  final String? id;
  final String? semanticLabel;
  final String? semanticHint;
  final bool enabled;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onHover;

  const AccessibleWidget({
    super.key,
    required this.child,
    this.id,
    this.semanticLabel,
    this.semanticHint,
    this.enabled = true,
    this.onTap,
    this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      enabled: enabled,
      child: MouseRegion(
        onEnter: (_) => onHover?.call(true),
        onExit: (_) => onHover?.call(false),
        child: GestureDetector(
          onTap: enabled ? onTap : null,
          child: child,
        ),
      ),
    );
  }
}