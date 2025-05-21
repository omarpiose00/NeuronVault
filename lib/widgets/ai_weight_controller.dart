// lib/widgets/ai_weight_controller.dart
import 'package:flutter/material.dart';
import '../widgets/ui/glass_container.dart';

class AIWeightController extends StatefulWidget {
  final Map<String, double> weights;
  final Function(String, double) onWeightChanged;
  final VoidCallback onResetWeights;
  final Function(Map<String, double>) onApplyPreset; // Added parameter
  final bool isExpanded;

  const AIWeightController({
    Key? key,
    required this.weights,
    required this.onWeightChanged,
    required this.onResetWeights,
    required this.onApplyPreset, // Added parameter
    this.isExpanded = false,
  }) : super(key: key);

  @override
  State<AIWeightController> createState() => _AIWeightControllerState();
}

class _AIWeightControllerState extends State<AIWeightController> {
  // Preimpostazioni di pesi per scenari comuni
  final Map<String, Map<String, double>> _presets = {
    'Bilanciato': {
      'gpt': 1.0,
      'claude': 1.0,
      'deepseek': 1.0,
      'gemini': 1.0,
      'mistral': 1.0,
      'ollama': 1.0,
      'llama': 1.0,
    },
    'Creativo': {
      'gpt': 1.2,
      'claude': 1.5,
      'deepseek': 0.8,
      'gemini': 1.2,
      'mistral': 0.7,
      'ollama': 0.8,
      'llama': 0.8,
    },
    'Analitico': {
      'gpt': 1.3,
      'claude': 0.9,
      'deepseek': 1.4,
      'gemini': 1.0,
      'mistral': 1.2,
      'ollama': 0.7,
      'llama': 0.7,
    },
    'Solo OpenAI': {
      'gpt': 2.0,
      'claude': 0.1,
      'deepseek': 0.1,
      'gemini': 0.1,
      'mistral': 0.1,
      'ollama': 0.1,
      'llama': 0.1,
    },
    'Solo Claude': {
      'gpt': 0.1,
      'claude': 2.0,
      'deepseek': 0.1,
      'gemini': 0.1,
      'mistral': 0.1,
      'ollama': 0.1,
      'llama': 0.1,
    },
  };

  String _activePreset = 'Personalizzato';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: 16,
      backgroundColor: isDark
          ? Colors.black.withOpacity(0.3)
          : Colors.white.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Intestazione con titolo e azioni
          Row(
            children: [
              Icon(
                Icons.balance,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Controllo Pesi Modelli AI',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              // Pulsante di espansione/compressione
              if (widget.isExpanded)
                IconButton(
                  icon: const Icon(Icons.unfold_less),
                  onPressed: () {
                    // Implementazione compressione
                  },
                  tooltip: 'Comprimi',
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Selezione preset
          _buildPresetSelector(theme),

          const SizedBox(height: 16),

          // Slider per ogni modello
          ...widget.weights.entries.map((entry) =>
              _buildModelWeightSlider(entry.key, entry.value, theme)
          ).toList(),

          const SizedBox(height: 16),

          // Pulsanti di azione
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.restart_alt),
                label: const Text('Ripristina Default'),
                onPressed: () {
                  widget.onResetWeights();
                  setState(() {
                    _activePreset = 'Bilanciato';
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preimpostazioni:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ..._presets.keys.map((presetName) =>
                  _buildPresetChip(presetName, theme)
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPresetChip(String presetName, ThemeData theme) {
    final isActive = _activePreset == presetName;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(presetName),
        selected: isActive,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _activePreset = presetName;
            });

            // Use the new onApplyPreset callback
            widget.onApplyPreset(_presets[presetName]!);
          }
        },
        backgroundColor: theme.colorScheme.surface,
        selectedColor: theme.colorScheme.primaryContainer,
        checkmarkColor: theme.colorScheme.onPrimaryContainer,
      ),
    );
  }

  Widget _buildModelWeightSlider(String model, double value, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: value,
            min: 0.0,
            max: 2.0,
            divisions: 20,
            label: value.toStringAsFixed(2),
            onChanged: (newValue) {
              widget.onWeightChanged(model, newValue);
            },
            activeColor: theme.colorScheme.primary,
            inactiveColor: theme.colorScheme.primary.withOpacity(0.2),
          ),
        ),
        SizedBox(width: 8),
        Text(model, style: TextStyle(fontWeight: FontWeight.w500)),
        SizedBox(width: 8),
        Text(value.toStringAsFixed(2)),
      ],
    );
  }

// Rest of the existing methods (_getModelColor, _getModelIcon, _getModelDisplayName) remain unchanged...
// ... [keep all other existing methods exactly as they were]
}

