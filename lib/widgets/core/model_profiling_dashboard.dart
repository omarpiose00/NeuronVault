// 🧠 MODEL PROFILING DASHBOARD - AI TRANSPARENCY SUPREME
// lib/widgets/core/model_profiling_dashboard.dart
// Revolutionary AI model analysis and performance visualization

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;

import '../../core/providers/providers_main.dart';
import '../../core/design_system.dart';

/// 🌟 Model Profiling Dashboard Widget
class ModelProfilingDashboard extends ConsumerStatefulWidget {
  final bool isExpanded;
  final VoidCallback? onToggleExpanded;

  const ModelProfilingDashboard({
    super.key,
    this.isExpanded = false,
    this.onToggleExpanded,
  });

  @override
  ConsumerState<ModelProfilingDashboard> createState() => _ModelProfilingDashboardState();
}

class _ModelProfilingDashboardState extends ConsumerState<ModelProfilingDashboard>
    with TickerProviderStateMixin {

  late AnimationController _animationController;
  late AnimationController _heatmapController;
  late Animation<double> _expandAnimation;
  late Animation<double> _heatmapAnimation;

  // Model performance data
  final Map<String, ModelProfile> _modelProfiles = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateModelProfiles();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _heatmapController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _heatmapAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(_heatmapController);

    if (widget.isExpanded) {
      _animationController.forward();
    }

    _heatmapController.repeat();
  }

  void _generateModelProfiles() {
    // Claude Profile
    _modelProfiles['claude'] = ModelProfile(
      modelId: 'claude',
      modelName: 'Claude',
      specializations: {
        'reasoning': 0.95,
        'creativity': 0.88,
        'coding': 0.85,
        'analysis': 0.92,
        'writing': 0.90,
        'math': 0.78,
        'conversation': 0.93,
        'safety': 0.98,
      },
      performance: ModelPerformance(
        averageResponseTime: 1.2,
        successRate: 0.96,
        reliabilityScore: 0.94,
        costEfficiency: 0.85,
        totalRequests: 1247,
        averageTokens: 380,
      ),
      color: const Color(0xFFFF6B35),
      icon: Icons.psychology,
    );

    // GPT-4 Profile
    _modelProfiles['gpt'] = ModelProfile(
      modelId: 'gpt',
      modelName: 'GPT-4',
      specializations: {
        'reasoning': 0.91,
        'creativity': 0.85,
        'coding': 0.89,
        'analysis': 0.87,
        'writing': 0.86,
        'math': 0.88,
        'conversation': 0.84,
        'safety': 0.82,
      },
      performance: ModelPerformance(
        averageResponseTime: 1.8,
        successRate: 0.92,
        reliabilityScore: 0.90,
        costEfficiency: 0.75,
        totalRequests: 934,
        averageTokens: 420,
      ),
      color: const Color(0xFF10B981),
      icon: Icons.auto_awesome,
    );

    // Gemini Profile
    _modelProfiles['gemini'] = ModelProfile(
      modelId: 'gemini',
      modelName: 'Gemini',
      specializations: {
        'reasoning': 0.87,
        'creativity': 0.92,
        'coding': 0.82,
        'analysis': 0.89,
        'writing': 0.84,
        'math': 0.91,
        'conversation': 0.88,
        'safety': 0.86,
      },
      performance: ModelPerformance(
        averageResponseTime: 1.4,
        successRate: 0.89,
        reliabilityScore: 0.87,
        costEfficiency: 0.90,
        totalRequests: 756,
        averageTokens: 350,
      ),
      color: const Color(0xFFF59E0B),
      icon: Icons.diamond,
    );

    // DeepSeek Profile
    _modelProfiles['deepseek'] = ModelProfile(
      modelId: 'deepseek',
      modelName: 'DeepSeek',
      specializations: {
        'reasoning': 0.89,
        'creativity': 0.75,
        'coding': 0.94,
        'analysis': 0.90,
        'writing': 0.77,
        'math': 0.93,
        'conversation': 0.79,
        'safety': 0.88,
      },
      performance: ModelPerformance(
        averageResponseTime: 0.9,
        successRate: 0.94,
        reliabilityScore: 0.91,
        costEfficiency: 0.95,
        totalRequests: 543,
        averageTokens: 290,
      ),
      color: const Color(0xFF8B5CF6),
      icon: Icons.explore,
    );
  }

  @override
  void didUpdateWidget(ModelProfilingDashboard oldWidget) {
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
    _heatmapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final activeModels = ref.watch(activeModelsProvider);

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
              color: ds.colors.neuralPrimary.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: ds.colors.neuralPrimary.withOpacity(0.2),
                blurRadius: 15,
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
                  _buildHeader(ds),
                  if (widget.isExpanded) ...[
                    SizeTransition(
                      sizeFactor: _expandAnimation,
                      child: _buildExpandedContent(ds, activeModels),
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

  Widget _buildHeader(DesignSystemData ds) {
    return GestureDetector(
      onTap: widget.onToggleExpanded,
      child: Container(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    ds.colors.neuralSecondary.withOpacity(0.3),
                    ds.colors.neuralSecondary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.analytics,
                color: ds.colors.neuralSecondary,
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Model Profiling',
                    style: ds.typography.h3.copyWith(
                      color: ds.colors.colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'AI Specialization Analysis',
                    style: ds.typography.caption.copyWith(
                      color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

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

  Widget _buildExpandedContent(DesignSystemData ds, List<String> activeModels) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: Column(
        children: [
          // Quick Stats Row
          _buildQuickStats(ds, activeModels),

          const SizedBox(height: 20),

          // Specialization Heatmap
          _buildSpecializationHeatmap(ds, activeModels),

          const SizedBox(height: 20),

          // Performance Comparison
          _buildPerformanceComparison(ds, activeModels),

          const SizedBox(height: 16),

          // Model Recommendations
          _buildModelRecommendations(ds),
        ],
      ),
    );
  }

  Widget _buildQuickStats(DesignSystemData ds, List<String> activeModels) {
    final activeProfiles = activeModels
        .where((id) => _modelProfiles.containsKey(id))
        .map((id) => _modelProfiles[id]!)
        .toList();

    if (activeProfiles.isEmpty) return const SizedBox.shrink();

    final avgResponseTime = activeProfiles
        .map((p) => p.performance.averageResponseTime)
        .reduce((a, b) => a + b) / activeProfiles.length;

    final avgSuccessRate = activeProfiles
        .map((p) => p.performance.successRate)
        .reduce((a, b) => a + b) / activeProfiles.length;

    final totalRequests = activeProfiles
        .map((p) => p.performance.totalRequests)
        .reduce((a, b) => a + b);

    return Row(
      children: [
        Expanded(child: _buildQuickStatCard(
          'Avg Response',
          '${avgResponseTime.toStringAsFixed(1)}s',
          Icons.timer,
          ds.colors.neuralAccent,
          ds,
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildQuickStatCard(
          'Success Rate',
          '${(avgSuccessRate * 100).toStringAsFixed(1)}%',
          Icons.check_circle,
          ds.colors.connectionGreen,
          ds,
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildQuickStatCard(
          'Total Requests',
          totalRequests.toString(),
          Icons.trending_up,
          ds.colors.neuralSecondary,
          ds,
        )),
      ],
    );
  }

  Widget _buildQuickStatCard(String label, String value, IconData icon, Color color, DesignSystemData ds) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ds.colors.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: ds.typography.h3.copyWith(
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

  Widget _buildSpecializationHeatmap(DesignSystemData ds, List<String> activeModels) {
    final specializations = ['reasoning', 'creativity', 'coding', 'analysis', 'writing', 'math', 'conversation', 'safety'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.grid_on,
              color: ds.colors.neuralPrimary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Specialization Heatmap',
              style: ds.typography.h3.copyWith(
                color: ds.colors.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Heatmap Grid
        AnimatedBuilder(
          animation: _heatmapAnimation,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ds.colors.colorScheme.surface.withOpacity(0.8),
                    ds.colors.colorScheme.surface.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: ds.colors.neuralPrimary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Header row with model names
                  Row(
                    children: [
                      const SizedBox(width: 80), // Space for specialty labels
                      ...activeModels.where((id) => _modelProfiles.containsKey(id)).map((modelId) {
                        final profile = _modelProfiles[modelId]!;
                        return Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              children: [
                                Icon(
                                  profile.icon,
                                  color: profile.color,
                                  size: 16,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  profile.modelName,
                                  style: ds.typography.caption.copyWith(
                                    color: ds.colors.colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Heatmap rows
                  ...specializations.map((spec) => _buildHeatmapRow(
                    spec,
                    activeModels.where((id) => _modelProfiles.containsKey(id)).toList(),
                    ds,
                  )),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeatmapRow(String specialization, List<String> activeModels, DesignSystemData ds) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          // Specialization label
          SizedBox(
            width: 80,
            child: Text(
              specialization.toUpperCase(),
              style: ds.typography.caption.copyWith(
                color: ds.colors.colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w600,
                fontSize: 9,
              ),
            ),
          ),

          // Heatmap cells
          ...activeModels.map((modelId) {
            final profile = _modelProfiles[modelId]!;
            final score = profile.specializations[specialization] ?? 0.0;

            return Expanded(
              child: Container(
                height: 24,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      profile.color.withOpacity(score * 0.8),
                      profile.color.withOpacity(score * 0.4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: profile.color.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    (score * 100).toInt().toString(),
                    style: ds.typography.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 8,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPerformanceComparison(DesignSystemData ds, List<String> activeModels) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.speed,
              color: ds.colors.neuralAccent,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Performance Metrics',
              style: ds.typography.h3.copyWith(
                color: ds.colors.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        ...activeModels.where((id) => _modelProfiles.containsKey(id)).map((modelId) {
          final profile = _modelProfiles[modelId]!;
          return _buildPerformanceBar(profile, ds);
        }),
      ],
    );
  }

  Widget _buildPerformanceBar(ModelProfile profile, DesignSystemData ds) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ds.colors.colorScheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: profile.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                profile.icon,
                color: profile.color,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                profile.modelName,
                style: ds.typography.body2.copyWith(
                  color: ds.colors.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: profile.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(profile.performance.reliabilityScore * 100).toInt()}% Reliable',
                  style: ds.typography.caption.copyWith(
                    color: profile.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              _buildMiniMetric('Speed', '${profile.performance.averageResponseTime}s', ds),
              _buildMiniMetric('Success', '${(profile.performance.successRate * 100).toInt()}%', ds),
              _buildMiniMetric('Cost', '${(profile.performance.costEfficiency * 100).toInt()}%', ds),
              _buildMiniMetric('Requests', '${profile.performance.totalRequests}', ds),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value, DesignSystemData ds) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: ds.typography.caption.copyWith(
              color: ds.colors.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          Text(
            label,
            style: ds.typography.caption.copyWith(
              color: ds.colors.colorScheme.onSurface.withOpacity(0.6),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelRecommendations(DesignSystemData ds) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: ds.colors.neuralPrimary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Recommendations',
                style: ds.typography.h3.copyWith(
                  color: ds.colors.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _buildRecommendation(
            'For complex reasoning tasks',
            'Claude excels with 95% reasoning score',
            Icons.psychology,
            ds.colors.neuralPrimary,
            ds,
          ),

          _buildRecommendation(
            'For fast coding solutions',
            'DeepSeek offers 94% coding + 0.9s response',
            Icons.code,
            ds.colors.neuralAccent,
            ds,
          ),

          _buildRecommendation(
            'For creative writing',
            'Gemini leads with 92% creativity score',
            Icons.create,
            ds.colors.neuralSecondary,
            ds,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendation(String title, String description, IconData icon, Color color, DesignSystemData ds) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ds.typography.caption.copyWith(
                    color: ds.colors.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
                Text(
                  description,
                  style: ds.typography.caption.copyWith(
                    color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 🧠 Model Profile Data Class
class ModelProfile {
  final String modelId;
  final String modelName;
  final Map<String, double> specializations;
  final ModelPerformance performance;
  final Color color;
  final IconData icon;

  ModelProfile({
    required this.modelId,
    required this.modelName,
    required this.specializations,
    required this.performance,
    required this.color,
    required this.icon,
  });
}

/// 📊 Model Performance Data Class
class ModelPerformance {
  final double averageResponseTime;
  final double successRate;
  final double reliabilityScore;
  final double costEfficiency;
  final int totalRequests;
  final int averageTokens;

  ModelPerformance({
    required this.averageResponseTime,
    required this.successRate,
    required this.reliabilityScore,
    required this.costEfficiency,
    required this.totalRequests,
    required this.averageTokens,
  });
}