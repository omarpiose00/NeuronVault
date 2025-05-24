// 🏠 NEURONVAULT - ENTERPRISE MAIN INTERFACE
// Professional AI orchestration dashboard with chat interface
// Part of PHASE 2.5 - QUANTUM STATE MANAGEMENT

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/design_system.dart';
import '../core/providers/providers_main.dart';
import '../widgets/core/chat_input_bar.dart';
import '../widgets/core/message_bubble.dart';
import '../widgets/core/strategy_selector.dart';
import '../widgets/core/model_grid.dart';
import '../widgets/neural_app_bar.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with TickerProviderStateMixin {
  
  late TabController _tabController;
  bool _isLeftPanelOpen = false;
  bool _isRightPanelOpen = false;
  final _scrollController = ScrollController();
  
  // 📱 RESPONSIVE BREAKPOINTS
  static const double _mobileBreakpoint = 768;
  static const double _tabletBreakpoint = 1024;
  static const double _desktopBreakpoint = 1440;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    
    // 📱 Responsive layout detection
    final layoutType = _getLayoutType(size.width);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Column(
        children: [
          // 🧠 Custom app bar
          const NeuralAppBar(),
          
          // 🏠 Main content area
          Expanded(
            child: _buildMainContent(layoutType, theme),
          ),
        ],
      ),
    );
  }

  LayoutType _getLayoutType(double width) {
    if (width < _mobileBreakpoint) return LayoutType.mobile;
    if (width < _tabletBreakpoint) return LayoutType.tablet;
    if (width < _desktopBreakpoint) return LayoutType.desktop;
    return LayoutType.ultrawide;
  }

  Widget _buildMainContent(LayoutType layoutType, ThemeData theme) {
    switch (layoutType) {
      case LayoutType.mobile:
        return _buildMobileLayout(theme);
      case LayoutType.tablet:
        return _buildTabletLayout(theme);
      case LayoutType.desktop:
      case LayoutType.ultrawide:
        return _buildDesktopLayout(theme, layoutType == LayoutType.ultrawide);
    }
  }

  // 📱 MOBILE LAYOUT
  Widget _buildMobileLayout(ThemeData theme) {
    return Column(
      children: [
        // 📊 Status bar
        _buildStatusBar(theme, compact: true),
        
        // 💬 Chat area
        Expanded(
          child: _buildChatArea(theme),
        ),
        
        // ⚙️ Quick controls
        _buildQuickControls(theme),
        
        // 📝 Chat input
        const ChatInputBar(),
      ],
    );
  }

  // 🖥️ TABLET LAYOUT
  Widget _buildTabletLayout(ThemeData theme) {
    return Row(
      children: [
        // 🎛️ Left sidebar (strategy & models)
        Container(
          width: 280,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              right: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: _buildLeftPanel(theme),
        ),
        
        // 💬 Main chat area
        Expanded(
          child: Column(
            children: [
              _buildStatusBar(theme),
              Expanded(child: _buildChatArea(theme)),
              const ChatInputBar(),
            ],
          ),
        ),
      ],
    );
  }

  // 🖥️ DESKTOP LAYOUT
  Widget _buildDesktopLayout(ThemeData theme, bool isUltrawide) {
    return Row(
      children: [
        // 🎛️ Left panel (collapsible)
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _isLeftPanelOpen ? 320 : 60,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              right: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: _buildLeftPanel(theme, isCollapsed: !_isLeftPanelOpen),
        ),
        
        // 💬 Main content area
        Expanded(
          flex: isUltrawide ? 3 : 2,
          child: Column(
            children: [
              _buildStatusBar(theme),
              Expanded(child: _buildChatArea(theme)),
              const ChatInputBar(),
            ],
          ),
        ),
        
        // 📊 Right panel (analytics & monitoring)
        if (isUltrawide)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isRightPanelOpen ? 350 : 60,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                left: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: _buildRightPanel(theme, isCollapsed: !_isRightPanelOpen),
          ),
      ],
    );
  }

  // 📊 STATUS BAR
  Widget _buildStatusBar(ThemeData theme, {bool compact = false}) {
    return Consumer(
      builder: (context, ref, child) {
        final connectionStatus = ref.watch(connectionStatusProvider);
        final systemStatus = ref.watch(systemStatusProvider);
        final budgetUsage = ref.watch(budgetUsageProvider);
        
        return Container(
          height: compact ? 40 : 50,
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: compact ? 4 : 8,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.5),
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // 🌐 Connection status
              _buildStatusIndicator(
                theme,
                _getConnectionIcon(connectionStatus),
                _getConnectionColor(connectionStatus),
                connectionStatus.name.toUpperCase(),
                compact,
              ),
              
              const SizedBox(width: 16),
              
              // 🤖 Active models
              _buildStatusIndicator(
                theme,
                Icons.psychology,
                systemStatus.healthyModelCount > 0 ? Colors.green : Colors.red,
                '${systemStatus.healthyModelCount} models',
                compact,
              ),
              
              const SizedBox(width: 16),
              
              // 💰 Budget usage
              _buildBudgetIndicator(theme, budgetUsage, compact),
              
              const Spacer(),
              
              // ⚙️ Panel toggles (desktop only)
              if (!compact) ...[
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isLeftPanelOpen = !_isLeftPanelOpen;
                    });
                  },
                  icon: const Icon(Icons.menu),
                  tooltip: 'Toggle Strategy Panel',
                ),
                
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isRightPanelOpen = !_isRightPanelOpen;
                    });
                  },
                  icon: const Icon(Icons.analytics),
                  tooltip: 'Toggle Analytics Panel',
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator(
    ThemeData theme,
    IconData icon,
    Color color,
    String label,
    bool compact,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: compact ? 16 : 18,
          color: color,
        ),
        if (!compact) ...[
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBudgetIndicator(ThemeData theme, double usage, bool compact) {
    final color = usage > 80 ? Colors.red : (usage > 60 ? Colors.orange : Colors.green);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.account_balance_wallet,
          size: compact ? 16 : 18,
          color: color,
        ),
        if (!compact) ...[
          const SizedBox(width: 6),
          Text(
            '${usage.toInt()}%',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ],
    );
  }

  // 🎛️ LEFT PANEL
  Widget _buildLeftPanel(ThemeData theme, {bool isCollapsed = false}) {
    if (isCollapsed) {
      return _buildCollapsedLeftPanel(theme);
    }
    
    return Column(
      children: [
        // 📋 Panel header
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.tune,
                size: 20,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              const SizedBox(width: 8),
              Text(
                'AI Configuration',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        // 📑 Tabbed content
        Expanded(
          child: Column(
            children: [
              // 📑 Tab bar
              TabBar(
                controller: _tabController,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
                indicatorColor: theme.colorScheme.primary,
                tabs: const [
                  Tab(text: 'Strategy'),
                  Tab(text: 'Models'),
                  Tab(text: 'Settings'),
                ],
              ),
              
              // 📄 Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildStrategyTab(theme),
                    _buildModelsTab(theme),
                    _buildSettingsTab(theme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsedLeftPanel(ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 16),
        IconButton(
          onPressed: () {
            setState(() {
              _isLeftPanelOpen = true;
            });
          },
          icon: const Icon(Icons.tune),
          tooltip: 'Open Configuration',
        ),
        const SizedBox(height: 16),
        Consumer(
          builder: (context, ref, child) {
            final activeStrategy = ref.watch(activeStrategyProvider);
            return IconButton(
              onPressed: () {
                setState(() {
                  _isLeftPanelOpen = true;
                  _tabController.index = 0;
                });
              },
              icon: Icon(_getStrategyIcon(activeStrategy)),
              tooltip: 'Strategy: ${activeStrategy.name}',
            );
          },
        ),
      ],
    );
  }

  // 📊 RIGHT PANEL
  Widget _buildRightPanel(ThemeData theme, {bool isCollapsed = false}) {
    if (isCollapsed) {
      return _buildCollapsedRightPanel(theme);
    }
    
    return Column(
      children: [
        // 📋 Panel header
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.analytics,
                size: 20,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              const SizedBox(width: 8),
              Text(
                'Analytics & Monitoring',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        // 📊 Analytics content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPerformanceMetrics(theme),
                const SizedBox(height: 16),
                _buildModelHealthCards(theme),
                const SizedBox(height: 16),
                _buildUsageStatistics(theme),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsedRightPanel(ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 16),
        IconButton(
          onPressed: () {
            setState(() {
              _isRightPanelOpen = true;
            });
          },
          icon: const Icon(Icons.analytics),
          tooltip: 'Open Analytics',
        ),
      ],
    );
  }

  // 💬 CHAT AREA
  Widget _buildChatArea(ThemeData theme) {
    return Consumer(
      builder: (context, ref, child) {
        final messages = ref.watch(chatMessagesProvider);
        final isGenerating = ref.watch(isGeneratingProvider);
        
        if (messages.isEmpty) {
          return _buildEmptyChat(theme);
        }
        
        return Column(
          children: [
            // 💬 Messages list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length + (isGenerating ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < messages.length) {
                    return MessageBubble(message: messages[index]);
                  } else {
                    // Typing indicator
                    return _buildTypingIndicator(theme);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyChat(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 🧠 Welcome icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: NeuralDesignSystem.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.psychology,
              size: 40,  
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 👋 Welcome message
          Text(
            'Welcome to NeuronVault',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Your enterprise AI orchestration platform.\nStart a conversation to begin.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // 💡 Quick actions
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildQuickActionChip(
                theme,
                'Ask about AI',
                Icons.psychology,
                () => _insertQuickPrompt('What can you tell me about artificial intelligence?'),
              ),
              _buildQuickActionChip(
                theme,
                'Code Review',
                Icons.code,
                () => _insertQuickPrompt('Please review my code for best practices'),
              ),
              _buildQuickActionChip(
                theme,
                'Creative Writing',
                Icons.edit,
                () => _insertQuickPrompt('Help me write a creative story about'),
              ),
              _buildQuickActionChip(
                theme,
                'Data Analysis',
                Icons.analytics,
                () => _insertQuickPrompt('Analyze this data and provide insights:'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionChip(
    ThemeData theme,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(icon, size: 16),
      label: Text(label),
      backgroundColor: theme.colorScheme.surface,
      side: BorderSide(
        color: theme.colorScheme.outline.withOpacity(0.3),
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: theme.colorScheme.primary,
            child: const Icon(Icons.psychology, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'AI is thinking...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🎯 TAB CONTENT BUILDERS
  Widget _buildStrategyTab(ThemeData theme) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: StrategySelector(),
    );
  }

  Widget _buildModelsTab(ThemeData theme) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: ModelGrid(),
    );
  }

  Widget _buildSettingsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'General Settings',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Theme selector
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            subtitle: const Text('Neural Dark'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Open theme selector
            },
          ),
          
          // Language selector
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: const Text('English (US)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Open language selector
            },
          ),
          
          const Divider(height: 32),
          
          Text(
            'Advanced Settings',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Export/Import
          ListTile(
            leading: const Icon(Icons.import_export),
            title: const Text('Export/Import'),
            subtitle: const Text('Backup your configuration'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Open export/import dialog
            },
          ),
          
          // Reset settings
          ListTile(
            leading: const Icon(Icons.restore, color: Colors.red),
            title: const Text('Reset Settings'),
            subtitle: const Text('Restore default configuration'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Show reset confirmation
            },
          ),
        ],
      ),
    );
  }

  // ⚡ QUICK CONTROLS
  Widget _buildQuickControls(ThemeData theme) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Consumer(
        builder: (context, ref, child) {
          final activeStrategy = ref.watch(activeStrategyProvider);
          final isGenerating = ref.watch(isGeneratingProvider);
          
          return Row(
            children: [
              // 🎛️ Strategy quick switch
              Expanded(
                child: DropdownButton<AIStrategy>(
                  value: activeStrategy,
                  onChanged: isGenerating ? null : (strategy) {
                    if (strategy != null) {
                      ref.read(strategyControllerProvider.notifier)
                          .setStrategy(strategy);
                    }
                  },
                  items: AIStrategy.values.map((strategy) {
                    return DropdownMenuItem(
                      value: strategy,
                      child: Row(
                        children: [
                          Icon(_getStrategyIcon(strategy), size: 16),
                          const SizedBox(width: 8),
                          Text(strategy.name.toUpperCase()),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // ⏹️ Stop generation button
              if (isGenerating)
                IconButton(
                  onPressed: () {
                    ref.read(chatControllerProvider.notifier).stopGeneration();
                  },
                  icon: const Icon(Icons.stop),
                  tooltip: 'Stop Generation',
                ),
            ],
          );
        },
      ),
    );
  }

  // 📊 ANALYTICS COMPONENTS
  Widget _buildPerformanceMetrics(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            // Performance metrics would go here
            const Text('Real-time metrics coming in Phase 3'),
          ],
        ),
      ),
    );
  }

  Widget _buildModelHealthCards(ThemeData theme) {
    return Consumer(
      builder: (context, ref, child) {
        final modelHealth = ref.watch(modelHealthProvider);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Model Health',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...modelHealth.entries.map((entry) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    _getHealthIcon(entry.value.status),
                    color: _getHealthColor(entry.value.status),
                  ),
                  title: Text(entry.key.name.toUpperCase()),
                  subtitle: Text('${entry.value.responseTime}ms'),
                  trailing: Text(
                    '${(entry.value.successRate * 100).toInt()}%',
                    style: TextStyle(
                      color: _getHealthColor(entry.value.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildUsageStatistics(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usage Statistics',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            // Usage statistics would go here
            const Text('Detailed analytics coming in Phase 3'),
          ],
        ),
      ),
    );
  }

  // 🔧 UTILITY METHODS
  IconData _getConnectionIcon(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return Icons.wifi;
      case ConnectionStatus.connecting:
        return Icons.wifi_find;
      case ConnectionStatus.disconnected:
        return Icons.wifi_off;
      case ConnectionStatus.error:
        return Icons.error_outline;
      case ConnectionStatus.reconnecting:
        return Icons.refresh;
    }
  }

  Color _getConnectionColor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.connecting:
        return Colors.orange;
      case ConnectionStatus.disconnected:
        return Colors.grey;
      case ConnectionStatus.error:
        return Colors.red;
      case ConnectionStatus.reconnecting:
        return Colors.amber;
    }
  }

  IconData _getStrategyIcon(AIStrategy strategy) {
    switch (strategy) {
      case AIStrategy.parallel:
        return Icons.account_tree;
      case AIStrategy.consensus:
        return Icons.how_to_vote;
      case AIStrategy.adaptive:
        return Icons.auto_awesome;
      case AIStrategy.sequential:
        return Icons.timeline;
      case AIStrategy.weighted:
        return Icons.balance;
    }
  }

  IconData _getHealthIcon(HealthStatus status) {
    switch (status) {
      case HealthStatus.healthy:
        return Icons.check_circle;
      case HealthStatus.degraded:
        return Icons.warning;
      case HealthStatus.unhealthy:
        return Icons.error;
      case HealthStatus.unknown:
        return Icons.help;
    }
  }

  Color _getHealthColor(HealthStatus status) {
    switch (status) {
      case HealthStatus.healthy:
        return Colors.green;
      case HealthStatus.degraded:
        return Colors.orange;
      case HealthStatus.unhealthy:
        return Colors.red;
      case HealthStatus.unknown:
        return Colors.grey;
    }
  }

  void _insertQuickPrompt(String prompt) {
    ref.read(chatControllerProvider.notifier).updateInput(prompt);
  }
}

enum LayoutType {
  mobile,
  tablet,
  desktop,
  ultrawide,
}