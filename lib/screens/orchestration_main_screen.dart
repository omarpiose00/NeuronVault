// lib/screens/orchestration_main_screen.dart - PHASE 3.3 LAYOUT FIXED
// 🧬 LUXURY NEURAL ORCHESTRATION SCREEN - Layout issues resolved + Achievement System

import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;

import '../core/services/websocket_orchestration_service.dart' as WS;
import '../core/providers/providers_main.dart';
import '../core/design_system.dart';
import '../core/theme/neural_theme_system.dart';
import '../core/state/state_models.dart';
import '../widgets/core/neural_brain_logo.dart';
import '../widgets/core/neural_3d_particle_system.dart';
import '../widgets/core/model_profiling_dashboard.dart';
import '../widgets/core/spatial_audio_controls.dart';
import '../widgets/core/neural_theme_selector.dart';
import '../widgets/core/achievement_notification.dart';
import '../widgets/core/achievement_progress_panel.dart';
import '../widgets/core/revolutionary_connection_status.dart';


class OrchestrationMainScreen extends ConsumerStatefulWidget {
  const OrchestrationMainScreen({super.key});

  @override
  ConsumerState<OrchestrationMainScreen> createState() => _OrchestrationMainScreenState();
}

class _OrchestrationMainScreenState extends ConsumerState<OrchestrationMainScreen>
    with TickerProviderStateMixin {

  // Animation controllers
  late AnimationController _backgroundController;
  late AnimationController _panelController;
  late AnimationController _chatController;

  // Animations
  late Animation<double> _backgroundAnimation;
  late Animation<Offset> _panelSlideAnimation;
  late Animation<double> _chatFadeAnimation;

  // UI State
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLeftPanelOpen = true;
  bool _isRightPanelOpen = true;
  bool _isModelProfilingExpanded = false;
  final List<ChatMessage> _messages = [];

  // PHASE 3.3: Achievement System State
  bool _showAchievementPanel = false;
  DateTime _sessionStartTime = DateTime.now();
  int _orchestrationsThisSession = 0;
  int _themeChangesThisSession = 0;
  DateTime? _lastThemeChange;

  // Theme system state
  NeuralThemeType _currentThemeType = NeuralThemeType.cosmos;
  late NeuralThemeData _neuralTheme;

  // FIXED: Layout constraints
  double _leftPanelWidth = 350;
  double _rightPanelWidth = 320;
  static const double _minScreenWidth = 1000;

  WS.OrchestrationStrategy _convertToWebSocketStrategy(OrchestrationStrategy strategy) {
    switch (strategy) {
      case OrchestrationStrategy.parallel:
        return WS.OrchestrationStrategy.parallel;
      case OrchestrationStrategy.consensus:
        return WS.OrchestrationStrategy.consensus;
      case OrchestrationStrategy.adaptive:
        return WS.OrchestrationStrategy.adaptive;
      case OrchestrationStrategy.sequential:
        return WS.OrchestrationStrategy.sequential;
      case OrchestrationStrategy.weighted:
        return WS.OrchestrationStrategy.weighted;
      case OrchestrationStrategy.cascade:
        throw UnimplementedError('Cascade strategy not yet implemented');
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupOrchestrationListeners();
    _setupAchievementTracking();
    _neuralTheme = NeuralThemeData.cosmos();
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_backgroundController);

    _panelController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _panelSlideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _panelController,
      curve: Curves.easeOutCubic,
    ));

    _chatController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _chatFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chatController,
      curve: Curves.easeOut,
    ));

    _backgroundController.repeat();
    _panelController.forward();
    _chatController.forward();
  }

  void _setupOrchestrationListeners() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orchestrationService = ref.read(webSocketOrchestrationServiceProvider);

      orchestrationService.individualResponsesStream.listen((responses) {
        if (mounted) {
          setState(() {
            for (final response in responses) {
              _messages.add(ChatMessage(
                id: '${DateTime.now().millisecondsSinceEpoch}_${response.modelName}',
                content: response.content,
                type: MessageType.assistant,
                timestamp: response.timestamp,
              ));
            }
          });
        }
      });

      orchestrationService.synthesizedResponseStream.listen((synthesis) {
        if (synthesis.isNotEmpty && mounted) {
          setState(() {
            _messages.add(ChatMessage(
              id: '${DateTime.now().millisecondsSinceEpoch}_synthesis',
              content: synthesis,
              type: MessageType.assistant,
              timestamp: DateTime.now(),
              metadata: {'is_synthesis': true},
            ));
          });
        }
      });
    });
  }

  void _setupAchievementTracking() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tracker = ref.read(achievementServiceProvider); // FIXED: Use standard service

      tracker.trackParticleInteraction();
      tracker.trackFeatureUsage('main_screen');
      _trackSessionStart();
    });
  }

  void _trackSessionStart() {
    final tracker = ref.read(achievementServiceProvider);
    tracker.trackFeatureUsage('session_start');

    _sessionStartTime = DateTime.now();
    _orchestrationsThisSession = 0;
    _themeChangesThisSession = 0;
  }

  void _trackOrchestrationCompletion(List<String> modelsUsed, String strategy, {
    double? responseTime,
    int? tokenCount,
    double? qualityScore,
  }) {
    final tracker = ref.read(achievementServiceProvider);
    tracker.trackOrchestration(modelsUsed, strategy);

    _orchestrationsThisSession++;

    if (_orchestrationsThisSession >= 5) {
      tracker.trackEnhancedProgress('speed_synthesizer');
    }

    if (_orchestrationsThisSession >= 10) {
      tracker.trackEnhancedProgress('neural_marathon');
    }
  }

  void _trackThemeChange(String themeName) {
    final tracker = ref.read(achievementServiceProvider);
    tracker.trackThemeActivation(themeName);

    _themeChangesThisSession++;
    _lastThemeChange = DateTime.now();

    if (_themeChangesThisSession >= 5) {
      tracker.trackEnhancedProgress('visual_shapeshifter');
    }
  }

  void _trackFeatureInteraction(String feature, {Map<String, dynamic>? additionalData}) {
    final tracker = ref.read(achievementServiceProvider);
    tracker.trackFeatureUsage(feature);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _panelController.dispose();
    _chatController.dispose();
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final connectionState = ref.watch(connectionControllerProvider);
    final orchestrationService = ref.watch(webSocketOrchestrationServiceProvider);
    final isOrchestrationActive = ref.watch(isOrchestrationActiveProvider);

    return Scaffold(
      body: LayoutBuilder( // FIXED: Use LayoutBuilder for responsive design
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;
          final isTablet = constraints.maxWidth < 1200;

          // FIXED: Adjust panel widths based on screen size
          if (constraints.maxWidth < _minScreenWidth) {
            _leftPanelWidth = constraints.maxWidth * 0.25;
            _rightPanelWidth = constraints.maxWidth * 0.25;
          } else {
            _leftPanelWidth = 350;
            _rightPanelWidth = 320;
          }

          return AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: _neuralTheme.gradients.background,
                ),
                child: Stack(
                  children: [
                    // 🌟 3D NEURAL PARTICLE SYSTEM
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () => _trackFeatureInteraction('particle_interaction'),
                        child: Neural3DParticleSystem(
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                          isActive: connectionState.isConnected,
                          intensity: isOrchestrationActive ? 1.5 : 1.0,
                          primaryColor: _neuralTheme.colors.primary,
                          secondaryColor: _neuralTheme.colors.secondary,
                          neuralTheme: _neuralTheme,
                        ),
                      ),
                    ),

                    // 🏆 ACHIEVEMENT NOTIFICATION OVERLAY
                    const AchievementNotificationOverlay(),

                    // 🏆 ACHIEVEMENT PANEL OVERLAY
                    if (_showAchievementPanel)
                      _buildAchievementPanelOverlay(constraints),

                    // 📊 PERFORMANCE OVERLAY (FIXED positioning)
                    if (!isMobile && !isTablet)
                      _buildPerformanceOverlay(ds, constraints),

                    // MAIN CONTENT
                    Column(
                      children: [
                        _buildNeuralAppBar(ds, orchestrationService, constraints),
                        Expanded(
                          child: isMobile
                              ? _buildMobileLayout(ds, constraints)
                              : _buildDesktopLayout(ds, constraints),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 🏆 FIXED: Achievement Panel Overlay
  Widget _buildAchievementPanelOverlay(BoxConstraints constraints) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            width: (constraints.maxWidth * 0.8).clamp(300.0, 900.0),
            height: (constraints.maxHeight * 0.8).clamp(400.0, 700.0),
            child: Stack(
              children: [
                const AchievementProgressPanel(),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    onPressed: () {
                      setState(() => _showAchievementPanel = false);
                      _trackFeatureInteraction('achievement_panel_close');
                    },
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 📊 FIXED: Performance Overlay
  Widget _buildPerformanceOverlay(DesignSystemData ds, BoxConstraints constraints) {
    return Positioned(
      top: 90,
      right: 20,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: constraints.maxWidth * 0.2,
          maxHeight: 200,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ds.colors.colorScheme.surface.withOpacity(0.9),
              ds.colors.colorScheme.surface.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ds.colors.neuralPrimary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.analytics,
                  color: ds.colors.neuralAccent,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'LIVE ANALYTICS',
                    style: ds.typography.caption.copyWith(
                      color: ds.colors.colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '150 nodes • 300 connections',
              style: ds.typography.caption.copyWith(
                color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
                fontSize: 9,
              ),
            ),
            Text(
              '60 FPS • GPU accelerated',
              style: ds.typography.caption.copyWith(
                color: ds.colors.connectionGreen,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Container(height: 1, color: ds.colors.neuralPrimary.withOpacity(0.2)),
            const SizedBox(height: 6),
            Text(
              'Session: ${DateTime.now().difference(_sessionStartTime).inMinutes}m',
              style: ds.typography.caption.copyWith(
                color: ds.colors.neuralPrimary,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Orchestrations: $_orchestrationsThisSession',
              style: ds.typography.caption.copyWith(
                color: Colors.amber,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🧠 FIXED: Neural App Bar
  Widget _buildNeuralAppBar(DesignSystemData ds, WS.WebSocketOrchestrationService orchestrationService, BoxConstraints constraints) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ds.colors.colorScheme.surface.withOpacity(0.95),
            ds.colors.colorScheme.surface.withOpacity(0.85),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: ds.colors.neuralPrimary.withOpacity(0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: ds.colors.neuralPrimary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                // Neural Brain Logo
                GestureDetector(
                  onTap: () => _trackFeatureInteraction('neural_logo'),
                  child: NeuralBrainLogo(
                    size: 50,
                    isConnected: ref.watch(connectionControllerProvider).isConnected,
                    showConnections: true,
                    primaryColor: ds.colors.neuralPrimary,
                    secondaryColor: ds.colors.neuralSecondary,
                  ),
                ),

                const SizedBox(width: 16),

                // App Title with responsive text
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            ds.colors.neuralPrimary,
                            ds.colors.neuralSecondary,
                            ds.colors.neuralAccent,
                          ],
                        ).createShader(bounds),
                        child: Text(
                          'NeuronVault',
                          style: ds.typography.h1.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: constraints.maxWidth < 800 ? 20 : 24,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (constraints.maxWidth > 600)
                        Text(
                          'AI Orchestration Platform',
                          style: ds.typography.caption.copyWith(
                            color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),

                const Spacer(),

                // 🏆 Achievement Quick Stats (FIXED: Simplified for compatibility)
                if (constraints.maxWidth > 800)
                  GestureDetector(
                    onTap: () {
                      setState(() => _showAchievementPanel = true);
                      _trackFeatureInteraction('achievement_panel_open');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ds.colors.neuralAccent.withOpacity(0.3),
                            ds.colors.neuralAccent.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ds.colors.neuralAccent.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: ds.colors.neuralAccent,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Achievements',
                            style: ds.typography.caption.copyWith(
                              color: ds.colors.neuralAccent,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (constraints.maxWidth > 800) const SizedBox(width: 16),

                // 🔗 Connection Status
                const RevolutionaryConnectionStatus(isCompact: false),

                const SizedBox(width: 16),

                // Action buttons
                _buildEnhanced3DButton(
                  icon: Icons.emoji_events,
                  onTap: () {
                    setState(() => _showAchievementPanel = true);
                    _trackFeatureInteraction('achievement_panel_toggle');
                  },
                  ds: ds,
                  size: constraints.maxWidth < 800 ? 44 : 52,
                ),

                const SizedBox(width: 8),

                _buildEnhanced3DButton(
                  icon: Icons.settings,
                  onTap: () => _trackFeatureInteraction('settings'),
                  ds: ds,
                  size: constraints.maxWidth < 800 ? 44 : 52,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔘 FIXED: Enhanced 3D Button
  Widget _buildEnhanced3DButton({
    required IconData icon,
    required VoidCallback onTap,
    required DesignSystemData ds,
    double size = 52,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ds.colors.neuralPrimary.withOpacity(0.8),
              ds.colors.neuralSecondary.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(size * 0.35),
          border: Border.all(
            color: ds.colors.neuralPrimary.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: ds.colors.neuralPrimary.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }

  // 📱 FIXED: Mobile Layout
  Widget _buildMobileLayout(DesignSystemData ds, BoxConstraints constraints) {
    return Column(
      children: [
        Expanded(
          child: _buildChatArea(ds, constraints),
        ),
        _buildNeuralChatInput(ds, constraints),
      ],
    );
  }

  // 💻 FIXED: Desktop Layout with proper constraints
  Widget _buildDesktopLayout(DesignSystemData ds, BoxConstraints constraints) {
    return Row(
      children: [
        // FIXED: Left Panel with constraints
        if (_isLeftPanelOpen && constraints.maxWidth > _minScreenWidth)
          Container(
            width: _leftPanelWidth,
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth * 0.3,
              minWidth: 280,
            ),
            child: SlideTransition(
              position: _panelSlideAnimation,
              child: _buildEnhancedGlassmorphicPanel(
                child: _buildLeftPanelContent(ds, constraints),
                ds: ds,
              ),
            ),
          ),

        // FIXED: Chat Area with Flexible
        Flexible(
          flex: constraints.maxWidth > _minScreenWidth ? 1 : 1,
          child: FadeTransition(
            opacity: _chatFadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(child: _buildChatArea(ds, constraints)),
                  _buildNeuralChatInput(ds, constraints),
                ],
              ),
            ),
          ),
        ),

        // FIXED: Right Panel with constraints
        if (_isRightPanelOpen && constraints.maxWidth > _minScreenWidth)
          Container(
            width: _rightPanelWidth,
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth * 0.3,
              minWidth: 250,
            ),
            child: _buildEnhancedGlassmorphicPanel(
              child: _buildRightPanelContent(ds, constraints),
              ds: ds,
            ),
          ),
      ],
    );
  }

  Widget _buildEnhancedGlassmorphicPanel({required Widget child, required DesignSystemData ds}) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ds.colors.colorScheme.surface.withOpacity(0.85),
            ds.colors.colorScheme.surface.withOpacity(0.65),
          ],
        ),
        border: Border.all(
          color: ds.colors.neuralPrimary.withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: ds.colors.colorScheme.shadow.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: child,
        ),
      ),
    );
  }

  // FIXED: Left Panel Content
  Widget _buildLeftPanelContent(DesignSystemData ds, BoxConstraints constraints) {
    final activeModels = ref.watch(activeModelsProvider);
    final currentStrategy = ref.watch(currentStrategyProvider);
    final availableStrategies = ref.watch(availableStrategiesProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tune,
                  color: ds.colors.neuralPrimary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'AI Orchestration',
                    style: ds.typography.h2.copyWith(
                      color: ds.colors.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            _buildSectionHeader('Strategy', Icons.psychology, ds),
            const SizedBox(height: 16),
            _buildStrategyCards(ds, availableStrategies, currentStrategy, constraints),

            const SizedBox(height: 32),

            _buildSectionHeader('AI Models', Icons.smart_toy, ds),
            const SizedBox(height: 16),
            _buildModelCards(ds, activeModels, constraints),
          ],
        ),
      ),
    );
  }

  // FIXED: Right Panel Content
  Widget _buildRightPanelContent(DesignSystemData ds, BoxConstraints constraints) {
    final connectionState = ref.watch(connectionControllerProvider);
    final isOrchestrationActive = ref.watch(isOrchestrationActiveProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: ds.colors.neuralSecondary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'Live Analytics',
                    style: ds.typography.h2.copyWith(
                      color: ds.colors.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            _buildEnhancedMetricCard(
              'Connection',
              connectionState.isConnected ? 'Active • ${connectionState.latencyMs}ms' : 'Inactive',
              connectionState.isConnected ? ds.colors.connectionGreen : ds.colors.connectionRed,
              Icons.wifi,
              ds,
            ),

            const SizedBox(height: 16),

            _buildEnhancedMetricCard(
              '3D Particles',
              '150 Neural Nodes',
              ds.colors.neuralPrimary,
              Icons.grain,
              ds,
            ),

            const SizedBox(height: 16),

            _buildEnhancedMetricCard(
              'Messages',
              '${_messages.length}',
              ds.colors.neuralAccent,
              Icons.message,
              ds,
            ),

            const SizedBox(height: 16),

            _buildEnhancedMetricCard(
              'AI Activity',
              isOrchestrationActive ? 'ORCHESTRATING' : 'IDLE',
              isOrchestrationActive ? ds.colors.connectionGreen : ds.colors.neuralSecondary,
              Icons.psychology,
              ds,
            ),

            const SizedBox(height: 16),

            _buildEnhancedMetricCard(
              'Session',
              '${DateTime.now().difference(_sessionStartTime).inMinutes}m • $_orchestrationsThisSession AI calls',
              ds.colors.neuralAccent,
              Icons.access_time,
              ds,
            ),

            const SizedBox(height: 24),

            // Model Profiling Dashboard
            GestureDetector(
              onTap: () {
                setState(() {
                  _isModelProfilingExpanded = !_isModelProfilingExpanded;
                });
                _trackFeatureInteraction('model_profiling');
              },
              child: ModelProfilingDashboard(
                isExpanded: _isModelProfilingExpanded,
                onToggleExpanded: () {
                  setState(() {
                    _isModelProfilingExpanded = !_isModelProfilingExpanded;
                  });
                  _trackFeatureInteraction('model_profiling_toggle');
                },
              ),
            ),

            const SizedBox(height: 16),

            // Spatial Audio Controls
            GestureDetector(
              onTap: () => _trackFeatureInteraction('spatial_audio'),
              child: const SpatialAudioControls(isCompact: true),
            ),

            const SizedBox(height: 16),

            // Neural Theme Selector
            NeuralThemeSelector(
              isCompact: true,
              onThemeChanged: (themeType) => _changeTheme(themeType),
            ),
          ],
        ),
      ),
    );
  }

  void _changeTheme(NeuralThemeType themeType) {
    setState(() {
      _currentThemeType = themeType;
      switch (themeType) {
        case NeuralThemeType.cosmos:
          _neuralTheme = NeuralThemeData.cosmos();
          break;
        case NeuralThemeType.matrix:
          _neuralTheme = NeuralThemeData.matrix();
          break;
        case NeuralThemeType.sunset:
          _neuralTheme = NeuralThemeData.sunset();
          break;
        case NeuralThemeType.ocean:
          _neuralTheme = NeuralThemeData.ocean();
          break;
        case NeuralThemeType.midnight:
          _neuralTheme = NeuralThemeData.midnight();
          break;
        case NeuralThemeType.aurora:
          _neuralTheme = NeuralThemeData.aurora();
          break;
      }
    });

    _trackThemeChange(themeType.name);
  }

  Widget _buildSectionHeader(String title, IconData icon, DesignSystemData ds) {
    return Row(
      children: [
        Icon(
          icon,
          color: ds.colors.neuralAccent,
          size: 20,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            title,
            style: ds.typography.h3.copyWith(
              color: ds.colors.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedMetricCard(String label, String value, Color color, IconData icon, DesignSystemData ds) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ds.colors.colorScheme.surfaceContainer.withOpacity(0.8),
            ds.colors.colorScheme.surfaceContainer.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  color.withOpacity(0.3),
                  color.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: ds.typography.caption.copyWith(
                    color: ds.colors.colorScheme.onSurface.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: ds.typography.h3.copyWith(
                    color: ds.colors.colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // FIXED: Strategy Cards with proper constraints
  Widget _buildStrategyCards(DesignSystemData ds, List<String> availableStrategies, String currentStrategy, BoxConstraints constraints) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableStrategies.map((strategy) {
        final isActive = strategy == currentStrategy;
        return GestureDetector(
          onTap: () {
            ref.read(currentStrategyProvider.notifier).state = strategy;
            HapticFeedback.selectionClick();
            _trackFeatureInteraction('strategy_selection');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth * 0.4,
            ),
            decoration: BoxDecoration(
              gradient: isActive ? LinearGradient(colors: [ds.colors.neuralPrimary, ds.colors.neuralSecondary]) : null,
              color: isActive ? null : ds.colors.colorScheme.surfaceContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive ? Colors.transparent : ds.colors.colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              strategy,
              style: ds.typography.caption.copyWith(
                color: isActive ? Colors.white : ds.colors.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }).toList(),
    );
  }

  // FIXED: Model Cards with proper constraints
  Widget _buildModelCards(DesignSystemData ds, List<String> activeModels, BoxConstraints constraints) {
    final allModels = [
      {'name': 'Claude', 'id': 'claude', 'color': const Color(0xFFFF6B35), 'icon': Icons.psychology},
      {'name': 'GPT-4', 'id': 'gpt', 'color': const Color(0xFF10B981), 'icon': Icons.auto_awesome},
      {'name': 'Gemini', 'id': 'gemini', 'color': const Color(0xFFF59E0B), 'icon': Icons.diamond},
      {'name': 'DeepSeek', 'id': 'deepseek', 'color': const Color(0xFF8B5CF6), 'icon': Icons.explore},
    ];

    return Column(
      children: allModels.map((model) {
        final modelId = model['id'] as String;
        final isActive = activeModels.contains(modelId);
        final color = model['color'] as Color;
        final icon = model['icon'] as IconData;
        final name = model['name'] as String;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ds.colors.colorScheme.surfaceContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? color.withOpacity(0.5) : ds.colors.colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.2),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: ds.typography.body1.copyWith(
                    color: ds.colors.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Switch(
                value: isActive,
                onChanged: (value) {
                  final modelsNotifier = ref.read(activeModelsProvider.notifier);
                  final currentModels = List<String>.from(activeModels);
                  if (value) {
                    if (!currentModels.contains(modelId)) {
                      currentModels.add(modelId);
                    }
                  } else {
                    currentModels.remove(modelId);
                  }
                  modelsNotifier.state = currentModels;
                  HapticFeedback.lightImpact();
                  _trackFeatureInteraction('model_toggle');
                },
                activeColor: color,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // FIXED: Chat Area with constraints
  Widget _buildChatArea(DesignSystemData ds, BoxConstraints constraints) {
    if (_messages.isEmpty) {
      return _buildEmptyState(ds, constraints);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return _buildLuxuryMessageBubble(_messages[index], ds, constraints);
      },
    );
  }

  Widget _buildEmptyState(DesignSystemData ds, BoxConstraints constraints) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _trackFeatureInteraction('neural_logo_tap'),
              child: NeuralBrainLogo(
                size: constraints.maxWidth < 600 ? 80 : 120,
                isConnected: ref.watch(connectionControllerProvider).isConnected,
                showConnections: true,
                primaryColor: ds.colors.neuralPrimary,
                secondaryColor: ds.colors.neuralSecondary,
              ),
            ),
            const SizedBox(height: 32),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [ds.colors.neuralPrimary, ds.colors.neuralSecondary],
              ).createShader(bounds),
              child: Text(
                'Welcome to NeuronVault',
                style: ds.typography.h1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: constraints.maxWidth < 600 ? 24 : 32,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth * 0.8,
              ),
              child: Text(
                'AI Orchestration Platform\nTransparent multi-AI orchestration\nSession: ${DateTime.now().difference(_sessionStartTime).inMinutes}m • $_orchestrationsThisSession calls',
                style: ds.typography.body1.copyWith(
                  color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
                  height: 1.6,
                  fontSize: constraints.maxWidth < 600 ? 14 : 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLuxuryMessageBubble(ChatMessage message, DesignSystemData ds, BoxConstraints constraints) {
    final maxWidth = constraints.maxWidth * 0.7;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.type == MessageType.user ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.type != MessageType.user) ...[
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [ds.colors.neuralPrimary, ds.colors.neuralSecondary]),
              ),
              child: const Icon(Icons.psychology, color: Colors.white, size: 20),
            ),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: message.type == MessageType.user ? LinearGradient(colors: [ds.colors.neuralPrimary, ds.colors.neuralSecondary]) : null,
                color: message.type == MessageType.user ? null : ds.colors.colorScheme.surfaceContainer.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.content,
                style: ds.typography.body1.copyWith(
                  color: message.type == MessageType.user ? Colors.white : ds.colors.colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (message.type == MessageType.user) ...[
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ds.colors.colorScheme.primary.withOpacity(0.2),
              ),
              child: Icon(Icons.person, color: ds.colors.colorScheme.primary, size: 20),
            ),
          ],
        ],
      ),
    );
  }

  // FIXED: Neural Chat Input
  Widget _buildNeuralChatInput(DesignSystemData ds, BoxConstraints constraints) {
    final connectionState = ref.watch(connectionControllerProvider);
    final isConnected = connectionState.isConnected;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ds.colors.colorScheme.surface.withOpacity(0.8),
            ds.colors.colorScheme.surface.withOpacity(0.95),
          ],
        ),
        border: Border(
          top: BorderSide(color: ds.colors.neuralPrimary.withOpacity(0.1), width: 1),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: LayoutBuilder(
            builder: (context, inputConstraints) {
              return Row(
                children: [
                  Expanded(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: inputConstraints.maxWidth - 80, // Leave space for button
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ds.colors.colorScheme.surfaceContainer.withOpacity(0.8),
                            ds.colors.colorScheme.surfaceContainer.withOpacity(0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: ds.colors.neuralPrimary.withOpacity(0.2), width: 1),
                      ),
                      child: TextField(
                        controller: _messageController,
                        enabled: isConnected,
                        decoration: InputDecoration(
                          hintText: isConnected ? 'Ask multiple AIs...' : 'Backend not connected...',
                          hintStyle: ds.typography.body1.copyWith(
                            color: ds.colors.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                        style: ds.typography.body1.copyWith(color: ds.colors.colorScheme.onSurface),
                        onSubmitted: isConnected ? _sendMessage : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildEnhanced3DButton(
                    icon: Icons.send,
                    onTap: isConnected ? () => _sendMessage(_messageController.text) : () {},
                    ds: ds,
                    size: constraints.maxWidth < 600 ? 44 : 52,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    final startTime = DateTime.now();
    final userMessage = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_user',
      content: message.trim(),
      type: MessageType.user,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
    });

    _messageController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    final orchestrationService = ref.read(webSocketOrchestrationServiceProvider);
    final activeModels = ref.read(activeModelsProvider);
    final currentStrategy = ref.read(currentStrategyProvider);

    Future.delayed(const Duration(seconds: 1), () {
      final responseTime = DateTime.now().difference(startTime).inMilliseconds / 1000.0;
      _trackOrchestrationCompletion(
        activeModels,
        currentStrategy,
        responseTime: responseTime,
        tokenCount: message.length,
        qualityScore: 0.9,
      );
    });

    orchestrationService.orchestrateAIRequest(
      prompt: message.trim(),
      selectedModels: activeModels,
      strategy: _convertToWebSocketStrategy(OrchestrationStrategy.parallel),
    );
  }
}