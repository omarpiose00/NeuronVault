// 🧬 NEURONVAULT - ENHANCED MODEL GRID WITH ATHENA INTELLIGENCE
// PHASE 3.4: Revolutionary AI Autonomy Integration
// Real-time intelligent recommendations + Neural confidence visualization + Auto-suggestions

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import '../../core/design_system.dart';
import '../../core/accessibility/accessibility_manager.dart';
import '../../core/state/state_models.dart';
import '../../core/providers/providers_main.dart';
import '../../core/controllers/athena_controller.dart';
import '../../core/services/mini_llm_analyzer_service.dart';

/// 🧠 ATHENA RECOMMENDATION OVERLAY
class AthenaRecommendationOverlay extends StatelessWidget {
  final String modelName;
  final double confidence;
  final bool isRecommended;
  final VoidCallback? onTap;

  const AthenaRecommendationOverlay({
    super.key,
    required this.modelName,
    required this.confidence,
    required this.isRecommended,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    if (!isRecommended && confidence < 0.6) return const SizedBox.shrink();

    return Positioned(
      top: 8,
      right: 8,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isRecommended
                  ? [ds.colors.neuralPrimary, ds.colors.neuralSecondary]
                  : [ds.colors.neuralSecondary.withOpacity(0.8), ds.colors.neuralPrimary.withOpacity(0.6)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isRecommended
                    ? ds.colors.neuralPrimary.withOpacity(0.4)
                    : ds.colors.neuralSecondary.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isRecommended ? Icons.recommend : Icons.psychology,
                color: Colors.white,
                size: 12,
              ),
              const SizedBox(width: 4),
              Text(
                isRecommended ? 'AI Pick' : '${(confidence * 100).round()}%',
                style: ds.typography.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🎯 CONFIDENCE VISUALIZATION WIDGET
class ConfidenceVisualization extends StatefulWidget {
  final double confidence;
  final Color color;
  final bool isAnimated;

  const ConfidenceVisualization({
    super.key,
    required this.confidence,
    required this.color,
    this.isAnimated = true,
  });

  @override
  State<ConfidenceVisualization> createState() => _ConfidenceVisualizationState();
}

class _ConfidenceVisualizationState extends State<ConfidenceVisualization>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.confidence,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    if (widget.isAnimated) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(ConfidenceVisualization oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.confidence != widget.confidence) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.confidence,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: Colors.grey.withOpacity(0.2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: widget.isAnimated ? _animation.value : widget.confidence,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.color,
                    widget.color.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.3),
                    blurRadius: 3,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 🤖 ATHENA SUGGESTIONS PANEL
class AthenaSuggestionsPanel extends ConsumerWidget {
  final VoidCallback? onApplyRecommendations;
  final VoidCallback? onToggleDecisionTree;

  const AthenaSuggestionsPanel({
    super.key,
    this.onApplyRecommendations,
    this.onToggleDecisionTree,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ds = context.ds;
    final recommendation = ref.watch(athenaCurrentRecommendationProvider);
    final isReady = ref.watch(athenaIsReadyProvider);
    final hasNewRecommendation = ref.watch(athenaHasNewRecommendationProvider);
    final autoApplyEnabled = ref.watch(athenaAutoApplyEnabledProvider);

    if (recommendation == null || !isReady) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ds.colors.neuralPrimary.withOpacity(0.1),
            ds.colors.neuralSecondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasNewRecommendation
              ? ds.colors.neuralAccent.withOpacity(0.6)
              : ds.colors.neuralPrimary.withOpacity(0.3),
          width: hasNewRecommendation ? 2 : 1,
        ),
        boxShadow: hasNewRecommendation ? [
          BoxShadow(
            color: ds.colors.neuralAccent.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🧠 ATHENA HEADER
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ds.colors.neuralPrimary, ds.colors.neuralSecondary],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Athena Intelligence',
                      style: ds.typography.h4.copyWith(
                        color: ds.colors.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Confidence: ${(recommendation.overallConfidence * 100).round()}%',
                      style: ds.typography.caption.copyWith(
                        color: ds.colors.neuralAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasNewRecommendation)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: ds.colors.neuralAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'NEW',
                    style: ds.typography.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 8,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // 📊 RECOMMENDATION SUMMARY
          Text(
            recommendation.reasoning,
            style: ds.typography.caption.copyWith(
              color: ds.colors.colorScheme.onSurface.withOpacity(0.8),
              height: 1.3,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          // 🎯 RECOMMENDED MODELS
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: recommendation.recommendedModels.map((model) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getModelColor(model).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getModelColor(model).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  model.toUpperCase(),
                  style: ds.typography.caption.copyWith(
                    color: _getModelColor(model),
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          // 🎮 ACTION BUTTONS
          Row(
            children: [
              // 🤖 APPLY BUTTON
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: autoApplyEnabled ? null : onApplyRecommendations,
                  icon: Icon(
                    autoApplyEnabled ? Icons.autorenew : Icons.check,
                    size: 16,
                  ),
                  label: Text(
                    autoApplyEnabled ? 'Auto-Applied' : 'Apply Now',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: autoApplyEnabled
                        ? ds.colors.connectionGreen.withOpacity(0.8)
                        : ds.colors.neuralPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // 🌳 DECISION TREE BUTTON
              IconButton(
                onPressed: onToggleDecisionTree,
                icon: const Icon(Icons.account_tree, size: 16),
                style: IconButton.styleFrom(
                  backgroundColor: ds.colors.colorScheme.surfaceContainer,
                  foregroundColor: ds.colors.colorScheme.onSurface,
                  padding: const EdgeInsets.all(8),
                ),
                tooltip: 'Show Decision Tree',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getModelColor(String modelName) {
    switch (modelName.toLowerCase()) {
      case 'claude':
        return Colors.orange;
      case 'gpt':
        return Colors.green;
      case 'deepseek':
        return Colors.blue;
      case 'gemini':
        return Colors.purple;
      case 'mistral':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

/// 🧬 ENHANCED MODEL CARD WITH ATHENA INTELLIGENCE
class EnhancedModelCardWithAthena extends ConsumerWidget {
  final AIModel model;
  final int index;
  final bool isFocused;
  final VoidCallback onToggle;

  const EnhancedModelCardWithAthena({
    super.key,
    required this.model,
    required this.index,
    required this.isFocused,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ds = context.ds;
    final recommendation = ref.watch(athenaCurrentRecommendationProvider);
    final liveScores = ref.watch(athenaLiveModelScoresProvider);
    final isAnalyzing = ref.watch(athenaControllerProvider.select((state) => state.isAnalyzing));

    // 🧠 ATHENA INTELLIGENCE CALCULATIONS
    final isRecommended = recommendation?.recommendedModels.contains(model.name) ?? false;
    final confidence = liveScores[model.name] ?? (recommendation?.modelScores[model.name] ?? 0.5);
    final modelWeight = recommendation?.modelWeights[model.name] ?? 0.0;

    return GestureDetector(
      onTap: onToggle,
      child: Stack(
        children: [
          // 🎨 BASE MODEL CARD
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: model.isActive
                  ? LinearGradient(
                colors: [
                  model.color.withOpacity(isRecommended ? 0.4 : 0.2),
                  model.color.withOpacity(isRecommended ? 0.3 : 0.1),
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
                    : isRecommended
                    ? ds.colors.neuralPrimary.withOpacity(0.8)
                    : model.isActive
                    ? model.color.withOpacity(0.5)
                    : ds.colors.colorScheme.outline.withOpacity(0.3),
                width: isFocused ? 2 : (isRecommended ? 2 : 1),
              ),
              boxShadow: [
                if (model.isActive || isRecommended)
                  BoxShadow(
                    color: isRecommended
                        ? ds.colors.neuralPrimary.withOpacity(0.3)
                        : model.color.withOpacity(0.2),
                    blurRadius: isRecommended ? 15 : 12,
                    spreadRadius: isRecommended ? 2 : 1,
                  ),
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
                // 🎯 ENHANCED HEADER WITH INTELLIGENCE
                _buildIntelligentHeader(ds, isRecommended, isAnalyzing),

                const SizedBox(height: 12),

                // 🧠 ATHENA CONFIDENCE VISUALIZATION
                if (recommendation != null)
                  _buildConfidenceSection(ds, confidence, modelWeight),

                const SizedBox(height: 12),

                // 💚 HEALTH INDICATOR (EXISTING)
                _buildHealthIndicator(ds),

                const SizedBox(height: 12),

                // 📊 ENHANCED PERFORMANCE METRICS
                _buildEnhancedMetrics(ds),
              ],
            ),
          ),

          // 🧠 ATHENA RECOMMENDATION OVERLAY
          AthenaRecommendationOverlay(
            modelName: model.name,
            confidence: confidence,
            isRecommended: isRecommended,
            onTap: () {
              // Show detailed recommendation info
              _showRecommendationDetails(context, ref);
            },
          ),

          // ⚡ NEURAL PULSE ANIMATION
          if (isRecommended && recommendation != null)
            _buildNeuralPulseEffect(ds),
        ],
      ),
    );
  }

  /// 🎯 BUILD INTELLIGENT HEADER
  Widget _buildIntelligentHeader(DesignSystemData ds, bool isRecommended, bool isAnalyzing) {
    return Row(
      children: [
        // 🤖 MODEL ICON WITH INTELLIGENCE INDICATOR
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: model.color.withOpacity(isRecommended ? 0.3 : 0.2),
                borderRadius: BorderRadius.circular(8),
                boxShadow: isRecommended ? [
                  BoxShadow(
                    color: model.color.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ] : null,
              ),
              child: Icon(
                model.icon,
                color: model.color,
                size: 20,
              ),
            ),
            // 🧠 INTELLIGENCE INDICATOR
            if (isRecommended)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: ds.colors.neuralAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 8,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(width: 12),

        // 📊 MODEL NAME & ENHANCED STATUS
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
              Row(
                children: [
                  // 🔄 STATUS INDICATOR
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: model.isActive
                          ? (isRecommended
                          ? ds.colors.neuralAccent.withOpacity(0.2)
                          : ds.colors.connectionGreen.withOpacity(0.2))
                          : ds.colors.connectionRed.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isRecommended ? 'AI Recommended' : (model.isActive ? 'Active' : 'Inactive'),
                      style: ds.typography.caption.copyWith(
                        color: isRecommended
                            ? ds.colors.neuralAccent
                            : (model.isActive
                            ? ds.colors.connectionGreen
                            : ds.colors.connectionRed),
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),

                  // 🧠 ATHENA BRAIN ICON
                  if (isRecommended) ...[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.psychology,
                      color: ds.colors.neuralAccent,
                      size: 12,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // 🔄 TOGGLE SWITCH
        Transform.scale(
          scale: 0.8,
          child: Switch(
            value: model.isActive,
            onChanged: (_) => onToggle(),
            activeColor: isRecommended ? ds.colors.neuralAccent : model.color,
          ),
        ),
      ],
    );
  }

  /// 🧠 BUILD CONFIDENCE SECTION
  Widget _buildConfidenceSection(DesignSystemData ds, double confidence, double weight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Athena Confidence',
              style: ds.typography.caption.copyWith(
                color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(confidence * 100).round()}%',
              style: ds.typography.caption.copyWith(
                color: ds.colors.neuralAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ConfidenceVisualization(
          confidence: confidence,
          color: ds.colors.neuralPrimary,
        ),
        if (weight > 0) ...[
          const SizedBox(height: 6),
          Text(
            'Weight: ${(weight * 100).round()}%',
            style: ds.typography.caption.copyWith(
              color: ds.colors.colorScheme.onSurface.withOpacity(0.6),
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }

  /// 💚 BUILD HEALTH INDICATOR
  Widget _buildHealthIndicator(DesignSystemData ds) {
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
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: ds.colors.colorScheme.outline.withOpacity(0.2),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: model.health,
            child: Container(
              decoration: BoxDecoration(
                color: healthColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 📊 BUILD ENHANCED METRICS
  Widget _buildEnhancedMetrics(DesignSystemData ds) {
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

  /// ⚡ BUILD NEURAL PULSE EFFECT
  Widget _buildNeuralPulseEffect(DesignSystemData ds) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ds.colors.neuralAccent.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

  /// 📋 SHOW RECOMMENDATION DETAILS
  void _showRecommendationDetails(BuildContext context, WidgetRef ref) {
    final recommendation = ref.read(athenaCurrentRecommendationProvider);
    if (recommendation == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Athena Recommendation Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Model: ${model.name.toUpperCase()}'),
            const SizedBox(height: 8),
            Text('Confidence: ${(recommendation.modelConfidences[model.name]! * 100).round()}%'),
            const SizedBox(height: 8),
            Text('Weight: ${(recommendation.modelWeights[model.name]! * 100).round()}%'),
            const SizedBox(height: 8),
            const Text('Reasoning:'),
            const SizedBox(height: 4),
            Text(
              recommendation.reasoning,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// 🎨 UTILITY METHODS
  Color _getHealthColor(double health, DesignSystemData ds) {
    if (health >= 0.8) return ds.colors.connectionGreen;
    if (health >= 0.6) return ds.colors.tokenWarning;
    return ds.colors.tokenDanger;
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

/// 🧬 ENHANCED MODEL GRID WITH FULL ATHENA INTEGRATION
class EnhancedModelGridWithAthena extends ConsumerStatefulWidget {
  final List<AIModel> models;
  final ValueChanged<String> onModelToggle;
  final bool showDetailedMetrics;

  const EnhancedModelGridWithAthena({
    super.key,
    required this.models,
    required this.onModelToggle,
    this.showDetailedMetrics = false,
  });

  @override
  ConsumerState<EnhancedModelGridWithAthena> createState() => _EnhancedModelGridWithAthenaState();
}

class _EnhancedModelGridWithAthenaState extends ConsumerState<EnhancedModelGridWithAthena>
    with TickerProviderStateMixin {

  // 🎨 ANIMATION CONTROLLERS
  late AnimationController _athenaController;
  late Animation<double> _athenaAnimation;

  // 🎯 UI STATE
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
    _athenaController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _athenaAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _athenaController,
      curve: Curves.easeOutQuart,
    ));
  }

  void _setupKeyboardHandling() {
    _containerFocus.addListener(() {
      if (_containerFocus.hasFocus) {
        AccessibilityManager().announce(
          'Enhanced AI models grid with Athena Intelligence. ${widget.models.length} models available.',
        );
      }
    });
  }

  @override
  void dispose() {
    _athenaController.dispose();
    _containerFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final athenaController = ref.watch(athenaControllerProvider.notifier);
    final showDecisionTree = ref.watch(athenaShowDecisionTreeProvider);

    return Focus(
      focusNode: _containerFocus,
      onKeyEvent: _handleKeyEvent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🧠 ATHENA SUGGESTIONS PANEL
          Consumer(
            builder: (context, ref, child) {
              return AthenaSuggestionsPanel(
                onApplyRecommendations: () {
                  athenaController.applyRecommendations(force: true);
                },
                onToggleDecisionTree: () {
                  athenaController.toggleDecisionTree();
                },
              );
            },
          ),

          // 🎯 ENHANCED HEADER
          _buildEnhancedHeader(ds),

          const SizedBox(height: 20),

          // 💫 ENHANCED MODELS GRID/LIST
          Expanded(
            child: _isGridView
                ? _buildEnhancedGridView(ds)
                : _buildEnhancedListView(ds),
          ),

          // 🌳 DECISION TREE (if enabled)
          if (showDecisionTree)
            Container(
              margin: const EdgeInsets.only(top: 16),
              height: 300,
              child: const VisualDecisionTree(),
            ),
        ],
      ),
    );
  }

  /// 🎯 BUILD ENHANCED HEADER
  Widget _buildEnhancedHeader(DesignSystemData ds) {
    final activeModels = ref.watch(activeModelsProvider);
    final isActive = ref.watch(isOrchestrationActiveProvider);
    final athenaStatus = ref.watch(athenaStatusTextProvider);

    return Row(
      children: [
        // 🧠 ENHANCED ICON WITH ATHENA INDICATOR
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: isActive ? [
                  BoxShadow(
                    color: ds.colors.neuralPrimary.withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ] : null,
              ),
              child: Icon(
                Icons.smart_toy,
                color: isActive ? ds.colors.neuralPrimary : ds.colors.neuralSecondary,
                size: 24,
              ),
            ),
            // 🧠 ATHENA BRAIN OVERLAY
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: ds.colors.neuralAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 10,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(width: 12),

        // 📊 ENHANCED TITLE WITH ATHENA STATUS
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Models + Athena',
                style: ds.typography.h2.copyWith(
                  color: ds.colors.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                athenaStatus,
                style: ds.typography.caption.copyWith(
                  color: ds.colors.neuralAccent,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),

        // 🤖 AUTO-APPLY TOGGLE
        Consumer(
          builder: (context, ref, child) {
            final autoApplyEnabled = ref.watch(athenaAutoApplyEnabledProvider);
            final athenaController = ref.watch(athenaControllerProvider.notifier);

            return GestureDetector(
              onTap: () => athenaController.toggleAutoApply(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: autoApplyEnabled
                      ? ds.colors.neuralAccent.withOpacity(0.2)
                      : ds.colors.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: autoApplyEnabled
                        ? ds.colors.neuralAccent
                        : ds.colors.colorScheme.outline.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      autoApplyEnabled ? Icons.autorenew : Icons.touch_app,
                      color: autoApplyEnabled
                          ? ds.colors.neuralAccent
                          : ds.colors.colorScheme.onSurface,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      autoApplyEnabled ? 'Auto' : 'Manual',
                      style: ds.typography.caption.copyWith(
                        color: autoApplyEnabled
                            ? ds.colors.neuralAccent
                            : ds.colors.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(width: 12),

        // 🔄 VIEW TOGGLE
        _buildViewToggle(ds),
      ],
    );
  }

  /// 🔄 BUILD VIEW TOGGLE
  Widget _buildViewToggle(DesignSystemData ds) {
    return GestureDetector(
      onTap: _toggleViewMode,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: ds.colors.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: ds.colors.neuralPrimary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Icon(
          _isGridView ? Icons.view_list : Icons.grid_view,
          color: ds.colors.colorScheme.onSurface,
          size: 20,
        ),
      ),
    );
  }

  /// 🏗️ BUILD ENHANCED GRID VIEW
  Widget _buildEnhancedGridView(DesignSystemData ds) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0, // Adjusted for Athena information
      ),
      itemCount: widget.models.length,
      itemBuilder: (context, index) {
        return EnhancedModelCardWithAthena(
          model: widget.models[index],
          index: index,
          isFocused: index == _focusedModelIndex && _containerFocus.hasFocus,
          onToggle: () => widget.onModelToggle(widget.models[index].name),
        );
      },
    );
  }

  /// 📋 BUILD ENHANCED LIST VIEW
  Widget _buildEnhancedListView(DesignSystemData ds) {
    return ListView.builder(
      itemCount: widget.models.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: EnhancedModelCardWithAthena(
            model: widget.models[index],
            index: index,
            isFocused: index == _focusedModelIndex && _containerFocus.hasFocus,
            onToggle: () => widget.onModelToggle(widget.models[index].name),
          ),
        );
      },
    );
  }

  /// ⌨️ KEYBOARD NAVIGATION
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
        case LogicalKeyboardKey.keyA:
          ref.read(athenaControllerProvider.notifier).toggleAutoApply();
          return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _navigateModel(int direction) {
    setState(() {
      _focusedModelIndex = (_focusedModelIndex + direction) % widget.models.length;
      if (_focusedModelIndex < 0) _focusedModelIndex = widget.models.length - 1;
    });

    final model = widget.models[_focusedModelIndex];
    AccessibilityManager().announce(
      'Focused on ${model.name} model. ${model.isActive ? 'Active' : 'Inactive'}.',
    );

    HapticFeedback.selectionClick();
  }

  void _toggleCurrentModel() {
    final model = widget.models[_focusedModelIndex];
    widget.onModelToggle(model.name);
    HapticFeedback.mediumImpact();
  }

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });

    AccessibilityManager().announce(
      'Switched to ${_isGridView ? 'grid' : 'list'} view',
    );

    HapticFeedback.lightImpact();
  }
}