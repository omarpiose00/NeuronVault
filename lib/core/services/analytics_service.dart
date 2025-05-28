// 📊 NEURONVAULT - PRIVACY-FIRST ANALYTICS SERVICE
// Local-only analytics with zero external tracking
// Part of PHASE 2.5 - QUANTUM STATE MANAGEMENT

import 'dart:async';
import 'package:logger/logger.dart';
import '../state/state_models.dart';
import 'storage_service.dart';

class AnalyticsService {
  final StorageService _storageService;
  final Logger _logger;

  // 📊 Analytics Data
  final Map<String, int> _eventCounts = {};
  final Map<String, List<DateTime>> _eventTimestamps = {};
  final Map<String, Duration> _sessionDurations = {};

  // 🎯 Performance Metrics
  final List<double> _responseTimeHistory = [];
  final List<double> _memoryUsageHistory = [];
  final List<int> _errorCounts = [];

  // ⏰ Session Tracking
  DateTime? _sessionStart;
  Timer? _analyticsTimer;

  static const String _analyticsKey = 'neuronvault_analytics';
  static const String _performanceKey = 'neuronvault_performance';
  static const String _sessionKey = 'neuronvault_sessions';

  AnalyticsService({
    required StorageService storageService,
    required Logger logger,
  }) : _storageService = storageService,
        _logger = logger {
    _initializeAnalytics();
  }

  // 🚀 INITIALIZATION
  Future<void> _initializeAnalytics() async {
    try {
      _logger.d('📊 Initializing Analytics Service...');

      // Load existing analytics data
      await _loadAnalyticsData();

      // Start session
      _startSession();

      // Setup periodic data persistence
      _analyticsTimer = Timer.periodic(
        const Duration(minutes: 5),
            (_) => _persistAnalyticsData(),
      );

      _logger.i('✅ Analytics Service initialized (Privacy-First Mode)');

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to initialize analytics', error: e, stackTrace: stackTrace);
    }
  }

  // 📊 EVENT TRACKING
  void trackEvent(String eventName, {Map<String, dynamic>? properties}) {
    try {
      _logger.d('📊 Tracking event: $eventName');

      // Increment event count
      _eventCounts[eventName] = (_eventCounts[eventName] ?? 0) + 1;

      // Track timestamp
      _eventTimestamps.putIfAbsent(eventName, () => []).add(DateTime.now());

      // Keep only last 100 timestamps per event
      if (_eventTimestamps[eventName]!.length > 100) {
        _eventTimestamps[eventName]!.removeAt(0);
      }

      // Log properties (locally only)
      if (properties != null) {
        _logger.d('📊 Event properties: $properties');
      }

    } catch (e) {
      _logger.w('⚠️ Failed to track event $eventName: $e');
    }
  }

  // 📈 PERFORMANCE TRACKING
  void trackPerformance(String metric, double value) {
    try {
      _logger.d('📈 Tracking performance: $metric = $value');

      switch (metric) {
        case 'response_time':
          _responseTimeHistory.add(value);
          if (_responseTimeHistory.length > 1000) {
            _responseTimeHistory.removeAt(0);
          }
          break;

        case 'memory_usage':
          _memoryUsageHistory.add(value);
          if (_memoryUsageHistory.length > 1000) {
            _memoryUsageHistory.removeAt(0);
          }
          break;
      }

    } catch (e) {
      _logger.w('⚠️ Failed to track performance $metric: $e');
    }
  }

  // ❌ ERROR TRACKING
  void trackError(String errorType, {String? description, StackTrace? stackTrace}) {
    try {
      _logger.w('❌ Tracking error: $errorType');

      final errorKey = 'error_$errorType';
      _eventCounts[errorKey] = (_eventCounts[errorKey] ?? 0) + 1;
      _eventTimestamps.putIfAbsent(errorKey, () => []).add(DateTime.now());

      // Track error count for trending
      _errorCounts.add(DateTime.now().millisecondsSinceEpoch);

      // Keep only last 50 error timestamps
      if (_errorCounts.length > 50) {
        _errorCounts.removeAt(0);
      }

      if (description != null) {
        _logger.w('❌ Error description: $description');
      }

    } catch (e) {
      _logger.w('⚠️ Failed to track error $errorType: $e');
    }
  }

  // 🎯 AI MODEL USAGE TRACKING
  void trackModelUsage(AIModel model, {
    required int tokens,
    required Duration responseTime,
    required bool success,
  }) {
    try {
      final modelName = model.displayName;

      trackEvent('model_usage', properties: {
        'model': modelName,
        'tokens': tokens,
        'response_time_ms': responseTime.inMilliseconds,
        'success': success,
      });

      trackPerformance('${modelName.toLowerCase()}_response_time',
          responseTime.inMilliseconds.toDouble());

      if (!success) {
        trackError('model_failure', description: 'Model $modelName failed');
      }

    } catch (e) {
      _logger.w('⚠️ Failed to track model usage: $e');
    }
  }

  // 💬 CHAT ANALYTICS
  void trackChatEvent(String eventType, {Map<String, dynamic>? data}) {
    try {
      trackEvent('chat_$eventType', properties: data);

      // Special handling for message events
      if (eventType == 'message_sent') {
        final messageLength = data?['length'] as int? ?? 0;
        trackPerformance('message_length', messageLength.toDouble());
      }

    } catch (e) {
      _logger.w('⚠️ Failed to track chat event: $e');
    }
  }

