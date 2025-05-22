import 'package:flutter/material.dart';

class AppStateProvider extends ChangeNotifier {
  // Stato dell'applicazione
  bool _isInitialSetupComplete = false;
  bool _isBackendRunning = false;
  String _currentConversationId = '';
  bool _isProcessing = false;

  // Pesi dei modelli AI con valori iniziali
  final Map<String, double> _modelWeights = {
    'openai': 1.0,
    'anthropic': 1.0,
    'deepseek': 1.0,
    'google': 1.0,
    'mistral': 1.0,
    'ollama': 1.0,
    'llama': 1.0,
    'cohere': 1.0,
    'meta': 1.0,
  };

  // Configurazioni presettate
  static const Map<String, Map<String, double>> _presets = {
    'balanced': {
      'openai': 1.0,
      'anthropic': 1.0,
      'deepseek': 1.0,
      'google': 1.0,
      'mistral': 1.0,
      'ollama': 1.0,
      'llama': 1.0,
      'cohere': 1.0,
      'meta': 1.0,
    },
    'creative': {
      'openai': 1.2,
      'anthropic': 1.1,
      'google': 1.3,
      'mistral': 0.8,
      'others': 0.7,
    },
    'technical': {
      'openai': 1.5,
      'deepseek': 1.3,
      'google': 1.2,
      'others': 0.5,
    },
    'local': {
      'ollama': 1.5,
      'llama': 1.5,
      'others': 0.2,
    },
  };

  // Getter
  bool get isInitialSetupComplete => _isInitialSetupComplete;
  bool get isBackendRunning => _isBackendRunning;
  String get currentConversationId => _currentConversationId;
  bool get isProcessing => _isProcessing;
  Map<String, double> get modelWeights => Map.unmodifiable(_modelWeights);
  static Map<String, Map<String, double>> get presets => _presets;

  // Setter
  void markInitialSetupComplete() {
    _isInitialSetupComplete = true;
    notifyListeners();
  }

  void setBackendStatus(bool isRunning) {
    _isBackendRunning = isRunning;
    notifyListeners();
  }

  void startNewConversation() {
    _currentConversationId = DateTime.now().millisecondsSinceEpoch.toString();
    notifyListeners();
  }

  void setProcessing(bool isProcessing) {
    _isProcessing = isProcessing;
    notifyListeners();
  }

  // Metodi per la gestione dei pesi
  void updateModelWeight(String model, double weight) {
    if (_modelWeights.containsKey(model)) {
      _modelWeights[model] = weight.clamp(0.0, 2.0); // Limita tra 0 e 2
      notifyListeners();
    }
  }

  void resetModelWeights() {
    for (final key in _modelWeights.keys) {
      _modelWeights[key] = 1.0;
    }
    notifyListeners();
  }

  void applyPresetWeights(Map<String, double> presetWeights) {
    // Applica i pesi forniti direttamente
    for (final entry in presetWeights.entries) {
      if (_modelWeights.containsKey(entry.key)) {
        _modelWeights[entry.key] = entry.value;
      }
    }
    notifyListeners();
  }

  // Calcola il peso normalizzato (0-1) per la visualizzazione
  double getNormalizedWeight(String model) {
    if (!_modelWeights.containsKey(model)) return 0.0;
    return _modelWeights[model]! / 2.0; // Normalizza tra 0 e 1 (per slider)
  }

  // Imposta il peso da un valore normalizzato (0-1)
  void setNormalizedWeight(String model, double normalizedValue) {
    if (_modelWeights.containsKey(model)) {
      _modelWeights[model] = normalizedValue * 2.0; // Da 0-1 a 0-2
      notifyListeners();
    }
  }
}

