// lib/widgets/core/token_cost_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/design_system.dart';
import '../../core/accessibility/accessibility_manager.dart';
import '../../main.dart'; // For AIModel

/// 💰 TOKEN COST WIDGET
/// Widget per monitoraggio costi token con analytics avanzate
class TokenCostWidget extends StatefulWidget {
  final int totalTokens;
  final List<AIModel> models;
  final int budgetLimit;
  final bool showDetailedBreakdown;

  const TokenCostWidget({
    Key? key,
    required this.totalTokens,
    required this.models,
    required this.budgetLimit,
    this.showDetailedBreakdown = false,
  }) : super(key: key);

  @override
  State<TokenCostWidget> createState() => _TokenCostWidgetState();
}

class _TokenCostWidgetState extends State<TokenCostWidget> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _warningController;

  bool _isExpanded = false;
  final FocusNode _widgetFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupKeyboardHandling();
  }

  void _initializeAnimations() {
    // Progress bar animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    // Pulse animation for budget warnings
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Warning color animation
    _warningController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _startAnimations();
    _checkBudgetWarnings();
  }

  void _startAnimations() {
    _progressController.forward();

    if (_getBudgetPercentage() > 0.8) {
      _pulseController.repeat(reverse: true);
      _warningController.forward();
    }
  }

  void _checkBudgetWarnings() {
    final percentage = _getBudgetPercentage();

    if (percentage > 0.9) {
      AccessibilityManager().announce(
        'Budget warning: ${(percentage * 100).round()}% of token budget used',
        assertive: true,
      );
    }
  }

  void _setupKeyboardHandling() {
    _widgetFocus.addListener(() {
      if (_widgetFocus.hasFocus) {
        AccessibilityManager().announce(
          'Token cost monitor. ${widget.totalTokens} tokens used out of ${widget.budgetLimit} budget limit. ${((_getBudgetPercentage()) * 100).round()}% used.',
        );
      }
    });
  }

  @override
  void didUpdateWidget(TokenCostWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalTokens != widget.totalTokens) {
      _progressController.reset();
      _progressController.forward();
      _checkBudgetWarnings();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _warningController.dispose();
    _widgetFocus.dispose();
    super.dispose();
  }

  /// 📊 Get Budget Percentage
  double _getBudgetPercentage() {
    return widget.totalTokens / widget.budgetLimit;
  }

  /// 💰 Calculate Total Cost
  double _calculateTotalCost() {
    // Simplified cost calculation (in reality this would be more complex)
    return widget.totalTokens * 0.002; // $0.002 per token
  }

  /// 🎨 Get Budget Status Color
  Color _getBudgetStatusColor(DesignSystemData ds) {
    final percentage = _getBudgetPercentage();

    if (percentage >= 0.9) return ds.colors.tokenDanger;
    if (percentage >= 0.7) return ds.colors.tokenWarning;
    return ds.colors.connectionGreen;
  }

  /// 📈 Build Progress Bar
  Widget _buildProgressBar(DesignSystemData ds) {
    final percentage = _getBudgetPercentage();
    final statusColor = _getBudgetStatusColor(ds);

    return AnimatedBuilder(
      animation: Listenable.merge([_progressAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Token Usage',
                  style: ds.typography.caption.copyWith(
                    color: ds.colors.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_formatNumber(widget.totalTokens)} / ${_formatNumber(widget.budgetLimit)}',
                  style: ds.typography.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Progress Bar Background
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: ds.colors.colorScheme.outline.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Stack(
                children: [
                  // Progress Fill
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (percentage * _progressAnimation.value).clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: percentage > 0.8 ? _pulseAnimation.value : 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: percentage > 0.8
                                ? [statusColor, statusColor.withOpacity(0.8)]
                                : [ds.colors.neuralPrimary, ds.colors.neuralSecondary],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: percentage > 0.8
                              ? [
                            BoxShadow(
                              color: statusColor.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                              : null,
                        ),
                      ),
                    ),
                  ),

                  // Warning Threshold Indicator
                  if (percentage < 0.8)
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.8,
                      child: Container(
                        width: 2,
                        decoration: BoxDecoration(
                          color: ds.colors.tokenWarning,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // Percentage Text
            Text(
              '${(percentage * 100).round()}% used',
              style: ds.typography.caption.copyWith(
                color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 💰 Build Cost Summary
  Widget _buildCostSummary(DesignSystemData ds) {
    final totalCost = _calculateTotalCost();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ds.colors.colorScheme.surfaceContainer.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ds.colors.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.attach_money,
            color: ds.colors.connectionGreen,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated Cost',
                  style: ds.typography.caption.copyWith(
                    color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                Text(
                  '\$${totalCost.toStringAsFixed(3)}',
                  style: ds.typography.body1.copyWith(
                    color: ds.colors.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ds.colors.connectionGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Live',
              style: ds.typography.caption.copyWith(
                color: ds.colors.connectionGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📊 Build Model Breakdown
  Widget _buildModelBreakdown(DesignSystemData ds) {
    final activeModels = widget.models.where((model) => model.isActive && model.tokensUsed > 0).toList();

    if (activeModels.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ds.colors.colorScheme.surfaceContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: ds.colors.colorScheme.onSurface.withOpacity(0.6),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'No active models with token usage',
              style: ds.typography.body2.copyWith(
                color: ds.colors.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Model Breakdown',
          style: ds.typography.caption.copyWith(
            color: ds.colors.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        ...activeModels.map((model) => _buildModelBreakdownItem(model, ds)),
      ],
    );
  }

  /// 🤖 Build Model Breakdown Item
  Widget _buildModelBreakdownItem(AIModel model, DesignSystemData ds) {
    final percentage = model.tokensUsed / widget.totalTokens;
    final cost = model.tokensUsed * 0.002;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Model Icon
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: model.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              model.icon,
              color: model.color,
              size: 12,
            ),
          ),

          const SizedBox(width: 8),

          // Model Name
          Expanded(
            flex: 2,
            child: Text(
              model.name,
              style: ds.typography.caption.copyWith(
                color: ds.colors.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Token Count
          Expanded(
            child: Text(
              _formatNumber(model.tokensUsed),
              style: ds.typography.caption.copyWith(
                color: ds.colors.colorScheme.onSurface.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Percentage
          Expanded(
            child: Text(
              '${(percentage * 100).round()}%',
              style: ds.typography.caption.copyWith(
                color: model.color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Cost
          Expanded(
            child: Text(
              '\$${cost.toStringAsFixed(3)}',
              style: ds.typography.caption.copyWith(
                color: ds.colors.connectionGreen,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
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

  /// 🔄 Toggle Expansion
  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    AccessibilityManager().announce(
      _isExpanded ? 'Token details expanded' : 'Token details collapsed',
    );

    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final percentage = _getBudgetPercentage();

    return GestureDetector(
      onTap: _toggleExpansion,
      child: Focus(
        focusNode: _widgetFocus,
        child: Semantics(
          label: 'Token cost monitor',
          hint: 'Current token usage: ${widget.totalTokens} out of ${widget.budgetLimit}. ${(percentage * 100).round()}% of budget used.',
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ds.colors.colorScheme.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: percentage > 0.8
                    ? _getBudgetStatusColor(ds).withOpacity(0.5)
                    : ds.colors.colorScheme.outline.withOpacity(0.2),
                width: percentage > 0.8 ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: percentage > 0.8
                      ? _getBudgetStatusColor(ds).withOpacity(0.2)
                      : ds.colors.colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 12,
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
                      Icons.token,
                      color: ds.colors.neuralAccent,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Token Usage',
                      style: ds.typography.h3.copyWith(
                        color: ds.colors.colorScheme.onSurface,
                      ),
                    ),

                    const Spacer(),

                    // Budget Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getBudgetStatusColor(ds).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        percentage >= 0.9 ? 'Critical' : percentage >= 0.7 ? 'Warning' : 'Normal',
                        style: ds.typography.caption.copyWith(
                          color: _getBudgetStatusColor(ds),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Expand/Collapse Button
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: ds.colors.colorScheme.onSurface,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Progress Bar
                _buildProgressBar(ds),

                const SizedBox(height: 16),

                // Cost Summary
                _buildCostSummary(ds),

                // Expanded Details
                if (_isExpanded) ...[
                  const SizedBox(height: 20),
                  _buildModelBreakdown(ds),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}