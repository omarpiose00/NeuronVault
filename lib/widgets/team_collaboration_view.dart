// lib/widgets/team_collaboration_view.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';
import '../models/ai_agent.dart';
import '../widgets/ui/glass_container.dart';
import 'ai_weight_controller.dart';
import '../services/api_service.dart';

class TeamCollaborationView extends StatefulWidget {
  final String prompt;
  final Map<String, String> responses;
  final Map<String, double> weights;
  final String synthesizedResponse;
  final bool isProcessing;
  final Function(String, double) onWeightChanged;
  final VoidCallback onResetWeights;
  final Function(Map<String, double>) onApplyPreset; // Added parameter

  const TeamCollaborationView({
    super.key,
    required this.prompt,
    required this.responses,
    required this.weights,
    required this.synthesizedResponse,
    this.isProcessing = false,
    required this.onWeightChanged,
    required this.onResetWeights,
    required this.onApplyPreset, // Added parameter
  });

  @override
  State<TeamCollaborationView> createState() => _TeamCollaborationViewState();
}

class _TeamCollaborationViewState extends State<TeamCollaborationView> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _flowController;
  final Map<String, Offset> _positions = {};
  bool _showWeightController = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _calculatePositions();

    // Aggiungi questo all'initState esistente per gestire gli errori di rendering
    FlutterError.onError = (FlutterErrorDetails details) {
      print('Errore di Flutter catturato: ${details.exception}');
      // Non interrompere il flusso normale di gestione degli errori
      FlutterError.presentError(details);
    };
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _flowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat();
  }

  void _calculatePositions() {
    _positions.clear();
    final models = widget.responses.keys.toList();

    // Se non ci sono modelli in risposta e siamo in modalità demo,
    // crea modelli fittizi per la visualizzazione
    if (models.isEmpty && ApiService.useMockData) {
      // Crea modelli fittizi per la demo
      _positions['gpt'] = const Offset(0.3, 0.3);
      _positions['claude'] = const Offset(0.7, 0.3);
      _positions['deepseek'] = const Offset(0.3, 0.7);
      _positions['gemini'] = const Offset(0.7, 0.7);
      return;
    }

    final count = models.length;
    if (count == 0) return;

    final center = const Offset(0.5, 0.5);
    const radius = 0.35;

    for (int i = 0; i < count; i++) {
      final angle = 2 * math.pi * i / count;
      _positions[models[i]] = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
    }
  }

  @override
  void didUpdateWidget(TeamCollaborationView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Gestione migliorata della modalità demo
    if (widget.isProcessing) {
      _pulseController.repeat(reverse: true);
    } else if (widget.responses.isNotEmpty) {
      // Verifica se siamo in modalità demo usando un approccio più diretto
      final isDemoMode = widget.responses.containsKey('gpt') &&
          widget.responses['gpt']!.contains('mock');

      if (isDemoMode && _positions.isNotEmpty) {
        // Assicurati che il controller di animazione sia in esecuzione per l'effetto demo
        if (!_flowController.isAnimating) {
          _flowController.repeat();
        }

        // Aggiungi effetto pulsante all'hub di sintesi in modalità demo
        _pulseController.repeat(reverse: true);

        // Ri-calcola le posizioni se necessario
        if (oldWidget.responses.length != widget.responses.length) {
          _calculatePositions();
        }
      }
    }
  }


  @override
  void dispose() {
    _pulseController.dispose();
    _flowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Assicurati che le posizioni siano calcolate anche se non ci sono dati
    if (_positions.isEmpty) {
      _calculatePositions();
    }

    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: 24,
      blur: 8,
      backgroundColor: isDark ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.2),
      child: Column(
        children: [
          _buildHeader(theme),
          if (_showWeightController) _buildWeightController(),
          if (widget.prompt.isNotEmpty) _buildPromptSection(theme),
          _buildCollaborationVisualization(theme),
          if (widget.synthesizedResponse.isNotEmpty && !widget.isProcessing)
            _buildSynthesizedResponse(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.psychology_alt, color: theme.colorScheme.primary),
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
          IconButton(
            icon: Icon(
              _showWeightController ? Icons.tune : Icons.tune_outlined,
              color: theme.colorScheme.primary,
            ),
            onPressed: () => setState(() => _showWeightController = !_showWeightController),
            tooltip: _showWeightController ? 'Hide weights' : 'Show weights',
          ),
          if (widget.isProcessing) _buildThinkingIndicator(theme),
        ],
      ),
    );
  }

  Widget _buildWeightController() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AIWeightController(
        weights: Map<String, double>.from(widget.weights),
        onWeightChanged: widget.onWeightChanged,
        onResetWeights: widget.onResetWeights,
        onApplyPreset: widget.onApplyPreset, // Pass through the callback
        isExpanded: true,
      ),
    );
  }

  Widget _buildPromptSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Prompt:', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
            const SizedBox(height: 4),
            Text(widget.prompt),
          ],
        ),
      ),
    );
  }

  // lib/widgets/team_collaboration_view.dart - metodo _buildCollaborationVisualization
  Widget _buildCollaborationVisualization(ThemeData theme) {
    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Proteggi il CustomPaint con try-catch
          Builder(
            builder: (context) {
              try {
                return CustomPaint(
                  painter: ConnectionsPainter(
                    positions: _positions,
                    animation: _flowController,
                    weights: widget.weights,
                    theme: theme,
                  ),
                  child: Container(),
                );
              } catch (e) {
                // In caso di errore, mostra un messaggio
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Visualizzazione temporaneamente non disponibile',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                );
              }
            },
          ),

          // Posizionamento degli avatar con controllo di validità
          ..._positions.entries.map((entry) {
            // Verifica le posizioni prima di posizionare
            if (entry.value.dx.isNaN || entry.value.dy.isNaN) {
              return const SizedBox.shrink(); // Salta posizioni invalide
            }

            return Positioned(
              left: entry.value.dx * MediaQuery.of(context).size.width - 25,
              top: entry.value.dy * MediaQuery.of(context).size.height - 25,
              child: _buildAIAvatar(entry.key, theme),
            );
          }),
          _buildSynthesisHub(theme),
        ],
      ),
    );
  }

  Widget _buildSynthesizedResponse(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Synthesized Response:',
              style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.secondary),
            ),
            const SizedBox(height: 4),
            Text(widget.synthesizedResponse, maxLines: 3, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildThinkingIndicator(ThemeData theme) {
    return Row(
      children: [
        Text('Team working', style: TextStyle(fontStyle: FontStyle.italic, color: theme.colorScheme.primary)),
        const SizedBox(width: 8),
        ...List.generate(3, (index) => _buildPulsingDot(index, theme)),
      ],
    );
  }

  Widget _buildPulsingDot(int index, ThemeData theme) {
    return AnimatedBuilder(
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
    );
  }

  Widget _buildAIAvatar(String model, ThemeData theme) {
    final agent = _getAgentForModel(model);
    final weight = widget.weights[model] ?? 1.0;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = widget.isProcessing ? 1.0 + (_pulseController.value * 0.1 * weight) : 1.0;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getAgentColor(agent, theme),
              shape: BoxShape.circle,
              boxShadow: [_getAgentShadow(agent, theme)],
            ),
            child: Center(child: _getAgentIcon(agent, theme)),
          ).animate(autoPlay: widget.isProcessing).shimmer(
            duration: const Duration(seconds: 3),
            color: Colors.white54,
          ),
        );
      },
    );
  }

  AiAgent? _getAgentForModel(String model) {
    switch (model) {
      case 'gpt': return AiAgent.gpt;
      case 'claude': return AiAgent.claude;
      case 'deepseek': return AiAgent.deepseek;
      case 'gemini': return AiAgent.gemini;
      case 'mistral': return AiAgent.mistral;
      default: return null;
    }
  }

  Color _getAgentColor(AiAgent? agent, ThemeData theme) {
    if (agent == null) return theme.colorScheme.primary;
    return agentColor(agent);
  }

  BoxShadow _getAgentShadow(AiAgent? agent, ThemeData theme) {
    return BoxShadow(
      color: _getAgentColor(agent, theme).withOpacity(0.4),
      blurRadius: 10,
      spreadRadius: 2,
    );
  }

  Widget _getAgentIcon(AiAgent? agent, ThemeData theme) {
    if (agent == null) return Icon(Icons.smart_toy, color: theme.colorScheme.onPrimary);
    switch (agent) {
      case AiAgent.gpt: return const Text('🤖', style: TextStyle(fontSize: 24));
      case AiAgent.claude: return const Text('🧠', style: TextStyle(fontSize: 24));
      case AiAgent.deepseek: return const Text('💻', style: TextStyle(fontSize: 24));
      case AiAgent.gemini: return const Text('✨', style: TextStyle(fontSize: 24));
      case AiAgent.mistral: return const Text('🌬️', style: TextStyle(fontSize: 24));
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
              colors: [theme.colorScheme.tertiary, theme.colorScheme.tertiary.withOpacity(0.0)],
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
                boxShadow: [_getHubShadow(theme)],
              ),
              child: const Center(child: Text('🔄', style: TextStyle(fontSize: 24))),
            ),
          ),
        );
      },
    );
  }

  BoxShadow _getHubShadow(ThemeData theme) {
    return BoxShadow(
      color: theme.colorScheme.tertiary.withOpacity(0.4),
      blurRadius: 15,
      spreadRadius: 5,
    );
  }
}

