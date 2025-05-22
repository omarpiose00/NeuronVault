// lib/providers/api_key_provider.dart - Implementazione completa
import 'package:flutter/material.dart';
import '../services/api_key_manager.dart';

class ApiKeyProvider extends ChangeNotifier {
  final ApiKeyManager _manager = ApiKeyManager();

  // Stati interni
  Map<String, String> _keys = {};
  Map<String, bool> _enabled = {};
  Map<String, bool> _testing = {};
  Map<String, bool> _testResults = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  Map<String, String> get keys => Map.unmodifiable(_keys);
  Map<String, bool> get enabled => Map.unmodifiable(_enabled);
  Map<String, bool> get testing => Map.unmodifiable(_testing);
  Map<String, bool> get testResults => Map.unmodifiable(_testResults);
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<String> get enabledProviders => _enabled.entries
      .where((entry) => entry.value)
      .map((entry) => entry.key)
      .toList();

  int get enabledCount => enabledProviders.length;
  bool get hasAnyEnabled => enabledCount > 0;

  // Inizializzazione
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _manager.loadKeys();

      // Carica keys e stati
      for (final provider in _manager.supportedProviders) {
        final key = _manager.getKey(provider);
        if (key != null) {
          _keys[provider] = key;
        }
        _enabled[provider] = _manager.isEnabled(provider);
        _testResults[provider] = false;
      }

      _error = null;
    } catch (e) {
      _error = 'Errore nel caricamento delle configurazioni: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Gestione chiavi API
  Future<bool> setKey(String provider, String key) async {
    if (!_manager.supportedProviders.contains(provider)) {
      _error = 'Provider non supportato: $provider';
      notifyListeners();
      return false;
    }

    try {
      await _manager.setKey(provider, key);
      _keys[provider] = key;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Errore nel salvataggio della chiave per $provider: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeKey(String provider) async {
    try {
      await _manager.removeKey(provider);
      _keys.remove(provider);
      _enabled[provider] = false;
      _testResults[provider] = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Errore nella rimozione della chiave per $provider: $e';
      notifyListeners();
      return false;
    }
  }

  String? getKey(String provider) => _keys[provider];

  // Gestione abilitazione provider
  Future<void> toggleProvider(String provider, bool enabled) async {
    try {
      await _manager.setEnabled(provider, enabled);
      _enabled[provider] = enabled;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Errore nel cambio stato per $provider: $e';
      notifyListeners();
    }
  }

  bool isEnabled(String provider) => _enabled[provider] ?? false;
  bool hasKey(String provider) => _keys.containsKey(provider) && _keys[provider]!.isNotEmpty;

  // Test connessioni
  Future<bool> testKey(String provider) async {
    if (!hasKey(provider)) {
      _error = 'Nessuna chiave configurata per $provider';
      notifyListeners();
      return false;
    }

    _testing[provider] = true;
    notifyListeners();

    try {
      final result = await _manager.testKey(provider);
      _testResults[provider] = result;
      _error = null;
      return result;
    } catch (e) {
      _testResults[provider] = false;
      _error = 'Errore nel test per $provider: $e';
      return false;
    } finally {
      _testing[provider] = false;
      notifyListeners();
    }
  }

  Future<Map<String, bool>> testAllKeys() async {
    final results = <String, bool>{};

    _setLoading(true);

    try {
      for (final provider in _keys.keys) {
        if (hasKey(provider)) {
          results[provider] = await testKey(provider);
        }
      }
      _error = null;
    } catch (e) {
      _error = 'Errore nel test delle connessioni: $e';
    } finally {
      _setLoading(false);
    }

    return results;
  }

  bool isTestSuccessful(String provider) => _testResults[provider] ?? false;
  bool isTesting(String provider) => _testing[provider] ?? false;

  // Configurazioni aggiuntive
  Future<void> setAdditionalConfig(String provider, Map<String, dynamic> config) async {
    try {
      await _manager.setAdditionalConfig(provider, config);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Errore nel salvataggio configurazione per $provider: $e';
      notifyListeners();
    }
  }

  Map<String, dynamic>? getAdditionalConfig(String provider) {
    return _manager.getAdditionalConfig(provider);
  }

  // Salvataggio
  Future<bool> saveAll() async {
    _setLoading(true);
    try {
      await _manager.saveKeys();
      _error = null;
      return true;
    } catch (e) {
      _error = 'Errore nel salvataggio: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reset
  Future<void> resetAll() async {
    _setLoading(true);
    try {
      await _manager.clearAll();
      _keys.clear();
      _enabled.clear();
      _testResults.clear();
      _testing.clear();
      _error = null;
    } catch (e) {
      _error = 'Errore nel reset: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Utility
  String getProviderDisplayName(String provider) {
    const displayNames = {
      'openai': 'OpenAI (GPT)',
      'anthropic': 'Anthropic (Claude)',
      'deepseek': 'DeepSeek',
      'google': 'Google (Gemini)',
      'mistral': 'Mistral AI',
      'cohere': 'Cohere',
      'meta': 'Meta AI (Llama)',
      'ollama': 'Ollama (Locale)',
      'llama': 'llama.cpp (Locale)',
    };
    return displayNames[provider] ?? provider.toUpperCase();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Validazione
  String? validateApiKey(String provider, String key) {
    if (key.isEmpty) return 'La chiave API non può essere vuota';

    switch (provider) {
      case 'openai':
        if (!key.startsWith('sk-')) return 'Chiave OpenAI deve iniziare con "sk-"';
        if (key.length < 20) return 'Chiave OpenAI troppo corta';
        break;
      case 'anthropic':
        if (!key.startsWith('sk-ant-')) return 'Chiave Anthropic deve iniziare con "sk-ant-"';
        break;
      case 'deepseek':
        if (key.length < 10) return 'Chiave DeepSeek troppo corta';
        break;
      case 'google':
        if (key.length < 30) return 'Chiave Google troppo corta';
        break;
    }

    return null;
  }

  // Statistiche
  Map<String, dynamic> getStats() {
    return {
      'totalProviders': _manager.supportedProviders.length,
      'configuredProviders': _keys.length,
      'enabledProviders': enabledCount,
      'testedProviders': _testResults.values.where((r) => r).length,
      'lastUpdate': DateTime.now().toIso8601String(),
    };
  }
}