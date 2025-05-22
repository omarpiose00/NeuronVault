// lib/services/performance_monitor.dart - Monitoraggio performance
import 'package:flutter/material.dart';
import 'dart:async';

class PerformanceMetrics {
  final String operation;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final bool success;
  final Map<String, dynamic> metadata;

  PerformanceMetrics({
    required this.operation,
    required this.startTime,
    required this.endTime,
    required this.success,
    this.metadata = const {},
  }) : duration = endTime.difference(startTime);

  Map<String, dynamic> toJson() => {
    'operation': operation,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'duration': duration.inMilliseconds,
    'success': success,
    'metadata': metadata,
  };
}

class PerformanceMonitor extends ChangeNotifier {
  static PerformanceMonitor? _instance;
  static PerformanceMonitor get instance => _instance ??= PerformanceMonitor._internal();

  PerformanceMonitor._internal();

  final List<PerformanceMetrics> _metrics = [];
  final Map<String, DateTime> _activeOperations = {};
  final int _maxMetrics = 1000; // Mantieni solo le ultime 1000 metriche

  List<PerformanceMetrics> get metrics => List.unmodifiable(_metrics);

  // Inizia il tracciamento di un'operazione
  void startOperation(String operation, {Map<String, dynamic>? metadata}) {
    _activeOperations[operation] = DateTime.now();
    debugPrint('📊 Started tracking: $operation');
  }

  // Termina il tracciamento di un'operazione
  void endOperation(String operation, {
    bool success = true,
    Map<String, dynamic>? metadata,
  }) {
    final startTime = _activeOperations.remove(operation);
    if (startTime == null) {
      debugPrint('⚠️ No start time found for operation: $operation');
      return;
    }

    final endTime = DateTime.now();
    final metric = PerformanceMetrics(
      operation: operation,
      startTime: startTime,
      endTime: endTime,
      success: success,
      metadata: metadata ?? {},
    );

    _addMetric(metric);

    debugPrint('📊 Completed: $operation in ${metric.duration.inMilliseconds}ms '
        '(${success ? "SUCCESS" : "FAILED"})');
  }

  // Esegue e traccia automaticamente un'operazione
  Future<T> trackOperation<T>(
      String operation,
      Future<T> Function() function, {
        Map<String, dynamic>? metadata,
      }) async {
    startOperation(operation, metadata: metadata);

    try {
      final result = await function();
      endOperation(operation, success: true, metadata: metadata);
      return result;
    } catch (error) {
      endOperation(
          operation,
          success: false,
          metadata: {
            ...?metadata,
            'error': error.toString(),
          }
      );
      rethrow;
    }
  }

  void _addMetric(PerformanceMetrics metric) {
    _metrics.add(metric);

    // Mantieni solo le metriche recenti
    if (_metrics.length > _maxMetrics) {
      _metrics.removeAt(0);
    }

    notifyListeners();
  }

  // Statistiche
  Map<String, dynamic> getStats({Duration? period}) {
    final cutoffTime = period != null
        ? DateTime.now().subtract(period)
        : null;

    final relevantMetrics = _metrics.where((m) =>
    cutoffTime == null || m.endTime.isAfter(cutoffTime)
    ).toList();

    if (relevantMetrics.isEmpty) {
      return {
        'totalOperations': 0,
        'successRate': 0.0,
        'averageDuration': 0,
        'operationBreakdown': <String, dynamic>{},
      };
    }

    final totalOperations = relevantMetrics.length;
    final successfulOperations = relevantMetrics.where((m) => m.success).length;
    final successRate = successfulOperations / totalOperations;

    final totalTime = relevantMetrics.fold<int>(
        0, (sum, m) => sum + m.duration.inMilliseconds
    );
    final averageDuration = totalTime / totalOperations;

    // Breakdown per operazione
    final operationBreakdown = <String, Map<String, dynamic>>{};

    for (final metric in relevantMetrics) {
      if (!operationBreakdown.containsKey(metric.operation)) {
        operationBreakdown[metric.operation] = {
          'count': 0,
          'successes': 0,
          'totalTime': 0,
          'averageTime': 0.0,
          'successRate': 0.0,
        };
      }

      final breakdown = operationBreakdown[metric.operation]!;
      breakdown['count'] = breakdown['count'] + 1;
      if (metric.success) breakdown['successes'] = breakdown['successes'] + 1;
      breakdown['totalTime'] = breakdown['totalTime'] + metric.duration.inMilliseconds;
    }

    // Calcola le medie
    operationBreakdown.forEach((operation, data) {
      data['averageTime'] = data['totalTime'] / data['count'];
      data['successRate'] = data['successes'] / data['count'];
    });

    return {
      'totalOperations': totalOperations,
      'successfulOperations': successfulOperations,
      'successRate': successRate,
      'averageDuration': averageDuration,
      'operationBreakdown': operationBreakdown,
      'period': period?.inMinutes ?? 'all-time',
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }

  // Esporta metriche per debugging
  List<Map<String, dynamic>> exportMetrics({Duration? period}) {
    final cutoffTime = period != null
        ? DateTime.now().subtract(period)
        : null;

    return _metrics
        .where((m) => cutoffTime == null || m.endTime.isAfter(cutoffTime))
        .map((m) => m.toJson())
        .toList();
  }

  // Pulisci metriche vecchie
  void clearMetrics() {
    _metrics.clear();
    notifyListeners();
    debugPrint('📊 Performance metrics cleared');
  }

  // Widget per visualizzare le performance
  Widget buildPerformanceWidget(BuildContext context) {
    final stats = getStats(period: const Duration(minutes: 30));

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.speed, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Performance (30min)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text('${stats['totalOperations']} ops'),
              ],
            ),
            const SizedBox(height: 12),

            LinearProgressIndicator(
              value: stats['successRate'].toDouble(),
              backgroundColor: Colors.red.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation(
                stats['successRate'] > 0.9 ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Success Rate: ${(stats['successRate'] * 100).toStringAsFixed(1)}%'),
                Text('Avg: ${stats['averageDuration'].round()}ms'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}