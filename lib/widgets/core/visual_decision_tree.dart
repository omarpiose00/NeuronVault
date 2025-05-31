// 🌳 NEURONVAULT - VISUAL DECISION TREE - PHASE 3.4 [FIXED]
// World's first AI decision transparency widget with neural luxury design
// FIXED: Riverpod lifecycle and context access issues

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;

import '../../core/design_system.dart';
import '../../core/providers/providers_main.dart';
import '../../core/controllers/athena_controller.dart';

/// 🧠 Decision Tree Node Types
enum DecisionNodeType {
  input,          // Prompt input
  analysis,       // Prompt analysis
  categorization, // Category detection
  modelSelection, // Model recommendations
  strategyChoice, // Strategy selection
  weightAdjust,   // Weight optimization
  output,         // Final recommendation
}

/// 🎯 Decision Node Data
class DecisionNode {
  final String id;
  final DecisionNodeType type;
  final String title;
  final String description;
  final double confidence;
  final Color color;
  final Offset position;
  final bool isActive;
  final bool isCompleted;
  final Map<String, dynamic> data;

  const DecisionNode({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.confidence,
    required this.color,
    required this.position,
    required this.isActive,
    required this.isCompleted,
    required this.data,
  });

  DecisionNode copyWith({
    String? id,
    DecisionNodeType? type,
    String? title,
    String? description,
    double? confidence,
    Color? color,
    Offset? position,
    bool? isActive,
    bool? isCompleted,
    Map<String, dynamic>? data,
  }) {
    return DecisionNode(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      confidence: confidence ?? this.confidence,
      color: color ?? this.color,
      position: position ?? this.position,
      isActive: isActive ?? this.isActive,
      isCompleted: isCompleted ?? this.isCompleted,
      data: data ?? this.data,
    );
  }
}

/// 🌳 Decision Tree Connection
class DecisionConnection {
  final String fromNodeId;
  final String toNodeId;
  final double strength;
  final bool isActive;
  final Color color;

  const DecisionConnection({
    required this.fromNodeId,
    required this.toNodeId,
    required this.strength,
    required this.isActive,
    required this.color,
  });
}

/// 🌳 VISUAL DECISION TREE WIDGET - FIXED VERSION
class VisualDecisionTree extends ConsumerStatefulWidget {
  final double width;
  final double height;
  final bool isCompact;
  final VoidCallback? onNodeTap;

  const VisualDecisionTree({
    super.key,
    this.width = 400,
    this.height = 300,
    this.isCompact = false,
    this.onNodeTap,
  });

  @override
  ConsumerState<VisualDecisionTree> createState() => _VisualDecisionTreeState();
}

