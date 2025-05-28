// lib/widgets/orchestration/transparent_orchestration_panel.dart
// 🧠 Transparent AI Orchestration Panel - FIXED VERSION
// Shows real-time multi-AI responses and synthesis process

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // FIXED: Corrected import

import '../../core/services/websocket_orchestration_service.dart';
import '../../core/providers/providers_main.dart'; // FIXED: Corrected import

/// 🧠 Transparent AI Orchestration Panel
/// Shows real-time multi-AI responses and synthesis process
class TransparentOrchestrationPanel extends ConsumerStatefulWidget {
  final String prompt;
  final List<String> selectedModels;
  final OrchestrationStrategy strategy;
  final Map<String, double>? modelWeights;

  const TransparentOrchestrationPanel({
    super.key,
    required this.prompt,
    required this.selectedModels,
    required this.strategy,
    this.modelWeights,
  });

  @override
  ConsumerState<TransparentOrchestrationPanel> createState() => _TransparentOrchestrationPanelState();
}

class _TransparentOrchestrationPanelState extends ConsumerState<TransparentOrchestrationPanel>
    with TickerProviderStateMixin {

  late AnimationController _pulseController;
  late AnimationController _synthesisController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _synthesisAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for active models
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Synthesis animation
    _synthesisController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _synthesisAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _synthesisController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _synthesisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orchestrationService = ref.watch(webSocketOrchestrationServiceProvider); // FIXED: Using ref.watch correctly

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[900]!,
            Colors.grey[850]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.deepPurple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildProgressIndicator(orchestrationService),
          const SizedBox(height: 24),
          _buildIndividualResponses(orchestrationService),
          const SizedBox(height: 24),
          _buildSynthesisSection(orchestrationService),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.psychology,
            color: Colors.deepPurple,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI Orchestration in Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Strategy: ${widget.strategy.name.toUpperCase()} • Models: ${widget.selectedModels.length}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
        _buildStrategyIcon(),
      ],
    );
  }

  Widget _buildStrategyIcon() {
    IconData icon;
    Color color;

    switch (widget.strategy) {
      case OrchestrationStrategy.parallel:
        icon = Icons.blur_on;
        color = Colors.blue;
        break;
      case OrchestrationStrategy.consensus:
        icon = Icons.group_work;
        color = Colors.green;
        break;
      case OrchestrationStrategy.weighted:
        icon = Icons.balance;
        color = Colors.orange;
        break;
      case OrchestrationStrategy.adaptive:
        icon = Icons.auto_awesome;
        color = Colors.purple;
        break;
      case OrchestrationStrategy.sequential:
        icon = Icons.linear_scale;
        color = Colors.teal;
        break;
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2 * _pulseAnimation.value),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(_pulseAnimation.value),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(WebSocketOrchestrationService service) {
    // Simplified progress indicator since we don't have the stream working yet
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Processing...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              'Active',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            backgroundColor: Colors.grey[700],
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.deepPurple,
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildIndividualResponses(WebSocketOrchestrationService service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Individual AI Responses',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        // Show placeholder cards for selected models
        ...widget.selectedModels.map((model) => _buildPlaceholderCard(model)),
      ],
    );
  }

  Widget _buildPlaceholderCard(String modelName) {
    final color = _getModelColor(modelName);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[800]!.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(_pulseAnimation.value * 0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color.withOpacity(_pulseAnimation.value),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        modelName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            color.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSynthesisSection(WebSocketOrchestrationService service) {
    // Check if we have a synthesized response
    final synthesis = service.synthesizedResponse;

    if (synthesis == null || synthesis.isEmpty) {
      return _buildSynthesisPlaceholder();
    }

    // Show the actual synthesis
    return AnimatedBuilder(
      animation: _synthesisAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * _synthesisAnimation.value),
          child: Opacity(
            opacity: _synthesisAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurple.withOpacity(0.2),
                    Colors.blue.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.deepPurple.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.deepPurple,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'AI Orchestrated Synthesis',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    synthesis,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSynthesisPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[800]!.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[600]!.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.grey[500],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Waiting for AI Synthesis...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Column(
                children: List.generate(3, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[700]!.withOpacity(
                            0.3 + (0.2 * _pulseAnimation.value)
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getModelColor(String modelName) {
    switch (modelName.toLowerCase()) {
      case 'claude':
        return Colors.orange;
      case 'gpt':
      case 'openai':
        return Colors.green;
      case 'deepseek':
        return Colors.blue;
      case 'gemini':
        return Colors.purple;
      case 'mistral':
        return Colors.red;
      case 'llama':
        return Colors.teal;
      case 'ollama':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }
}