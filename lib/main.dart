// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Core Imports
import 'core/design_system.dart';
import 'core/accessibility/accessibility_manager.dart';

// Widget Imports
import 'widgets/neural_app_bar.dart';
import 'widgets/core/strategy_selector.dart';
import 'widgets/core/model_grid.dart';
import 'widgets/core/message_bubble.dart';
import 'widgets/core/token_cost_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Accessibility
  await AccessibilityManager().initialize();

  runApp(const NeuronVaultApp());
}

/// 🧠 NEURON VAULT APP
/// App principale con tema moderno e accessibility completa
class NeuronVaultApp extends StatelessWidget {
  const NeuronVaultApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeuronVault',
      navigatorKey: AccessibilityManager().navigatorKey,
      theme: DesignSystem.instance.themeData,
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// 🏠 MAIN SCREEN
/// Schermo principale dell'applicazione
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // App State
  AIStrategy _currentStrategy = AIStrategy.parallel;
  bool _isConnected = true;
  final List<AIModel> _models = [
    AIModel(
      name: 'Claude',
      icon: Icons.psychology,
      color: const Color(0xFF6366F1),
      isActive: true,
      health: 0.95,
      tokensUsed: 12500,
    ),
    AIModel(
      name: 'GPT-4',
      icon: Icons.auto_awesome,
      color: const Color(0xFF10B981),
      isActive: true,
      health: 0.88,
      tokensUsed: 8200,
    ),
    AIModel(
      name: 'Gemini',
      icon: Icons.diamond,
      color: const Color(0xFFF59E0B),
      isActive: false,
      health: 0.72,
      tokensUsed: 0,
    ),
    AIModel(
      name: 'DeepSeek',
      icon: Icons.explore,
      color: const Color(0xFF8B5CF6),
      isActive: true,
      health: 0.91,
      tokensUsed: 2800,
    ),
  ];

  // Focus Nodes - rimuovi quelli non utilizzati

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// 🔄 Handle Strategy Change
  void _onStrategyChanged(AIStrategy strategy) {
    setState(() {
      _currentStrategy = strategy;
    });

    AccessibilityManager().announce(
      'Strategy changed to ${strategy.displayName}',
      assertive: true,
    );

    HapticFeedback.selectionClick();
  }

  /// 🔌 Toggle Connection
  void _toggleConnection() {
    setState(() {
      _isConnected = !_isConnected;
    });

    AccessibilityManager().announce(
      'Connection ${_isConnected ? 'established' : 'lost'}',
      assertive: true,
    );

    HapticFeedback.lightImpact();
  }

  /// 🎛️ Toggle High Contrast
  void _toggleHighContrast() {
    DesignSystem.instance.toggleHighContrast();
    setState(() {});

    AccessibilityManager().announce(
      'High contrast mode ${DesignSystem.instance.isHighContrast ? 'enabled' : 'disabled'}',
      assertive: true,
    );
  }

