// lib/widgets/synthesis_process_view.dart (nuovo widget)

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/ai_agent.dart';
import '../widgets/ui/glass_container.dart';

class SynthesisProcessView extends StatefulWidget {
  final Map<String, String> inputTexts;
  final String prompt;
  final String synthesizedOutput;
  final Map<String, double> weights;
  final bool isProcessing;
  final bool useMiniLLM;

  const SynthesisProcessView({
    Key? key,
    required this.inputTexts,
    required this.prompt,
    required this.synthesizedOutput,
    required this.weights,
    this.isProcessing = false,
    this.useMiniLLM = false,
  }) : super(key: key);

  @override
  State<SynthesisProcessView> createState() => _SynthesisProcessViewState();
}

class _SynthesisProcessViewState extends State<SynthesisProcessView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isProcessing) {
      _controller.repeat(reverse: false);
    } else {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(SynthesisProcessView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isProcessing != oldWidget.isProcessing) {
      if (widget.isProcessing) {
        _controller.repeat(reverse: false);
      } else {
        _controller.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: 24,
      backgroundColor: isDark
          ? Colors.black.withOpacity(0.3)
          : Colors.white.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titolo con indicatore
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  widget.useMiniLLM ? Icons.psychology_alt : Icons.auto_awesome,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.useMiniLLM
                            ? 'Sintesi con Mini-LLM'
                            : 'Sintesi delle Risposte',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      if (widget.useMiniLLM)
                        Text(
                          'Utilizzo di un modello locale leggero per combinare le risposte',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                    ],
                  ),
                ),
                if (widget.isProcessing)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Visualizzazione del processo di sintesi
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Prompt originale
                      _buildPromptSection(theme),
                      const SizedBox(height: 20),

                      // Modelli e risposte
                      _buildModelResponsesSection(theme),
                      const SizedBox(height: 20),

                      // Processo di sintesi (grafico)
                      _buildSynthesisProcess(theme),
                      const SizedBox(height: 20),

                      // Output finale
                      _buildOutputSection(theme),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prompt:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(widget.prompt),
        ),
      ],
    );
  }

  Widget _buildModelResponsesSection(ThemeData theme) {
    final models = widget.inputTexts.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Risposte dei modelli:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        ...models.map((model) {
          final response = widget.inputTexts[model]!;
          final weight = widget.weights[model] ?? 1.0;
          final color = _getModelColor(model);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getModelName(model),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Peso: ${weight.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  response.length > 200
                      ? '${response.substring(0, 200)}...'
                      : response,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onBackground.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSynthesisProcess(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Processo di sintesi:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 180,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: widget.useMiniLLM
              ? _buildMiniLLMSynthesisVisualization(theme)
              : _buildWeightedSynthesisVisualization(theme),
        ),
      ],
    );
  }

  Widget _buildMiniLLMSynthesisVisualization(ThemeData theme) {
    final models = widget.inputTexts.keys.toList();
    final miniLLMColor = theme.colorScheme.tertiary;

    return Stack(
      children: [
        // Linee di connessione dagli input al Mini-LLM
        ...models.asMap().entries.map((entry) {
          final index = entry.key;
          final model = entry.value;
          final modelColor = _getModelColor(model);

          // Posizione relativa del modello a sinistra
          final modelY = 20.0 + index * 30.0;

          // Progressione animata della linea
          final start = _progressAnimation.value * 0.6; // Start dopo il 60% dell'animazione
          final amount = start > 0 ? ((_progressAnimation.value - 0.6) / 0.4).clamp(0.0, 1.0) : 0.0;

          return CustomPaint(
            painter: FlowLinePainter(
              start: Offset(0, modelY),
              end: Offset(140, 90),
              color: modelColor,
              progress: amount,
            ),
          );
        }).toList(),

        // Mini-LLM al centro
        Positioned(
          left: 120,
          top: 70,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: miniLLMColor.withOpacity(0.7),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: miniLLMColor.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.psychology,
                color: Colors.white,
                size: 24,
              ),
            ),
          ).animate(
            target: _progressAnimation.value > 0.4 ? 1 : 0,
          ).shimmer(
            duration: const Duration(seconds: 2),
          ),
        ),

        // Linea dal Mini-LLM all'output
        Positioned(
          left: 160,
          top: 90,
          child: CustomPaint(
            painter: FlowLinePainter(
              start: Offset(0, 0),
              end: Offset(80, 0),
              color: miniLLMColor,
              progress: _progressAnimation.value > 0.8
                  ? ((_progressAnimation.value - 0.8) / 0.2).clamp(0.0, 1.0)
                  : 0.0,
              thickness: 3.0,
            ),
          ),
        ),

        // Input models (left side)
        ...models.asMap().entries.map((entry) {
          final index = entry.key;
          final model = entry.value;
          final modelColor = _getModelColor(model);

          return Positioned(
            left: 0,
            top: 10.0 + index * 30.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: modelColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: modelColor.withOpacity(0.5),
                ),
              ),
              child: Text(
                _getModelShortName(model),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: modelColor,
                  fontSize: 12,
                ),
              ),
            ).animate(
              target: _progressAnimation.value > 0.1 * index ? 1 : 0,
            ).fadeIn(
              duration: const Duration(milliseconds: 300),
            ).moveX(
              begin: -50,
              end: 0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutQuad,
            ),
          );
        }).toList(),

        // Output visualization (right side)
        Positioned(
          right: 0,
          top: 80,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.secondary.withOpacity(0.5),
              ),
            ),
            child: Text(
              'Risposta\nsintetizzata',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ).animate(
            target: _progressAnimation.value > 0.9 ? 1 : 0,
          ).fadeIn(
            duration: const Duration(milliseconds: 300),
          ).scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.0, 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
          ),
        ),

        // Model caption
        Positioned(
          left: 120,
          top: 110,
          child: Text(
            "Mini-LLM",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: miniLLMColor,
            ),
          ),
        ),

        // Process stages
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Column(
            children: [
              LinearProgressIndicator(
                value: _progressAnimation.value,
                backgroundColor: theme.colorScheme.surface,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.tertiary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Input",
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    "Elaborazione",
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    "Output",
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeightedSynthesisVisualization(ThemeData theme) {
    final models = widget.inputTexts.keys.toList();

    return Stack(
      children: [
        // Linee di connessione dagli input all'output
        ...models.asMap().entries.map((entry) {
          final index = entry.key;
          final model = entry.value;
          final weight = widget.weights[model] ?? 1.0;
          final modelColor = _getModelColor(model);

          // Posizione relativa del modello a sinistra
          final modelY = 20.0 + index * 30.0;

          // Linea con spessore proporzionale al peso
          return CustomPaint(
            painter: FlowLinePainter(
              start: Offset(0, modelY),
              end: Offset(200, 80),
              color: modelColor,
              progress: _progressAnimation.value,
              thickness: weight * 2.0, // Spessore basato sul peso
            ),
          );
        }).toList(),

        // Input models (left side)
        ...models.asMap().entries.map((entry) {
          final index = entry.key;
          final model = entry.value;
          final modelColor = _getModelColor(model);

          return Positioned(
            left: 0,
            top: 10.0 + index * 30.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: modelColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: modelColor.withOpacity(0.5),
                ),
              ),
              child: Text(
                _getModelShortName(model),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: modelColor,
                  fontSize: 12,
                ),
              ),
            ).animate(
              target: _progressAnimation.value > 0.1 * index ? 1 : 0,
            ).fadeIn(
              duration: const Duration(milliseconds: 300),
            ).moveX(
              begin: -50,
              end: 0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutQuad,
            ),
          );
        }).toList(),

        // Output visualization (right side)
        Positioned(
          right: 0,
          top: 70,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.secondary.withOpacity(0.5),
              ),
            ),
            child: Text(
              'Risposta\nsintetizzata',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ).animate(
            target: _progressAnimation.value > 0.9 ? 1 : 0,
          ).fadeIn(
            duration: const Duration(milliseconds: 300),
          ).scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.0, 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
          ),
        ),

        // Weighted combination visualization
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Contribuzione relativa:",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: models.map((model) {
                  final weight = widget.weights[model] ?? 1.0;
                  final totalWeight = models.fold(0.0,
                          (sum, m) => sum + (widget.weights[m] ?? 1.0));
                  final percentage = (weight / totalWeight) * 100;

                  return Expanded(
                    flex: (percentage * 10).round(),
                    child: Container(
                      height: 8,
                      color: _getModelColor(model),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: models.map((model) {
                  final weight = widget.weights[model] ?? 1.0;
                  final totalWeight = models.fold(0.0,
                          (sum, m) => sum + (widget.weights[m] ?? 1.0));
                  final percentage = (weight / totalWeight) * 100;

                  return Text(
                    "${percentage.round()}%",
                    style: TextStyle(
                      fontSize: 10,
                      color: _getModelColor(model),
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOutputSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Risposta sintetizzata:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.secondary.withOpacity(0.3),
            ),
          ),
          child: Text(
            widget.isProcessing
                ? 'Elaborazione in corso...'
                : widget.synthesizedOutput.isNotEmpty
                ? widget.synthesizedOutput
                : 'Nessun output disponibile',
          ),
        ),
      ],
    );
  }

  Color _getModelColor(String model) {
    switch (model) {
      case 'gpt':
        return const Color(0xFF00695C);
      case 'claude':
        return const Color(0xFF9C64A6);
      case 'deepseek':
        return const Color(0xFFFFEB3B);
      case 'gemini':
        return const Color(0xFF4285F4);
      case 'mistral':
        return const Color(0xFFFF5722);
      case 'ollama':
        return const Color(0xFF795548);
      case 'llama':
        return const Color(0xFF607D8B);
      default:
        return Colors.grey;
    }
  }

  String _getModelName(String model) {
    switch (model) {
      case 'gpt':
        return 'OpenAI GPT';
      case 'claude':
        return 'Anthropic Claude';
      case 'deepseek':
        return 'DeepSeek';
      case 'gemini':
        return 'Google Gemini';
      case 'mistral':
        return 'Mistral AI';
      case 'ollama':
        return 'Ollama (Locale)';
      case 'llama':
        return 'Llama (Locale)';
      default:
        return model.toUpperCase();
    }
  }

  String _getModelShortName(String model) {
    switch (model) {
      case 'gpt':
        return 'GPT';
      case 'claude':
        return 'Claude';
      case 'deepseek':
        return 'DeepSeek';
      case 'gemini':
        return 'Gemini';
      case 'mistral':
        return 'Mistral';
      case 'ollama':
        return 'Ollama';
      case 'llama':
        return 'Llama';
      default:
        return model.toUpperCase();
    }
  }
}

