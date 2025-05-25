// lib/screens/orchestration_main_screen.dart
// 🧬 NEURONVAULT - AI ORCHESTRATION MAIN SCREEN - CORRECTED VERSION
// Real Multi-AI Orchestration with WebSocket Backend Integration

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/websocket_orchestration_service.dart';
import '../core/providers/providers_main.dart';

// 💬 ENHANCED CHAT MESSAGE MODEL
class RealOrchestrationMainScreen extends StatelessWidget {
  const RealOrchestrationMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Orchestration Main Screen')),
    );
  }
}
class ChatMessage {
  final String id;
  final String content;
  final bool isFromUser;
  final DateTime timestamp;
  final AIModelType? sourceModel;
  final MessageType messageType;
  final double? confidence;
  final Duration? responseTime;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isFromUser,
    required this.timestamp,
    this.sourceModel,
    this.messageType = MessageType.individual,
    this.confidence,
    this.responseTime,
  });

  factory ChatMessage.fromAIResponse(AIResponse response) {
    return ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_${response.modelName}',
      content: response.content,
      isFromUser: false,
      timestamp: response.timestamp,
      sourceModel: AIModelType.fromString(response.modelName),
      messageType: MessageType.individual,
      confidence: response.confidence,
      responseTime: response.responseTime,
    );
  }

  factory ChatMessage.synthesized(String content) {
    return ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_synthesis',
      content: content,
      isFromUser: false,
      timestamp: DateTime.now(),
      messageType: MessageType.synthesized,
    );
  }

  factory ChatMessage.user(String content) {
    return ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_user',
      content: content,
      isFromUser: true,
      timestamp: DateTime.now(),
      messageType: MessageType.user,
    );
  }
}

// 🤖 AI MODEL TYPES - ENHANCED
enum AIModelType {
  claude(name: 'Claude', icon: Icons.ac_unit, color: Colors.purple),
  gpt(name: 'GPT', icon: Icons.api, color: Colors.green),
  deepseek(name: 'DeepSeek', icon: Icons.search, color: Colors.blue),
  gemini(name: 'Gemini', icon: Icons.star, color: Colors.orange),
  mistral(name: 'Mistral', icon: Icons.speed, color: Colors.red),
  llama(name: 'Llama', icon: Icons.pets, color: Colors.teal),
  ollama(name: 'Ollama', icon: Icons.computer, color: Colors.cyan);

  const AIModelType({
    required this.name,
    required this.icon,
    required this.color,
  });

  final String name;
  final IconData icon;
  final Color color;

  static AIModelType? fromString(String modelName) {
    final name = modelName.toLowerCase();
    switch (name) {
      case 'claude':
        return AIModelType.claude;
      case 'gpt':
      case 'openai':
        return AIModelType.gpt;
      case 'deepseek':
        return AIModelType.deepseek;
      case 'gemini':
        return AIModelType.gemini;
      case 'mistral':
        return AIModelType.mistral;
      case 'llama':
        return AIModelType.llama;
      case 'ollama':
        return AIModelType.ollama;
      default:
        return null;
    }
  }
}

// 📝 MESSAGE TYPES
enum MessageType {
  individual,    // Response from a single AI model
  synthesized,   // Final orchestrated response
  user,         // User message
}

class OrchestrationMainScreen extends ConsumerStatefulWidget {
  const OrchestrationMainScreen({super.key});

  @override
  ConsumerState<OrchestrationMainScreen> createState() => _OrchestrationMainScreenState();
}