  /// ℹ️ Show Help Dialog
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keyboard Shortcuts'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ctrl+H: Toggle High Contrast'),
            Text('F1: Show Help'),
            Text('Ctrl+Shift+S: Focus Strategy Selector'),
            Text('Ctrl+Shift+C: Toggle Connection'),
            Text('Tab: Navigate between elements'),
            Text('Space/Enter: Activate focused element'),
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


  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    return Scaffold(
      backgroundColor: ds.colors.colorScheme.surface,
      appBar: NeuralAppBar(
        isConnected: _isConnected,
        onConnectionToggle: _toggleConnection,
        pulseAnimation: _pulseAnimation,
      ),
      body: Column(
        children: [
          // Strategy Selector
          Padding(
            padding: EdgeInsets.all(ds.spacing.md),
            child: StrategySelector(
              currentStrategy: _currentStrategy,
              onStrategyChanged: _onStrategyChanged,
            ),
          ),

          // Main Content Area
          Expanded(
            child: Row(
              children: [
                // Left Panel - Models
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.all(ds.spacing.md),
                    child: ModelGrid(
                      models: _models,
                      onModelToggle: (modelName) {
                        setState(() {
                          final modelIndex = _models.indexWhere((m) => m.name == modelName);
                          if (modelIndex != -1) {
                            _models[modelIndex] = _models[modelIndex].copyWith(
                              isActive: !_models[modelIndex].isActive,
                            );
                          }
                        });

                        AccessibilityManager().announce(
                          '$modelName ${_models.firstWhere((m) => m.name == modelName).isActive ? 'activated' : 'deactivated'}',
                        );
                      },
                    ),
                  ),
                ),

                // Right Panel - Chat & Token Usage
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(ds.spacing.md),
                    child: Column(
                      children: [
                        // Token Cost Widget
                        TokenCostWidget(
                          totalTokens: _models.fold<int>(0, (sum, model) => sum + model.tokensUsed),
                          models: _models,
                          budgetLimit: 50000,
                        ),

                        SizedBox(height: ds.spacing.md),

                        // Chat Messages Area
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: ds.colors.colorScheme.surfaceContainer,
                              borderRadius: ds.effects.cardRadius,
                              boxShadow: [ds.effects.cardShadow],
                            ),
                            child: Column(
                              children: [
                                // Sample Message Bubbles
                                Expanded(
                                  child: ListView(
                                    padding: const EdgeInsets.all(16),
                                    children: const [
                                      MessageBubble(
                                        message: 'Welcome to NeuronVault! How can I help you today?',
                                        isFromAI: true,
                                        aiModel: 'Claude',
                                        timestamp: 'Just now',
                                      ),
                                      SizedBox(height: 16),
                                      MessageBubble(
                                        message: 'I need help with my Flutter project.',
                                        isFromAI: false,
                                        timestamp: '2 minutes ago',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Accessibility FAB
      floatingActionButton: FloatingActionButton(
        onPressed: _showAccessibilityMenu,
        backgroundColor: ds.colors.neuralPrimary,
        child: Icon(
          Icons.accessibility,
          color: ds.colors.colorScheme.onPrimary,
        ),
      ),
    );
  }

  /// 🧸 Show Accessibility Menu
  void _showAccessibilityMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => AccessibilityMenu(
        onHighContrastChanged: _toggleHighContrast,
        onHelpPressed: _showHelpDialog,
      ),
    );
  }
}

/// 🎯 AI STRATEGY ENUM
enum AIStrategy {
  parallel,
  consensus,
  adaptive,
  cascade;

  String get displayName {
    switch (this) {
      case AIStrategy.parallel:
        return 'Parallel';
      case AIStrategy.consensus:
        return 'Consensus';
      case AIStrategy.adaptive:
        return 'Adaptive';
      case AIStrategy.cascade:
        return 'Cascade';
    }
  }

  IconData get icon {
    switch (this) {
      case AIStrategy.parallel:
        return Icons.call_split;
      case AIStrategy.consensus:
        return Icons.groups;
      case AIStrategy.adaptive:
        return Icons.psychology;
      case AIStrategy.cascade:
        return Icons.waterfall_chart;
    }
  }
}

/// 🤖 AI MODEL DATA CLASS
class AIModel {
  final String name;
  final IconData icon;
  final Color color;
  final bool isActive;
  final double health;
  final int tokensUsed;

  AIModel({
    required this.name,
    required this.icon,
    required this.color,
    required this.isActive,
    required this.health,
    required this.tokensUsed,
  });

  AIModel copyWith({
    String? name,
    IconData? icon,
    Color? color,
    bool? isActive,
    double? health,
    int? tokensUsed,
  }) {
    return AIModel(
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      health: health ?? this.health,
      tokensUsed: tokensUsed ?? this.tokensUsed,
    );
  }
}

/// 🧸 ACCESSIBILITY MENU
/// Menu dedicato alle opzioni di accessibilità
class AccessibilityMenu extends StatelessWidget {
  final VoidCallback onHighContrastChanged;
  final VoidCallback onHelpPressed;

  const AccessibilityMenu({
    Key? key,
    required this.onHighContrastChanged,
    required this.onHelpPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    return Container(
      padding: EdgeInsets.all(ds.spacing.lg),
      decoration: BoxDecoration(
        color: ds.colors.colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accessibility Options',
            style: ds.typography.h2.copyWith(
              color: ds.colors.colorScheme.onSurface,
            ),
          ),

          SizedBox(height: ds.spacing.lg),

          // High Contrast Toggle
          GestureDetector(
            onTap: () {
              onHighContrastChanged();
              Navigator.pop(context);
            },
            child: ListTile(
              leading: Icon(
                Icons.contrast,
                color: ds.colors.neuralPrimary,
              ),
              title: Text(
                'High Contrast Mode',
                style: ds.typography.body1.copyWith(
                  color: ds.colors.colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                ds.isHighContrast ? 'Enabled' : 'Disabled',
                style: ds.typography.body2.copyWith(
                  color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              trailing: Switch(
                value: ds.isHighContrast,
                onChanged: (_) {
                  onHighContrastChanged();
                  Navigator.pop(context);
                },
              ),
            ),
          ),

          // Keyboard Shortcuts
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              onHelpPressed();
            },
            child: ListTile(
              leading: Icon(
                Icons.keyboard,
                color: ds.colors.neuralSecondary,
              ),
              title: Text(
                'Keyboard Shortcuts',
                style: ds.typography.body1.copyWith(
                  color: ds.colors.colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                'View available shortcuts',
                style: ds.typography.body2.copyWith(
                  color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),

          SizedBox(height: ds.spacing.lg),
        ],
      ),
    );
  }
}