// Painter personalizzato per disegnare linee di flusso animate
class FlowLinePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;
  final double progress;
  final double thickness;

  FlowLinePainter({
    required this.start,
    required this.end,
    required this.color,
    required this.progress,
    this.thickness = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(start.dx, start.dy);

    // Crea una curva Bezier per un effetto più fluido
    final controlPoint1 = Offset(
      start.dx + (end.dx - start.dx) * 0.5,
      start.dy,
    );
    final controlPoint2 = Offset(
      start.dx + (end.dx - start.dx) * 0.5,
      end.dy,
    );

    path.cubicTo(
      controlPoint1.dx, controlPoint1.dy,
      controlPoint2.dx, controlPoint2.dy,
      end.dx, end.dy,
    );

    // Animazione del tratteggio per effetto progressivo
    final pathMetrics = path.computeMetrics().single;
    final extractPath = pathMetrics.extractPath(
      0,
      pathMetrics.length * progress,
    );

    canvas.drawPath(extractPath, paint);

    // Aggiungi particelle che scorrono lungo il percorso se progress > 0.5
    if (progress > 0.5) {
      final particleProgress = ((progress - 0.5) * 2).clamp(0.0, 1.0);
      final particlePosition = pathMetrics.extractPath(
        0,
        pathMetrics.length * particleProgress,
      ).computeMetrics().single.getTangentForOffset(
        pathMetrics.length * particleProgress,
      )?.position;

      if (particlePosition != null) {
        canvas.drawCircle(
          particlePosition,
          3.0,
          Paint()..color = color.withOpacity(0.8),
        );
      }
    }
  }

  @override
  bool shouldRepaint(FlowLinePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.start != start ||
        oldDelegate.end != end ||
        oldDelegate.thickness != thickness;
  }
}