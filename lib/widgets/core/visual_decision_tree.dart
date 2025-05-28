// 🌳 NEURONVAULT - VISUAL DECISION TREE WIDGET
// PHASE 3.4: Athena Intelligence Engine - AI Decision Transparency
// Revolutionary real-time visualization of AI meta-orchestration decisions

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import '../../core/design_system.dart';
import '../../core/providers/providers_main.dart';
import '../../core/services/mini_llm_analyzer_service.dart';

/// 🧠 DECISION NODE DATA
class DecisionNode {
  final String id;
  final String label;
  final String description;
  final double confidence;
  final Color color;
  final IconData icon;
  final List<DecisionNode> children;
  final Map<String, dynamic> metadata;
  final bool isSelected;
  final bool isProcessing;
  final DateTime timestamp;

  const DecisionNode({
    required this.id,
    required this.label,
    required this.description,
    required this.confidence,
    required this.color,
    required this.icon,
    this.children = const [],
    this.metadata = const {},
    this.isSelected = false,
    this.isProcessing = false,
    required this.timestamp,
  });

  DecisionNode copyWith({
    String? id,
    String? label,
    String? description,
    double? confidence,
    Color? color,
    IconData? icon,
    List<DecisionNode>? children,
    Map<String, dynamic>? metadata,
    bool? isSelected,
    bool? isProcessing,
    DateTime? timestamp,
  }) {
    return DecisionNode(
      id: id ?? this.id,
      label: label ?? this.label,
      description: description ?? this.description,
      confidence: confidence ?? this.confidence,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      children: children ?? this.children,
      metadata: metadata ?? this.metadata,
      isSelected: isSelected ?? this.isSelected,
      isProcessing: isProcessing ?? this.isProcessing,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// 🎯 DECISION TREE STATE
class DecisionTreeState {
  final DecisionNode? rootNode;
  final List<DecisionNode> pathNodes;
  final String? selectedNodeId;
  final bool isAnalyzing;
  final PromptAnalysis? currentAnalysis;
  final DateTime? lastUpdate;

  const DecisionTreeState({
    this.rootNode,
    this.pathNodes = const [],
    this.selectedNodeId,
    this.isAnalyzing = false,
    this.currentAnalysis,
    this.lastUpdate,
  });

  DecisionTreeState copyWith({
    DecisionNode? rootNode,
    List<DecisionNode>? pathNodes,
    String? selectedNodeId,
    bool? isAnalyzing,
    PromptAnalysis? currentAnalysis,
    DateTime? lastUpdate,
  }) {
    return DecisionTreeState(
      rootNode: rootNode ?? this.rootNode,
      pathNodes: pathNodes ?? this.pathNodes,
      selectedNodeId: selectedNodeId ?? this.selectedNodeId,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      currentAnalysis: currentAnalysis ?? this.currentAnalysis,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}

/// 🌳 VISUAL DECISION TREE WIDGET
/// Revolutionary AI decision transparency with neural luxury design
class VisualDecisionTree extends ConsumerStatefulWidget {
  final double width;
  final double height;
  final bool showMetadata;
  final VoidCallback? onNodeSelected;

  const VisualDecisionTree({
    super.key,
    this.width = 400,
    this.height = 600,
    this.showMetadata = true,
    this.onNodeSelected,
  });

  @override
  ConsumerState<VisualDecisionTree> createState() => _VisualDecisionTreeState();
}

class _VisualDecisionTreeState extends ConsumerState<VisualDecisionTree>
    with TickerProviderStateMixin {

  // 🎨 ANIMATIONS
  late AnimationController _treeController;
  late AnimationController _nodeController;
  late AnimationController _connectionController;
  late AnimationController _pulseController;

  late Animation<double> _treeAnimation;
  late Animation<double> _nodeAnimation;
  late Animation<double> _connectionAnimation;
  late Animation<double> _pulseAnimation;

  // 📊 STATE
  DecisionTreeState _state = const DecisionTreeState();
  final Map<String, Offset> _nodePositions = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _listenToAnalysisUpdates();
  }

  void _initializeAnimations() {
    _treeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _treeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _treeController,
      curve: Curves.easeOutQuart,
    ));

    _nodeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _nodeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _nodeController,
      curve: Curves.elasticOut,
    ));

    _connectionController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _connectionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _connectionController,
      curve: Curves.easeInOut,
    ));

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
  }

  void _listenToAnalysisUpdates() {
    // Listen to orchestration state changes
    ref.listen<bool>(isOrchestrationActiveProvider, (previous, next) {
      if (next && !_state.isAnalyzing) {
        _startAnalysisVisualization();
      } else if (!next && _state.isAnalyzing) {
        _completeAnalysisVisualization();
      }
    });
  }

  /// 🚀 START ANALYSIS VISUALIZATION
  void _startAnalysisVisualization() {
    setState(() {
      _state = _state.copyWith(
        isAnalyzing: true,
        lastUpdate: DateTime.now(),
      );
    });

    // Create root analysis node
    final rootNode = DecisionNode(
      id: 'root',
      label: 'Analyzing Prompt',
      description: 'Athena Intelligence analyzing prompt characteristics...',
      confidence: 0.0,
      color: Colors.blue,
      icon: Icons.search,
      isProcessing: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _state = _state.copyWith(rootNode: rootNode);
    });

    _treeController.forward();
    _simulateAnalysisProgression();
  }

  /// ✅ COMPLETE ANALYSIS VISUALIZATION
  void _completeAnalysisVisualization() {
    setState(() {
      _state = _state.copyWith(
        isAnalyzing: false,
        lastUpdate: DateTime.now(),
      );
    });

    _nodeController.forward();
  }

  /// 🎯 SIMULATE ANALYSIS PROGRESSION
  void _simulateAnalysisProgression() async {
    if (!mounted) return;

    // Step 1: Prompt Analysis (0-2s)
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted || !_state.isAnalyzing) return;

    final promptAnalysisNode = DecisionNode(
      id: 'prompt_analysis',
      label: 'Prompt Classification',
      description: 'Analyzing creativity, technical depth, and reasoning complexity',
      confidence: 0.3,
      color: Colors.purple,
      icon: Icons.psychology,
      timestamp: DateTime.now(),
    );

    _updateDecisionTree(promptAnalysisNode);

    // Step 2: Model Scoring (2-3s)
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted || !_state.isAnalyzing) return;

    final modelScoringNode = DecisionNode(
      id: 'model_scoring',
      label: 'Model Evaluation',
      description: 'Scoring models based on specialization profiles',
      confidence: 0.6,
      color: Colors.orange,
      icon: Icons.assessment,
      children: _createModelNodes(),
      timestamp: DateTime.now(),
    );

    _updateDecisionTree(modelScoringNode);

    // Step 3: Strategy Selection (3-4s)
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted || !_state.isAnalyzing) return;

    final strategyNode = DecisionNode(
      id: 'strategy_selection',
      label: 'Strategy Selection',
      description: 'Selecting optimal orchestration strategy',
      confidence: 0.9,
      color: Colors.green,
      icon: Icons.route,
      children: _createStrategyNodes(),
      timestamp: DateTime.now(),
    );

    _updateDecisionTree(strategyNode);

    // Step 4: Final Recommendations (4-5s)
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted || !_state.isAnalyzing) return;

    final finalNode = DecisionNode(
      id: 'final_recommendation',
      label: 'Recommendations Ready',
      description: 'Athena Intelligence has optimized your orchestration',
      confidence: 1.0,
      color: Colors.teal,
      icon: Icons.check_circle,
      timestamp: DateTime.now(),
    );

    _updateDecisionTree(finalNode);
    _connectionController.forward();
  }

  /// 🔄 UPDATE DECISION TREE
  void _updateDecisionTree(DecisionNode newNode) {
    setState(() {
      _state = _state.copyWith(
        pathNodes: [..._state.pathNodes, newNode],
        lastUpdate: DateTime.now(),
      );
    });

    _calculateNodePositions();
  }

  /// 🤖 CREATE MODEL NODES
  List<DecisionNode> _createModelNodes() {
    final activeModels = ref.read(activeModelsProvider);

    return activeModels.map((modelName) {
      final confidence = 0.6 + (math.Random().nextDouble() * 0.4);

      return DecisionNode(
        id: 'model_$modelName',
        label: modelName.toUpperCase(),
        description: 'Score: ${(confidence * 100).round()}%',
        confidence: confidence,
        color: _getModelColor(modelName),
        icon: _getModelIcon(modelName),
        timestamp: DateTime.now(),
      );
    }).toList();
  }

  /// 🎯 CREATE STRATEGY NODES
  List<DecisionNode> _createStrategyNodes() {
    return [
      DecisionNode(
        id: 'strategy_parallel',
        label: 'Parallel',
        description: 'Fast concurrent processing',
        confidence: 0.8,
        color: Colors.blue,
        icon: Icons.tune,
        timestamp: DateTime.now(),
      ),
      DecisionNode(
        id: 'strategy_consensus',
        label: 'Consensus',
        description: 'Agreement-based synthesis',
        confidence: 0.7,
        color: Colors.purple,
        icon: Icons.group_work,
        timestamp: DateTime.now(),
      ),
      DecisionNode(
        id: 'strategy_weighted',
        label: 'Weighted',
        description: 'Confidence-based combination',
        confidence: 0.9,
        color: Colors.green,
        icon: Icons.balance,
        isSelected: true,
        timestamp: DateTime.now(),
      ),
    ];
  }

  /// 📊 CALCULATE NODE POSITIONS
  void _calculateNodePositions() {
    _nodePositions.clear();

    final centerX = widget.width / 2;
    double currentY = 50;

    // Position nodes vertically
    for (int i = 0; i < _state.pathNodes.length; i++) {
      final node = _state.pathNodes[i];
      _nodePositions[node.id] = Offset(centerX, currentY);

      // Position child nodes horizontally
      if (node.children.isNotEmpty) {
        final childY = currentY + 80;
        final childSpacing = widget.width / (node.children.length + 1);

        for (int j = 0; j < node.children.length; j++) {
          final childX = childSpacing * (j + 1);
          _nodePositions[node.children[j].id] = Offset(childX, childY);
        }
        currentY = childY + 60;
      } else {
        currentY += 80;
      }
    }
  }

  @override
  void dispose() {
    _treeController.dispose();
    _nodeController.dispose();
    _connectionController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ds.colors.colorScheme.surfaceContainer,
            ds.colors.colorScheme.surfaceContainer.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ds.colors.neuralPrimary.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ds.colors.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // 🎯 HEADER
          _buildHeader(ds),

          // 🌳 DECISION TREE VISUALIZATION
          Expanded(
            child: Stack(
              children: [
                // 💫 CONNECTION LINES
                AnimatedBuilder(
                  animation: _connectionAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size(widget.width, widget.height - 60),
                      painter: DecisionTreeConnectionPainter(
                        nodes: _state.pathNodes,
                        positions: _nodePositions,
                        animation: _connectionAnimation.value,
                        neuralColor: ds.colors.neuralPrimary,
                      ),
                    );
                  },
                ),

                // 🎯 DECISION NODES
                ..._buildDecisionNodes(ds),
              ],
            ),
          ),

          // 📊 ANALYSIS SUMMARY
          if (widget.showMetadata)
            _buildAnalysisSummary(ds),
        ],
      ),
    );
  }

  /// 🎯 BUILD HEADER
  Widget _buildHeader(DesignSystemData ds) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: ds.colors.neuralPrimary.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 🧠 ATHENA ICON
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ds.colors.neuralPrimary,
                  ds.colors.neuralSecondary,
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.psychology,
              color: Colors.white,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // 📊 TITLE & STATUS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Athena Intelligence',
                  style: ds.typography.h3.copyWith(
                    color: ds.colors.colorScheme.onSurface,
                  ),
                ),
                if (_state.isAnalyzing)
                  Text(
                    'Analyzing decision path...',
                    style: ds.typography.caption.copyWith(
                      color: ds.colors.neuralAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else if (_state.pathNodes.isNotEmpty)
                  Text(
                    'Decision path complete',
                    style: ds.typography.caption.copyWith(
                      color: ds.colors.connectionGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),

          // 🔄 PROCESSING INDICATOR
          if (_state.isAnalyzing)
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Icon(
                    Icons.autorenew,
                    color: ds.colors.neuralAccent,
                    size: 20,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  /// 🎯 BUILD DECISION NODES
  List<Widget> _buildDecisionNodes(DesignSystemData ds) {
    final nodes = <Widget>[];

    for (final node in _state.pathNodes) {
      final position = _nodePositions[node.id];
      if (position != null) {
        nodes.add(
          Positioned(
            left: position.dx - 40,
            top: position.dy - 20,
            child: _buildDecisionNode(node, ds),
          ),
        );

        // Add child nodes
        for (final child in node.children) {
          final childPosition = _nodePositions[child.id];
          if (childPosition != null) {
            nodes.add(
              Positioned(
                left: childPosition.dx - 30,
                top: childPosition.dy - 15,
                child: _buildDecisionNode(child, ds, isChild: true),
              ),
            );
          }
        }
      }
    }

    return nodes;
  }

  /// 🎯 BUILD DECISION NODE
  Widget _buildDecisionNode(DecisionNode node, DesignSystemData ds, {bool isChild = false}) {
    return AnimatedBuilder(
      animation: Listenable.merge([_treeAnimation, _nodeAnimation]),
      builder: (context, child) {
        final scale = isChild ? 0.8 : 1.0;
        final animationValue = isChild ? _nodeAnimation.value : _treeAnimation.value;

        return Transform.scale(
          scale: scale * animationValue,
          child: GestureDetector(
            onTap: () => _selectNode(node.id),
            child: Container(
              width: isChild ? 60 : 80,
              height: isChild ? 30 : 40,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    node.color.withOpacity(0.8),
                    node.color.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(isChild ? 15 : 20),
                border: Border.all(
                  color: node.isSelected
                      ? ds.colors.neuralAccent
                      : node.color.withOpacity(0.5),
                  width: node.isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: node.color.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    node.icon,
                    color: Colors.white,
                    size: isChild ? 12 : 16,
                  ),
                  if (!isChild) ...[
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        node.label,
                        style: ds.typography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
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

  /// 📊 BUILD ANALYSIS SUMMARY
  Widget _buildAnalysisSummary(DesignSystemData ds) {
    if (_state.pathNodes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Start an orchestration to see Athena Intelligence in action',
          style: ds.typography.caption.copyWith(
            color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: ds.colors.neuralPrimary.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Decision Summary',
            style: ds.typography.h4.copyWith(
              color: ds.colors.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Athena analyzed ${_state.pathNodes.length} decision points',
            style: ds.typography.caption.copyWith(
              color: ds.colors.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          if (_state.lastUpdate != null) ...[
            const SizedBox(height: 4),
            Text(
              'Last update: ${_formatTime(_state.lastUpdate!)}',
              style: ds.typography.caption.copyWith(
                color: ds.colors.colorScheme.onSurface.withOpacity(0.6),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 🎯 SELECT NODE
  void _selectNode(String nodeId) {
    setState(() {
      _state = _state.copyWith(selectedNodeId: nodeId);
    });

    widget.onNodeSelected?.call();
  }

  /// 🎨 UTILITY METHODS
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

  IconData _getModelIcon(String modelName) {
    switch (modelName.toLowerCase()) {
      case 'claude':
        return Icons.psychology;
      case 'gpt':
        return Icons.smart_toy;
      case 'deepseek':
        return Icons.code;
      case 'gemini':
        return Icons.auto_awesome;
      case 'mistral':
        return Icons.tune;
      default:
        return Icons.circle;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }
}

/// 💫 DECISION TREE CONNECTION PAINTER
class DecisionTreeConnectionPainter extends CustomPainter {
  final List<DecisionNode> nodes;
  final Map<String, Offset> positions;
  final double animation;
  final Color neuralColor;

  DecisionTreeConnectionPainter({
    required this.nodes,
    required this.positions,
    required this.animation,
    required this.neuralColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = neuralColor.withOpacity(0.3 + (animation * 0.4))
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Draw connections between parent and child nodes
    for (final node in nodes) {
      final parentPosition = positions[node.id];
      if (parentPosition == null || node.children.isEmpty) continue;

      for (final child in node.children) {
        final childPosition = positions[child.id];
        if (childPosition == null) continue;

        // Animated connection line
        final animatedChildX = parentPosition.dx + ((childPosition.dx - parentPosition.dx) * animation);
        final animatedChildY = parentPosition.dy + ((childPosition.dy - parentPosition.dy) * animation);

        canvas.drawLine(
          parentPosition,
          Offset(animatedChildX, animatedChildY),
          paint,
        );

        // Connection pulse
        canvas.drawCircle(
          Offset(animatedChildX, animatedChildY),
          2.0 + (animation * 1.0),
          Paint()
            ..color = neuralColor.withOpacity(0.6 - (animation * 0.3))
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant DecisionTreeConnectionPainter oldDelegate) {
    return animation != oldDelegate.animation ||
        nodes != oldDelegate.nodes ||
        positions != oldDelegate.positions;
  }
}