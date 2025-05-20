import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class ApiKeyManager extends ChangeNotifier {
  // Secure storage per le chiavi API
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Configurazioni locali
  final Map<String, String> _apiKeys = {};
  final Map<String, bool> _enabledModels = {};

  // Configurazioni aggiuntive per modelli locali
  final Map<String, Map<String, dynamic>> _additionalConfigs = {};

  // Lista dei provider supportati
  final List<String> supportedProviders = [
    'openai',    // OpenAI (GPT)
    'anthropic', // Anthropic (Claude)
    'deepseek',  // DeepSeek
    'google',    // Google (Gemini)
    'cohere',    // Cohere
    'mistral',   // Mistral AI
    'meta',      // Meta AI (Llama)
    'ollama',    // Ollama (endpoint locale)
    'llama',     // llama.cpp diretto
    'mini_llm',  // Mini-LLM per sintesi
  ];

  // URL base per test di connessione
  final Map<String, String> _apiBaseUrls = {
    'openai': 'https://api.openai.com/v1/models',
    'anthropic': 'https://api.anthropic.com/v1/messages',
    'deepseek': 'https://api.deepseek.com/v1/models',
    'google': 'https://generativelanguage.googleapis.com/v1/models',
    'cohere': 'https://api.cohere.ai/v1/models',
    'mistral': 'https://api.mistral.ai/v1/models',
    'meta': 'https://api.meta.ai/v1/models', // Endpoint da aggiornare
    'ollama': 'http://localhost:11434/api/tags', // Endpoint Ollama locale
  };

  // Getters
  String? getKey(String provider) => _apiKeys[provider];
  bool isEnabled(String provider) => _enabledModels[provider] ?? false;
  List<String> get enabledProviders => _enabledModels.entries
      .where((entry) => entry.value)
      .map((entry) => entry.key)
      .toList();

  // Getter e setter per configurazioni aggiuntive
  Map<String, dynamic>? getAdditionalConfig(String provider) => _additionalConfigs[provider];

  Future<void> setAdditionalConfig(String provider, Map<String, dynamic> config) async {
    _additionalConfigs[provider] = config;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('config_$provider', jsonEncode(config));
    notifyListeners();
  }

  // Verifica se è il primo avvio
  Future<bool> isFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_first_run') ?? true;
  }

  // Carica le chiavi API e le configurazioni aggiuntive
  Future<void> loadKeys() async {
    try {
      // Carica le chiavi da Secure Storage
      for (final provider in supportedProviders) {
        final key = await _secureStorage.read(key: 'api_key_$provider');
        if (key != null && key.isNotEmpty) {
          _apiKeys[provider] = key;
        }
      }

      // Carica lo stato abilitato/disabilitato
      final prefs = await SharedPreferences.getInstance();
      for (final provider in supportedProviders) {
        _enabledModels[provider] = prefs.getBool('enabled_$provider') ?? false;
      }

      // Carica le configurazioni aggiuntive
      for (final provider in supportedProviders) {
        final configJson = prefs.getString('config_$provider');
        if (configJson != null) {
          try {
            _additionalConfigs[provider] = jsonDecode(configJson);
          } catch (e) {
            debugPrint('Errore nel parsing della configurazione di $provider: $e');
          }
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Errore nel caricamento delle chiavi API: $e');
      rethrow;
    }
  }

  // Salva una chiave API
  Future<void> setKey(String provider, String key) async {
    if (!supportedProviders.contains(provider)) {
      throw Exception('Provider non supportato: $provider');
    }

    _apiKeys[provider] = key;
    await _secureStorage.write(key: 'api_key_$provider', value: key);
    notifyListeners();
  }

  // Abilita/disabilita un provider
  Future<void> setEnabled(String provider, bool enabled) async {
    if (!supportedProviders.contains(provider)) {
      throw Exception('Provider non supportato: $provider');
    }

    _enabledModels[provider] = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enabled_$provider', enabled);
    notifyListeners();
  }

  // Rimuove una chiave API
  Future<void> removeKey(String provider) async {
    _apiKeys.remove(provider);
    await _secureStorage.delete(key: 'api_key_$provider');
    notifyListeners();
  }

  // Salva tutte le configurazioni
  Future<void> saveKeys() async {
    try {
      // Salva le chiavi
      for (final entry in _apiKeys.entries) {
        await _secureStorage.write(key: 'api_key_${entry.key}', value: entry.value);
      }

      // Salva lo stato abilitato/disabilitato
      final prefs = await SharedPreferences.getInstance();
      for (final entry in _enabledModels.entries) {
        await prefs.setBool('enabled_${entry.key}', entry.value);
      }

      // Salva le configurazioni aggiuntive
      for (final entry in _additionalConfigs.entries) {
        await prefs.setString('config_${entry.key}', jsonEncode(entry.value));
      }

      // Segna che l'app non è più al primo avvio
      await prefs.setBool('is_first_run', false);

      notifyListeners();
    } catch (e) {
      debugPrint('Errore nel salvataggio delle chiavi API: $e');
      rethrow;
    }
  }

  // Testa una chiave API
  Future<bool> testKey(String provider) async {
    if (!supportedProviders.contains(provider)) {
      throw Exception('Provider non supportato: $provider');
    }

    // Per llama.cpp e mini-llm, verifichiamo l'esistenza dei file
    if (provider == 'llama' || provider == 'mini_llm') {
      return await _testLocalModelConfig(provider);
    }

    if (!_apiKeys.containsKey(provider) || _apiKeys[provider]!.isEmpty) {
      return false;
    }

    try {
      final key = _apiKeys[provider]!;

      // Gestione speciale per URL personalizzati (per provider locali)
      if (provider == 'ollama' ||
          (provider == 'meta' && (key.startsWith('http://') || key.startsWith('https://')))) {
        return await _testCustomEndpoint(provider, key);
      }

      // Test standard API
      final url = _apiBaseUrls[provider];
      if (url == null) return false;

      final response = await _makeTestRequest(provider, url, key);
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('Errore nel test della chiave API $provider: $e');
      return false;
    }
  }

  // Test configurazione modelli locali
  Future<bool> _testLocalModelConfig(String provider) async {
    if (!_additionalConfigs.containsKey(provider)) {
      return false;
    }

    final config = _additionalConfigs[provider]!;

    // Verifica l'esistenza dei file
    if (provider == 'llama') {
      final executablePath = config['executable_path'];
      final modelPath = config['model_path'];

      if (executablePath == null || modelPath == null) {
        return false;
      }

      return await File(executablePath).exists() &&
          await File(modelPath).exists();
    } else if (provider == 'mini_llm') {
      final executablePath = config['executable_path'];
      final modelPath = config['model_path'];

      if (executablePath == null || modelPath == null) {
        return false;
      }

      return await File(executablePath).exists() &&
          await File(modelPath).exists();
    }

    return false;
  }

  // Test per endpoint personalizzato
  Future<bool> _testCustomEndpoint(String provider, String key) async {
    try {
      String url = key;

      // Se è Ollama e non contiene http, assumiamo localhost
      if (provider == 'ollama' && !key.startsWith('http')) {
        url = 'http://$key:11434/api/tags';

        // Se key è vuoto, usa localhost
        if (key.isEmpty) {
          url = 'http://localhost:11434/api/tags';
        }
      }

      final response = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }

  // Esegue una richiesta di test specifica per provider
  Future<http.Response> _makeTestRequest(String provider, String url, String key) async {
    switch (provider) {
      case 'openai':
        return http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $key',
            'Content-Type': 'application/json',
          },
        ).timeout(const Duration(seconds: 5));

      case 'anthropic':
        return http.get(
          Uri.parse(url),
          headers: {
            'x-api-key': key,
            'anthropic-version': '2023-06-01',
            'Content-Type': 'application/json',
          },
        ).timeout(const Duration(seconds: 5));

      case 'google':
        return http.get(
          Uri.parse('$url?key=$key'),
          headers: {
            'Content-Type': 'application/json',
          },
        ).timeout(const Duration(seconds: 5));

      case 'ollama':
        return http.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
          },
        ).timeout(const Duration(seconds: 5));

      default:
      // Per tutti gli altri provider, tentativo generico
        return http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $key',
            'Content-Type': 'application/json',
          },
        ).timeout(const Duration(seconds: 5));
    }
  }

  // Ottiene le configurazioni per il backend
  Map<String, dynamic> getBackendConfig() {
    final config = <String, dynamic>{};

    // Configurazioni base (API keys)
    for (final provider in supportedProviders) {
      if (_enabledModels[provider] == true && _apiKeys.containsKey(provider)) {
        config[provider.toUpperCase() + '_API_KEY'] = _apiKeys[provider];
      }
    }

    // Configurazioni aggiuntive per modelli locali
    if (_enabledModels['llama'] == true && _additionalConfigs.containsKey('llama')) {
      config['LLAMA_CONFIG'] = _additionalConfigs['llama'];
    }

    if (_enabledModels['mini_llm'] == true && _additionalConfigs.containsKey('mini_llm')) {
      config['MINI_LLM_CONFIG'] = _additionalConfigs['mini_llm'];
    }

    return config;
  }

  // Pulisce tutte le chiavi
  Future<void> clearAll() async {
    try {
      await _secureStorage.deleteAll();

      final prefs = await SharedPreferences.getInstance();
      for (final provider in supportedProviders) {
        await prefs.remove('enabled_$provider');
        await prefs.remove('config_$provider');
      }

      _apiKeys.clear();
      _enabledModels.clear();
      _additionalConfigs.clear();

      notifyListeners();
    } catch (e) {
      debugPrint('Errore nella cancellazione delle chiavi API: $e');
      rethrow;
    }
  }
}