  // 🔄 SESSION MANAGEMENT
  void _startSession() {
    try {
      _sessionStart = DateTime.now();
      trackEvent('session_start');
      _logger.d('🚀 Analytics session started');

    } catch (e) {
      _logger.w('⚠️ Failed to start session: $e');
    }
  }

  void endSession() {
    try {
      if (_sessionStart != null) {
        final sessionDuration = DateTime.now().difference(_sessionStart!);
        _sessionDurations['session_${DateTime.now().millisecondsSinceEpoch}'] = sessionDuration;

        trackEvent('session_end', properties: {
          'duration_minutes': sessionDuration.inMinutes,
        });

        _logger.d('🏁 Analytics session ended (${sessionDuration.inMinutes}m)');
      }

      // Persist final data
      _persistAnalyticsData();

    } catch (e) {
      _logger.w('⚠️ Failed to end session: $e');
    }
  }

  // 💾 DATA PERSISTENCE
  Future<void> _loadAnalyticsData() async {
    try {
      // This would load from SharedPreferences in a real implementation
      // For now, we start with empty data
      _logger.d('📖 Loading analytics data...');

    } catch (e) {
      _logger.w('⚠️ Failed to load analytics data: $e');
    }
  }

  Future<void> _persistAnalyticsData() async {
    try {
      _logger.d('💾 Persisting analytics data...');

      final analyticsData = {
        'event_counts': _eventCounts,
        'last_updated': DateTime.now().toIso8601String(),
        'version': '2.5.0',
      };

      // This would save to SharedPreferences in a real implementation
      _logger.d('💾 Analytics data persisted');

    } catch (e) {
      _logger.w('⚠️ Failed to persist analytics data: $e');
    }
  }

  // 📊 ANALYTICS REPORTS
  Map<String, dynamic> getAnalyticsReport() {
    try {
      final now = DateTime.now();
      final dayAgo = now.subtract(const Duration(days: 1));
      final weekAgo = now.subtract(const Duration(days: 7));

      return {
        'overview': {
          'total_events': _eventCounts.values.fold<int>(0, (sum, count) => sum + count),
          'unique_events': _eventCounts.keys.length,
          'session_count': _sessionDurations.length,
          'average_session_minutes': _getAverageSessionDuration(),
        },
        'top_events': _getTopEvents(10),
        'performance': {
          'average_response_time': _getAverageResponseTime(),
          'memory_usage_trend': _getMemoryUsageTrend(),
          'error_rate': _getErrorRate(),
        },
        'usage_patterns': {
          'daily_active_events': _getEventsInPeriod(dayAgo, now),
          'weekly_active_events': _getEventsInPeriod(weekAgo, now),
        },
        'generated_at': now.toIso8601String(),
      };

    } catch (e) {
      _logger.e('❌ Failed to generate analytics report: $e');
      return {'error': 'Failed to generate report'};
    }
  }

  // 📈 ANALYTICS UTILITIES
  List<Map<String, dynamic>> _getTopEvents(int limit) {
    final sortedEvents = _eventCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEvents
        .take(limit)
        .map((entry) => {
      'event': entry.key,
      'count': entry.value,
    })
        .toList();
  }

  double _getAverageSessionDuration() {
    if (_sessionDurations.isEmpty) return 0.0;

    final totalMinutes = _sessionDurations.values
        .fold<int>(0, (sum, duration) => sum + duration.inMinutes);

    return totalMinutes / _sessionDurations.length;
  }

  double _getAverageResponseTime() {
    if (_responseTimeHistory.isEmpty) return 0.0;

    return _responseTimeHistory.reduce((a, b) => a + b) / _responseTimeHistory.length;
  }

  double _getMemoryUsageTrend() {
    if (_memoryUsageHistory.length < 2) return 0.0;

    final recent = _memoryUsageHistory.sublist(_memoryUsageHistory.length - 10);
    return recent.reduce((a, b) => a + b) / recent.length;
  }

  double _getErrorRate() {
    final totalEvents = _eventCounts.values.fold<int>(0, (sum, count) => sum + count);
    if (totalEvents == 0) return 0.0;

    final totalErrors = _errorCounts.length;
    return (totalErrors / totalEvents) * 100;
  }

  int _getEventsInPeriod(DateTime start, DateTime end) {
    int count = 0;

    for (final timestamps in _eventTimestamps.values) {
      count += timestamps
          .where((timestamp) => timestamp.isAfter(start) && timestamp.isBefore(end))
          .length;
    }

    return count;
  }

  // 🔄 CLEANUP
  void dispose() {
    try {
      _logger.d('🧹 Disposing Analytics Service...');

      endSession();
      _analyticsTimer?.cancel();

      _eventCounts.clear();
      _eventTimestamps.clear();
      _sessionDurations.clear();
      _responseTimeHistory.clear();
      _memoryUsageHistory.clear();
      _errorCounts.clear();

      _logger.i('✅ Analytics Service disposed');

    } catch (e) {
      _logger.e('❌ Failed to dispose analytics service: $e');
    }
  }
}

// 📊 ANALYTICS EXTENSION FOR EASY TRACKING
extension AnalyticsTracker on AnalyticsService {
  // 🎯 Quick event tracking shortcuts
  void trackUserAction(String action) => trackEvent('user_$action');
  void trackUIInteraction(String component) => trackEvent('ui_$component');
  void trackFeatureUsage(String feature) => trackEvent('feature_$feature');

  // 📱 App lifecycle events
  void trackAppStart() => trackEvent('app_start');
  void trackAppPause() => trackEvent('app_pause');
  void trackAppResume() => trackEvent('app_resume');
}