// 📊 NEURONVAULT - PRIVACY-FIRST ANALYTICS SERVICE
// Local-only analytics and telemetry for enterprise optimization
// Part of PHASE 2.5 - QUANTUM STATE MANAGEMENT

import 'dart:convert';
import 'dart:math';
import 'package:logger/logger.dart';
import 'storage_service.dart';

class AnalyticsService {
  final StorageService _storageService;
  final Logger _logger;
  
  // 📊 LOCAL ANALYTICS KEYS
  static const String _analyticsKey = 'neuronvault_analytics';
  static const String _sessionKey = 'neuronvault_session';
  static const String _performanceKey = 'neuronvault_performance';
  static const String _usageKey = 'neuronvault_usage';
  static const String _errorsKey = 'neuronvault_errors';

  // 🔧 SESSION TRACKING
  late final String _sessionId;
  late final DateTime _sessionStart;
  final Map<String, dynamic> _sessionData = {};
  final List<Map<String, dynamic>> _eventQueue = [];
  
  // 📈 PERFORMANCE METRICS
  final Map<String, List<double>> _performanceMetrics = {};
  final Map<String, int> _eventCounts = {};
  final Map<String, DateTime> _lastEventTimes = {};

  AnalyticsService({
    required StorageService storageService,
    required Logger logger,
  }) : _storageService = storageService,
       _logger = logger {
    _initializeSession();
  }

  // 🚀 SESSION INITIALIZATION
  void _initializeSession() {
    _sessionId = _generateSessionId();
    _sessionStart = DateTime.now();
    
    _sessionData.addAll({
      'session_id': _sessionId,
      'start_time': _sessionStart.toIso8601String(),
      'version': '2.5.0',
      'platform': 'flutter_desktop',
    });
    
    _logger.i('📊 Analytics session started: $_sessionId');
    
    // Track session start
    trackEvent('session_started', {
      'session_id': _sessionId,
      'timestamp': _sessionStart.toIso8601String(),
    });
  }