class _VisualDecisionTreeState extends ConsumerState<VisualDecisionTree>
    with TickerProviderStateMixin {

  // 🎭 Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _flowController;
  late AnimationController _revealController;
  late AnimationController _glowController;

  // 🎨 Animations
  late Animation<double> _pulseAnimation;
  late Animation<double> _flowAnimation;
  late Animation<double> _revealAnimation;
  late Animation<double> _glowAnimation;

  // 🧠 Decision Tree State
  List<DecisionNode> _nodes = [];
  List<DecisionConnection> _connections = [];
  String? _hoveredNodeId;

  // 🎯 UI State
  bool _isAnalyzing = false;
  bool _showDetails = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    // FIXED: Use addPostFrameCallback to setup tree after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _setupTreeAndListeners();
      }
    });
  }

  void _initializeAnimations() {
    // 💫 Pulse animation for active nodes
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // 🌊 Flow animation for connections
    _flowController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _flowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flowController,
      curve: Curves.linear,
    ));

    // ✨ Reveal animation for new nodes
    _revealController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _revealAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeOutCubic,
    ));

    // 🌟 Glow animation for neural effects
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Start continuous animations
    _pulseController.repeat(reverse: true);
    _flowController.repeat();
    _glowController.repeat(reverse: true);
  }

  // FIXED: Setup tree and listeners after build context is available
  void _setupTreeAndListeners() {
    if (_isInitialized) return;

    final ds = context.ds; // Now safe to use context
    _setupDefaultTree(ds);
    _listenToAthenaStreams();

    setState(() {
      _isInitialized = true;
    });
  }

  void _setupDefaultTree(DesignSystemData ds) {
    _nodes = [
      DecisionNode(
        id: 'input',
        type: DecisionNodeType.input,
        title: 'Input',
        description: 'Prompt Analysis',
        confidence: 1.0,
        color: ds.colors.neuralPrimary,
        position: const Offset(50, 150),
        isActive: false,
        isCompleted: false,
        data: {},
      ),
      DecisionNode(
        id: 'analysis',
        type: DecisionNodeType.analysis,
        title: 'Analysis',
        description: 'Category Detection',
        confidence: 0.0,
        color: ds.colors.neuralSecondary,
        position: const Offset(150, 100),
        isActive: false,
        isCompleted: false,
        data: {},
      ),
      DecisionNode(
        id: 'models',
        type: DecisionNodeType.modelSelection,
        title: 'Models',
        description: 'AI Selection',
        confidence: 0.0,
        color: ds.colors.neuralAccent,
        position: const Offset(250, 80),
        isActive: false,
        isCompleted: false,
        data: {},
      ),
      DecisionNode(
        id: 'strategy',
        type: DecisionNodeType.strategyChoice,
        title: 'Strategy',
        description: 'Orchestration',
        confidence: 0.0,
        color: ds.colors.connectionGreen,
        position: const Offset(250, 180),
        isActive: false,
        isCompleted: false,
        data: {},
      ),
      DecisionNode(
        id: 'weights',
        type: DecisionNodeType.weightAdjust,
        title: 'Weights',
        description: 'Optimization',
        confidence: 0.0,
        color: ds.colors.tokenWarning,
        position: const Offset(350, 130),
        isActive: false,
        isCompleted: false,
        data: {},
      ),
      DecisionNode(
        id: 'output',
        type: DecisionNodeType.output,
        title: 'Output',
        description: 'Recommendation',
        confidence: 0.0,
        color: ds.colors.neuralPrimary,
        position: const Offset(450, 150),
        isActive: false,
        isCompleted: false,
        data: {},
      ),
    ];

    _connections = [
      DecisionConnection(
        fromNodeId: 'input',
        toNodeId: 'analysis',
        strength: 0.0,
        isActive: false,
        color: ds.colors.neuralPrimary,
      ),
      DecisionConnection(
        fromNodeId: 'analysis',
        toNodeId: 'models',
        strength: 0.0,
        isActive: false,
        color: ds.colors.neuralSecondary,
      ),
      DecisionConnection(
        fromNodeId: 'analysis',
        toNodeId: 'strategy',
        strength: 0.0,
        isActive: false,
        color: ds.colors.neuralSecondary,
      ),
      DecisionConnection(
        fromNodeId: 'models',
        toNodeId: 'weights',
        strength: 0.0,
        isActive: false,
        color: ds.colors.neuralAccent,
      ),
      DecisionConnection(
        fromNodeId: 'strategy',
        toNodeId: 'weights',
        strength: 0.0,
        isActive: false,
        color: ds.colors.connectionGreen,
      ),
      DecisionConnection(
        fromNodeId: 'weights',
        toNodeId: 'output',
        strength: 0.0,
        isActive: false,
        color: ds.colors.tokenWarning,
      ),
    ];
  }

  void _listenToAthenaStreams() {
    if (!mounted) return;

    // FIXED: Use try-catch for provider safety
    try {
      // 🧠 Listen to Athena state (safe fallback if provider missing)
      ref.listen<AthenaControllerState>(athenaControllerProvider, (previous, next) {
        if (mounted) {
          setState(() {
            _isAnalyzing = next.isAnalyzing;
          });

          if (next.isAnalyzing && !previous!.isAnalyzing) {
            _startAnalysisAnimation();
          } else if (!next.isAnalyzing && previous!.isAnalyzing) {
            _stopAnalysisAnimation();
          }

          // Update tree with current recommendation
          if (next.hasRecommendation && next.currentRecommendation != null) {
            _updateTreeWithMockRecommendation(next.currentRecommendation!);
          }
        }
      });
    } catch (e) {
      print('⚠️ Decision Tree: Athena provider not available: $e');
      // Continue with static tree display
    }
  }

  void _startAnalysisAnimation() {
    _revealController.forward();
    _animateNodeSequence();
  }

  void _stopAnalysisAnimation() {
    // Keep final state visible
  }

  void _animateNodeSequence() async {
    final nodeIds = ['input', 'analysis', 'models', 'strategy', 'weights', 'output'];

    for (int i = 0; i < nodeIds.length; i++) {
      await Future.delayed(Duration(milliseconds: 300 * i));
      if (mounted) {
        setState(() {
          final nodeIndex = _nodes.indexWhere((n) => n.id == nodeIds[i]);
          if (nodeIndex >= 0) {
            _nodes[nodeIndex] = _nodes[nodeIndex].copyWith(isActive: true);
          }
        });
      }
    }
  }

  // FIXED: Mock update for demo purposes (replace with real recommendation when available)
  void _updateTreeWithMockRecommendation(dynamic recommendation) {
    if (!mounted) return;

    setState(() {
      // Update analysis node
      final analysisIndex = _nodes.indexWhere((n) => n.id == 'analysis');
      if (analysisIndex >= 0) {
        _nodes[analysisIndex] = _nodes[analysisIndex].copyWith(
          confidence: 0.85,
          isCompleted: true,
          data: {
            'category': 'reasoning',
            'complexity': 'medium',
          },
        );
      }

      // Update models node
      final modelsIndex = _nodes.indexWhere((n) => n.id == 'models');
      if (modelsIndex >= 0) {
        _nodes[modelsIndex] = _nodes[modelsIndex].copyWith(
          confidence: 0.82,
          isCompleted: true,
          data: {
            'models': ['claude', 'gpt'],
            'count': 2,
          },
        );
      }

      // Update strategy node
      final strategyIndex = _nodes.indexWhere((n) => n.id == 'strategy');
      if (strategyIndex >= 0) {
        _nodes[strategyIndex] = _nodes[strategyIndex].copyWith(
          confidence: 0.78,
          isCompleted: true,
          data: {
            'strategy': 'parallel',
          },
        );
      }

      // Update weights node
      final weightsIndex = _nodes.indexWhere((n) => n.id == 'weights');
      if (weightsIndex >= 0) {
        _nodes[weightsIndex] = _nodes[weightsIndex].copyWith(
          confidence: 0.80,
          isCompleted: true,
          data: {
            'weights': {'claude': 1.2, 'gpt': 1.0},
          },
        );
      }

      // Update output node
      final outputIndex = _nodes.indexWhere((n) => n.id == 'output');
      if (outputIndex >= 0) {
        _nodes[outputIndex] = _nodes[outputIndex].copyWith(
          confidence: 0.82,
          isCompleted: true,
          data: {
            'auto_apply': true,
          },
        );
      }

      // Activate connections
      final ds = context.ds;
      _connections = _connections.map((conn) => DecisionConnection(
        fromNodeId: conn.fromNodeId,
        toNodeId: conn.toNodeId,
        strength: 0.8,
        isActive: true,
        color: conn.color,
      )).toList();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _flowController.dispose();
    _revealController.dispose();
    _glowController.dispose();
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
            ds.colors.colorScheme.surface.withOpacity(0.95),
            ds.colors.colorScheme.surface.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ds.colors.neuralPrimary.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ds.colors.neuralPrimary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Stack(
            children: [
              // 🎨 Header
              _buildHeader(ds),

              // 🌳 Decision Tree Canvas
              if (_isInitialized)
                Positioned(
                  top: 50,
                  left: 0,
                  right: 0,
                  bottom: _showDetails ? 100 : 20,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _pulseAnimation,
                      _flowAnimation,
                      _revealAnimation,
                      _glowAnimation,
                    ]),
                    builder: (context, child) {
                      return MouseRegion(
                        onHover: (event) {
                          final node = _getNodeAtPosition(event.localPosition);
                          setState(() {
                            _hoveredNodeId = node?.id;
                          });
                        },
                        onExit: (_) {
                          setState(() {
                            _hoveredNodeId = null;
                          });
                        },
                        child: GestureDetector(
                          onTapUp: (details) {
                            final node = _getNodeAtPosition(details.localPosition);
                            if (node != null) {
                              widget.onNodeTap?.call();
                              _showNodeDetails(node);
                            }
                          },
                          child: CustomPaint(
                            painter: DecisionTreePainter(
                              nodes: _nodes,
                              connections: _connections,
                              hoveredNodeId: _hoveredNodeId,
                              pulseAnimation: _pulseAnimation.value,
                              flowAnimation: _flowAnimation.value,
                              revealAnimation: _revealAnimation.value,
                              glowAnimation: _glowAnimation.value,
                              isAnalyzing: _isAnalyzing,
                              neuralColors: ds.colors,
                              typography: ds.typography,
                            ),
                            size: Size(widget.width, widget.height - 70),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // 📊 Loading indicator if not initialized
              if (!_isInitialized)
                Positioned.fill(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(ds.colors.neuralPrimary),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading Decision Tree...',
                          style: ds.typography.caption.copyWith(
                            color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // 📊 Details Panel
              if (_showDetails)
                _buildDetailsPanel(ds),

              // 🔄 Analysis Indicator
              if (_isAnalyzing)
                _buildAnalysisIndicator(ds),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(DesignSystemData ds) {
    // FIXED: Safe provider access with fallbacks
    bool athenaEnabled = false;
    int decisionCount = 0;

    try {
      final athenaState = ref.watch(athenaControllerProvider);
      athenaEnabled = athenaState.isEnabled;
      decisionCount = athenaState.recentDecisions.length;
    } catch (e) {
      // Provider not available, use defaults
    }

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
          Icon(
            Icons.account_tree,
            color: ds.colors.neuralPrimary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'AI Decision Tree',
            style: ds.typography.h3.copyWith(
              color: ds.colors.colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          if (!widget.isCompact) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: athenaEnabled
                    ? ds.colors.neuralAccent.withOpacity(0.2)
                    : ds.colors.colorScheme.outline.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                athenaEnabled ? '$decisionCount decisions' : 'Demo Mode',
                style: ds.typography.caption.copyWith(
                  color: athenaEnabled
                      ? ds.colors.neuralAccent
                      : ds.colors.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          IconButton(
            onPressed: () {
              setState(() {
                _showDetails = !_showDetails;
              });
            },
            icon: Icon(
              _showDetails ? Icons.expand_less : Icons.expand_more,
              color: ds.colors.colorScheme.onSurface,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsPanel(DesignSystemData ds) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 100,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ds.colors.colorScheme.surface.withOpacity(0.9),
              ds.colors.colorScheme.surface.withOpacity(0.95),
            ],
          ),
          border: Border(
            top: BorderSide(
              color: ds.colors.neuralPrimary.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Decision Tree Demo',
                style: ds.typography.caption.copyWith(
                  color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Interactive AI decision visualization showing Athena\'s thought process.',
                style: ds.typography.body2.copyWith(
                  color: ds.colors.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Click nodes for details • Hover for interactions',
                style: ds.typography.caption.copyWith(
                  color: ds.colors.neuralAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisIndicator(DesignSystemData ds) {
    return Positioned(
      top: 60,
      right: 16,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ds.colors.neuralAccent.withOpacity(0.9),
                  ds.colors.neuralPrimary.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: ds.colors.neuralAccent.withOpacity(_glowAnimation.value * 0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'ANALYZING',
                  style: ds.typography.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  DecisionNode? _getNodeAtPosition(Offset position) {
    for (final node in _nodes) {
      final nodeRect = Rect.fromCenter(
        center: node.position,
        width: 80,
        height: 50,
      );
      if (nodeRect.contains(position)) {
        return node;
      }
    }
    return null;
  }

  void _showNodeDetails(DecisionNode node) {
    setState(() {
      _showDetails = true;
    });
  }
}

/// 🎨 DECISION TREE CUSTOM PAINTER (same as before but simplified)
class DecisionTreePainter extends CustomPainter {
  final List<DecisionNode> nodes;
  final List<DecisionConnection> connections;
  final String? hoveredNodeId;
  final double pulseAnimation;
  final double flowAnimation;
  final double revealAnimation;
  final double glowAnimation;
  final bool isAnalyzing;
  final NeuronColors neuralColors;
  final NeuronTypography typography;

  DecisionTreePainter({
    required this.nodes,
    required this.connections,
    this.hoveredNodeId,
    required this.pulseAnimation,
    required this.flowAnimation,
    required this.revealAnimation,
    required this.glowAnimation,
    required this.isAnalyzing,
    required this.neuralColors,
    required this.typography,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw connections first (behind nodes)
    _drawConnections(canvas, size);

    // Draw nodes
    _drawNodes(canvas, size);

    // Draw flow particles on connections
    if (isAnalyzing) {
      _drawFlowParticles(canvas, size);
    }
  }

  void _drawConnections(Canvas canvas, Size size) {
    for (final connection in connections) {
      final fromNode = nodes.firstWhere((n) => n.id == connection.fromNodeId);
      final toNode = nodes.firstWhere((n) => n.id == connection.toNodeId);

      if (!connection.isActive) continue;

      final paint = Paint()
        ..color = connection.color.withOpacity(0.3 + (connection.strength * 0.4))
        ..strokeWidth = 2.0 + (connection.strength * 2.0)
        ..style = PaintingStyle.stroke;

      // Draw straight line (simplified)
      canvas.drawLine(fromNode.position, toNode.position, paint);

      // Draw glow effect if active
      if (connection.isActive) {
        final glowPaint = Paint()
          ..color = connection.color.withOpacity(glowAnimation * 0.3)
          ..strokeWidth = 8.0
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

        canvas.drawLine(fromNode.position, toNode.position, glowPaint);
      }
    }
  }

  void _drawNodes(Canvas canvas, Size size) {
    for (final node in nodes) {
      _drawNode(canvas, node);
    }
  }

  void _drawNode(Canvas canvas, DecisionNode node) {
    final isHovered = hoveredNodeId == node.id;
    final scale = isHovered ? 1.1 : (node.isActive ? (1.0 + pulseAnimation * 0.1) : 1.0);

    // Node background
    final nodePaint = Paint()
      ..color = node.color.withOpacity(node.isCompleted ? 0.8 : 0.4)
      ..style = PaintingStyle.fill;

    final nodeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: node.position,
        width: 80 * scale,
        height: 50 * scale,
      ),
      const Radius.circular(12),
    );

    canvas.drawRRect(nodeRect, nodePaint);

    // Node border
    final borderPaint = Paint()
      ..color = node.color.withOpacity(node.isActive ? 0.8 : 0.5)
      ..strokeWidth = node.isActive ? 2.0 : 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(nodeRect, borderPaint);

    // Node text
    _drawNodeText(canvas, node, scale);

    // Confidence indicator
    if (node.confidence > 0) {
      _drawConfidenceIndicator(canvas, node, scale);
    }
  }

  void _drawNodeText(Canvas canvas, DecisionNode node, double scale) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: node.title,
        style: typography.caption.copyWith(
          color: Colors.white,
          fontSize: 10 * scale,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout(maxWidth: 70 * scale);
    textPainter.paint(
      canvas,
      Offset(
        node.position.dx - textPainter.width / 2,
        node.position.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawConfidenceIndicator(Canvas canvas, DecisionNode node, double scale) {
    final indicatorRect = Rect.fromCenter(
      center: Offset(node.position.dx + 35 * scale, node.position.dy - 20 * scale),
      width: 20 * scale,
      height: 12 * scale,
    );

    // Background
    final bgPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(indicatorRect, const Radius.circular(6)),
      bgPaint,
    );

    // Confidence text
    final confidenceText = TextPainter(
      text: TextSpan(
        text: '${(node.confidence * 100).round()}%',
        style: typography.caption.copyWith(
          color: Colors.white,
          fontSize: 8 * scale,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    confidenceText.layout();
    confidenceText.paint(
      canvas,
      Offset(
        indicatorRect.center.dx - confidenceText.width / 2,
        indicatorRect.center.dy - confidenceText.height / 2,
      ),
    );
  }

  void _drawFlowParticles(Canvas canvas, Size size) {
    for (final connection in connections) {
      if (!connection.isActive) continue;

      final fromNode = nodes.firstWhere((n) => n.id == connection.fromNodeId);
      final toNode = nodes.firstWhere((n) => n.id == connection.toNodeId);

      // Calculate particle position along the connection
      final t = (flowAnimation + connection.strength) % 1.0;
      final particlePos = Offset.lerp(fromNode.position, toNode.position, t);

      if (particlePos != null) {
        final particlePaint = Paint()
          ..color = connection.color.withOpacity(0.8)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(particlePos, 3, particlePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DecisionTreePainter oldDelegate) {
    return oldDelegate.pulseAnimation != pulseAnimation ||
        oldDelegate.flowAnimation != flowAnimation ||
        oldDelegate.hoveredNodeId != hoveredNodeId ||
        oldDelegate.isAnalyzing != isAnalyzing;
  }
}