import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math' as math;
import 'package:provider/provider.dart';

import '../models/ai_agent.dart';
import '../models/conversation_mode.dart';
import '../services/api_service.dart';
import '../widgets/messaging/multimodal_message_bubble.dart';
import '../widgets/input/photo_input_button.dart';
import '../widgets/utils/demo_messages.dart';
import '../widgets/ui/glass_container.dart';
import '../widgets/ui/dynamic_background.dart';
import '../widgets/ui/mode_icon.dart';
import '../widgets/team_collaboration_view.dart';
import '../widgets/synthesis_visualizer.dart';
import '../providers/app_state_provider.dart';

bool get isDemoMode => ApiService.useMockData;

class AiChatScreenUpdated extends StatefulWidget {
  final bool showDemoMessages;

  const AiChatScreenUpdated({
    super.key,
    this.showDemoMessages = false,
  });

  @override
  State<AiChatScreenUpdated> createState() => _AiChatScreenUpdatedState();
}

class _AiChatScreenUpdatedState extends State<AiChatScreenUpdated> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  bool _showCollaborationView = true;
  bool _showSynthesisDetails = false;
  Map<String, String> _currentResponses = {};
  Map<String, double> _currentWeights = {};
  String _synthesizedResponse = '';
  bool _isLoading = false;
  bool _isScrolled = false;
  List<AiConversationMessage> _conversation = [];
  String _conversationId = DateTime.now().millisecondsSinceEpoch.toString();
  ConversationMode _currentMode = ConversationMode.chat;

  // Controllori per le animazioni
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _rotateController;
  late Animation<double> _rotateAnimation;

  late AnimationController _backgroundAnimController;
  late Animation<double> _backgroundAnimation;

  int _activeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _scrollController.addListener(_handleScroll);
    if (widget.showDemoMessages) _loadDemoMessages();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuad),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    _rotateAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
    );
    _rotateController.repeat();

    _backgroundAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    _backgroundAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _backgroundAnimController, curve: Curves.easeInOut),
    );
    _backgroundAnimController.repeat(reverse: true);

    _animationController.forward();
    _activeTabIndex = _currentMode.index;
  }

  void _handleScroll() {
    setState(() {
      _isScrolled = _scrollController.offset > 10;
    });
  }

  void _loadDemoMessages() {
    setState(() {
      _conversation = DemoMessages.getForMode(_currentMode);
    });
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _backgroundAnimController.dispose();
    super.dispose();
  }

  void _sendPrompt() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;

    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final weights = appState.modelWeights;

    setState(() {
      _isLoading = true;
      _conversation.add(AiConversationMessage(
        agent: 'user',
        message: prompt,
        timestamp: DateTime.now(),
      ));
      _controller.clear();
    });

    _scrollToBottom();

    try {
      final aiResp = await ApiService.askAgents(
        prompt,
        conversationId: _conversationId,
        mode: _currentMode,
        weights: weights,
      );

      setState(() {
        _conversation = aiResp.conversation;
        _currentResponses = aiResp.responses;
        _currentWeights = aiResp.weights;
        _synthesizedResponse = aiResp.synthesizedResponse;
        _isLoading = false;

        // In demo mode, ensure weights match app state
        if (isDemoMode) {
          _currentWeights = Map<String, double>.from(appState.modelWeights);
        }
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _conversation.add(AiConversationMessage(
          agent: 'system',
          message: 'Errore: ${e.toString()}',
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });

      if (mounted) {
        _showErrorSnackbar('Errore di comunicazione con i servizi AI');
      }
    }
  }

  void _handleWeightChange(String model, double weight) {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    appState.updateModelWeight(model, weight);

    // In demo mode, update weights immediately for visual feedback
    if (isDemoMode) {
      setState(() {
        _currentWeights = Map<String, double>.from(appState.modelWeights);

        // Generate new mock responses with updated weights
        if (_conversation.isNotEmpty && _conversation.last.agent == 'user') {
          final lastPrompt = _conversation.last.message;
          _currentResponses = MockResponses.getMockResponses(lastPrompt, _currentMode);
          _synthesizedResponse = MockResponses.getMockSynthesizedResponse(lastPrompt, _currentMode);
        }
      });
    }
  }

  void _handleResetWeights() {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    appState.resetModelWeights();

    setState(() {
      _currentWeights = appState.modelWeights;

      // In demo mode, regenerate responses
      if (isDemoMode && _conversation.isNotEmpty && _conversation.last.agent == 'user') {
        final lastPrompt = _conversation.last.message;
        _currentResponses = MockResponses.getMockResponses(lastPrompt, _currentMode);
        _synthesizedResponse = MockResponses.getMockSynthesizedResponse(lastPrompt, _currentMode);
      }
    });
  }

  void _handleApplyPreset(Map<String, double> presetWeights) {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    appState.applyPresetWeights(presetWeights);

    // In demo mode, update weights immediately
    if (isDemoMode) {
      setState(() {
        _currentWeights = Map<String, double>.from(presetWeights);

        // Generate new mock responses with updated weights
        if (_conversation.isNotEmpty && _conversation.last.agent == 'user') {
          final lastPrompt = _conversation.last.message;
          _currentResponses = MockResponses.getMockResponses(lastPrompt, _currentMode);
          _synthesizedResponse = MockResponses.getMockSynthesizedResponse(lastPrompt, _currentMode);
        }
      });
    }
  }

  void _handlePhotoSelected(XFile photo) async {
    String prompt = _controller.text.trim().isEmpty
        ? "Descrivi questa immagine"
        : _controller.text.trim();

    setState(() {
      _isLoading = true;
      _conversation.add(AiConversationMessage(
        agent: 'user',
        message: prompt,
        mediaUrl: photo.path,
        mediaType: 'image/jpeg',
        timestamp: DateTime.now(),
      ));
      _controller.clear();
    });

    _scrollToBottom();

    try {
      final aiResp = await ApiService.uploadImage(
        prompt,
        File(photo.path),
        conversationId: _conversationId,
      );
      setState(() {
        _conversation = aiResp.conversation;
        _currentResponses = aiResp.responses;
        _currentWeights = aiResp.weights;
        _synthesizedResponse = aiResp.synthesizedResponse;
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _conversation.add(AiConversationMessage(
          agent: 'system',
          message: 'Errore durante l\'elaborazione dell\'immagine',
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });

      _showErrorSnackbar('Errore durante l\'elaborazione dell\'immagine');
    }
  }

  void _resetChat() {
    _animationController.reverse().then((_) {
      setState(() {
        if (widget.showDemoMessages) {
          _conversation = DemoMessages.getForMode(_currentMode);
        } else {
          _conversation.clear();
        }
        _controller.clear();
        _conversationId = DateTime.now().millisecondsSinceEpoch.toString();
      });
      _animationController.forward();
      if (widget.showDemoMessages) {
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      }
    });
  }

  void _changeMode(ConversationMode mode) {
    if (_currentMode == mode) return;

    final newIndex = mode.index;
    _animationController.reverse().then((_) {
      setState(() {
        _currentMode = mode;
        _activeTabIndex = newIndex;
        if (widget.showDemoMessages) {
          _conversation = DemoMessages.getForMode(mode);
        } else {
          _conversation.clear();
        }
      });
      _animationController.forward();
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    });
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

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
          textColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DynamicBackground(
      child: Stack(
        children: [
          Positioned.fill(child: _buildBackgroundParticles()),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Row(
                children: [
                  AnimatedBuilder(
                      animation: _isLoading ? _pulseController : const AlwaysStoppedAnimation(0),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _isLoading ? (_pulseAnimation.value * 0.1 + 0.9) : 1.0,
                          child: const Text('Team AI'),
                        );
                      }
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _currentMode.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: isDark
                  ? theme.colorScheme.surface.withOpacity(0.8)
                  : theme.colorScheme.surface,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  color: theme.colorScheme.primary,
                  onPressed: _resetChat,
                  tooltip: 'Nuova conversazione',
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  _buildDynamicModeSelector(),
                  Expanded(
                    child: GlassContainer(
                      borderRadius: 24,
                      blur: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      backgroundColor: isDark
                          ? Colors.black.withOpacity(0.2)
                          : Colors.white.withOpacity(0.15),
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: child,
                            ),
                          );
                        },
                        child: _conversation.isEmpty && !_isLoading
                            ? _buildWelcomeSection()
                            : _buildConversationList(),
                      ),
                    ),
                  ),
                  if (_showCollaborationView && _currentResponses.isNotEmpty)
                    SizedBox(
                      height: 300,
                      child: TeamCollaborationView(
                        prompt: _conversation.isNotEmpty && _conversation.last.agent == 'user'
                            ? _conversation.last.message
                            : '',
                        responses: _currentResponses,
                        weights: _currentWeights,
                        synthesizedResponse: _synthesizedResponse,
                        isProcessing: _isLoading,
                        onWeightChanged: _handleWeightChange,
                        onResetWeights: _handleResetWeights,
                        onApplyPreset: _handleApplyPreset,
                      ),
                    ),
                  if (_showSynthesisDetails && _currentResponses.isNotEmpty)
                    SizedBox(
                      height: 350,
                      child: SynthesisVisualizer(
                        inputTexts: _currentResponses,
                        weights: _currentWeights,
                        outputText: _synthesizedResponse,
                        isProcessing: _isLoading,
                        progress: 0.8,
                      ),
                    ),
                  _buildInputSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundParticles() {
    return AnimatedBuilder(
      animation: _backgroundAnimController,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlesPainter(
            progress: _backgroundAnimController.value,
            isDark: Theme.of(context).brightness == Brightness.dark,
            primaryColor: Theme.of(context).colorScheme.primary,
          ),
          child: Container(),
        );
      },
    );
  }

  Widget _buildDynamicModeSelector() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 20,
      blur: 10,
      backgroundColor: isDark
          ? theme.colorScheme.surface.withOpacity(0.2)
          : theme.colorScheme.surface.withOpacity(0.1),
      border: Border.all(
        color: theme.colorScheme.primary.withOpacity(0.2),
        width: 1.5,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ConversationMode.values.map((mode) =>
              _buildModeOption(mode, mode.name, mode.icon)
          ).toList(),
        ),
      ),
    );
  }

  Widget _buildModeOption(ConversationMode mode, String label, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _currentMode == mode;
    final color = mode.getBaseColor(isDark);

    return GestureDetector(
      onTap: () => _changeMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? color.withOpacity(0.2) : color.withOpacity(0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ] : null,
          border: isSelected
              ? Border.all(color: color.withOpacity(0.3), width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedModeIcon(
              mode: mode,
              isSelected: isSelected,
              size: 24,
            ),
            const SizedBox(width: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isSelected ? 14 : 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(24),
        borderRadius: 16,
        backgroundColor: isDark
            ? theme.colorScheme.surface.withOpacity(0.5)
            : theme.colorScheme.surface.withOpacity(0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedModeIcon(
              mode: _currentMode,
              isSelected: true,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _currentMode.welcomeMessage,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Scrivi la tua richiesta per iniziare',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: _conversation.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, i) {
        if (_isLoading && i == _conversation.length) {
          return _buildLoadingIndicator();
        }

        final message = _conversation[i];
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: 1.0,
          child: MultimodalMessageBubble(
            agent: message.toAiAgent(),
            text: message.getFormattedMessage(),
            selectable: true,
            mediaUrl: message.mediaUrl,
            mediaType: message.mediaType,
            timestamp: message.timestamp,
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(
              "Le AI stanno pensando...",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 0,
      blur: 8,
      backgroundColor: isDark
          ? theme.colorScheme.surface.withOpacity(0.7)
          : theme.colorScheme.surface.withOpacity(0.8),
      child: Row(
        children: [
          PhotoInputButton(
            onPhotoSelected: _handlePhotoSelected,
            isLoading: _isLoading,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: _currentMode.placeholderText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark
                    ? Colors.grey.shade800.withOpacity(0.6)
                    : Colors.grey.shade100.withOpacity(0.8),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              maxLines: 3,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendPrompt(),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _controller.text.trim().isNotEmpty ? _sendPrompt : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: _controller.text.trim().isNotEmpty
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
                boxShadow: _controller.text.trim().isNotEmpty
                    ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ]
                    : [],
              ),
              child: Icon(
                Icons.send,
                color: theme.colorScheme.onPrimary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ParticlesPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  final Color primaryColor;

  ParticlesPainter({
    required this.progress,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final particleCount = 30;
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < particleCount; i++) {
      final seed = i * 0.1;
      final x = (math.sin(seed + progress * math.pi) * 0.5 + 0.5) * size.width;
      final y = (math.cos(seed * 1.5 + progress * math.pi) * 0.5 + 0.5) * size.height;

      paint.color = primaryColor.withOpacity(0.1);
      canvas.drawCircle(Offset(x, y), 2.0, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) => true;
}