class _OrchestrationMainScreenState extends ConsumerState<OrchestrationMainScreen>
    with TickerProviderStateMixin {

  // 🎛️ UI STATE
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _pulseAnimationController;

  // 💬 CHAT STATE
  final List<ChatMessage> _messages = [];
  String? _currentOrchestrationId;
  bool _showOrchestrationPanel = false;
  String? _currentPrompt;

  // 📱 RESPONSIVE STATE
  bool _isLeftPanelOpen = true;
  bool _isRightPanelOpen = true;

  // 📱 RESPONSIVE BREAKPOINTS
  static const double _mobileBreakpoint = 768;
  static const double _desktopBreakpoint = 1024;

  @override
  void initState() {
    super.initState();
    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _setupOrchestrationListeners();

    debugPrint('🧬 AI Orchestration MainScreen initialized');
  }

  @override
  void dispose() {
    _pulseAnimationController.dispose();
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  /// Setup listeners for orchestration events
  void _setupOrchestrationListeners() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orchestrationService = ref.read(webSocketOrchestrationServiceProvider);

      // Listen for individual AI responses
      orchestrationService.individualResponsesStream.listen((responses) {
        for (final response in responses) {
          final existingIndex = _messages.indexWhere((msg) =>
          msg.sourceModel?.name.toLowerCase() == response.modelName.toLowerCase() &&
              msg.id.contains(_currentOrchestrationId ?? ''));

          if (existingIndex == -1) {
            // Add new individual response
            setState(() {
              _messages.add(ChatMessage.fromAIResponse(response));
            });
            _scrollToBottom();
          }
        }
      });

      // Listen for synthesized response
      orchestrationService.synthesizedResponseStream.listen((synthesis) {
        if (synthesis.isNotEmpty) {
          setState(() {
            _messages.add(ChatMessage.synthesized(synthesis));
            _showOrchestrationPanel = false;
            _currentOrchestrationId = null;
            _currentPrompt = null;
          });

          // Update orchestration state
          ref.read(isOrchestrationActiveProvider.notifier).state = false;
          ref.read(currentOrchestrationProvider.notifier).state = null;

          _scrollToBottom();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final orchestrationService = ref.watch(webSocketOrchestrationServiceProvider);
    final systemStatus = ref.watch(systemStatusProvider);
    final isOrchestrationActive = ref.watch(isOrchestrationActiveProvider);

    final isMobile = size.width < _mobileBreakpoint;
    final isDesktop = size.width >= _desktopBreakpoint;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Column(
        children: [
          _buildStatusBar(theme, orchestrationService, systemStatus, compact: isMobile),
          Expanded(
            child: isMobile
                ? _buildMobileLayout(theme)
                : isDesktop
                ? _buildDesktopLayout(theme)
                : _buildTabletLayout(theme),
          ),
        ],
      ),
    );
  }

  // 📊 ENHANCED STATUS BAR with real orchestration status
  Widget _buildStatusBar(ThemeData theme, WebSocketOrchestrationService orchestrationService,
      SystemStatus systemStatus, {bool compact = false}) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= _desktopBreakpoint;
    final isOrchestrationActive = ref.watch(isOrchestrationActiveProvider);

    return Material(
      color: theme.colorScheme.surface.withOpacity(0.9),
      elevation: 1,
      child: Container(
        height: compact ? 40 : 50,
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: compact ? 4 : 8,
        ),
        child: Row(
          children: [
            // Real connection status
            Icon(
              orchestrationService.isConnected ? Icons.wifi : Icons.wifi_off,
              color: orchestrationService.isConnected ? Colors.green : Colors.red,
              size: compact ? 16 : 18,
            ),
            if (!compact) ...[
              const SizedBox(width: 6),
              Text(
                orchestrationService.isConnected ? 'CONNECTED' : 'DISCONNECTED',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: orchestrationService.isConnected ? Colors.green : Colors.red,
                ),
              ),
            ],

            const SizedBox(width: 16),

            // Orchestration status
            if (isOrchestrationActive) ...[
              SizedBox(
                width: compact ? 12 : 16,
                height: compact ? 12 : 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: 6),
                Text('ORCHESTRATING', style: theme.textTheme.bodySmall),
              ],
            ] else ...[
              Icon(Icons.psychology,
                  color: orchestrationService.isConnected ? Colors.green : Colors.grey,
                  size: compact ? 16 : 18),
              if (!compact) ...[
                const SizedBox(width: 6),
                Text('${systemStatus.healthyModelCount} models ready',
                    style: theme.textTheme.bodySmall),
              ],
            ],

            const Spacer(),

            if (isDesktop) ...[
              IconButton(
                onPressed: () => setState(() => _isLeftPanelOpen = !_isLeftPanelOpen),
                icon: Icon(_isLeftPanelOpen ? Icons.menu_open : Icons.menu),
              ),
              IconButton(
                onPressed: () => setState(() => _isRightPanelOpen = !_isRightPanelOpen),
                icon: Icon(_isRightPanelOpen ? Icons.analytics : Icons.analytics_outlined),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 📱 LAYOUTS
  Widget _buildMobileLayout(ThemeData theme) {
    return Column(
      children: [
        if (_showOrchestrationPanel && _currentPrompt != null)
          Expanded(child: _buildOrchestrationPanel(theme))
        else
          Expanded(child: _buildChatArea(theme)),
        _buildQuickControls(theme),
        _buildChatInput(theme),
      ],
    );
  }

  Widget _buildTabletLayout(ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 280,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(right: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1))),
          ),
          child: _buildLeftPanel(theme),
        ),
        Expanded(
          child: Column(
            children: [
              if (_showOrchestrationPanel && _currentPrompt != null)
                Expanded(child: _buildOrchestrationPanel(theme))
              else
                Expanded(child: _buildChatArea(theme)),
              _buildChatInput(theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(ThemeData theme) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _isLeftPanelOpen ? 320 : 0,
          child: _isLeftPanelOpen ? Material(
            color: theme.colorScheme.surface,
            elevation: 2,
            child: _buildLeftPanel(theme),
          ) : null,
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              if (_showOrchestrationPanel && _currentPrompt != null)
                Expanded(child: _buildOrchestrationPanel(theme))
              else
                Expanded(child: _buildChatArea(theme)),
              _buildChatInput(theme),
            ],
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _isRightPanelOpen ? 300 : 0,
          child: _isRightPanelOpen ? Material(
            color: theme.colorScheme.surface,
            elevation: 2,
            child: _buildRightPanel(theme),
          ) : null,
        ),
      ],
    );
  }

  // 🧬 ORCHESTRATION PANEL PLACEHOLDER
  Widget _buildOrchestrationPanel(ThemeData theme) {
    if (_currentPrompt == null) {
      return const Center(child: Text('No active orchestration'));
    }

    // For now, show a simple placeholder until the TransparentOrchestrationPanel is fixed
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'AI Orchestration in Progress',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            'Prompt: $_currentPrompt',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  // 🎛️ LEFT PANEL - SIMPLE VERSION
  Widget _buildLeftPanel(ThemeData theme) {
    final activeModels = ref.watch(activeModelsProvider);
    final currentStrategy = ref.watch(currentStrategyProvider);

    return Column(
      children: [
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            border: Border(bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1))),
          ),
          child: Row(
            children: [
              Icon(Icons.tune, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text('AI Orchestration', style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Strategy', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Text('Current: ${currentStrategy.name}', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 24),
                Text('AI Models', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Text('Active: ${activeModels.length}', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                ...activeModels.map((model) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('• $model', style: theme.textTheme.bodySmall),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 📊 RIGHT PANEL - SIMPLE VERSION
  Widget _buildRightPanel(ThemeData theme) {
    final orchestrationService = ref.watch(webSocketOrchestrationServiceProvider);

    return Column(
      children: [
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withOpacity(0.1),
            border: Border(bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1))),
          ),
          child: Row(
            children: [
              Icon(Icons.analytics, size: 20, color: theme.colorScheme.secondary),
              const SizedBox(width: 8),
              Text('Status', style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600, color: theme.colorScheme.secondary)),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Connection: ${orchestrationService.isConnected ? "Connected" : "Disconnected"}'),
                const SizedBox(height: 8),
                Text('Messages: ${_messages.length}'),
                const SizedBox(height: 8),
                Text('Individual Responses: ${orchestrationService.individualResponses.length}'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 💬 CHAT AREA
  Widget _buildChatArea(ThemeData theme) {
    if (_messages.isEmpty) {
      return _buildEmptyChat(theme);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(theme, message);
      },
    );
  }

  // 🗨️ MESSAGE BUBBLE
  Widget _buildMessageBubble(ThemeData theme, ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: message.isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isFromUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: message.messageType == MessageType.synthesized
                    ? Colors.deepPurple
                    : message.sourceModel?.color ?? Colors.grey,
              ),
              child: Icon(
                message.messageType == MessageType.synthesized
                    ? Icons.psychology
                    : message.sourceModel?.icon ?? Icons.smart_toy,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isFromUser
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: !message.isFromUser ? Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!message.isFromUser && message.sourceModel != null) ...[
                    Text(
                      message.sourceModel!.name.toUpperCase(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: message.sourceModel!.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    message.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: message.isFromUser ? Colors.white : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isFromUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(0.2),
              ),
              child: Icon(Icons.person, color: theme.colorScheme.primary, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  // 💬 EMPTY CHAT
  Widget _buildEmptyChat(ThemeData theme) {
    final orchestrationService = ref.watch(webSocketOrchestrationServiceProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimationController,
            builder: (context, child) {
              return Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(0.8 + 0.2 * _pulseAnimationController.value),
                ),
                child: const Icon(Icons.psychology, size: 40, color: Colors.white),
              );
            },
          ),
          const SizedBox(height: 24),
          Text('Welcome to NeuronVault', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'AI Orchestration Platform\nTransparent multi-AI orchestration',
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.7)),
            textAlign: TextAlign.center,
          ),
          if (!orchestrationService.isConnected) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Text('Backend not connected', style: TextStyle(color: Colors.orange)),
            ),
          ],
        ],
      ),
    );
  }

  // ⚡ QUICK CONTROLS
  Widget _buildQuickControls(ThemeData theme) {
    final currentStrategy = ref.watch(currentStrategyProvider);
    final activeModels = ref.watch(activeModelsProvider);

    return Material(
      color: theme.colorScheme.surface,
      elevation: 1,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Text('${currentStrategy.name} • ${activeModels.length} models',
                style: theme.textTheme.bodySmall),
            const Spacer(),
            if (_messages.isNotEmpty) ...[
              TextButton(
                onPressed: () => setState(() => _messages.clear()),
                child: Text('Clear', style: TextStyle(color: theme.colorScheme.error)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 📝 CHAT INPUT
  Widget _buildChatInput(ThemeData theme) {
    final orchestrationService = ref.watch(webSocketOrchestrationServiceProvider);
    final isOrchestrationActive = ref.watch(isOrchestrationActiveProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: orchestrationService.isConnected && !isOrchestrationActive,
              decoration: InputDecoration(
                hintText: !orchestrationService.isConnected
                    ? 'Backend not connected...'
                    : isOrchestrationActive
                    ? 'AI orchestration in progress...'
                    : 'Ask multiple AIs...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (message) {
                if (message.trim().isNotEmpty && orchestrationService.isConnected && !isOrchestrationActive) {
                  _sendMessage(message);
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            onPressed: orchestrationService.isConnected && !isOrchestrationActive ? () {
              final message = _messageController.text.trim();
              if (message.isNotEmpty) {
                _sendMessage(message);
              }
            } : null,
            backgroundColor: orchestrationService.isConnected
                ? theme.colorScheme.primary
                : Colors.grey,
            child: Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // 🚀 SEND MESSAGE (SIMPLIFIED)
  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final orchestrationService = ref.read(webSocketOrchestrationServiceProvider);
    final activeModels = ref.read(activeModelsProvider);
    final currentStrategy = ref.read(currentStrategyProvider);

    if (!orchestrationService.isConnected) {
      _showErrorSnackBar('Backend not connected');
      return;
    }

    // Add user message
    final userMessage = ChatMessage.user(message.trim());
    setState(() {
      _messages.add(userMessage);
      _showOrchestrationPanel = true;
      _currentPrompt = message.trim();
    });

    // Generate conversation ID
    final conversationId = 'conv_${DateTime.now().millisecondsSinceEpoch}';
    _currentOrchestrationId = conversationId;

    // Update state
    ref.read(isOrchestrationActiveProvider.notifier).state = true;
    ref.read(currentOrchestrationProvider.notifier).state = conversationId;

    _messageController.clear();
    _scrollToBottom();

    try {
      debugPrint('🧬 Starting orchestration: $message');

      // Start orchestration
      await orchestrationService.orchestrateAIRequest(
        prompt: message.trim(),
        selectedModels: activeModels,
        strategy: currentStrategy,
        conversationId: conversationId,
      );
    } catch (error) {
      debugPrint('❌ Orchestration error: $error');
      _showErrorSnackBar('Orchestration failed: $error');
    }
  }

  // 🔧 UTILITY METHODS
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red[700]),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}