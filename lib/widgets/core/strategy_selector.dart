// lib/widgets/core/strategy_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/design_system.dart';
import '../../core/accessibility/accessibility_manager.dart';
import '../../main.dart'; // For AIStrategy enum

/// 🎯 STRATEGY SELECTOR
/// Selettore strategia AI con animazioni moderne e accessibilità completa
class StrategySelector extends StatefulWidget {
  final AIStrategy currentStrategy;
  final ValueChanged<AIStrategy> onStrategyChanged;

  const StrategySelector({
    Key? key,
    required this.currentStrategy,
    required this.onStrategyChanged,
  }) : super(key: key);

  @override
  State<StrategySelector> createState() => _StrategySelectorState();
}

class _StrategySelectorState extends State<StrategySelector> with TickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  // Focus and Navigation
  final FocusNode _containerFocus = FocusNode();
  int _focusedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupKeyboardHandling();
    _focusedIndex = AIStrategy.values.indexOf(widget.currentStrategy);
  }

  void _initializeAnimations() {
    // Glow animation for active strategy
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    _glowController.repeat(reverse: true);

    // Scale animation for interactions
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupKeyboardHandling() {
    _containerFocus.addListener(() {
      if (_containerFocus.hasFocus) {
        AccessibilityManager().announce(
          'Strategy selector focused. Current strategy: ${widget.currentStrategy.displayName}. Use arrow keys to navigate.',
        );
      }
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _scaleController.dispose();
    _containerFocus.dispose();
    super.dispose();
  }

  /// ⌨️ Handle Keyboard Navigation
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowLeft:
          _navigateStrategy(-1);
          return KeyEventResult.handled;
        case LogicalKeyboardKey.arrowRight:
          _navigateStrategy(1);
          return KeyEventResult.handled;
        case LogicalKeyboardKey.home:
          _selectStrategy(0);
          return KeyEventResult.handled;
        case LogicalKeyboardKey.end:
          _selectStrategy(AIStrategy.values.length - 1);
          return KeyEventResult.handled;
        case LogicalKeyboardKey.space:
        case LogicalKeyboardKey.enter:
          _selectStrategy(_focusedIndex);
          return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  /// 🔄 Navigate Strategy
  void _navigateStrategy(int direction) {
    setState(() {
      _focusedIndex = (_focusedIndex + direction) % AIStrategy.values.length;
      if (_focusedIndex < 0) _focusedIndex = AIStrategy.values.length - 1;
    });

    final strategy = AIStrategy.values[_focusedIndex];
    AccessibilityManager().announce(
      'Focused on ${strategy.displayName} strategy',
    );

    HapticFeedback.selectionClick();
  }

  /// ✅ Select Strategy
  void _selectStrategy(int index) {
    final strategy = AIStrategy.values[index];
    if (strategy != widget.currentStrategy) {
      widget.onStrategyChanged(strategy);
      setState(() {
        _focusedIndex = index;
      });

      // Trigger scale animation
      _scaleController.forward().then((_) {
        _scaleController.reverse();
      });

      HapticFeedback.mediumImpact();
    }
  }

  /// 🎨 Build Strategy Pill
  Widget _buildStrategyPill(AIStrategy strategy, int index, DesignSystemData ds) {
    final isActive = strategy == widget.currentStrategy;
    final isFocused = index == _focusedIndex && _containerFocus.hasFocus;

    return GestureDetector(
      onTap: () => _selectStrategy(index),
      child: AnimatedBuilder(
        animation: Listenable.merge([_glowAnimation, _scaleAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: isActive ? _scaleAnimation.value : 1.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: isActive
                    ? LinearGradient(
                  colors: [
                    ds.colors.neuralPrimary,
                    ds.colors.neuralSecondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : null,
                color: isActive ? null : ds.colors.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isFocused
                      ? ds.colors.neuralAccent
                      : isActive
                      ? Colors.transparent
                      : ds.colors.colorScheme.outline.withOpacity(0.3),
                  width: isFocused ? 2 : 1,
                ),
                boxShadow: isActive
                    ? [
                  BoxShadow(
                    color: ds.colors.neuralPrimary.withOpacity(_glowAnimation.value * 0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    strategy.icon,
                    color: isActive
                        ? ds.colors.colorScheme.onPrimary
                        : ds.colors.colorScheme.onSurface,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    strategy.displayName,
                    style: ds.typography.button.copyWith(
                      color: isActive
                          ? ds.colors.colorScheme.onPrimary
                          : ds.colors.colorScheme.onSurface,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// ℹ️ Build Strategy Info
  Widget _buildStrategyInfo(DesignSystemData ds) {
    final strategy = widget.currentStrategy;
    final description = _getStrategyDescription(strategy);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ds.colors.colorScheme.surfaceContainer.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ds.colors.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: ds.colors.neuralAccent,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${strategy.displayName} Strategy',
                  style: ds.typography.caption.copyWith(
                    color: ds.colors.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: ds.typography.body2.copyWith(
                    color: ds.colors.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 📝 Get Strategy Description
  String _getStrategyDescription(AIStrategy strategy) {
    switch (strategy) {
      case AIStrategy.parallel:
        return 'All AI models process simultaneously for fastest response';
      case AIStrategy.consensus:
        return 'Models collaborate to reach consensus on best answer';
      case AIStrategy.adaptive:
        return 'Dynamically selects best model based on query type';
      case AIStrategy.cascade:
        return 'Processes through models sequentially for refined output';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    return AccessibleWidget(
      focusNode: _containerFocus,
      autofocus: false,
      child: Focus(
        focusNode: _containerFocus,
        onKeyEvent: _handleKeyEvent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ds.colors.colorScheme.surface.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ds.colors.colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: ds.colors.colorScheme.shadow.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.psychology,
                    color: ds.colors.neuralPrimary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI Strategy',
                    style: ds.typography.h3.copyWith(
                      color: ds.colors.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ds.colors.neuralPrimary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Active',
                      style: ds.typography.caption.copyWith(
                        color: ds.colors.neuralPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Strategy Pills
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: AIStrategy.values.asMap().entries.map((entry) {
                  return _buildStrategyPill(entry.value, entry.key, ds);
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Strategy Info
              _buildStrategyInfo(ds),
            ],
          ),
        ),
      ),
    );
  }
}