// Painter per visualizzare le connessioni tra agenti AI
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

      // Calcola posizione assoluta
      final posRelative = entry.value;
      final position = Offset(
        posRelative.dx * size.width,
        posRelative.dy * size.height,
      );

      // Calcola il peso della connessione (default a 1.0 se non specificato)
      final weight = weights[model] ?? 1.0;

      try {
        // Disegna la connessione con gestione errori
        if (!position.dx.isNaN && !position.dy.isNaN &&
            !center.dx.isNaN && !center.dy.isNaN) {
          _drawConnection(canvas, position, center, weight);
          _drawFlowingParticles(canvas, position, center, weight);
        }
      } catch (e) {
        print('Errore nel disegno connessione per $model: $e');
        // Continua con il prossimo modello
      }
    }
  }

  void _drawConnection(Canvas canvas, Offset start, Offset end, double weight) {
    // Ignora connessioni invalide
    if (start.dx.isNaN || start.dy.isNaN || end.dx.isNaN || end.dy.isNaN) {
      return;
    }

    final paint = Paint()
      ..color = theme.colorScheme.primary.withOpacity(0.3 * weight)
      ..strokeWidth = 2.0 * weight
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, end, paint);
  }

  void _drawFlowingParticles(Canvas canvas, Offset start, Offset end, double weight) {
    // Ignora particelle invalide
    if (start.dx.isNaN || start.dy.isNaN || end.dx.isNaN || end.dy.isNaN) {
      return;
    }

    try {
      final distance = (end - start).distance;

      // Evita divisione per zero
      if (distance < 0.001) return;

      final direction = Offset(
          (end.dx - start.dx) / distance,
          (end.dy - start.dy) / distance
      );

      // Numero di particelle basato sul peso (limiti sicuri)
      final particleCount = (5 * weight).round().clamp(1, 10);

      for (int i = 0; i < particleCount; i++) {
        // Calcolo progresso con correttezza matematica
        final progressValue = animation.value;
        final offset = i / particleCount;
        final progress = (progressValue + offset) % 1.0;

        // Calcolo posizione
        final particleDx = start.dx + direction.dx * distance * progress;
        final particleDy = start.dy + direction.dy * distance * progress;

        // Verifica validità
        if (particleDx.isNaN || particleDy.isNaN) continue;

        final position = Offset(particleDx, particleDy);

        // Dimensione e opacità con range limitati
        final size = 4.0 * weight.clamp(0.5, 2.0);
        final opacity = 0.3 + 0.7 * progress.clamp(0.0, 1.0);

        // Disegna particella
        final paint = Paint()
          ..color = theme.colorScheme.primary.withOpacity(opacity)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(position, size, paint);
      }
    } catch (e) {
      // Cattura qualsiasi errore nelle particelle
      print('Errore nel disegno particelle: $e');
    }
  }

  @override
  bool shouldRepaint(ConnectionsPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.positions != positions ||
        oldDelegate.weights != weights;
  }
}