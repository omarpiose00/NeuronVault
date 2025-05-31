// lib/widgets/core/model_grid.dart - PHASE 3.4 ENHANCED
// 🧬 REVOLUTIONARY MODEL CARDS PROCESSING ENHANCEMENT
// Real-time processing indicators + Neural connection animations + Achievement integration + Athena AI

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system.dart';
import '../../core/accessibility/accessibility_manager.dart';
import '../../core/state/state_models.dart';
import '../../core/providers/providers_main.dart';
// 🧠 ATHENA AI AUTONOMY IMPORTS - PHASE 3.4
import '../../core/services/athena_intelligence_service.dart';
// For AIModel

/// 🧬 PROCESSING STATUS ENUM
enum ProcessingStatus {
  idle,
  analyzing,
  generating,
  synthesizing,
  completed,
  error,
}

/// 📊 PROCESSING STAGE DATA
class ProcessingStage {
  final ProcessingStatus status;
  final double progress;
  final int tokensUsed;
  final Duration elapsedTime;
  final String? errorMessage;

  const ProcessingStage({
    required this.status,
    required this.progress,
    required this.tokensUsed,
    required this.elapsedTime,
    this.errorMessage,
  });

  ProcessingStage copyWith({
    ProcessingStatus? status,
    double? progress,
    int? tokensUsed,
    Duration? elapsedTime,
    String? errorMessage,
  }) {
    return ProcessingStage(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      tokensUsed: tokensUsed ?? this.tokensUsed,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// 🤖 ENHANCED MODEL GRID - PHASE 3.4 REVOLUTIONARY
/// Real-time processing transparency + Neural connection animations + Athena AI
class ModelGrid extends ConsumerStatefulWidget {
  final List<AIModel> models;
  final ValueChanged<String> onModelToggle;
  final bool showDetailedMetrics;

  const ModelGrid({
    super.key,
    required this.models,
    required this.onModelToggle,
    this.showDetailedMetrics = false,
  });

  @override
  ConsumerState<ModelGrid> createState() => _ModelGridState();
}

class _ModelGridState extends ConsumerState<ModelGrid> with TickerProviderStateMixin {
  // 🎨 EXISTING ANIMATIONS
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _healthController;
  late Animation<double> _healthAnimation;

  // 🧬 NEW: PROCESSING ANIMATIONS
  late AnimationController _processController;
  late Animation<double> _processAnimation;
  late AnimationController _connectionController;
  late Animation<double> _connectionAnimation;
  late AnimationController _tokenController;
  late Animation<double> _tokenAnimation;

  // 📊 PROCESSING STATE
  final Map<String, ProcessingStage> _processingStages = {};
  final Map<String, int> _realtimeTokens = {};
  bool _isOrchestrationActive = false;

  // 🎯 UI STATE
  bool _isGridView = true;
  final FocusNode _containerFocus = FocusNode();
  int _focusedModelIndex = 0;

  // 🧠 ATHENA INTEGRATION - PHASE 3.4
  bool _athenaEnabled = false;
  AthenaRecommendation? _currentRecommendation;
  final Map<String, double> _athenaConfidenceScores = {};
  final Map<String, bool> _athenaRecommendedModels = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupKeyboardHandling();
    _initializeProcessingState();
    _listenToOrchestrationStreams();
  }

  void _initializeAnimations() {
    // 🎨 EXISTING ANIMATIONS
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

    // 🧬 NEW: PROCESSING ANIMATIONS
    _processController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _processAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _processController,
      curve: Curves.easeInOut,
    ));

    _connectionController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _connectionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _connectionController,
      curve: Curves.easeInOut,
    ));

    _tokenController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _tokenAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _tokenController,
      curve: Curves.elasticOut,
    ));
  }

  void _initializeProcessingState() {
    // Initialize processing stages for all models
    for (final model in widget.models) {
      _processingStages[model.name] = const ProcessingStage(
        status: ProcessingStatus.idle,
        progress: 0.0,
        tokensUsed: 0,
        elapsedTime: Duration.zero,
      );
      _realtimeTokens[model.name] = model.tokensUsed;
    }
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

  // 🧬 LISTEN TO ORCHESTRATION STREAMS
  void _listenToOrchestrationStreams() {
    // 📊 Listen to orchestration activity
    ref.listen<bool>(isOrchestrationActiveProvider, (previous, next) {
      if (mounted) {
        setState(() {
          _isOrchestrationActive = next;
        });

        if (next) {
          _startProcessingAnimations();
          _trackAchievementOrchestrationStart();
        } else {
          _stopProcessingAnimations();
        }
      }
    });

    // 📥 Listen to individual responses
    ref.listen(individualResponsesProvider, (previous, next) {
      next.whenData((responses) {
        if (mounted) {
          _updateProcessingStages(responses);
        }
      });
    });

    // ✨ Listen to synthesis completion
    ref.listen(synthesizedResponseProvider, (previous, next) {
      next.whenData((synthesis) {
        if (mounted && synthesis.isNotEmpty) {
          _handleSynthesisComplete();
        }
      });
    });

    // 🧠 ATHENA STREAMS - PHASE 3.4
    ref.listen<bool>(athenaEnabledProvider, (previous, next) {
      if (mounted) {
        setState(() {
          _athenaEnabled = next;
        });
      }
    });

    ref.listen(athenaCurrentRecommendationProvider, (previous, next) {
      if (mounted && next != null) {
        setState(() {
          _currentRecommendation = next;
          _updateAthenaRecommendations(next);
        });
      }
    });
  }

  // 🚀 START PROCESSING ANIMATIONS
  void _startProcessingAnimations() {
    final activeModels = ref.read(activeModelsProvider);

    // Start processing for active models
    for (final modelName in activeModels) {
      _processingStages[modelName] = _processingStages[modelName]!.copyWith(
        status: ProcessingStatus.analyzing,
        progress: 0.0,
      );
    }

    // Start animations
    _processController.repeat();
    _connectionController.repeat();

    // Simulate progressive processing stages
    _simulateProcessingProgression(activeModels);
  }

  // 🛑 STOP PROCESSING ANIMATIONS
  void _stopProcessingAnimations() {
    _processController.stop();
    _connectionController.stop();

    // Reset all processing states
    for (final modelName in _processingStages.keys) {
      _processingStages[modelName] = _processingStages[modelName]!.copyWith(
        status: ProcessingStatus.idle,
        progress: 0.0,
      );
    }
    setState(() {});
  }

  // 📊 UPDATE PROCESSING STAGES
  void _updateProcessingStages(List<dynamic> responses) {
    for (final response in responses) {
      final modelName = response.modelName as String;

      if (_processingStages.containsKey(modelName)) {
        _processingStages[modelName] = _processingStages[modelName]!.copyWith(
          status: ProcessingStatus.completed,
          progress: 1.0,
          tokensUsed: _realtimeTokens[modelName]! + 50, // Simulate token usage
        );

        // Animate token counter
        _realtimeTokens[modelName] = _realtimeTokens[modelName]! + 50;
        _tokenController.forward().then((_) => _tokenController.reset());

        // Track achievement
        _trackAchievementModelUsage(modelName);
      }
    }
    setState(() {});
  }

  // ✨ HANDLE SYNTHESIS COMPLETE
  void _handleSynthesisComplete() {
    // Mark all active models as completed synthesis
    final activeModels = ref.read(activeModelsProvider);

    for (final modelName in activeModels) {
      if (_processingStages.containsKey(modelName)) {
        _processingStages[modelName] = _processingStages[modelName]!.copyWith(
          status: ProcessingStatus.completed,
          progress: 1.0,
        );
      }
    }

    // Track achievement for synthesis completion
    _trackAchievementSynthesisComplete();

    setState(() {});
  }

  // 🎯 SIMULATE PROCESSING PROGRESSION
  void _simulateProcessingProgression(List<String> activeModels) async {
    if (!_isOrchestrationActive) return;

    // Analyzing phase (0-30%)
    await Future.delayed(const Duration(milliseconds: 500));
    if (!_isOrchestrationActive || !mounted) return;

    for (final modelName in activeModels) {
      _processingStages[modelName] = _processingStages[modelName]!.copyWith(
        status: ProcessingStatus.analyzing,
        progress: 0.3,
      );
    }
    setState(() {});

    // Generating phase (30-80%)
    await Future.delayed(const Duration(milliseconds: 800));
    if (!_isOrchestrationActive || !mounted) return;

    for (final modelName in activeModels) {
      _processingStages[modelName] = _processingStages[modelName]!.copyWith(
        status: ProcessingStatus.generating,
        progress: 0.8,
      );
    }
    setState(() {});

    // Synthesizing phase (80-100%)
    await Future.delayed(const Duration(milliseconds: 600));
    if (!_isOrchestrationActive || !mounted) return;

    for (final modelName in activeModels) {
      _processingStages[modelName] = _processingStages[modelName]!.copyWith(
        status: ProcessingStatus.synthesizing,
        progress: 1.0,
      );
    }
    setState(() {});
  }

  // 🏆 ACHIEVEMENT TRACKING
  void _trackAchievementOrchestrationStart() {
    try {
      final tracker = ref.read(achievementTrackerProvider);
      tracker.trackOrchestration(
        ref.read(activeModelsProvider),
        ref.read(currentStrategyProvider),
      );
    } catch (e) {
      debugPrint('⚠️ Achievement tracking error: $e');
    }
  }

  void _trackAchievementModelUsage(String modelName) {
    try {
      final tracker = ref.read(achievementTrackerProvider);
      tracker.trackFeatureUsage('model_$modelName');
    } catch (e) {
      debugPrint('⚠️ Achievement tracking error: $e');
    }
  }

  void _trackAchievementSynthesisComplete() {
    try {
      final tracker = ref.read(achievementTrackerProvider);
      tracker.trackFeatureUsage('synthesis_complete');
    } catch (e) {
      debugPrint('⚠️ Achievement tracking error: $e');
    }
  }

  // 🧠 ATHENA RECOMMENDATION HANDLING - PHASE 3.4
  void _updateAthenaRecommendations(AthenaRecommendation recommendation) {
    // Update confidence scores and recommendations
    _athenaConfidenceScores.clear();
    _athenaRecommendedModels.clear();

    for (final model in recommendation.recommendedModels) {
      _athenaRecommendedModels[model] = true;
      _athenaConfidenceScores[model] = recommendation.modelWeights[model] ?? 0.5;
    }

    // Track achievement for Athena usage
    _trackAchievementAthenaUsage();
  }

  void _trackAchievementAthenaUsage() {
    try {
      final tracker = ref.read(achievementTrackerProvider);
      tracker.trackFeatureUsage('athena_recommendations');
    } catch (e) {
      debugPrint('⚠️ Achievement tracking error: $e');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _healthController.dispose();
    _processController.dispose();
    _connectionController.dispose();
    _tokenController.dispose();
    _containerFocus.dispose();
    super.dispose();
  }

  // ⌨️ KEYBOARD NAVIGATION (EXISTING)
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

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    return Focus(
      focusNode: _containerFocus,
      onKeyEvent: _handleKeyEvent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🎯 ENHANCED HEADER
          _buildEnhancedHeader(ds),

          const SizedBox(height: 20),

          // 💫 NEURAL CONNECTION OVERLAY + 🧬 ENHANCED MODELS GRID/LIST
          // Wrapped Grid/List and Overlay in a Stack for correct positioning
          Expanded(
            child: Stack(
              children: [
                _isGridView
                    ? _buildEnhancedGridView(ds)
                    : _buildEnhancedListView(ds),
                if (_isOrchestrationActive && _isGridView)
                  _buildNeuralConnectionOverlay(ds),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🎯 BUILD ENHANCED HEADER
  Widget _buildEnhancedHeader(DesignSystemData ds) {
    final activeModels = ref.watch(activeModelsProvider);
    final isActive = ref.watch(isOrchestrationActiveProvider);

    return Row(
      children: [
        // 🤖 ICON WITH ORCHESTRATION PULSE
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

        const SizedBox(width: 12),

        // 📊 TITLE WITH LIVE STATUS
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Models',
              style: ds.typography.h2.copyWith(
                color: ds.colors.colorScheme.onSurface,
              ),
            ),
            if (isActive) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    'ORCHESTRATING • ${activeModels.length} models active',
                    style: ds.typography.caption.copyWith(
                      color: ds.colors.neuralAccent,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                  // 🧠 ATHENA STATUS BADGE
                  if (_athenaEnabled && _currentRecommendation != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ds.colors.neuralAccent.withOpacity(0.2),
                            ds.colors.neuralPrimary.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: ds.colors.neuralAccent.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.psychology,
                            color: ds.colors.neuralAccent,
                            size: 10,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'AI RECOMMENDATIONS ACTIVE',
                            style: ds.typography.caption.copyWith(
                              color: ds.colors.neuralAccent,
                              fontWeight: FontWeight.w700,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),

        const Spacer(),

        // 🏆 LIVE PROCESSING METRICS
        if (isActive)
          _buildLiveProcessingMetrics(ds),

        const SizedBox(width: 16),

        // 🔄 VIEW TOGGLE
        _buildViewToggle(ds),
      ],
    );
  }

  // 📊 BUILD LIVE PROCESSING METRICS
  Widget _buildLiveProcessingMetrics(DesignSystemData ds) {
    final totalTokens = _realtimeTokens.values.fold(0, (sum, tokens) => sum + tokens);
    final activeCount = _processingStages.values
        .where((stage) => stage.status != ProcessingStatus.idle)
        .length;
    final recCount = _athenaRecommendedModels.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ds.colors.neuralPrimary.withOpacity(0.2),
            ds.colors.neuralSecondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ds.colors.neuralPrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.flash_on,
            color: ds.colors.neuralAccent,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            '$activeCount processing${_athenaEnabled && recCount > 0 ? ' • $recCount recs' : ''} • ${_formatNumber(totalTokens)} tokens',
            style: ds.typography.caption.copyWith(
              color: ds.colors.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // 🔄 BUILD VIEW TOGGLE
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

  // 💫 BUILD NEURAL CONNECTION OVERLAY
  Widget _buildNeuralConnectionOverlay(DesignSystemData ds) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _connectionAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: NeuralConnectionPainter(
              animation: _connectionAnimation.value,
              activeModels: ref.watch(activeModelsProvider),
              neuralColor: ds.colors.neuralPrimary,
              isActive: _isOrchestrationActive,
            ),
          );
        },
      ),
    );
  }

  // 🏗️ BUILD ENHANCED GRID VIEW
  Widget _buildEnhancedGridView(DesignSystemData ds) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1, // Slightly taller for processing indicators
      ),
      itemCount: widget.models.length,
      itemBuilder: (context, index) {
        return _buildEnhancedModelCard(widget.models[index], index, ds);
      },
    );
  }

  // 📋 BUILD ENHANCED LIST VIEW
  Widget _buildEnhancedListView(DesignSystemData ds) {
    return ListView.builder(
      itemCount: widget.models.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildEnhancedModelCard(widget.models[index], index, ds),
        );
      },
    );
  }

  // 🧬 BUILD ENHANCED MODEL CARD
  Widget _buildEnhancedModelCard(AIModel model, int index, DesignSystemData ds) {
    final isFocused = index == _focusedModelIndex && _containerFocus.hasFocus;
    final processingStage = _processingStages[model.name] ?? const ProcessingStage(
      status: ProcessingStatus.idle,
      progress: 0.0,
      tokensUsed: 0,
      elapsedTime: Duration.zero,
    );
    final realtimeTokens = _realtimeTokens[model.name] ?? model.tokensUsed;
    final isProcessing = processingStage.status != ProcessingStatus.idle;
    final isAthenaRecommended = _athenaEnabled &&
        _athenaRecommendedModels[model.name] == true;

    return GestureDetector(
      onTap: () => widget.onModelToggle(model.name),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _pulseAnimation,
          _healthAnimation,
          _processAnimation,
          _tokenAnimation,
        ]),
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: model.isActive
                  ? LinearGradient(
                colors: [
                  model.color.withOpacity(isProcessing ? 0.3 : 0.2),
                  model.color.withOpacity(isProcessing ? 0.2 : 0.1),
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
                    ? model.color.withOpacity(isProcessing ? 0.8 : 0.5)
                    : ds.colors.colorScheme.outline.withOpacity(0.3),
                width: isFocused ? 2 : 1,
              ),
              boxShadow: model.isActive
                  ? [
                BoxShadow(
                  color: model.color.withOpacity(
                      isProcessing
                          ? _processAnimation.value * 0.5
                          : _pulseAnimation.value * 0.3
                  ),
                  blurRadius: isProcessing ? 20 : 12,
                  spreadRadius: isProcessing ? 3 : 1,
                ),
                // 🧠 Athena glow effect
                if (isAthenaRecommended)
                  BoxShadow(
                    color: ds.colors.neuralAccent.withOpacity(0.4),
                    blurRadius: 20,
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
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🎯 ENHANCED HEADER ROW
                    _buildEnhancedHeaderRow(model, ds, isProcessing),

                    const SizedBox(height: 12),

                    // 🧬 PROCESSING STATUS INDICATOR
                    if (isProcessing)
                      _buildProcessingStatusIndicator(processingStage, ds),

                    const SizedBox(height: 12),

                    // 💚 HEALTH INDICATOR (EXISTING)
                    _buildHealthIndicator(model, ds),

                    const SizedBox(height: 12),

                    // 📊 ENHANCED PERFORMANCE METRICS
                    _buildEnhancedPerformanceMetrics(model, realtimeTokens, ds),
                  ],
                ),

                // 🧠 ATHENA RECOMMENDATION OVERLAY
                if (isAthenaRecommended)
                  _buildAthenaRecommendationOverlay(model, ds),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🎯 BUILD ENHANCED HEADER ROW
  Widget _buildEnhancedHeaderRow(AIModel model, DesignSystemData ds, bool isProcessing) {
    return Row(
      children: [
        // 🤖 MODEL ICON WITH PROCESSING PULSE
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: model.color.withOpacity(isProcessing ? 0.3 : 0.2),
            borderRadius: BorderRadius.circular(8),
            boxShadow: isProcessing ? [
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
                          ? (isProcessing
                          ? ds.colors.neuralAccent.withOpacity(0.2)
                          : ds.colors.connectionGreen.withOpacity(0.2))
                          : ds.colors.connectionRed.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isProcessing ? 'Processing' : (model.isActive ? 'Active' : 'Inactive'),
                      style: ds.typography.caption.copyWith(
                        color: isProcessing
                            ? ds.colors.neuralAccent
                            : (model.isActive
                            ? ds.colors.connectionGreen
                            : ds.colors.connectionRed),
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),

                  // 🔥 PROCESSING FIRE ICON
                  if (isProcessing) ...[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.flash_on,
                      color: ds.colors.neuralAccent,
                      size: 12,
                    ),
                  ],

                  // 🧠 ATHENA RECOMMENDED BADGE
                  if (_athenaEnabled && _athenaRecommendedModels[model.name] == true) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ds.colors.neuralAccent.withOpacity(0.3),
                            ds.colors.neuralPrimary.withOpacity(0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: ds.colors.neuralAccent,
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.psychology,
                            size: 10,
                            color: ds.colors.neuralAccent,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'AI RECOMMENDED',
                            style: ds.typography.caption.copyWith(
                              color: ds.colors.neuralAccent,
                              fontWeight: FontWeight.w700,
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
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
            onChanged: (_) => widget.onModelToggle(model.name),
            activeColor: model.color,
          ),
        ),
      ],
    );
  }

  // 🧬 BUILD PROCESSING STATUS INDICATOR
  Widget _buildProcessingStatusIndicator(ProcessingStage stage, DesignSystemData ds) {
    final statusText = _getProcessingStatusText(stage.status);
    final statusColor = _getProcessingStatusColor(stage.status, ds);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 📊 STATUS TEXT
        Row(
          children: [
            Icon(
              _getProcessingStatusIcon(stage.status),
              color: statusColor,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              statusText,
              style: ds.typography.caption.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
            const Spacer(),
            Text(
              '${(stage.progress * 100).round()}%',
              style: ds.typography.caption.copyWith(
                color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // 📈 PROGRESS BAR
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: ds.colors.colorScheme.outline.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: AnimatedBuilder(
            animation: _processAnimation,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: stage.progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        statusColor,
                        statusColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 💚 BUILD HEALTH INDICATOR (EXISTING - Enhanced)
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

        // 📊 HEALTH PROGRESS BAR
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

  // 📊 BUILD ENHANCED PERFORMANCE METRICS
  Widget _buildEnhancedPerformanceMetrics(AIModel model, int realtimeTokens, DesignSystemData ds) {
    return Row(
      children: [
        // 🔢 ANIMATED TOKEN COUNTER
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
              AnimatedBuilder(
                animation: _tokenAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_tokenAnimation.value * 0.1),
                    child: Text(
                      _formatNumber(realtimeTokens),
                      style: ds.typography.body2.copyWith(
                        color: ds.colors.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // ⏱️ RESPONSE TIME
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

  // 🧠 BUILD ATHENA RECOMMENDATION OVERLAY
  Widget _buildAthenaRecommendationOverlay(AIModel model, DesignSystemData ds) {
    final confidence = _athenaConfidenceScores[model.name] ?? 0.5;

    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ds.colors.neuralAccent.withOpacity(0.9),
              ds.colors.neuralPrimary.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: ds.colors.neuralAccent.withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.psychology,
              color: Colors.white,
              size: 12,
            ),
            const SizedBox(width: 4),
            Text(
              '${(confidence * 100).round()}%',
              style: ds.typography.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🎨 UTILITY METHODS
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

  // 🧬 PROCESSING STATUS UTILITIES
  String _getProcessingStatusText(ProcessingStatus status) {
    switch (status) {
      case ProcessingStatus.idle:
        return 'Idle';
      case ProcessingStatus.analyzing:
        return 'Analyzing';
      case ProcessingStatus.generating:
        return 'Generating';
      case ProcessingStatus.synthesizing:
        return 'Synthesizing';
      case ProcessingStatus.completed:
        return 'Completed';
      case ProcessingStatus.error:
        return 'Error';
    }
  }

  Color _getProcessingStatusColor(ProcessingStatus status, DesignSystemData ds) {
    switch (status) {
      case ProcessingStatus.idle:
        return ds.colors.colorScheme.onSurface.withOpacity(0.5);
      case ProcessingStatus.analyzing:
        return ds.colors.neuralPrimary;
      case ProcessingStatus.generating:
        return ds.colors.neuralSecondary;
      case ProcessingStatus.synthesizing:
        return ds.colors.neuralAccent;
      case ProcessingStatus.completed:
        return ds.colors.connectionGreen;
      case ProcessingStatus.error:
        return ds.colors.connectionRed;
    }
  }

  IconData _getProcessingStatusIcon(ProcessingStatus status) {
    switch (status) {
      case ProcessingStatus.idle:
        return Icons.circle_outlined;
      case ProcessingStatus.analyzing:
        return Icons.search;
      case ProcessingStatus.generating:
        return Icons.auto_awesome;
      case ProcessingStatus.synthesizing:
        return Icons.merge_type;
      case ProcessingStatus.completed:
        return Icons.check_circle;
      case ProcessingStatus.error:
        return Icons.error;
    }
  }
}

/// 💫 NEURAL CONNECTION PAINTER
/// Custom painter for animated connections between model cards
class NeuralConnectionPainter extends CustomPainter {
  final double animation;
  final List<String> activeModels;
  final Color neuralColor;
  final bool isActive;

  NeuralConnectionPainter({
    required this.animation,
    required this.activeModels,
    required this.neuralColor,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isActive || activeModels.length < 2) return;

    final paint = Paint()
      ..color = neuralColor.withOpacity(0.3 + (animation * 0.4))
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final cardWidth = size.width / 2;
    final numRows = (activeModels.length / 2.0).ceil();
    final cardHeight = size.height / numRows;

    for (int i = 0; i < activeModels.length - 1; i++) {
      final startX = (i % 2) * cardWidth + (cardWidth / 2);
      final startY = (i ~/ 2) * cardHeight + (cardHeight / 2);

      final endX = ((i + 1) % 2) * cardWidth + (cardWidth / 2);
      final endY = ((i + 1) ~/ 2) * cardHeight + (cardHeight / 2);

      // Animated connection line
      final animatedEndX = startX + ((endX - startX) * animation);
      final animatedEndY = startY + ((endY - startY) * animation);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(animatedEndX, animatedEndY),
        paint,
      );

      // Pulse effect
      canvas.drawCircle(
        Offset(animatedEndX, animatedEndY),
        3.0 + (animation * 2.0),
        Paint()
          ..color = neuralColor.withOpacity(0.6 - (animation * 0.4))
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant NeuralConnectionPainter oldDelegate) {
    return animation != oldDelegate.animation ||
        activeModels != oldDelegate.activeModels ||
        isActive != oldDelegate.isActive;
  }
}