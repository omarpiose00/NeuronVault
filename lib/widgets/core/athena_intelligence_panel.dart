// 🧠 ATHENA INTELLIGENCE PANEL - AI AUTONOMY CONTROL CENTER
// lib/widgets/core/athena_intelligence_panel.dart
// Revolutionary AI orchestration intelligence - Neural luxury interface

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;

import '../../core/providers/providers_main.dart';
import '../../core/design_system.dart';
import '../../core/controllers/athena_controller.dart';
import '../../core/services/athena_intelligence_service.dart';
import 'visual_decision_tree.dart';

/// 🧠 Athena Intelligence Panel Widget
class AthenaIntelligencePanel extends ConsumerStatefulWidget {
  final bool isExpanded;
  final VoidCallback? onToggleExpanded;
  final VoidCallback? onShowDecisionTree;

  const AthenaIntelligencePanel({
    super.key,
    this.isExpanded = false,
    this.onToggleExpanded,
    this.onShowDecisionTree,
  });

  @override
  ConsumerState<AthenaIntelligencePanel> createState() => _AthenaIntelligencePanelState();
}

class _AthenaIntelligencePanelState extends ConsumerState<AthenaIntelligencePanel>
    with TickerProviderStateMixin {

  late AnimationController _animationController;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _expandAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2)
        .animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(_glowController);

    if (widget.isExpanded) {
      _animationController.forward();
    }

    _pulseController.repeat(reverse: true);
    _glowController.repeat();
  }

  @override
  void didUpdateWidget(AthenaIntelligencePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isExpanded != widget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final athenaState = ref.watch(athenaControllerProvider);

    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ds.colors.colorScheme.surfaceContainer.withOpacity(0.9),
                ds.colors.colorScheme.surfaceContainer.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getBorderColor(athenaState, ds),
              width: athenaState.isEnabled ? 2.0 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _getBorderColor(athenaState, ds).withOpacity(0.3),
                blurRadius: athenaState.isEnabled ? 20 : 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                children: [
                  _buildHeader(ds, athenaState),
                  if (widget.isExpanded) ...[
                    SizeTransition(
                      sizeFactor: _expandAnimation,
                      child: _buildExpandedContent(ds, athenaState),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getBorderColor(AthenaControllerState athenaState, DesignSystemData ds) {
    if (!athenaState.isEnabled) return ds.colors.colorScheme.outline;

    switch (athenaState.uiState) {
      case AthenaUIState.analyzing:
      case AthenaUIState.recommending:
        return ds.colors.neuralAccent;
      case AthenaUIState.ready:
        return ds.colors.connectionGreen;
      case AthenaUIState.applying:
        return ds.colors.neuralSecondary;
      case AthenaUIState.error:
        return ds.colors.connectionRed;
      default:
        return ds.colors.neuralPrimary;
    }
  }

  Widget _buildHeader(DesignSystemData ds, AthenaControllerState athenaState) {
    return GestureDetector(
      onTap: widget.onToggleExpanded,
      child: Container(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            // Athena Icon with Status
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: athenaState.isAnalyzing ? _pulseAnimation.value : 1.0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          _getBorderColor(athenaState, ds).withOpacity(0.3),
                          _getBorderColor(athenaState, ds).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.psychology,
                      color: _getBorderColor(athenaState, ds),
                      size: 20,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(width: 12),

            // Title and Status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Athena Intelligence',
                        style: ds.typography.h3.copyWith(
                          color: ds.colors.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusBadge(ds, athenaState),
                    ],
                  ),
                  Text(
                    _getStatusDescription(athenaState),
                    style: ds.typography.caption.copyWith(
                      color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Athena Toggle Switch
            _buildAthenaToggle(ds, athenaState),

            const SizedBox(width: 12),

            // Expand Arrow
            AnimatedRotation(
              turns: widget.isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(DesignSystemData ds, AthenaControllerState athenaState) {
    String text;
    Color color;

    switch (athenaState.uiState) {
      case AthenaUIState.disabled:
        text = 'OFF';
        color = ds.colors.colorScheme.outline;
        break;
      case AthenaUIState.idle:
        text = 'READY';
        color = ds.colors.neuralPrimary;
        break;
      case AthenaUIState.analyzing:
        text = 'ANALYZING';
        color = ds.colors.neuralAccent;
        break;
      case AthenaUIState.recommending:
        text = 'THINKING';
        color = ds.colors.neuralSecondary;
        break;
      case AthenaUIState.ready:
        text = 'READY';
        color = ds.colors.connectionGreen;
        break;
      case AthenaUIState.applying:
        text = 'APPLYING';
        color = ds.colors.neuralSecondary;
        break;
      case AthenaUIState.error:
        text = 'ERROR';
        color = ds.colors.connectionRed;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: ds.typography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 9,
        ),
      ),
    );
  }

  Widget _buildAthenaToggle(DesignSystemData ds, AthenaControllerState athenaState) {
    return GestureDetector(
      onTap: () => ref.read(athenaControllerProvider.notifier).toggleAthenaEnabled(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 50,
        height: 26,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: athenaState.isEnabled
                ? [ds.colors.neuralPrimary, ds.colors.neuralSecondary]
                : [ds.colors.colorScheme.outline, ds.colors.colorScheme.surfaceContainer],
          ),
          borderRadius: BorderRadius.circular(13),
          boxShadow: athenaState.isEnabled ? [
            BoxShadow(
              color: ds.colors.neuralPrimary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : [],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          alignment: athenaState.isEnabled ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              athenaState.isEnabled ? Icons.psychology : Icons.psychology_outlined,
              size: 12,
              color: athenaState.isEnabled ? ds.colors.neuralPrimary : ds.colors.colorScheme.outline,
            ),
          ),
        ),
      ),
    );
  }

  String _getStatusDescription(AthenaControllerState athenaState) {
    switch (athenaState.uiState) {
      case AthenaUIState.disabled:
        return 'AI autonomy disabled';
      case AthenaUIState.idle:
        return 'Monitoring for orchestration needs';
      case AthenaUIState.analyzing:
        return 'Analyzing prompt patterns...';
      case AthenaUIState.recommending:
        return 'Generating smart recommendations...';
      case AthenaUIState.ready:
        return 'Recommendations ready for review';
      case AthenaUIState.applying:
        return 'Applying AI recommendations...';
      case AthenaUIState.error:
        return athenaState.errorMessage ?? 'Error in AI analysis';
    }
  }

  Widget _buildExpandedContent(DesignSystemData ds, AthenaControllerState athenaState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: Column(
        children: [
          if (athenaState.isEnabled) ...[
            // Current Recommendation Section
            if (athenaState.hasRecommendation) ...[
              _buildRecommendationCard(ds, athenaState),
              const SizedBox(height: 16),
            ],

            // Quick Analytics
            _buildQuickAnalytics(ds, athenaState),

            const SizedBox(height: 16),

            // Action Buttons
            _buildActionButtons(ds, athenaState),

            const SizedBox(height: 16),

            // Auto-Apply Settings
            _buildAutoApplySettings(ds, athenaState),

            if (athenaState.hasError) ...[
              const SizedBox(height: 16),
              _buildErrorCard(ds, athenaState),
            ],
          ] else ...[
            _buildDisabledState(ds),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(DesignSystemData ds, AthenaControllerState athenaState) {
    final recommendation = athenaState.currentRecommendation!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ds.colors.connectionGreen.withOpacity(0.1),
            ds.colors.neuralSecondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ds.colors.connectionGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: ds.colors.connectionGreen,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Recommendation',
                style: ds.typography.h3.copyWith(
                  color: ds.colors.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _buildConfidenceIndicator(recommendation.overallConfidence, ds),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            'Category: ${recommendation.analysis.primaryCategory.name}',
            style: ds.typography.body2.copyWith(
              color: ds.colors.colorScheme.onSurface.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          if (recommendation.recommendedModels.isNotEmpty) ...[
            Text(
              'Suggested Models:',
              style: ds.typography.caption.copyWith(
                color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: recommendation.recommendedModels.map((model) =>
                  _buildModelChip(model, ds)
              ).toList(),
            ),
          ],

          if (recommendation.decision.reasoningSteps.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              recommendation.decision.reasoningSteps.join(' '),
              style: ds.typography.caption.copyWith(
                color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfidenceIndicator(double confidence, DesignSystemData ds) {
    final percentage = (confidence * 100).toInt();
    Color color;
    if (confidence >= 0.8) {
      color = ds.colors.connectionGreen;
    } else if (confidence >= 0.6) {
      color = ds.colors.tokenWarning;
    } else {
      color = ds.colors.connectionRed;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$percentage%',
        style: ds.typography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildModelChip(String model, DesignSystemData ds) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: ds.colors.neuralPrimary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        model.toUpperCase(),
        style: ds.typography.caption.copyWith(
          color: ds.colors.neuralPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 9,
        ),
      ),
    );
  }

  Widget _buildQuickAnalytics(DesignSystemData ds, AthenaControllerState athenaState) {
    final analytics = ref.read(athenaControllerProvider.notifier).getUsageInsights();

    return Row(
      children: [
        Expanded(child: _buildAnalyticCard(
          'Efficiency',
          '${analytics['efficiency_score'].toInt()}%',
          Icons.trending_up,
          ds.colors.neuralAccent,
          ds,
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildAnalyticCard(
          'Decisions',
          '${athenaState.recentDecisions.length}',
          Icons.psychology,
          ds.colors.neuralSecondary,
          ds,
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildAnalyticCard(
          'Confidence',
          '${(athenaState.averageConfidence * 100).toInt()}%',
          Icons.verified,
          ds.colors.connectionGreen,
          ds,
        )),
      ],
    );
  }

  Widget _buildAnalyticCard(String label, String value, IconData icon, Color color, DesignSystemData ds) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ds.colors.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: ds.typography.body2.copyWith(
              color: ds.colors.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: ds.typography.caption.copyWith(
              color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(DesignSystemData ds, AthenaControllerState athenaState) {
    return Column(
      children: [
        // Apply Recommendation Button
        if (athenaState.canApplyRecommendation) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => ref.read(athenaControllerProvider.notifier).applyRecommendation(),
              style: ElevatedButton.styleFrom(
                backgroundColor: ds.colors.connectionGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_fix_high, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Apply Intelligence',
                    style: ds.typography.button.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Action Buttons Row
        Row(
          children: [
            // Decision Tree Button
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onShowDecisionTree,
                style: OutlinedButton.styleFrom(
                  foregroundColor: ds.colors.neuralPrimary,
                  side: BorderSide(color: ds.colors.neuralPrimary.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_tree, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Decision Tree',
                      style: ds.typography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Clear History Button
            Expanded(
              child: OutlinedButton(
                onPressed: () => ref.read(athenaControllerProvider.notifier).clearHistory(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ds.colors.colorScheme.onSurface.withOpacity(0.7),
                  side: BorderSide(color: ds.colors.colorScheme.outline.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.clear_all, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Clear History',
                      style: ds.typography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAutoApplySettings(DesignSystemData ds, AthenaControllerState athenaState) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ds.colors.colorScheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ds.colors.neuralPrimary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_mode,
                color: ds.colors.neuralPrimary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Auto-Apply Settings',
                style: ds.typography.body2.copyWith(
                  color: ds.colors.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Switch(
                value: athenaState.autoApplyEnabled,
                onChanged: (value) => ref.read(athenaControllerProvider.notifier).configureAutoApply(enabled: value),
                activeColor: ds.colors.neuralPrimary,
              ),
            ],
          ),

          if (athenaState.autoApplyEnabled) ...[
            const SizedBox(height: 12),
            Text(
              'Confidence Threshold: ${(athenaState.autoApplyThreshold * 100).toInt()}%',
              style: ds.typography.caption.copyWith(
                color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                activeTrackColor: ds.colors.neuralPrimary,
                inactiveTrackColor: ds.colors.colorScheme.outline.withOpacity(0.3),
                thumbColor: ds.colors.neuralPrimary,
              ),
              child: Slider(
                value: athenaState.autoApplyThreshold,
                min: 0.5,
                max: 1.0,
                divisions: 10,
                onChanged: (value) => ref.read(athenaControllerProvider.notifier).configureAutoApply(threshold: value),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorCard(DesignSystemData ds, AthenaControllerState athenaState) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ds.colors.connectionRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ds.colors.connectionRed.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: ds.colors.connectionRed,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Error in AI Analysis',
                style: ds.typography.body2.copyWith(
                  color: ds.colors.connectionRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (athenaState.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              athenaState.errorMessage!,
              style: ds.typography.caption.copyWith(
                color: ds.colors.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => ref.read(athenaControllerProvider.notifier).retryFromError(),
              style: OutlinedButton.styleFrom(
                foregroundColor: ds.colors.connectionRed,
                side: BorderSide(color: ds.colors.connectionRed),
              ),
              child: Text('Retry Analysis'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledState(DesignSystemData ds) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.psychology_outlined,
            color: ds.colors.colorScheme.onSurface.withOpacity(0.4),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Athena Intelligence Disabled',
            style: ds.typography.h3.copyWith(
              color: ds.colors.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enable Athena to get AI-powered orchestration recommendations and autonomous model selection.',
            textAlign: TextAlign.center,
            style: ds.typography.body2.copyWith(
              color: ds.colors.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(athenaControllerProvider.notifier).toggleAthenaEnabled(),
            style: ElevatedButton.styleFrom(
              backgroundColor: ds.colors.neuralPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.psychology, size: 18),
                const SizedBox(width: 8),
                Text('Enable Athena'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}