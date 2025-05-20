import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';
import '../models/ai_agent.dart';
import '../widgets/ui/glass_container.dart';

class SynthesisVisualizer extends StatefulWidget {
  final Map<String, String> inputTexts;
  final Map<String, double> weights;
  final String outputText;
  final bool isProcessing;
  final double progress;

  const SynthesisVisualizer({
    Key? key,
    required this.inputTexts,
    required this.weights,
    required this.outputText,
    this.isProcessing = false,
    this.progress = 0.0,
  }) : super(key: key);

  @override
  State<SynthesisVisualizer> createState() => _SynthesisVisualizerState();
}

class _SynthesisVisualizerState extends State<SynthesisVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      borderRadius: 24,
      backgroundColor: isDark ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titolo
          Text(
            'Processo di Sintesi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Barra di progresso
          if (widget.isProcessing)
            LinearProgressIndicator(
              value: widget.progress,
              backgroundColor: theme.colorScheme.surface,
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),

          const SizedBox(height: 16),

          // Visualizzazione grafica dei pesi
          SizedBox(
            height: 100,
            child: _buildWeightChart(theme),
          ),

          const SizedBox(height: 16),

          // Input e output
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Input
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Input da modelli:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: widget.inputTexts.length,
                          itemBuilder: (context, index) {
                            final model = widget.inputTexts.keys.elementAt(index);
                            final text = widget.inputTexts[model] ?? '';
                            final weight = widget.weights[model] ?? 1.0;

                            return _buildInputItem(model, text, weight, theme);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Freccia animata
                SizedBox(
                  width: 60,
                  child: Center(
                    child: _buildAnimatedArrow(theme),
                  ),
                ),

                // Output
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Output sintetizzato:',
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
                          widget.outputText.isNotEmpty
                              ? widget.outputText
                              : widget.isProcessing
                              ? 'Sintetizzando...'
                              : 'Nessun output disponibile',
                          maxLines: 8,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputItem(String model, String text, double weight, ThemeData theme) {
    // Colore in base al modello
    Color color;
    switch (model) {
      case 'gpt':
        color = const Color(0xFF00695C);
        break;
      case 'claude':
        color = const Color(0xFF9C64A6);
        break;
      case 'deepseek':
        color = const Color(0xFFFFEB3B);
        break;
      default:
        color = theme.colorScheme.primary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
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
          // Nome del modello e peso
          Row(
            children: [
              Text(
                _getModelDisplayName(model),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
          const SizedBox(height: 4),
          // Testo di input
          Text(
            text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onBackground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChart(ThemeData theme) {
    // Se non ci sono pesi, mostra un messaggio
    if (widget.weights.isEmpty) {
      return Center(
        child: Text(
          'Nessun dato disponibile',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: theme.colorScheme.onBackground.withOpacity(0.5),
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ...widget.weights.entries.map((entry) {
          final model = entry.key;
          final weight = entry.value;

          // Colore in base al modello
          Color color;
          switch (model) {
            case 'gpt':
              color = const Color(0xFF00695C);
              break;
            case 'claude':
              color = const Color(0xFF9C64A6);
              break;
            case 'deepseek':
              color = const Color(0xFFFFEB3B);
              break;
            default:
              color = theme.colorScheme.primary;
          }

          // Calcola l'altezza della barra (max 100, min 10)
          final height = 10.0 + (weight / 3.0) * 90.0;

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: height,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.7),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getModelShortName(model),
                  style: const TextStyle(fontSize: 10),
                ),
                Text(
                  weight.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 9),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAnimatedArrow(ThemeData theme) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final value = _animationController.value;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Linea della freccia
            Container(
              width: 40,
              height: 2,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),

            // Punta della freccia
            Transform.translate(
              offset: Offset(10 + value * 10, 0),
              child: Icon(
                Icons.arrow_forward,
                color: theme.colorScheme.primary,
                size: 16,
              ),
            ),

            // Particelle che scorrono lungo la freccia
            for (int i = 0; i < 3; i++)
              Transform.translate(
                offset: Offset(
                  -15 + ((value + i / 3) % 1.0) * 30,
                  0,
                ),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  String _getModelDisplayName(String model) {
    switch (model) {
      case 'gpt':
        return 'OpenAI GPT';
      case 'claude':
        return 'Anthropic Claude';
      case 'deepseek':
        return 'DeepSeek';
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
        return 'DS';
      default:
        return model.substring(0, math.min(2, model.length)).toUpperCase();
    }
  }
}