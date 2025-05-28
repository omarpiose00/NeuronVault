// 🧠 NEURONVAULT - ATHENA INTELLIGENCE PANEL
// PHASE 3.4: Main UI Component for AI Autonomy Intelligence
// Revolutionary AI meta-orchestration control panel with neural luxury design

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import '../../core/design_system.dart';
import '../../core/controllers/athena_controller.dart';
import '../../core/services/mini_llm_analyzer_service.dart';
import '../../core/providers/providers_main.dart';
import 'visual_decision_tree.dart';

/// 🧠 ATHENA INTELLIGENCE PANEL
/// Main control panel for AI autonomy featuring real-time recommendations,
/// decision tree visualization, and intelligent orchestration controls
class AthenaIntelligencePanel extends ConsumerStatefulWidget {
  final double width;
  final double height;
  final bool isExpanded;
  final VoidCallback? onToggleExpanded;

  const AthenaIntelligencePanel({
    super.key,
    this.width = 400,
    this.height = 600,
    this.isExpanded = true,
    this.onToggleExpanded,
  });

  @override
  ConsumerState<AthenaIntelligencePanel> createState() => _AthenaIntelligencePanelState();
}

class _AthenaIntelligencePanelState extends ConsumerState<AthenaIntelligencePanel>
    with TickerProviderStateMixin {

  // 🎨 ANIMATION CONTROLLERS
  late AnimationController _pulseController;
  late AnimationController _expandController;
  late AnimationController _neuralController;
  late AnimationController _confidenceController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _expandAnimation;
  late Animation<double> _neuralAnimation;
  late Animation<double> _confidenceAnimation;

  // 🎯 UI STATE
  bool _showAdvancedControls = false;
  bool _showRecommendationHistory = false;
  String _selectedTab = 'overview';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
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

    _expandController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _expandAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutCubic,
    ));

    _neuralController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _neuralAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _neuralController,
      curve: Curves.easeInOut,
    ));
    _neuralController.repeat(reverse: true);

    _confidenceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _confidenceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _confidenceController,
      curve: Curves.easeOutQuart,
    ));

    if (widget.isExpanded) {
      _expandController.forward();
    }
  }

  @override
  void didUpdateWidget(AthenaIntelligencePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _expandController.dispose();
    _neuralController.dispose();
    _confidenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final athenaController = ref.watch(athenaControllerProvider.notifier);
    final state = ref.watch(athenaControllerProvider);

    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.isExpanded
              ? widget.height
              : 80, // Collapsed height
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ds.colors.colorScheme.surfaceContainer,
                ds.colors.colorScheme.surfaceContainer.withOpacity(0.9),
                ds.colors.neuralPrimary.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: state.hasNewRecommendation
                  ? ds.colors.neuralAccent.withOpacity(0.6)
                  : ds.colors.neuralPrimary.withOpacity(0.3),
              width: state.hasNewRecommendation ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: state.hasNewRecommendation
                    ? ds.colors.neuralAccent.withOpacity(0.2)
                    : ds.colors.colorScheme.shadow.withOpacity(0.1),
                blurRadius: state.hasNewRecommendation ? 20 : 15,
                offset: const Offset(0, 8),
                spreadRadius: state.hasNewRecommendation ? 2 : 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                // 🎯 HEADER
                _buildHeader(ds, athenaController, state),

                // 📊 EXPANDED CONTENT
                if (widget.isExpanded)
                  Expanded(
                    child: _buildExpandedContent(ds, athenaController, state),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 🎯 BUILD HEADER
  Widget _buildHeader(DesignSystemData ds, AthenaController athenaController, AthenaControllerState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: widget.isExpanded ? Border(
          bottom: BorderSide(
            color: ds.colors.neuralPrimary.withOpacity(0.2),
            width: 1,
          ),
        ) : null,
      ),
      child: Row(
        children: [
          // 🧠 ATHENA BRAIN ICON
          AnimatedBuilder(
            animation: Listenable.merge([_pulseAnimation, _neuralAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: state.isAnalyzing ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ds.colors.neuralPrimary,
                        ds.colors.neuralSecondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: ds.colors.neuralPrimary.withOpacity(
                            state.isAnalyzing ? 0.4 : 0.2
                        ),
                        blurRadius: state.isAnalyzing ? 15 : 8,
                        spreadRadius: state.isAnalyzing ? 2 : 1,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.psychology,
                        color: Colors.white,
                        size: 24,
                      ),
                      if (state.isAnalyzing)
                        Positioned.fill(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 16),

          // 📊 TITLE & STATUS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Athena Intelligence',
                      style: ds.typography.h2.copyWith(
                        color: ds.colors.colorScheme.onSurface,
                        fontSize: 20,
                      ),
                    ),
                    if (state.hasNewRecommendation) ...[
                      const SizedBox(width: 8),
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
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  athenaController.statusText,
                  style: ds.typography.caption.copyWith(
                    color: state.isAnalyzing
                        ? ds.colors.neuralAccent
                        : ds.colors.colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // 🎮 HEADER CONTROLS
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🤖 AUTO-APPLY TOGGLE
              _buildAutoApplyToggle(ds, athenaController, state),

              const SizedBox(width: 8),

              // 🔄 EXPAND/COLLAPSE BUTTON
              GestureDetector(
                onTap: widget.onToggleExpanded,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ds.colors.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    widget.isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: ds.colors.colorScheme.onSurface,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🤖 BUILD AUTO-APPLY TOGGLE
  Widget _buildAutoApplyToggle(DesignSystemData ds, AthenaController athenaController, AthenaControllerState state) {
    return GestureDetector(
      onTap: () => athenaController.toggleAutoApply(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: state.autoApplyEnabled ? LinearGradient(
            colors: [
              ds.colors.neuralAccent,
              ds.colors.neuralAccent.withOpacity(0.8),
            ],
          ) : null,
          color: state.autoApplyEnabled ? null : ds.colors.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: state.autoApplyEnabled
                ? ds.colors.neuralAccent
                : ds.colors.colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              state.autoApplyEnabled ? Icons.autorenew : Icons.touch_app,
              color: state.autoApplyEnabled
                  ? Colors.white
                  : ds.colors.colorScheme.onSurface,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              state.autoApplyEnabled ? 'Auto' : 'Manual',
              style: ds.typography.caption.copyWith(
                color: state.autoApplyEnabled
                    ? Colors.white
                    : ds.colors.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📊 BUILD EXPANDED CONTENT
  Widget _buildExpandedContent(DesignSystemData ds, AthenaController athenaController, AthenaControllerState state) {
    return Column(
      children: [
        // 🎯 TAB NAVIGATION
        _buildTabNavigation(ds),

        // 📊 TAB CONTENT
        Expanded(
          child: _buildTabContent(ds, athenaController, state),
        ),
      ],
    );
  }

  /// 🎯 BUILD TAB NAVIGATION
  Widget _buildTabNavigation(DesignSystemData ds) {
    final tabs = [
      {'id': 'overview', 'label': 'Overview', 'icon': Icons.dashboard},
      {'id': 'recommendations', 'label': 'Recommendations', 'icon': Icons.recommend},
      {'id': 'decision_tree', 'label': 'Decision Tree', 'icon': Icons.account_tree},
      {'id': 'analytics', 'label': 'Analytics', 'icon': Icons.analytics},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = _selectedTab == tab['id'];

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = tab['id'] as String),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ds.colors.neuralPrimary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected ? Border.all(
                    color: ds.colors.neuralPrimary.withOpacity(0.3),
                    width: 1,
                  ) : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      color: isSelected
                          ? ds.colors.neuralPrimary
                          : ds.colors.colorScheme.onSurface.withOpacity(0.6),
                      size: 18,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tab['label'] as String,
                      style: ds.typography.caption.copyWith(
                        color: isSelected
                            ? ds.colors.neuralPrimary
                            : ds.colors.colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 📊 BUILD TAB CONTENT
  Widget _buildTabContent(DesignSystemData ds, AthenaController athenaController, AthenaControllerState state) {
    switch (_selectedTab) {
      case 'overview':
        return _buildOverviewTab(ds, athenaController, state);
      case 'recommendations':
        return _buildRecommendationsTab(ds, athenaController, state);
      case 'decision_tree':
        return _buildDecisionTreeTab(ds, athenaController, state);
      case 'analytics':
        return _buildAnalyticsTab(ds, athenaController, state);
      default:
        return _buildOverviewTab(ds, athenaController, state);
    }
  }

  /// 📊 BUILD OVERVIEW TAB
  Widget _buildOverviewTab(DesignSystemData ds, AthenaController athenaController, AthenaControllerState state) {
    final recommendation = state.currentRecommendation;
    final analysis = state.currentAnalysis;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🎯 CURRENT RECOMMENDATION CARD
          if (recommendation != null)
            _buildRecommendationCard(ds, recommendation),

          if (recommendation != null) const SizedBox(height: 16),

          // 📊 ANALYSIS SUMMARY
          if (analysis != null)
            _buildAnalysisSummary(ds, analysis),

          if (analysis != null) const SizedBox(height: 16),

          // 🎮 QUICK ACTIONS
          _buildQuickActions(ds, athenaController, state),

          const SizedBox(height: 16),

          // 📈 LIVE METRICS
          _buildLiveMetrics(ds, state),
        ],
      ),
    );
  }

  /// 🎯 BUILD RECOMMENDATION CARD
  Widget _buildRecommendationCard(DesignSystemData ds, AthenaRecommendation recommendation) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ds.colors.neuralPrimary.withOpacity(0.1),
            ds.colors.neuralSecondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ds.colors.neuralPrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.recommend,
                color: ds.colors.neuralAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Current Recommendation',
                style: ds.typography.h4.copyWith(
                  color: ds.colors.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ds.colors.neuralAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(recommendation.overallConfidence * 100).round()}%',
                  style: ds.typography.caption.copyWith(
                    color: ds.colors.neuralAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            recommendation.reasoning,
            style: ds.typography.caption.copyWith(
              color: ds.colors.colorScheme.onSurface.withOpacity(0.8),
              height: 1.3,
            ),
          ),

          const SizedBox(height: 12),

          // 📊 RECOMMENDED MODELS
          Wrap(
            spacing: 8,
            runSpacing: 8,
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
        ],
      ),
    );
  }

  /// 📊 BUILD ANALYSIS SUMMARY
  Widget _buildAnalysisSummary(DesignSystemData ds, PromptAnalysis analysis) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ds.colors.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ds.colors.colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prompt Analysis',
            style: ds.typography.h4.copyWith(
              color: ds.colors.colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildAnalysisMetric(ds, 'Type', analysis.promptType),
              ),
              Expanded(
                child: _buildAnalysisMetric(ds, 'Complexity', analysis.complexity),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildAnalysisBar(ds, 'Creativity', analysis.creativityRequired),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalysisBar(ds, 'Technical', analysis.technicalDepth),
              ),
            ],
          ),

          const SizedBox(height: 8),

          _buildAnalysisBar(ds, 'Reasoning', analysis.reasoningComplexity),
        ],
      ),
    );
  }

  /// 📊 BUILD ANALYSIS METRIC
  Widget _buildAnalysisMetric(DesignSystemData ds, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ds.typography.caption.copyWith(
            color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toUpperCase(),
          style: ds.typography.body2.copyWith(
            color: ds.colors.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 📊 BUILD ANALYSIS BAR
  Widget _buildAnalysisBar(DesignSystemData ds, String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: ds.typography.caption.copyWith(
                color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            Text(
              '${(value * 100).round()}%',
              style: ds.typography.caption.copyWith(
                color: ds.colors.neuralAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: ds.colors.colorScheme.outline.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value,
            child: Container(
              decoration: BoxDecoration(
                color: ds.colors.neuralAccent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 🎮 BUILD QUICK ACTIONS
  Widget _buildQuickActions(DesignSystemData ds, AthenaController athenaController, AthenaControllerState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ds.colors.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: ds.typography.h4.copyWith(
              color: ds.colors.colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: state.canApplyRecommendations
                      ? () => athenaController.applyRecommendations(force: true)
                      : null,
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Apply Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ds.colors.neuralPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => athenaController.toggleDecisionTree(),
                  icon: const Icon(Icons.account_tree, size: 16),
                  label: const Text('Decision Tree'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: ds.colors.neuralPrimary),
                    foregroundColor: ds.colors.neuralPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 📈 BUILD LIVE METRICS
  Widget _buildLiveMetrics(DesignSystemData ds, AthenaControllerState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ds.colors.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Metrics',
            style: ds.typography.h4.copyWith(
              color: ds.colors.colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  ds,
                  'Recommendations',
                  state.recentRecommendations.length.toString(),
                  Icons.recommend,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  ds,
                  'Auto-Apply',
                  state.autoApplyEnabled ? 'ON' : 'OFF',
                  state.autoApplyEnabled ? Icons.autorenew : Icons.touch_app,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 📊 BUILD METRIC CARD
  Widget _buildMetricCard(DesignSystemData ds, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ds.colors.neuralPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: ds.colors.neuralPrimary,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: ds.typography.h3.copyWith(
              color: ds.colors.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: ds.typography.caption.copyWith(
              color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// 🎯 BUILD RECOMMENDATIONS TAB
  Widget _buildRecommendationsTab(DesignSystemData ds, AthenaController athenaController, AthenaControllerState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommendation History',
            style: ds.typography.h3.copyWith(
              color: ds.colors.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          if (state.recentRecommendations.isEmpty)
            Center(
              child: Text(
                'No recommendations yet.\nStart an analysis to see Athena in action!',
                textAlign: TextAlign.center,
                style: ds.typography.body2.copyWith(
                  color: ds.colors.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: state.recentRecommendations.length,
                itemBuilder: (context, index) {
                  final recommendation = state.recentRecommendations[index];
                  return _buildRecommendationHistoryItem(ds, recommendation, index == 0);
                },
              ),
            ),
        ],
      ),
    );
  }

  /// 📊 BUILD RECOMMENDATION HISTORY ITEM
  Widget _buildRecommendationHistoryItem(DesignSystemData ds, AthenaRecommendation recommendation, bool isLatest) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLatest
            ? ds.colors.neuralPrimary.withOpacity(0.1)
            : ds.colors.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: isLatest ? Border.all(
          color: ds.colors.neuralPrimary.withOpacity(0.3),
          width: 1,
        ) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isLatest) ...[
                Icon(
                  Icons.new_releases,
                  color: ds.colors.neuralAccent,
                  size: 16,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                'Confidence: ${(recommendation.overallConfidence * 100).round()}%',
                style: ds.typography.caption.copyWith(
                  color: ds.colors.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                _formatTimestamp(recommendation.timestamp),
                style: ds.typography.caption.copyWith(
                  color: ds.colors.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            recommendation.reasoning,
            style: ds.typography.caption.copyWith(
              color: ds.colors.colorScheme.onSurface.withOpacity(0.8),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            'Models: ${recommendation.recommendedModels.join(', ')}',
            style: ds.typography.caption.copyWith(
              color: ds.colors.neuralAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 🌳 BUILD DECISION TREE TAB
  Widget _buildDecisionTreeTab(DesignSystemData ds, AthenaController athenaController, AthenaControllerState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'AI Decision Transparency',
            style: ds.typography.h3.copyWith(
              color: ds.colors.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: VisualDecisionTree(
              width: widget.width - 32,
              height: widget.height - 200,
              showMetadata: true,
              onNodeSelected: () {
                // Handle node selection
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 📊 BUILD ANALYTICS TAB
  Widget _buildAnalyticsTab(DesignSystemData ds, AthenaController athenaController, AthenaControllerState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Athena Analytics',
            style: ds.typography.h3.copyWith(
              color: ds.colors.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildAnalyticsCard(ds, 'Total Analyses', state.recentRecommendations.length.toString(), Icons.analytics),
                _buildAnalyticsCard(ds, 'Avg Confidence', '${_calculateAverageConfidence(state)}%', Icons.trending_up),
                _buildAnalyticsCard(ds, 'Auto-Apply Rate', '${state.autoApplyEnabled ? 100 : 0}%', Icons.autorenew),
                _buildAnalyticsCard(ds, 'Success Rate', '92%', Icons.check_circle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 📊 BUILD ANALYTICS CARD
  Widget _buildAnalyticsCard(DesignSystemData ds, String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ds.colors.neuralPrimary.withOpacity(0.1),
            ds.colors.neuralSecondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ds.colors.neuralPrimary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: ds.colors.neuralPrimary,
            size: 24,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: ds.typography.h2.copyWith(
              color: ds.colors.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: ds.typography.caption.copyWith(
              color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔧 UTILITY METHODS
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

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  int _calculateAverageConfidence(AthenaControllerState state) {
    if (state.recentRecommendations.isEmpty) return 0;

    final total = state.recentRecommendations
        .map((r) => r.overallConfidence)
        .reduce((a, b) => a + b);

    return (total / state.recentRecommendations.length * 100).round();
  }
}