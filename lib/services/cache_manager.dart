// lib/services/cache_manager.dart - Sistema di caching avanzato
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final DateTime expiresAt;
  final String key;
  final Map<String, dynamic> metadata;

  CacheEntry({
    required this.data,
    required this.timestamp,
    required this.expiresAt,
    required this.key,
    this.metadata = const {},
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  Duration get timeToLive => expiresAt.difference(DateTime.now());
  Duration get age => DateTime.now().difference(timestamp);

  Map<String, dynamic> toJson() => {
    'data': data,
    'timestamp': timestamp.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'key': key,
    'metadata': metadata,
  };

  factory CacheEntry.fromJson(Map<String, dynamic> json, T data) {
    return CacheEntry<T>(
      data: data,
      timestamp: DateTime.parse(json['timestamp']),
      expiresAt: DateTime.parse(json['expiresAt']),
      key: json['key'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

enum CacheLevel {
  memory,      // RAM cache - veloce ma volatile
  persistent,  // Storage cache - più lento ma persistente
  both,       // Entrambi i livelli
}

class CacheManager extends ChangeNotifier {
  static CacheManager? _instance;
  static CacheManager get instance => _instance ??= CacheManager._internal();

  CacheManager._internal();

  // Memory cache
  final Map<String, CacheEntry> _memoryCache = {};

  // Configurazioni
  final Map<String, Duration> _defaultTTLs = {
    'api_response': const Duration(minutes: 5),
    'user_preference': const Duration(days: 30),
    'model_response': const Duration(minutes: 10),
    'image_analysis': const Duration(hours: 1),
    'conversation': const Duration(hours: 24),
  };

  int _maxMemoryEntries = 1000;
  int _maxPersistentEntries = 5000;

  // Statistiche
  int _hits = 0;
  int _misses = 0;
  int _evictions = 0;

  // Inizializzazione
  Future<void> initialize() async {
    await _cleanupExpiredEntries();
    _scheduleCleanup();
  }

  // GET - Recupera dal cache
  Future<T?> get<T>(
      String key, {
        CacheLevel level = CacheLevel.both,
        Duration? customTTL,
      }) async {
    // Prova prima dalla memoria
    if (level == CacheLevel.memory || level == CacheLevel.both) {
      final memoryEntry = _memoryCache[key];
      if (memoryEntry != null && !memoryEntry.isExpired) {
        _hits++;
        notifyListeners();
        return memoryEntry.data as T?;
      }
    }

    // Poi dallo storage persistente
    if (level == CacheLevel.persistent || level == CacheLevel.both) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final jsonString = prefs.getString('cache_$key');

        if (jsonString != null) {
          final jsonData = jsonDecode(jsonString);
          final entry = CacheEntry.fromJson(jsonData, jsonData['data'] as T);

          if (!entry.isExpired) {
            // Promuovi in memoria se richiesto
            if (level == CacheLevel.both) {
              _memoryCache[key] = entry;
              _enforceMemoryLimit();
            }

            _hits++;
            notifyListeners();
            return entry.data;
          } else {
            // Rimuovi entry scaduta
            await _removePersistent(key);
          }
        }
      } catch (e) {
        debugPrint('Error reading from persistent cache: $e');
      }
    }

    _misses++;
    notifyListeners();
    return null;
  }

  // SET - Salva nel cache
  Future<void> set<T>(
      String key,
      T data, {
        Duration? ttl,
        CacheLevel level = CacheLevel.both,
        Map<String, dynamic> metadata = const {},
      }) async {
    final effectiveTTL = ttl ?? _getDefaultTTL(key);
    final entry = CacheEntry<T>(
      data: data,
      timestamp: DateTime.now(),
      expiresAt: DateTime.now().add(effectiveTTL),
      key: key,
      metadata: metadata,
    );

    // Salva in memoria
    if (level == CacheLevel.memory || level == CacheLevel.both) {
      _memoryCache[key] = entry;
      _enforceMemoryLimit();
    }

    // Salva nello storage persistente
    if (level == CacheLevel.persistent || level == CacheLevel.both) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cache_$key', jsonEncode(entry.toJson()));
        await _enforcePersistentLimit();
      } catch (e) {
        debugPrint('Error writing to persistent cache: $e');
      }
    }

    notifyListeners();
  }

  // REMOVE - Rimuove dal cache
  Future<void> remove(String key, {CacheLevel level = CacheLevel.both}) async {
    if (level == CacheLevel.memory || level == CacheLevel.both) {
      _memoryCache.remove(key);
    }

    if (level == CacheLevel.persistent || level == CacheLevel.both) {
      await _removePersistent(key);
    }

    notifyListeners();
  }

  // CLEAR - Pulisce il cache
  Future<void> clear({CacheLevel level = CacheLevel.both}) async {
    if (level == CacheLevel.memory || level == CacheLevel.both) {
      _memoryCache.clear();
    }

    if (level == CacheLevel.persistent || level == CacheLevel.both) {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('cache_'));
      for (final key in keys) {
        await prefs.remove(key);
      }
    }

    notifyListeners();
  }

  // Metodi specializzati per tipi di dati comuni

  // Cache per risposte API
  Future<void> cacheApiResponse(
      String endpoint,
      Map<String, dynamic> params,
      dynamic response, {
        Duration? ttl,
      }) async {
    final key = _generateApiKey(endpoint, params);
    await set(
        key,
        response,
        ttl: ttl ?? const Duration(minutes: 5),
        metadata: {
          'type': 'api_response',
          'endpoint': endpoint,
          'params': params,
        }
    );
  }

  Future<T?> getCachedApiResponse<T>(
      String endpoint,
      Map<String, dynamic> params,
      ) async {
    final key = _generateApiKey(endpoint, params);
    return await get<T>(key);
  }

  // Cache per conversazioni
  Future<void> cacheConversation(
      String conversationId,
      List<dynamic> messages, {
        Duration? ttl,
      }) async {
    await set(
        'conversation_$conversationId',
        messages,
        ttl: ttl ?? const Duration(hours: 24),
        metadata: {
          'type': 'conversation',
          'messageCount': messages.length,
        }
    );
  }

  Future<List<dynamic>?> getCachedConversation(String conversationId) async {
    return await get<List<dynamic>>('conversation_$conversationId');
  }

  // Cache per modelli AI
  Future<void> cacheModelResponse(
      String model,
      String prompt,
      String response, {
        Duration? ttl,
        Map<String, dynamic>? weights,
      }) async {
    final key = _generateModelKey(model, prompt, weights);
    await set(
        key,
        response,
        ttl: ttl ?? const Duration(minutes: 10),
        metadata: {
          'type': 'model_response',
          'model': model,
          'prompt_length': prompt.length,
          'response_length': response.length,
          'weights': weights,
        }
    );
  }

  Future<String?> getCachedModelResponse(
      String model,
      String prompt, {
        Map<String, dynamic>? weights,
      }) async {
    final key = _generateModelKey(model, prompt, weights);
    return await get<String>(key);
  }

  // Utility methods
  String _generateApiKey(String endpoint, Map<String, dynamic> params) {
    final data = '$endpoint${jsonEncode(params)}';
    return 'api_${_hash(data)}';
  }

  String _generateModelKey(String model, String prompt, Map<String, dynamic>? weights) {
    final data = '$model$prompt${jsonEncode(weights ?? {})}';
    return 'model_${_hash(data)}';
  }

  String _hash(String input) {
    return sha256.convert(utf8.encode(input)).toString().substring(0, 16);
  }

  Duration _getDefaultTTL(String key) {
    for (final entry in _defaultTTLs.entries) {
      if (key.contains(entry.key)) {
        return entry.value;
      }
    }
    return const Duration(minutes: 5);
  }

  // Gestione limiti memoria
  void _enforceMemoryLimit() {
    while (_memoryCache.length > _maxMemoryEntries) {
      final oldestKey = _memoryCache.keys.reduce((a, b) =>
      _memoryCache[a]!.timestamp.isBefore(_memoryCache[b]!.timestamp) ? a : b
      );
      _memoryCache.remove(oldestKey);
      _evictions++;
    }
  }

  // Gestione limiti storage persistente
  Future<void> _enforcePersistentLimit() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKeys = prefs.getKeys().where((key) => key.startsWith('cache_')).toList();

    if (cacheKeys.length > _maxPersistentEntries) {
      // Rimuovi le voci più vecchie
      final entries = <String, DateTime>{};

      for (final key in cacheKeys) {
        try {
          final jsonString = prefs.getString(key);
          if (jsonString != null) {
            final jsonData = jsonDecode(jsonString);
            entries[key] = DateTime.parse(jsonData['timestamp']);
          }
        } catch (e) {
          // Rimuovi entry corrotta
          await prefs.remove(key);
        }
      }

      final sortedKeys = entries.keys.toList()
        ..sort((a, b) => entries[a]!.compareTo(entries[b]!));

      final keysToRemove = sortedKeys.take(cacheKeys.length - _maxPersistentEntries);
      for (final key in keysToRemove) {
        await prefs.remove(key);
        _evictions++;
      }
    }
  }

  Future<void> _removePersistent(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cache_$key');
  }

  // Cleanup automatico
  void _scheduleCleanup() {
    Timer.periodic(const Duration(minutes: 10), (_) {
      _cleanupExpiredEntries();
    });
  }

  Future<void> _cleanupExpiredEntries() async {
    // Cleanup memoria
    final expiredMemoryKeys = _memoryCache.keys
        .where((key) => _memoryCache[key]!.isExpired)
        .toList();

    for (final key in expiredMemoryKeys) {
      _memoryCache.remove(key);
    }

    // Cleanup storage persistente
    final prefs = await SharedPreferences.getInstance();
    final cacheKeys = prefs.getKeys().where((key) => key.startsWith('cache_'));

    for (final key in cacheKeys) {
      try {
        final jsonString = prefs.getString(key);
        if (jsonString != null) {
          final jsonData = jsonDecode(jsonString);
          final expiresAt = DateTime.parse(jsonData['expiresAt']);

          if (DateTime.now().isAfter(expiresAt)) {
            await prefs.remove(key);
          }
        }
      } catch (e) {
        // Rimuovi entry corrotta
        await prefs.remove(key);
      }
    }

    notifyListeners();
  }

  // Configurazione
  void setMaxMemoryEntries(int max) {
    _maxMemoryEntries = max;
    _enforceMemoryLimit();
  }

  void setMaxPersistentEntries(int max) {
    _maxPersistentEntries = max;
    _enforcePersistentLimit();
  }

  void setDefaultTTL(String type, Duration ttl) {
    _defaultTTLs[type] = ttl;
  }

  // Statistiche e monitoring
  Map<String, dynamic> getStats() {
    final hitRate = _hits + _misses > 0 ? _hits / (_hits + _misses) : 0.0;

    return {
      'hits': _hits,
      'misses': _misses,
      'hitRate': hitRate,
      'evictions': _evictions,
      'memoryEntries': _memoryCache.length,
      'maxMemoryEntries': _maxMemoryEntries,
      'maxPersistentEntries': _maxPersistentEntries,
      'defaultTTLs': _defaultTTLs.map((k, v) => MapEntry(k, v.inMinutes)),
    };
  }

  List<Map<String, dynamic>> getMemoryCacheInfo() {
    return _memoryCache.values.map((entry) => {
      'key': entry.key,
      'age': entry.age.inMinutes,
      'ttl': entry.timeToLive.inMinutes,
      'expired': entry.isExpired,
      'metadata': entry.metadata,
    }).toList();
  }

  void resetStats() {
    _hits = 0;
    _misses = 0;
    _evictions = 0;
    notifyListeners();
  }

  // Widget per visualizzare le statistiche
  Widget buildStatsWidget(BuildContext context) {
    final stats = getStats();

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.memory, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Cache Performance',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text('${stats['memoryEntries']} entries'),
              ],
            ),
            const SizedBox(height: 12),

            LinearProgressIndicator(
              value: stats['hitRate'].toDouble(),
              backgroundColor: Colors.red.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation(
                stats['hitRate'] > 0.8 ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Hit Rate: ${(stats['hitRate'] * 100).toStringAsFixed(1)}%'),
                Text('${stats['hits']}H / ${stats['misses']}M'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}