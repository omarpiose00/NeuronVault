// 🎨 NEURAL THEME SELECTOR WIDGET
// lib/widgets/core/neural_theme_selector.dart
// Premium UI for selecting neural luxury themes

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

import '../../core/theme/neural_theme_system.dart';
import '../../core/design_system.dart';

/// 🌟 Neural Theme Selector Widget
class NeuralThemeSelector extends ConsumerStatefulWidget {
  final bool isCompact;
  final Function(NeuralThemeType)? onThemeChanged;

  const NeuralThemeSelector({
    super.key,
    this.isCompact = false,
    this.onThemeChanged,
  });

  @override
  ConsumerState<NeuralThemeSelector> createState() => _NeuralThemeSelectorState();
}

class _NeuralThemeSelectorState extends ConsumerState<NeuralThemeSelector>
    with TickerProviderStateMixin {

  late AnimationController _animationController;
  late AnimationController _previewController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _previewAnimation;

  NeuralThemeType _selectedTheme = NeuralThemeType.cosmos;
  NeuralThemeType? _hoveredTheme;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _previewController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _previewAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(_previewController);

    _previewController.repeat();

    if (_isExpanded) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _previewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    if (widget.isCompact) {
      return _buildCompactSelector(ds);
    } else {
      return _buildFullSelector(ds);
    }
  }

  /// 🎚️ Build Compact Theme Selector
  Widget _buildCompactSelector(DesignSystemData ds) {
    final themeSystem = NeuralThemeSystem();
    final currentTheme = themeSystem.currentTheme;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
          if (_isExpanded) {
            _animationController.forward();
          } else {
            _animationController.reverse();
          }
        });
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              currentTheme.colors.surface.withOpacity(0.9),
              currentTheme.colors.surface.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: currentTheme.colors.primary.withOpacity(0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: currentTheme.colors.primary.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Current theme indicator
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildThemePreview(currentTheme, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'THEME',
                      style: ds.typography.caption.copyWith(
                        color: currentTheme.colors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                      ),
                    ),
                    const SizedBox(width: 6),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: currentTheme.colors.onSurface.withOpacity(0.7),
                        size: 16,
                      ),
                    ),
                  ],
                ),

                // Expanded theme grid
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: _isExpanded ? Container(
                    margin: const EdgeInsets.only(top: 12),
                    child: _buildCompactThemeGrid(),
                  ) : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🎛️ Build Full Theme Selector
  Widget _buildFullSelector(DesignSystemData ds) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ds.colors.colorScheme.surfaceContainer.withOpacity(0.9),
            ds.colors.colorScheme.surfaceContainer.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: ds.colors.neuralPrimary.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: ds.colors.neuralPrimary.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _previewAnimation,
                    builder: (context, child) {
                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              ds.colors.neuralPrimary.withOpacity(0.3 * _previewAnimation.value),
                              ds.colors.neuralPrimary.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.palette,
                          color: ds.colors.neuralPrimary,
                          size: 20,
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Neural Themes',
                          style: ds.typography.h3.copyWith(
                            color: ds.colors.colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Luxury Visual Experiences',
                          style: ds.typography.caption.copyWith(
                            color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Theme grid
              _buildFullThemeGrid(),
            ],
          ),
        ),
      ),
    );
  }

  /// 🎨 Build Compact Theme Grid
  Widget _buildCompactThemeGrid() {
    final themeSystem = NeuralThemeSystem();
    final themes = themeSystem.getAllThemes();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: themes.map((themePreset) {
        final isSelected = themePreset.type == _selectedTheme;

        return GestureDetector(
          onTap: () => _selectTheme(themePreset.type),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: themePreset.previewColors,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? Colors.white.withOpacity(0.8)
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: themePreset.previewColors.first.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ] : null,
            ),
            child: isSelected ? Icon(
              Icons.check,
              color: Colors.white,
              size: 16,
            ) : null,
          ),
        );
      }).toList(),
    );
  }

  /// 🎨 Build Full Theme Grid
  Widget _buildFullThemeGrid() {
    final themeSystem = NeuralThemeSystem();
    final themes = themeSystem.getAllThemes();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: themes.length,
      itemBuilder: (context, index) {
        final themePreset = themes[index];
        return _buildThemeCard(themePreset);
      },
    );
  }

  /// 🎨 Build Theme Card
  Widget _buildThemeCard(NeuralThemePreset themePreset) {
    final isSelected = themePreset.type == _selectedTheme;
    final isHovered = themePreset.type == _hoveredTheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredTheme = themePreset.type),
      onExit: (_) => setState(() => _hoveredTheme = null),
      child: GestureDetector(
        onTap: () => _selectTheme(themePreset.type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                themePreset.previewColors.first.withOpacity(0.2),
                themePreset.previewColors.last.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? themePreset.previewColors.first.withOpacity(0.8)
                  : themePreset.previewColors.first.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected || isHovered ? [
              BoxShadow(
                color: themePreset.previewColors.first.withOpacity(0.3),
                blurRadius: isSelected ? 16 : 8,
                spreadRadius: isSelected ? 2 : 1,
              ),
            ] : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme preview and icon
              Row(
                children: [
                  _buildThemePreview(
                    NeuralThemeSystem().currentTheme, // Placeholder
                    size: 32,
                    colors: themePreset.previewColors,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          themePreset.name,
                          style: TextStyle(
                            color: themePreset.previewColors.first,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          themePreset.description,
                          style: TextStyle(
                            color: themePreset.previewColors.first.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Selection indicator
              if (isSelected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: themePreset.previewColors,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'ACTIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
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

  /// 🎭 Build Theme Preview
  Widget _buildThemePreview(NeuralThemeData theme, {double size = 24, List<Color>? colors}) {
    final previewColors = colors ?? [
      theme.colors.primary,
      theme.colors.secondary,
      theme.colors.accent,
    ];

    return AnimatedBuilder(
      animation: _previewAnimation,
      builder: (context, child) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: SweepGradient(
              colors: [
                ...previewColors,
                previewColors.first,
              ],
              transform: GradientRotation(_previewAnimation.value * 2 * math.pi),
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: previewColors.first.withOpacity(0.4),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🎯 Select Theme
  void _selectTheme(NeuralThemeType themeType) {
    setState(() {
      _selectedTheme = themeType;
    });

    // Update theme system
    NeuralThemeSystem().setTheme(themeType);

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Call callback
    widget.onThemeChanged?.call(themeType);

    // Show feedback
    if (mounted) {
      final themeName = _getThemeName(themeType);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Theme changed to $themeName'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: NeuralThemeSystem().currentTheme.colors.primary,
        ),
      );
    }
  }

  /// 🏷️ Get Theme Name Helper
  String _getThemeName(NeuralThemeType themeType) {
    switch (themeType) {
      case NeuralThemeType.cosmos:
        return 'Cosmos';
      case NeuralThemeType.matrix:
        return 'Matrix';
      case NeuralThemeType.sunset:
        return 'Sunset';
      case NeuralThemeType.ocean:
        return 'Ocean';
      case NeuralThemeType.midnight:
        return 'Midnight';
      case NeuralThemeType.aurora:
        return 'Aurora';
    }
  }
}