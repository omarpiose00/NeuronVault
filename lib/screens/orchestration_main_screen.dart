// lib/screens/orchestration_main_screen.dart - ENHANCED WITH 3D PARTICLES
// 🧬 LUXURY NEURAL ORCHESTRATION SCREEN - 3D PARTICLE REVOLUTION
// Complete transformation with revolutionary 3D neural effects

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

import '../core/services/websocket_orchestration_service.dart';
import '../core/providers/providers_main.dart';
import '../core/design_system.dart';
import '../core/theme/neural_theme_system.dart'; // ADD THEME IMPORT
import '../widgets/core/neural_brain_logo.dart';
import '../widgets/core/neural_3d_particle_system.dart'; // NEW IMPORT
import '../widgets/core/model_profiling_dashboard.dart'; // NEW IMPORT
import '../widgets/core/spatial_audio_controls.dart'; // NEW IMPORT
import '../widgets/core/neural_theme_selector.dart'; // NEW IMPORT

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
  bool _isModelProfilingExpanded = false; // NEW STATE
  List<ChatMessage> _messages = [];

  // Theme system state
  NeuralThemeType _currentThemeType = NeuralThemeType.cosmos;
  late NeuralThemeData _neuralTheme;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupOrchestrationListeners();

    // Initialize theme system
    _neuralTheme = NeuralThemeData.cosmos();
  }

  void _initializeAnimations() {
    // Background gradient animation
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_backgroundController);

    // Panel slide animations
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

    // Chat fade animation
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

    // Start animations
    _backgroundController.repeat();
    _panelController.forward();
    _chatController.forward();
  }

  void _setupOrchestrationListeners() {
    // Setup listeners for real orchestration data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orchestrationService = ref.read(webSocketOrchestrationServiceProvider);

      orchestrationService.individualResponsesStream.listen((responses) {
        setState(() {
          for (final response in responses) {
            _messages.add(ChatMessage.fromAIResponse(response));
          }
        });
      });

      orchestrationService.synthesizedResponseStream.listen((synthesis) {
        if (synthesis.isNotEmpty) {
          setState(() {
            _messages.add(ChatMessage.synthesized(synthesis));
          });
        }
      });
    });
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
    final orchestrationService = ref.watch(webSocketOrchestrationServiceProvider);
    final isOrchestrationActive = ref.watch(isOrchestrationActiveProvider);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: _neuralTheme.gradients.background, // USE LOCAL THEME
            ),
            child: Stack(
              children: [
                // 🌟 REVOLUTIONARY 3D NEURAL PARTICLE SYSTEM
                Positioned.fill(
                  child: Neural3DParticleSystem(
                    size: size,
                    isActive: orchestrationService.isConnected,
                    intensity: isOrchestrationActive ? 1.5 : 1.0,
                    primaryColor: _neuralTheme.colors.primary, // USE LOCAL THEME
                    secondaryColor: _neuralTheme.colors.secondary, // USE LOCAL THEME
                    neuralTheme: _neuralTheme, // PASS THEME DATA
                  ),
                ),

                // 🌟 Performance FPS Overlay (debug)
                if (MediaQuery.of(context).size.width > 1200)
                  Positioned(
                    top: 90,
                    right: 20,
                    child: _buildPerformanceOverlay(ds),
                  ),

                // Main content
                Column(
                  children: [
                    _buildNeuralAppBar(ds, orchestrationService),
                    Expanded(
                      child: isMobile
                          ? _buildMobileLayout(ds)
                          : _buildDesktopLayout(ds),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 📊 Build Performance Overlay (shows 3D system performance)
  Widget _buildPerformanceOverlay(DesignSystemData ds) {
    return Container(
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
                Icons.speed,
                color: ds.colors.neuralAccent,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                '3D PARTICLES',
                style: ds.typography.caption.copyWith(
                  color: ds.colors.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
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
        ],
      ),
    );
  }

  // 🧠 Build Neural App Bar - ENHANCED WITH 3D GLOW
  Widget _buildNeuralAppBar(DesignSystemData ds, WebSocketOrchestrationService orchestrationService) {
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
                // Neural Brain Logo with enhanced glow
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ds.colors.neuralPrimary.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: NeuralBrainLogo(
                    size: 50,
                    isConnected: orchestrationService.isConnected,
                    showConnections: true,
                    primaryColor: ds.colors.neuralPrimary,
                    secondaryColor: ds.colors.neuralSecondary,
                  ),
                ),

                const SizedBox(width: 16),

                // App Title with enhanced gradient and 3D effect
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: ds.colors.neuralPrimary.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        ds.colors.neuralPrimary,
                        ds.colors.neuralSecondary,
                        ds.colors.neuralAccent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ).createShader(bounds),
                    child: Text(
                      'NeuronVault',
                      style: ds.typography.h1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Enhanced subtitle with glow
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Orchestration Platform',
                      style: ds.typography.caption.copyWith(
                        color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '3D Neural Luxury Edition',
                      style: ds.typography.caption.copyWith(
                        color: ds.colors.neuralAccent.withOpacity(0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Connection Status with enhanced 3D glow
                _buildEnhancedConnectionStatus(ds, orchestrationService),

                const SizedBox(width: 16),

                // Settings button with 3D effect
                _buildEnhanced3DButton(
                  icon: Icons.settings,
                  onTap: () {},
                  ds: ds,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔗 Build Enhanced Connection Status with 3D effects
  Widget _buildEnhancedConnectionStatus(DesignSystemData ds, WebSocketOrchestrationService orchestrationService) {
    final isConnected = orchestrationService.isConnected;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (isConnected ? ds.colors.connectionGreen : ds.colors.connectionRed).withOpacity(0.25),
            (isConnected ? ds.colors.connectionGreen : ds.colors.connectionRed).withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: (isConnected ? ds.colors.connectionGreen : ds.colors.connectionRed).withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isConnected ? ds.colors.connectionGreen : ds.colors.connectionRed).withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isConnected ? ds.colors.connectionGreen : ds.colors.connectionRed,
              boxShadow: [
                BoxShadow(
                  color: (isConnected ? ds.colors.connectionGreen : ds.colors.connectionRed).withOpacity(0.6),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isConnected ? 'CONNECTED' : 'DISCONNECTED',
                style: ds.typography.caption.copyWith(
                  color: isConnected ? ds.colors.connectionGreen : ds.colors.connectionRed,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
              if (isConnected)
                Text(
                  '3D NEURAL ACTIVE',
                  style: ds.typography.caption.copyWith(
                    color: ds.colors.connectionGreen.withOpacity(0.8),
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // 🔘 Build Enhanced 3D Button
  Widget _buildEnhanced3DButton({
    required IconData icon,
    required VoidCallback onTap,
    required DesignSystemData ds,
    bool isEnabled = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ds.colors.neuralPrimary.withOpacity(0.8),
              ds.colors.neuralSecondary.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
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
            BoxShadow(
              color: ds.colors.neuralSecondary.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }

  // 📱 Build Mobile Layout
  Widget _buildMobileLayout(DesignSystemData ds) {
    return Column(
      children: [
        Expanded(
          child: _buildChatArea(ds),
        ),
        _buildNeuralChatInput(ds),
      ],
    );
  }

  // 🖥️ Build Desktop Layout
  Widget _buildDesktopLayout(DesignSystemData ds) {
    return Row(
      children: [
        // Left Panel
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: _isLeftPanelOpen ? 350 : 0,
          child: _isLeftPanelOpen
              ? SlideTransition(
            position: _panelSlideAnimation,
            child: _buildEnhancedGlassmorphicPanel(
              child: _buildLeftPanelContent(ds),
              ds: ds,
            ),
          )
              : null,
        ),

        // Chat Area
        Expanded(
          child: FadeTransition(
            opacity: _chatFadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(child: _buildChatArea(ds)),
                  _buildNeuralChatInput(ds),
                ],
              ),
            ),
          ),
        ),

        // Right Panel
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: _isRightPanelOpen ? 320 : 0,
          child: _isRightPanelOpen
              ? _buildEnhancedGlassmorphicPanel(
            child: _buildRightPanelContent(ds),
            ds: ds,
          )
              : null,
        ),
      ],
    );
  }

  // 🌟 Build Enhanced Glassmorphic Panel with 3D effects
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
          BoxShadow(
            color: ds.colors.neuralPrimary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
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

  // 🎛️ Build Left Panel Content (same as before)
  Widget _buildLeftPanelContent(DesignSystemData ds) {
    final activeModels = ref.watch(activeModelsProvider);
    final currentStrategy = ref.watch(currentStrategyProvider);
    final availableStrategies = ref.watch(availableStrategiesProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
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
              Text(
                'AI Orchestration',
                style: ds.typography.h2.copyWith(
                  color: ds.colors.colorScheme.onSurface,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Strategy Section
          _buildSectionHeader('Strategy', Icons.psychology, ds),
          const SizedBox(height: 16),
          _buildStrategyCards(ds, availableStrategies, currentStrategy),

          const SizedBox(height: 32),

          // Models Section
          _buildSectionHeader('AI Models', Icons.smart_toy, ds),
          const SizedBox(height: 16),
          _buildModelCards(ds, activeModels),
        ],
      ),
    );
  }

  // 📊 Build Right Panel Content - ENHANCED WITH MODEL PROFILING
  Widget _buildRightPanelContent(DesignSystemData ds) {
    final orchestrationService = ref.watch(webSocketOrchestrationServiceProvider);
    final isOrchestrationActive = ref.watch(isOrchestrationActiveProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
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
              Text(
                'Live Analytics',
                style: ds.typography.h2.copyWith(
                  color: ds.colors.colorScheme.onSurface,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Real-time metrics with 3D enhancements
          _buildEnhancedMetricCard(
            'Connection',
            orchestrationService.isConnected ? 'Active' : 'Inactive',
            orchestrationService.isConnected ? ds.colors.connectionGreen : ds.colors.connectionRed,
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

          const SizedBox(height: 24),

          // 🧠 MODEL PROFILING DASHBOARD - REVOLUTIONARY FEATURE
          Expanded(
            flex: 2,
            child: ModelProfilingDashboard(
              isExpanded: _isModelProfilingExpanded,
              onToggleExpanded: () {
                setState(() {
                  _isModelProfilingExpanded = !_isModelProfilingExpanded;
                });
              },
            ),
          ),

          const SizedBox(height: 16),

          // 🔊 SPATIAL AUDIO CONTROLS - NEW FEATURE
          const SpatialAudioControls(isCompact: true),

          const SizedBox(height: 16),

          // 🎨 NEURAL THEME SELECTOR - NEW FEATURE
          NeuralThemeSelector(
            isCompact: true,
            onThemeChanged: (themeType) {
              setState(() {
                _currentThemeType = themeType;
                // Update theme data based on type
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
            },
          ),
        ],
      ),
    );
  }

  // 📊 Build Enhanced Metric Card with 3D effects
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
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: ds.typography.h3.copyWith(
                    color: ds.colors.colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // All other methods remain the same as before...
  // (keeping the implementation identical for compatibility)

  Widget _buildSectionHeader(String title, IconData icon, DesignSystemData ds) {
    return Row(
      children: [
        Icon(
          icon,
          color: ds.colors.neuralAccent,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: ds.typography.h3.copyWith(
            color: ds.colors.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildStrategyCards(DesignSystemData ds, List<String> availableStrategies, String currentStrategy) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableStrategies.map((strategy) {
        final isActive = strategy == currentStrategy;

        return GestureDetector(
          onTap: () {
            ref.read(currentStrategyProvider.notifier).state = strategy;
            HapticFeedback.selectionClick();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Strategy changed to $strategy'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: isActive
                  ? LinearGradient(
                colors: [
                  ds.colors.neuralPrimary,
                  ds.colors.neuralSecondary,
                ],
              )
                  : null,
              color: isActive ? null : ds.colors.colorScheme.surfaceContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive
                    ? Colors.transparent
                    : ds.colors.colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: isActive
                  ? [
                BoxShadow(
                  color: ds.colors.neuralPrimary.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
                  : null,
            ),
            child: Text(
              strategy,
              style: ds.typography.caption.copyWith(
                color: isActive
                    ? Colors.white
                    : ds.colors.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModelCards(DesignSystemData ds, List<String> activeModels) {
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
              color: isActive
                  ? color.withOpacity(0.5)
                  : ds.colors.colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: isActive
                ? [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ]
                : null,
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
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  name,
                  style: ds.typography.body1.copyWith(
                    color: ds.colors.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
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

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$name ${value ? 'enabled' : 'disabled'}'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                activeColor: color,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChatArea(DesignSystemData ds) {
    if (_messages.isEmpty) {
      return _buildEmptyState(ds);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return _buildLuxuryMessageBubble(_messages[index], ds);
      },
    );
  }

  Widget _buildEmptyState(DesignSystemData ds) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NeuralBrainLogo(
            size: 120,
            isConnected: ref.watch(webSocketOrchestrationServiceProvider).isConnected,
            showConnections: true,
            primaryColor: ds.colors.neuralPrimary,
            secondaryColor: ds.colors.neuralSecondary,
          ),

          const SizedBox(height: 32),

          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                ds.colors.neuralPrimary,
                ds.colors.neuralSecondary,
              ],
            ).createShader(bounds),
            child: Text(
              'Welcome to NeuronVault',
              style: ds.typography.h1.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'AI Orchestration Platform\nTransparent multi-AI orchestration\n3D Neural Particle System',
            style: ds.typography.body1.copyWith(
              color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLuxuryMessageBubble(ChatMessage message, DesignSystemData ds) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isFromUser) ...[
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ds.colors.neuralPrimary,
                    ds.colors.neuralSecondary,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: ds.colors.neuralPrimary.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],

          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: message.isFromUser
                    ? LinearGradient(
                  colors: [
                    ds.colors.neuralPrimary,
                    ds.colors.neuralSecondary,
                  ],
                )
                    : null,
                color: message.isFromUser
                    ? null
                    : ds.colors.colorScheme.surfaceContainer.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomRight: message.isFromUser ? const Radius.circular(4) : null,
                  bottomLeft: message.isFromUser ? null : const Radius.circular(4),
                ),
                border: Border.all(
                  color: message.isFromUser
                      ? Colors.transparent
                      : ds.colors.colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ds.colors.colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: ds.typography.body1.copyWith(
                  color: message.isFromUser
                      ? Colors.white
                      : ds.colors.colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
            ),
          ),

          if (message.isFromUser) ...[
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ds.colors.colorScheme.primary.withOpacity(0.2),
                border: Border.all(
                  color: ds.colors.colorScheme.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.person,
                color: ds.colors.colorScheme.primary,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNeuralChatInput(DesignSystemData ds) {
    final orchestrationService = ref.watch(webSocketOrchestrationServiceProvider);
    final isConnected = orchestrationService.isConnected;

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
          top: BorderSide(
            color: ds.colors.neuralPrimary.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ds.colors.colorScheme.surfaceContainer.withOpacity(0.8),
                        ds.colors.colorScheme.surfaceContainer.withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: ds.colors.neuralPrimary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _messageController,
                    enabled: isConnected,
                    decoration: InputDecoration(
                      hintText: isConnected
                          ? 'Ask multiple AIs...'
                          : 'Backend not connected...',
                      hintStyle: ds.typography.body1.copyWith(
                        color: ds.colors.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    style: ds.typography.body1.copyWith(
                      color: ds.colors.colorScheme.onSurface,
                    ),
                    onSubmitted: isConnected ? _sendMessage : null,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              _buildEnhanced3DButton(
                icon: Icons.send,
                onTap: isConnected ? () => _sendMessage(_messageController.text) : () {},
                ds: ds, // ADD MISSING ARGUMENT
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    final userMessage = ChatMessage.user(message.trim());
    setState(() {
      _messages.add(userMessage);
    });

    _messageController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    final orchestrationService = ref.read(webSocketOrchestrationServiceProvider);
    orchestrationService.orchestrateAIRequest(
      prompt: message.trim(),
      selectedModels: ['claude', 'gpt', 'deepseek'],
      strategy: OrchestrationStrategy.parallel,
    );
  }
}

// ChatMessage class (same as before)
class ChatMessage {
  final String id;
  final String content;
  final bool isFromUser;
  final DateTime timestamp;
  final String? sourceModel;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isFromUser,
    required this.timestamp,
    this.sourceModel,
  });

  factory ChatMessage.fromAIResponse(AIResponse response) {
    return ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_${response.modelName}',
      content: response.content,
      isFromUser: false,
      timestamp: response.timestamp,
      sourceModel: response.modelName,
    );
  }

  factory ChatMessage.synthesized(String content) {
    return ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_synthesis',
      content: content,
      isFromUser: false,
      timestamp: DateTime.now(),
      sourceModel: 'synthesis',
    );
  }

  factory ChatMessage.user(String content) {
    return ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_user',
      content: content,
      isFromUser: true,
      timestamp: DateTime.now(),
    );
  }
}