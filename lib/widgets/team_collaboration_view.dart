import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';
import '../models/ai_agent.dart';
import '../widgets/ui/glass_container.dart';

class TeamCollaborationView extends StatefulWidget {
  final String prompt;
  final Map<String, dynamic> responses;
  final Map<String, double> weights;
  final String synthesizedResponse;
  final bool isProcessing;

  const TeamCollaborationView({
    Key? key,
    required this.prompt,
    required this.responses,
    required this.weights,
    required this.synthesizedResponse,
    this.isProcessing = false,
  }) : super(key: key);

  @override
  State<TeamCollaborationView> createState() => _TeamCollaborationViewState();
}

class _TeamCollaborationViewState extends State<TeamCollaborationView> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _flowController;

  // Posizioni per gli avatar AI
  final Map<String, Offset> _positions = {};

  @override
  void initState() {
    super.initState();

    // Inizializza i controller per le animazioni
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _flowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat();

    // Posiziona gli agenti in un cerchio
    _calculatePositions();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _flowController.dispose();
    super.dispose();
  }

  // Calcola le posizioni degli avatar AI
  void _calculatePositions() {
    final models = widget.responses.keys.toList();
    final count = models.length;

    // Se non ci sono risposte, non calcolare posizioni
    if (count == 0) return;

    // Disponi gli agenti in un cerchio
    for (int i = 0; i < count; i++) {
      final angle = (2 * math.pi * i) / count;
      final radius = 0.4; // Raggio del cerchio (proporzione della vista)

      // Calcola la posizione dell'agente
      final x = 0.5 + radius * math.cos(angle);
      final y = 0.5 + radius * math.sin(angle);

      _positions[models[i]] = Offset(x, y);
    }
  }

  @override
  void didUpdateWidget(TeamCollaborationView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Ricalcola le posizioni se cambiano le risposte
    if (widget.responses.keys.toList().toString() !=
        oldWidget.responses.keys.toList().toString()) {
      _calculatePositions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: 24,
      blur: 8,
      backgroundColor: isDark ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.2),
      child: Column(
        children: [
          // Titolo sezione
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.psychology_alt,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  'Team AI Collaboration',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Spacer(),
                if (widget.isProcessing)
                  _buildThinkingIndicator(theme),
              ],
            ),
          ),

          // Visualizzazione del prompt
          if (widget.prompt.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prompt:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(widget.prompt),
                  ],
                ),
              ),
            ),

          // Visualizzazione della collaborazione
          Expanded(
            child: Stack(
              children: [
                // Visualizzazione delle connessioni
                CustomPaint(
                  painter: ConnectionsPainter(
                    positions: _positions,
                    animation: _flowController,
                    weights: widget.weights,
                    theme: theme,
                  ),
                  size: Size.infinite,
                ),

                // Visualizzatore centrale di sintesi
                if (_positions.isNotEmpty && widget.responses.isNotEmpty)
                  Center(
                    child: _buildSynthesisHub(theme),
                  ),

                // Avatar delle AI
                ...widget.responses.keys.map((model) {
                  final position = _positions[model] ?? const Offset(0.5, 0.5);
                  return Positioned(
                    left: position.dx * MediaQuery.of(context).size.width - 25,
                    top: position.dy * (MediaQuery.of(context).size.height / 2) - 25,
                    child: _buildAIAvatar(model, theme),
                  );
                }),
              ],
            ),
          ),

          // Risposta sintetizzata
          if (widget.synthesizedResponse.isNotEmpty && !widget.isProcessing)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.secondary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Risposta Sintetizzata:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.synthesizedResponse,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThinkingIndicator(ThemeData theme) {
    return Row(
      children: [
        Text(
          'Team al lavoro',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        // Punti pulsanti di caricamento
        ...List.generate(
          3,
              (index) => AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final delay = index * 0.3;
              final value = _pulseController.value;
              final animValue = (value - delay) % 1.0;
              final opacity = animValue > 0 ? (animValue < 0.5 ? animValue * 2 : (1 - animValue) * 2) : 0.0;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(opacity.clamp(0.2, 1.0)),
                  shape: BoxShape.circle,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAIAvatar(String model, ThemeData theme) {
    // Converti il nome del modello in un AiAgent
    AiAgent? agent;
    switch (model) {
      case 'gpt':
        agent = AiAgent.gpt;
        break;
      case 'claude':
        agent = AiAgent.claude;
        break;
      case 'deepseek':
        agent = AiAgent.deepseek;
        break;
      default:
        agent = null;
    }

    // Peso del modello (da usare per l'animazione)
    final weight = widget.weights[model] ?? 1.0;

    // Avatar animato
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        // L'avatar pulsa durante l'elaborazione
        final scale = widget.isProcessing
            ? 1.0 + (_pulseController.value * 0.1 * weight)
            : 1.0;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: agent != null ? agentColor(agent) : theme.colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (agent != null ? agentColor(agent) : theme.colorScheme.primary)
                      .withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: agent != null
                  ? Text(
                _getAIEmoji(agent),
                style: const TextStyle(fontSize: 24),
              )
                  : Icon(
                Icons.smart_toy,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ).animate(
            onPlay: (controller) => controller.repeat(),
            autoPlay: widget.isProcessing,  // Attiva l'animazione solo se isProcessing è true
          ).shimmer(
            duration: const Duration(seconds: 3),
            color: Colors.white54,
          ),
        );
      },
    );
  }

  String _getAIEmoji(AiAgent agent) {
    switch (agent) {
      case AiAgent.claude:
        return '🧠';
      case AiAgent.gpt:
        return '🤖';
      case AiAgent.deepseek:
        return '💻';
    }
  }

  Widget _buildSynthesisHub(ThemeData theme) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                theme.colorScheme.tertiary,
                theme.colorScheme.tertiary.withOpacity(0.0),
              ],
              radius: 0.7 + _pulseController.value * 0.3,
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiary.withOpacity(0.7),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.tertiary.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '🔄',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ConnectionsPainter extends CustomPainter {
  final Map<String, Offset> positions;
  final Animation<double> animation;
  final Map<String, double> weights;
  final ThemeData theme;

  ConnectionsPainter({
    required this.positions,
    required this.animation,
    required this.weights,
    required this.theme,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.isEmpty) return;

    // Punto centrale dove convergono tutte le connessioni
    final center = Offset(size.width / 2, size.height / 2);

    // Disegna le connessioni
    for (final entry in positions.entries) {
      final model = entry.key;
      final position = Offset(
        entry.value.dx * size.width,
        entry.value.dy * size.height,
      );

      // Calcola il peso della connessione
      final weight = weights[model] ?? 1.0;

      // Disegna la connessione
      _drawConnection(canvas, position, center, weight);

      // Disegna le particelle che fluiscono verso il centro
      _drawFlowingParticles(canvas, position, center, weight);
    }
  }

  void _drawConnection(Canvas canvas, Offset start, Offset end, double weight) {
    final paint = Paint()
      ..color = theme.colorScheme.primary.withOpacity(0.3 * weight)
      ..strokeWidth = 2.0 * weight
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, end, paint);
  }

  void _drawFlowingParticles(Canvas canvas, Offset start, Offset end, double weight) {
    final distance = (end - start).distance;
    final direction = (end - start) / distance;

    // Numero di particelle basato sul peso
    final particleCount = (5 * weight).round();

    for (int i = 0; i < particleCount; i++) {
      // Calcola la posizione della particella
      final progress = (animation.value + i / particleCount) % 1.0;
      final position = start + direction * distance * progress;

      // Dimensione della particella basata sul peso
      final size = 4.0 * weight;

      // Opacità che si intensifica verso il centro
      final opacity = 0.3 + 0.7 * progress;

      // Disegna la particella
      final paint = Paint()
        ..color = theme.colorScheme.primary.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(position, size, paint);
    }
  }

  @override
  bool shouldRepaint(ConnectionsPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.positions != positions ||
        oldDelegate.weights != weights;
  }
}