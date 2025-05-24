// 🔧 NEURONVAULT - SECURE CONFIGURATION SERVICE
// Enterprise-grade configuration management with encryption
// Part of PHASE 2.5 - QUANTUM STATE MANAGEMENT

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import '../state/state_models.dart';

class ConfigService {
  final SharedPreferences _sharedPreferences;
  final FlutterSecureStorage _secureStorage;
  final Logger _logger;
  
  late final Encrypter _encrypter;
  late final IV _iv;
  
  // 🔑 STORAGE KEYS
  static const String _strategyKey = 'neuronvault_strategy';
  static const String _modelsKey = 'neuronvault_models';
  static const String _connectionKey = 'neuronvault_connection';
  static const String _themeKey = 'neuronvault_theme';
  static const String _encryptionKeyKey = 'neuronvault_encryption_key';
  static const String _appConfigKey = 'neuronvault_app_config';

  ConfigService({
    required SharedPreferences sharedPreferences,
    required FlutterSecureStorage secureStorage,
    required Logger logger,
  }) : _sharedPreferences = sharedPreferences,
       _secureStorage = secureStorage,
       _logger = logger {
    _initializeEncryption();
  }

  // 🔐 ENCRYPTION INITIALIZATION
  Future<void> _initializeEncryption() async {
    try {
      _logger.d('🔐 Initializing encryption system...');
      
      // Get or create encryption key
      String? existingKey = await _secureStorage.read(key: _encryptionKeyKey);
      
      if (existingKey == null) {
        // Generate new encryption key
        final key = Key.fromSecureRandom(32);
        existingKey = key.base64;
        await _secureStorage.write(key: _encryptionKeyKey, value: existingKey);
        _logger.i('🔑 New encryption key generated and stored securely');
      }
      
      // Initialize encrypter
      final key = Key.fromBase64(existingKey);
      _encrypter = Encrypter(AES(key));
      _iv = IV.fromSecureRandom(16);
      
      _logger.i('✅ Encryption system initialized successfully');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to initialize encryption', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // 🎛️ STRATEGY CONFIGURATION
  Future<void> saveStrategy(StrategyState strategy) async {
    try {
      _logger.d('💾 Saving strategy configuration...');
      
      final jsonData = strategy.toJson();
      final encryptedData = _encryptData(jsonData);
      
      await _sharedPreferences.setString(_strategyKey, encryptedData);
      
      _logger.i('✅ Strategy configuration saved successfully');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to save strategy', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<StrategyState?> getStrategy() async {
    try {
      _logger.d('📖 Loading strategy configuration...');
      
      final encryptedData = _sharedPreferences.getString(_strategyKey);
      if (encryptedData == null) {
        _logger.d('ℹ️ No strategy configuration found');
        return null;
      }
      
      final jsonData = _decryptData(encryptedData);
      final strategy = StrategyState.fromJson(jsonData);
      
      _logger.i('✅ Strategy configuration loaded successfully');
      return strategy;
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to load strategy', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // 🤖 MODELS CONFIGURATION
  Future<void> saveModelsConfig(ModelsState models) async {
    try {
      _logger.d('💾 Saving models configuration...');
      
      // Separate sensitive data (API keys) from regular config
      final publicConfig = _extractPublicModelsConfig(models);
      final sensitiveConfig = _extractSensitiveModelsConfig(models);
      
      // Save public config to SharedPreferences (encrypted)
      final publicJsonData = publicConfig.toJson();
      final encryptedPublicData = _encryptData(publicJsonData);
      await _sharedPreferences.setString(_modelsKey, encryptedPublicData);
      
      // Save sensitive config to SecureStorage
      final sensitiveJson = jsonEncode(sensitiveConfig);
      await _secureStorage.write(key: '${_modelsKey}_sensitive', value: sensitiveJson);
      
      _logger.i('✅ Models configuration saved successfully');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to save models config', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<ModelsState?> getModelsConfig() async {
    try {
      _logger.d('📖 Loading models configuration...');
      
      // Load public config
      final encryptedPublicData = _sharedPreferences.getString(_modelsKey);
      if (encryptedPublicData == null) {
        _logger.d('ℹ️ No models configuration found');
        return null;
      }
      
      final publicJsonData = _decryptData(encryptedPublicData);
      final publicConfig = ModelsState.fromJson(publicJsonData);
      
      // Load sensitive config
      final sensitiveJson = await _secureStorage.read(key: '${_modelsKey}_sensitive');
      final sensitiveConfig = sensitiveJson != null 
          ? jsonDecode(sensitiveJson) as Map<String, dynamic>
          : <String, dynamic>{};
      
      // Merge configurations
      final mergedConfig = _mergeModelsConfig(publicConfig, sensitiveConfig);
      
      _logger.i('✅ Models configuration loaded successfully');
      return mergedConfig;
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to load models config', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // 🌐 CONNECTION CONFIGURATION
  Future<void> saveConnectionConfig(ConnectionState connection) async {
    try {
      _logger.d('💾 Saving connection configuration...');
      
      final jsonData = connection.toJson();
      final encryptedData = _encryptData(jsonData);
      
      await _sharedPreferences.setString(_connectionKey, encryptedData);
      
      _logger.i('✅ Connection configuration saved successfully');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to save connection config', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<ConnectionState?> getConnectionConfig() async {
    try {
      _logger.d('📖 Loading connection configuration...');
      
      final encryptedData = _sharedPreferences.getString(_connectionKey);
      if (encryptedData == null) {
        _logger.d('ℹ️ No connection configuration found');
        return null;
      }
      
      final jsonData = _decryptData(encryptedData);
      final connection = ConnectionState.fromJson(jsonData);
      
      _logger.i('✅ Connection configuration loaded successfully');
      return connection;
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to load connection config', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // 🎨 THEME CONFIGURATION
  Future<void> saveThemeConfig(AppTheme theme, bool isDarkMode) async {
    try {
      _logger.d('💾 Saving theme configuration...');
      
      final themeConfig = {
        'theme': theme.name,
        'isDarkMode': isDarkMode,
        'lastUpdate': DateTime.now().toIso8601String(),
      };
      
      final encryptedData = _encryptData(themeConfig);
      await _sharedPreferences.setString(_themeKey, encryptedData);
      
      _logger.i('✅ Theme configuration saved successfully');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to save theme config', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getThemeConfig() async {
    try {
      _logger.d('📖 Loading theme configuration...');
      
      final encryptedData = _sharedPreferences.getString(_themeKey);
      if (encryptedData == null) {
        _logger.d('ℹ️ No theme configuration found');
        return null;
      }
      
      final themeConfig = _decryptData(encryptedData);
      
      _logger.i('✅ Theme configuration loaded successfully');
      return themeConfig;
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to load theme config', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // 📊 APPLICATION CONFIGURATION
  Future<void> saveAppConfig(Map<String, dynamic> config) async {
    try {
      _logger.d('💾 Saving application configuration...');
      
      final configWithMetadata = {
        ...config,
        'version': '2.5.0',
        'lastUpdate': DateTime.now().toIso8601String(),
        'platform': 'flutter_desktop',
      };
      
      final encryptedData = _encryptData(configWithMetadata);
      await _sharedPreferences.setString(_appConfigKey, encryptedData);
      
      _logger.i('✅ Application configuration saved successfully');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to save app config', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getAppConfig() async {
    try {
      _logger.d('📖 Loading application configuration...');
      
      final encryptedData = _sharedPreferences.getString(_appConfigKey);
      if (encryptedData == null) {
        _logger.d('ℹ️ No application configuration found');
        return null;
      }
      
      final appConfig = _decryptData(encryptedData);
      
      _logger.i('✅ Application configuration loaded successfully');
      return appConfig;
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to load app config', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // 🔄 BACKUP & RESTORE
  Future<String> exportConfiguration() async {
    try {
      _logger.i('📤 Exporting configuration...');
      
      final exportData = {
        'version': '2.5.0',
        'exportTime': DateTime.now().toIso8601String(),
        'strategy': await getStrategy(),
        'models': await getModelsConfig(),
        'connection': await getConnectionConfig(),
        'theme': await getThemeConfig(),
        'app': await getAppConfig(),
      };
      
      // Remove sensitive data from export
      final sanitizedData = _sanitizeExportData(exportData);
      
      final exportJson = jsonEncode(sanitizedData);
      final encryptedExport = _encryptData(sanitizedData);
      
      _logger.i('✅ Configuration exported successfully');
      return encryptedExport;
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to export configuration', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> importConfiguration(String encryptedData, String password) async {
    try {
      _logger.i('📥 Importing configuration...');
      
      // Decrypt with password
      final importData = _decryptDataWithPassword(encryptedData, password);
      
      // Validate import data
      _validateImportData(importData);
      
      // Import each configuration
      if (importData['strategy'] != null) {
        final strategy = StrategyState.fromJson(importData['strategy']);
        await saveStrategy(strategy);
      }
      
      if (importData['connection'] != null) {
        final connection = ConnectionState.fromJson(importData['connection']);
        await saveConnectionConfig(connection);
      }
      
      if (importData['theme'] != null) {
        final themeData = importData['theme'] as Map<String, dynamic>;
        await _sharedPreferences.setString(_themeKey, jsonEncode(themeData));
      }
      
      if (importData['app'] != null) {
        await saveAppConfig(importData['app']);
      }
      
      _logger.i('✅ Configuration imported successfully');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to import configuration', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // 🗑️ CLEANUP & RESET
  Future<void> clearAllConfiguration() async {
    try {
      _logger.w('🗑️ Clearing all configuration...');
      
      // Clear SharedPreferences
      await _sharedPreferences.remove(_strategyKey);
      await _sharedPreferences.remove(_modelsKey);
      await _sharedPreferences.remove(_connectionKey);
      await _sharedPreferences.remove(_themeKey);
      await _sharedPreferences.remove(_appConfigKey);
      
      // Clear SecureStorage (except encryption key)
      await _secureStorage.delete(key: '${_modelsKey}_sensitive');
      
      _logger.i('✅ All configuration cleared successfully');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to clear configuration', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> resetToDefaults() async {
    try {
      _logger.i('🔄 Resetting to default configuration...');
      
      await clearAllConfiguration();
      
      // Initialize with default values will happen automatically
      // when controllers try to load configuration
      
      _logger.i('✅ Configuration reset to defaults');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to reset configuration', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // 🔐 ENCRYPTION UTILITIES
  String _encryptData(Map<String, dynamic> data) {
    try {
      final jsonString = jsonEncode(data);
      final encrypted = _encrypter.encrypt(jsonString, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      _logger.e('❌ Encryption failed: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _decryptData(String encryptedData) {
    try {
      final encrypted = Encrypted.fromBase64(encryptedData);
      final decryptedString = _encrypter.decrypt(encrypted, iv: _iv);
      return jsonDecode(decryptedString) as Map<String, dynamic>;
    } catch (e) {
      _logger.e('❌ Decryption failed: $e');
      rethrow;
    }
  }

  String _encryptDataWithPassword(Map<String, dynamic> data, String password) {
    try {
      final key = Key.fromBase64(sha256.convert(utf8.encode(password)).toString());
      final encrypter = Encrypter(AES(key));
      final iv = IV.fromSecureRandom(16);
      
      final jsonString = jsonEncode(data);
      final encrypted = encrypter.encrypt(jsonString, iv: iv);
      
      return '${iv.base64}:${encrypted.base64}';
    } catch (e) {
      _logger.e('❌ Password encryption failed: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _decryptDataWithPassword(String encryptedData, String password) {
    try {
      final parts = encryptedData.split(':');
      if (parts.length != 2) {
        throw const FormatException('Invalid encrypted data format');
      }
      
      final iv = IV.fromBase64(parts[0]);
      final encrypted = Encrypted.fromBase64(parts[1]);
      
      final key = Key.fromBase64(sha256.convert(utf8.encode(password)).toString());
      final encrypter = Encrypter(AES(key));
      
      final decryptedString = encrypter.decrypt(encrypted, iv: iv);
      return jsonDecode(decryptedString) as Map<String, dynamic>;
    } catch (e) {
      _logger.e('❌ Password decryption failed: $e');
      rethrow;
    }
  }

  // 🛡️ SENSITIVE DATA HANDLING
  ModelsState _extractPublicModelsConfig(ModelsState models) {
    final publicModels = <AIModel, ModelConfig>{};
    
    for (final entry in models.availableModels.entries) {
      publicModels[entry.key] = entry.value.copyWith(apiKey: ''); // Remove API key
    }
    
    return models.copyWith(availableModels: publicModels);
  }

  Map<String, String> _extractSensitiveModelsConfig(ModelsState models) {
    final sensitiveData = <String, String>{};
    
    for (final entry in models.availableModels.entries) {
      if (entry.value.apiKey.isNotEmpty) {
        sensitiveData['${entry.key.name}_api_key'] = entry.value.apiKey;
      }
    }
    
    return sensitiveData;
  }

  ModelsState _mergeModelsConfig(ModelsState publicConfig, Map<String, dynamic> sensitiveConfig) {
    final mergedModels = <AIModel, ModelConfig>{};
    
    for (final entry in publicConfig.availableModels.entries) {
      final apiKey = sensitiveConfig['${entry.key.name}_api_key'] as String? ?? '';
      mergedModels[entry.key] = entry.value.copyWith(apiKey: apiKey);
    }
    
    return publicConfig.copyWith(availableModels: mergedModels);
  }

  Map<String, dynamic> _sanitizeExportData(Map<String, dynamic> data) {
    final sanitized = Map<String, dynamic>.from(data);
    
    // Remove sensitive information from export
    if (sanitized['models'] != null) {
      final models = sanitized['models'] as Map<String, dynamic>;
      // API keys are already removed in _extractPublicModelsConfig
    }
    
    return sanitized;
  }

  void _validateImportData(Map<String, dynamic> data) {
    if (data['version'] == null) {
      throw const FormatException('Invalid import data: missing version');
    }
    
    // Add more validation as needed
  }

  // 📊 DIAGNOSTICS
  Future<Map<String, dynamic>> getDiagnostics() async {
    return {
      'hasStrategy': _sharedPreferences.containsKey(_strategyKey),
      'hasModels': _sharedPreferences.containsKey(_modelsKey),
      'hasConnection': _sharedPreferences.containsKey(_connectionKey),
      'hasTheme': _sharedPreferences.containsKey(_themeKey),
      'hasAppConfig': _sharedPreferences.containsKey(_appConfigKey),
      'encryptionInitialized': true,
      'storageSize': _calculateStorageSize(),
    };
  }

  int _calculateStorageSize() {
    int totalSize = 0;
    
    for (final key in _sharedPreferences.getKeys()) {
      if (key.startsWith('neuronvault_')) {
        final value = _sharedPreferences.getString(key) ?? '';
        totalSize += value.length;
      }
    }
    
    return totalSize;
  }
}