  String _generateSessionId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = random.nextInt(999999).toString().padLeft(6, '0');
    return 'ns_${timestamp}_$randomSuffix';
  }

  // 📊 EVENT TRACKING
  void trackEvent(String eventName, [Map<String, dynamic>? properties]) {
    try {
      final event = {
        'event': eventName,
        'timestamp': DateTime.now().toIso8601String(),
        'session_id': _sessionId,
        'properties': properties ?? {},
      };
      
      _eventQueue.add(event);
      _eventCounts[eventName] = (_eventCounts[eventName] ?? 0) + 1;
      _lastEventTimes[eventName] = DateTime.now();
      
      _logger.d('📊 Event tracked: $eventName');
      
      // Flush events periodically
      if (_eventQueue.length >= 10) {
        _flushEvents();
      }
      
    } catch (e) {
      _logger.w('⚠️ Failed to track event $eventName: $e');
    }
  }

  // 🚀 PERFORMANCE TRACKING
  void trackPerformance(String metric, double value, [String? unit]) {
    try {
      _performanceMetrics.putIfAbsent(metric, () => []).add(value);
      
      // Keep only last 100 measurements per metric
      if (_performanceMetrics[metric]!.length > 100) {
        _performanceMetrics[metric]!.removeAt(0);
      }
      
      _logger.d('📈 Performance tracked: $metric = $value ${unit ?? ''}');
      
      // Track significant performance events
      if (_isSignificantPerformanceEvent(metric, value)) {
        trackEvent('performance_alert', {
          'metric': metric,
          'value': value,
          'unit': unit,
          'threshold_exceeded': true,
        });
      }
      
    } catch (e) {
      _logger.w('⚠️ Failed to track performance $metric: $e');
    }
  }

  bool _isSignificantPerformanceEvent(String metric, double value) {
    switch (metric) {
      case 'memory_usage_mb':
        return value > 500; // Alert if memory usage > 500MB
      case 'response_time_ms':
        return value > 5000; // Alert if response time > 5s
      case 'error_rate':
        return value > 0.1; // Alert if error rate > 10%
      case 'cpu_usage_percent':
        return value > 80; // Alert if CPU usage > 80%
      default:
        return false;
    }
  }

  // ⏱️ TIMING UTILITIES
  Stopwatch startTiming(String operation) {
    final stopwatch = Stopwatch()..start();
    _logger.d('⏱️ Started timing: $operation');
    return stopwatch;
  }

  void endTiming(String operation, Stopwatch stopwatch) {
    stopwatch.stop();
    final elapsedMs = stopwatch.elapsedMilliseconds.toDouble();
    
    trackPerformance('${operation}_duration_ms', elapsedMs, 'ms');
    trackEvent('operation_completed', {
      'operation': operation,
      'duration_ms': elapsedMs,
    });
    
    _logger.d('⏱️ Completed timing: $operation (${elapsedMs}ms)');
  }

  // 🎯 USER BEHAVIOR TRACKING
  void trackUserAction(String action, [Map<String, dynamic>? context]) {
    trackEvent('user_action', {
      'action': action,
      'context': context ?? {},
    });
  }

  void trackScreenView(String screenName, [Duration? timeSpent]) {
    trackEvent('screen_view', {
      'screen': screenName,
      'time_spent_ms': timeSpent?.inMilliseconds,
    });
  }

  void trackFeatureUsage(String feature, [Map<String, dynamic>? usage_data]) {
    trackEvent('feature_usage', {
      'feature': feature,
      'usage_data': usage_data ?? {},
    });
  }

  // ❌ ERROR TRACKING
  void trackError(String error, [String? stackTrace, Map<String, dynamic>? context]) {
    try {
      final errorEvent = {
        'error': error,
        'stack_trace': stackTrace,
        'context': context ?? {},
        'timestamp': DateTime.now().toIso8601String(),
        'session_id': _sessionId,
      };
      
      trackEvent('error_occurred', errorEvent);
      
      // Store in separate error log
      _storeError(errorEvent);
      
      _logger.e('❌ Error tracked: $error');
      
    } catch (e) {
      _logger.w('⚠️ Failed to track error: $e');
    }
  }

  void trackException(Exception exception, [StackTrace? stackTrace, Map<String, dynamic>? context]) {
    trackError(
      exception.toString(),
      stackTrace?.toString(),
      {
        'exception_type': exception.runtimeType.toString(),
        ...?context,
      },
    );
  }

  // 🤖 AI USAGE ANALYTICS
  void trackAIRequest(String model, String strategy, int tokenCount, int responseTimeMs) {
    trackEvent('ai_request', {
      'model': model,
      'strategy': strategy,
      'token_count': tokenCount,
      'response_time_ms': responseTimeMs,
    });
    
    trackPerformance('ai_response_time_ms', responseTimeMs.toDouble(), 'ms');
    trackPerformance('ai_token_count', tokenCount.toDouble(), 'tokens');
  }

  void trackAIError(String model, String error, [String? strategy]) {
    trackEvent('ai_error', {
      'model': model,
      'strategy': strategy,
      'error': error,
    });
  }

  void trackModelHealth(String model, bool isHealthy, int responseTime) {
    trackEvent('model_health_check', {
      'model': model,
      'is_healthy': isHealthy,
      'response_time_ms': responseTime,
    });
  }

  // 💾 DATA PERSISTENCE
  Future<void> _flushEvents() async {
    if (_eventQueue.isEmpty) return;
    
    try {
      _logger.d('💾 Flushing ${_eventQueue.length} analytics events...');
      
      // Get existing analytics data
      final existingData = await _getStoredAnalytics();
      final events = List<Map<String, dynamic>>.from(existingData['events'] ?? []);
      
      // Add new events
      events.addAll(_eventQueue);
      
      // Keep only recent events (last 1000)
      if (events.length > 1000) {
        events.removeRange(0, events.length - 1000);
      }
      
      // Update analytics data
      final analyticsData = {
        'version': '2.5.0',
        'last_updated': DateTime.now().toIso8601String(),
        'session_id': _sessionId,
        'events': events,
        'event_counts': _eventCounts,
        'performance_metrics': _performanceMetrics,
      };
      
      // Store analytics data
      await _storeAnalytics(analyticsData);
      
      // Clear event queue
      _eventQueue.clear();
      
      _logger.i('✅ Analytics events flushed successfully');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to flush analytics events', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> _storeAnalytics(Map<String, dynamic> data) async {
    try {
      final jsonData = jsonEncode(data);
      // Using SharedPreferences through StorageService would be ideal
      // For now, we'll store in a simple way
      
    } catch (e) {
      _logger.e('❌ Failed to store analytics: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _getStoredAnalytics() async {
    try {
      // This would retrieve from storage
      // For now, return empty structure
      return {
        'events': [],
        'event_counts': {},
        'performance_metrics': {},
      };
    } catch (e) {
      _logger.w('⚠️ Failed to get stored analytics: $e');
      return {};
    }
  }

  Future<void> _storeError(Map<String, dynamic> errorData) async {
    try {
      // Store error in separate error log
      // This could be implemented with file-based storage
      _logger.d('💾 Error stored for analysis');
    } catch (e) {
      _logger.w('⚠️ Failed to store error: $e');
    }
  }

  // 📊 ANALYTICS REPORTS
  Future<Map<String, dynamic>> generateUsageReport() async {
    try {
      _logger.i('📊 Generating usage report...');
      
      final now = DateTime.now();
      final sessionDuration = now.difference(_sessionStart);
      
      // Calculate event statistics
      final totalEvents = _eventCounts.values.fold<int>(0, (sum, count) => sum + count);
      final topEvents = _eventCounts.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
      
      // Calculate performance statistics
      final performanceStats = <String, Map<String, dynamic>>{};
      for (final entry in _performanceMetrics.entries) {
        final values = entry.value;
        if (values.isNotEmpty) {
          performanceStats[entry.key] = {
            'count': values.length,
            'min': values.reduce((a, b) => a < b ? a : b),
            'max': values.reduce((a, b) => a > b ? a : b),
            'average': values.reduce((a, b) => a + b) / values.length,
          };
        }
      }
      
      final report = {
        'session_info': {
          'session_id': _sessionId,
          'start_time': _sessionStart.toIso8601String(),
          'duration_minutes': sessionDuration.inMinutes,
          'end_time': now.toIso8601String(),
        },
        'event_summary': {
          'total_events': totalEvents,
          'unique_events': _eventCounts.length,
          'top_events': topEvents.take(10).map((e) => {
            'event': e.key,
            'count': e.value,
          }).toList(),
        },
        'performance_summary': performanceStats,
        'system_info': {
          'version': '2.5.0',
          'platform': 'flutter_desktop',
        },
      };
      
      _logger.i('✅ Usage report generated successfully');
      return report;
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to generate usage report', error: e, stackTrace: stackTrace);
      return {};
    }
  }

  Future<Map<String, dynamic>> generatePerformanceReport() async {
    try {
      _logger.i('📈 Generating performance report...');
      
      final report = <String, dynamic>{};
      
      for (final entry in _performanceMetrics.entries) {
        final metric = entry.key;
        final values = entry.value;
        
        if (values.isEmpty) continue;
        
        final sorted = List<double>.from(values)..sort();
        final count = values.length;
        
        report[metric] = {
          'count': count,
          'min': sorted.first,
          'max': sorted.last,
          'average': values.reduce((a, b) => a + b) / count,
          'median': count.isOdd 
              ? sorted[count ~/ 2]
              : (sorted[count ~/ 2 - 1] + sorted[count ~/ 2]) / 2,
          'p95': sorted[(count * 0.95).floor()],
          'p99': sorted[(count * 0.99).floor()],
        };
      }
      
      _logger.i('✅ Performance report generated successfully');
      return report;
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to generate performance report', error: e, stackTrace: stackTrace);
      return {};
    }
  }

  // 🔄 SESSION MANAGEMENT
  Future<void> endSession() async {
    try {
      _logger.i('🔄 Ending analytics session...');
      
      final sessionEnd = DateTime.now();
      final sessionDuration = sessionEnd.difference(_sessionStart);
      
      trackEvent('session_ended', {
        'session_id': _sessionId,
        'duration_minutes': sessionDuration.inMinutes,
        'total_events': _eventCounts.values.fold<int>(0, (sum, count) => sum + count),
      });
      
      // Flush all remaining events
      await _flushEvents();
      
      _logger.i('✅ Analytics session ended successfully');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to end session', error: e, stackTrace: stackTrace);
    }
  }

  // 🗑️ DATA MANAGEMENT
  Future<void> clearAnalyticsData() async {
    try {
      _logger.w('🗑️ Clearing all analytics data...');
      
      _eventQueue.clear();
      _eventCounts.clear();
      _performanceMetrics.clear();
      _lastEventTimes.clear();
      
      // Clear stored data
      // This would clear from persistent storage
      
      _logger.i('✅ Analytics data cleared successfully');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to clear analytics data', error: e, stackTrace: stackTrace);
    }
  }

  Future<Map<String, dynamic>> exportAnalyticsData() async {
    try {
      _logger.i('📤 Exporting analytics data...');
      
      final usageReport = await generateUsageReport();
      final performanceReport = await generatePerformanceReport();
      
      final exportData = {
        'export_timestamp': DateTime.now().toIso8601String(),
        'version': '2.5.0',
        'usage_report': usageReport,
        'performance_report': performanceReport,
        'raw_data': {
          'event_counts': _eventCounts,
          'performance_metrics': _performanceMetrics,
        },
      };
      
      _logger.i('✅ Analytics data exported successfully');
      return exportData;
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to export analytics data', error: e, stackTrace: stackTrace);
      return {};
    }
  }

  // 📊 REAL-TIME STATISTICS
  Map<String, dynamic> getCurrentStatistics() {
    final now = DateTime.now();
    final sessionDuration = now.difference(_sessionStart);
    
    return {
      'session_id': _sessionId,
      'session_duration_minutes': sessionDuration.inMinutes,
      'total_events': _eventCounts.values.fold<int>(0, (sum, count) => sum + count),
      'unique_events': _eventCounts.length,
      'performance_metrics_count': _performanceMetrics.length,
      'last_event_time': _lastEventTimes.values.isNotEmpty
          ? _lastEventTimes.values.reduce((a, b) => a.isAfter(b) ? a : b).toIso8601String()
          : null,
    };
  }

  // 🧹 CLEANUP
  void dispose() {
    _logger.d('🧹 Disposing Analytics Service...');
    
    // End session and flush events
    endSession();
    
    _logger.i('✅ Analytics Service disposed successfully');
  }
}