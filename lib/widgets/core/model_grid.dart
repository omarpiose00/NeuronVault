// lib/widgets/core/model_grid.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/design_system.dart';
import '../../core/accessibility/accessibility_manager.dart';
import '../../core/state/state_models.dart';
import '../../main.dart'; // For AIModel

/// 🤖 MODEL GRID
/// Grid dei modelli AI con health indicators e performance metrics
class ModelGrid extends StatefulWidget {
  final List<AIModel> models;
  final ValueChanged<String> onModelToggle;
  final bool showDetailedMetrics;

  const ModelGrid({
    Key? key,
    required this.models,
    required this.onModelToggle,
    this.showDetailedMetrics = false,
  }) : super(key: key);

  @override
  State<ModelGrid> createState() => _ModelGridState();
}

class _ModelGridState extends State<ModelGrid> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _healthController;
  late Animation<double> _healthAnimation;

  bool _isGridView = true;
  final FocusNode _containerFocus = FocusNode();
  int _focusedModelIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupKeyboardHandling();
  }

  void _initializeAnimations() {
    // Pulse animation for active models
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);

    // Health indicator animation
    _healthController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _healthAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _healthController,
      curve: Curves.easeOut,
    ));
    _healthController.forward();
  }

  void _setupKeyboardHandling() {
    _containerFocus.addListener(() {
      if (_containerFocus.hasFocus) {
        AccessibilityManager().announce(
          'AI models grid. ${widget.models.length} models available. Use arrow keys to navigate.',
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _healthController.dispose();
    _containerFocus.dispose();
    super.dispose();
  }

  /// ⌨️ Handle Keyboard Navigation
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
          _navigateModel(-2);
          return KeyEventResult.handled;
        case LogicalKeyboardKey.arrowDown:
          _navigateModel(2);
          return KeyEventResult.handled;
        case LogicalKeyboardKey.arrowLeft:
          _navigateModel(-1);
          return KeyEventResult.handled;
        case LogicalKeyboardKey.arrowRight:
          _navigateModel(1);
          return KeyEventResult.handled;
        case LogicalKeyboardKey.space:
        case LogicalKeyboardKey.enter:
          _toggleCurrentModel();
          return KeyEventResult.handled;
        case LogicalKeyboardKey.keyV:
          _toggleViewMode();
          return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  /// 🔄 Navigate Models
  void _navigateModel(int direction) {
    setState(() {
      _focusedModelIndex = (_focusedModelIndex + direction) % widget.models.length;
      if (_focusedModelIndex < 0) _focusedModelIndex = widget.models.length - 1;
    });

    final model = widget.models[_focusedModelIndex];
    AccessibilityManager().announce(
      'Focused on ${model.name} model. ${model.isActive ? 'Active' : 'Inactive'}. Health: ${(model.health * 100).round()}%',
    );

    HapticFeedback.selectionClick();
  }

  /// ✅ Toggle Current Model
  void _toggleCurrentModel() {
    final model = widget.models[_focusedModelIndex];
    widget.onModelToggle(model.name);
    HapticFeedback.mediumImpact();
  }

  /// 🔄 Toggle View Mode
  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });

    AccessibilityManager().announce(
      'Switched to ${_isGridView ? 'grid' : 'list'} view',
    );

    HapticFeedback.lightImpact();
  }

  /// 🎨 Build Model Card
  Widget _buildModelCard(AIModel model, int index, DesignSystemData ds) {
    final isFocused = index == _focusedModelIndex && _containerFocus.hasFocus;

    return GestureDetector(
      onTap: () => widget.onModelToggle(model.name),
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _healthAnimation]),
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: model.isActive
                  ? LinearGradient(
                colors: [
                  model.color.withOpacity(0.2),
                  model.color.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : null,
              color: model.isActive ? null : ds.colors.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isFocused
                    ? ds.colors.neuralAccent
                    : model.isActive
                    ? model.color.withOpacity(0.5)
                    : ds.colors.colorScheme.outline.withOpacity(0.3),
                width: isFocused ? 2 : 1,
              ),
              boxShadow: model.isActive
                  ? [
                BoxShadow(
                  color: model.color.withOpacity(_pulseAnimation.value * 0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
                  : [
                BoxShadow(
                  color: ds.colors.colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Model Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: model.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        model.icon,
                        color: model.color,
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Model Name & Status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            model.name,
                            style: ds.typography.h3.copyWith(
                              color: ds.colors.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: model.isActive
                                  ? ds.colors.connectionGreen.withOpacity(0.2)
                                  : ds.colors.connectionRed.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              model.isActive ? 'Active' : 'Inactive',
                              style: ds.typography.caption.copyWith(
                                color: model.isActive
                                    ? ds.colors.connectionGreen
                                    : ds.colors.connectionRed,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Toggle Switch
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: model.isActive,
                        onChanged: (_) => widget.onModelToggle(model.name),
                        activeColor: model.color,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Health Indicator
                _buildHealthIndicator(model, ds),

                const SizedBox(height: 12),

                // Performance Metrics
                _buildPerformanceMetrics(model, ds),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 💚 Build Health Indicator
  Widget _buildHealthIndicator(AIModel model, DesignSystemData ds) {
    final healthColor = _getHealthColor(model.health, ds);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.favorite,
              color: healthColor,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Health: ${(model.health * 100).round()}%',
              style: ds.typography.caption.copyWith(
                color: ds.colors.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Health Progress Bar
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: ds.colors.colorScheme.outline.withOpacity(0.2),
            borderRadius: BorderRadius.circular(3),
          ),
          child: AnimatedBuilder(
            animation: _healthAnimation,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: model.health * _healthAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: healthColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 📊 Build Performance Metrics
  Widget _buildPerformanceMetrics(AIModel model, DesignSystemData ds) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tokens Used',
                style: ds.typography.caption.copyWith(
                  color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatNumber(model.tokensUsed),
                style: ds.typography.body2.copyWith(
                  color: ds.colors.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Response Time',
                style: ds.typography.caption.copyWith(
                  color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${(1.2 + (model.health * 0.8)).toStringAsFixed(1)}s',
                style: ds.typography.body2.copyWith(
                  color: ds.colors.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 🎨 Get Health Color
  Color _getHealthColor(double health, DesignSystemData ds) {
    if (health >= 0.8) return ds.colors.connectionGreen;
    if (health >= 0.6) return ds.colors.tokenWarning;
    return ds.colors.tokenDanger;
  }

  /// 🔢 Format Number
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  /// 🏗️ Build Grid View
  Widget _buildGridView(DesignSystemData ds) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: widget.models.length,
      itemBuilder: (context, index) {
        return _buildModelCard(widget.models[index], index, ds);
      },
    );
  }

  /// 📋 Build List View
  Widget _buildListView(DesignSystemData ds) {
    return ListView.builder(
      itemCount: widget.models.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildModelCard(widget.models[index], index, ds),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    return Focus(
      focusNode: _containerFocus,
      onKeyEvent: _handleKeyEvent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.smart_toy,
                color: ds.colors.neuralSecondary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'AI Models',
                style: ds.typography.h2.copyWith(
                  color: ds.colors.colorScheme.onSurface,
                ),
              ),

              const Spacer(),

              // View Toggle
              AccessibleWidget(
                semanticLabel: 'Toggle view mode',
                semanticHint: 'Switch between grid and list view',
                onTap: _toggleViewMode,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ds.colors.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _isGridView ? Icons.view_list : Icons.grid_view,
                    color: ds.colors.colorScheme.onSurface,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Models Grid/List
          Expanded(
            child: _isGridView ? _buildGridView(ds) : _buildListView(ds),
          ),
        ],
      ),
    );
  }
}