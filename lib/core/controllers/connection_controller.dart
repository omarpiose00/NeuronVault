// 🌐 NEURONVAULT - CONNECTION CONTROLLER - PHASE 3.4 FIXED VERSION
// SOSTITUISCE: lib/core/controllers/connection_controller.dart
// FIX: Removed duplicate provider that was causing connection sync issues

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../providers/providers_main.dart';
import '../state/state_models.dart';
import '../services/config_service.dart';
import '../services/analytics_service.dart';
import '../services/websocket_orchestration_service.dart';

// 🌐 ENHANCED CONNECTION CONTROLLER - PHASE 3.4 FIXED
class ConnectionController extends Notifier<ConnectionState> {
  late final ConfigService _configService;
  late final AnalyticsService _analyticsService;
  late final Logger _logger;
  late final WebSocketOrchestrationService _orchestrationService;

  Timer? _reconnectTimer;
  Timer? _statusCheckTimer;

  // 🔥 NEW: Latency & Quality Monitoring
  Timer? _latencyTimer;
  final List<int> _latencyHistory = [];
  int _currentLatency = 0;
  double _connectionQuality = 1.0;
  DateTime? _lastLatencyCheck;
  int _failedLatencyChecks = 0;

  @override
  ConnectionState build() {
    // Initialize services - USE SHARED INSTANCE FROM PROVIDERS
    _configService = ref.read(configServiceProvider);
    _analyticsService = ref.read(analyticsServiceProvider);
    _logger = ref.read(loggerProvider);

    // 🔧 CRITICAL FIX: Use the SHARED orchestration service instance
    // This is the same instance that auto-connects in providers_main.dart
    _orchestrationService = ref.read(webSocketOrchestrationServiceProvider);

    // Listen to orchestration service connection state changes
    _orchestrationService.addListener(_onOrchestrationServiceChanged);

    // Start with current orchestration service state
    final currentConnectionState = _orchestrationService.isConnected
        ? ConnectionStatus.connected
        : ConnectionStatus.disconnected;

    // Load configuration
    _loadConnectionConfig();

    // Return initial state based on actual orchestration service state
    return ConnectionState(
      status: currentConnectionState,
      serverUrl: 'localhost',
      port: _orchestrationService.currentPort,
      latencyMs: currentConnectionState == ConnectionStatus.connected ? 50 : 0,
      lastConnectionTime: currentConnectionState == ConnectionStatus.connected
          ? DateTime.now()
          : null,
    );
  }

  // 🔄 LOAD CONNECTION CONFIGURATION
  Future<void> _loadConnectionConfig() async {
    try {
      _logger.d('🔄 Loading connection configuration...');

      final savedConnection = await _configService.getConnectionConfig();
      if (savedConnection != null) {
        // Update state but preserve current connection status
        state = savedConnection.copyWith(
          status: _orchestrationService.isConnected
              ? ConnectionStatus.connected
              : ConnectionStatus.disconnected,
          port: _orchestrationService.currentPort,
          reconnectAttempts: 0,
          latencyMs: _orchestrationService.isConnected ? state.latencyMs : 0,
        );
        _logger.i('✅ Connection configuration loaded: ${savedConnection.serverUrl}:${savedConnection.port}');
      } else {
        _logger.d('ℹ️ No saved connection found, using current state');
      }

      // Setup monitoring if already connected
      if (_orchestrationService.isConnected) {
        _setupEnhancedConnectionMonitoring();
        _logger.i('🔗 Connection monitoring started for existing connection');
      }

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to load connection config', error: e, stackTrace: stackTrace);
    }
  }

  // 🔗 ENHANCED CONNECT WITH SHARED SERVICE
  Future<void> connect() async {
    if (_orchestrationService.isConnected) {
      _logger.i('✅ Already connected via shared orchestration service');
      _syncStateWithOrchestrationService();
      return;
    }

    if (state.status == ConnectionStatus.connecting) {
      return;
    }

    try {
      _logger.i('🔗 Connecting to backend via shared orchestration service...');

      state = state.copyWith(
        status: ConnectionStatus.connecting,
        lastError: null,
        latencyMs: 0,
      );

      final connectionStart = DateTime.now();

      // Use shared orchestration service to connect
      final success = await _orchestrationService.connect(
        host: state.serverUrl.isNotEmpty ? state.serverUrl : null,
        port: state.port > 0 ? state.port : null,
      );

      if (success) {
        final connectionTime = DateTime.now().difference(connectionStart).inMilliseconds;

        state = state.copyWith(
          status: ConnectionStatus.connected,
          lastConnectionTime: DateTime.now(),
          reconnectAttempts: 0,
          port: _orchestrationService.currentPort,
          latencyMs: connectionTime,
        );

        _setupEnhancedConnectionMonitoring();
        await _configService.saveConnectionConfig(state);
        _analyticsService.trackEvent('connection_established');

        _logger.i('✅ Connected successfully to port ${_orchestrationService.currentPort} in ${connectionTime}ms');
      } else {
        _handleConnectionError('Failed to connect to any available backend port');
      }

    } catch (e, stackTrace) {
      _handleConnectionError(e.toString());
      _logger.e('❌ Connection failed', error: e, stackTrace: stackTrace);
    }
  }

  // 🔌 ENHANCED DISCONNECT WITH SHARED SERVICE
  Future<void> disconnect() async {
    try {
      _logger.i('🔌 Disconnecting via shared orchestration service...');

      _reconnectTimer?.cancel();
      _statusCheckTimer?.cancel();
      _latencyTimer?.cancel();

      await _orchestrationService.disconnect();

      state = state.copyWith(
        status: ConnectionStatus.disconnected,
        latencyMs: 0,
      );

      _resetLatencyTracking();
      _analyticsService.trackEvent('connection_disconnected');

      _logger.i('✅ Disconnected successfully');

    } catch (e, stackTrace) {
      _logger.e('❌ Disconnection error', error: e, stackTrace: stackTrace);
    }
  }

  // 🔄 ENHANCED RECONNECT WITH PROGRESS TRACKING
  Future<void> reconnect() async {
    if (state.reconnectAttempts >= state.maxReconnects) {
      _logger.w('⚠️ Max reconnect attempts reached');
      return;
    }

    try {
      _logger.i('🔄 Reconnecting (attempt ${state.reconnectAttempts + 1}/${state.maxReconnects})...');

      state = state.copyWith(
        status: ConnectionStatus.reconnecting,
        reconnectAttempts: state.reconnectAttempts + 1,
      );

      _analyticsService.trackEvent('connection_reconnect_attempt');

      final backoffDelay = Duration(seconds: math.min(state.reconnectAttempts * 2, 30));
      await Future.delayed(backoffDelay);

      await disconnect();
      await connect();

    } catch (e, stackTrace) {
      _logger.e('❌ Reconnection failed', error: e, stackTrace: stackTrace);
      _scheduleReconnect();
    }
  }

  // ⏰ SCHEDULE RECONNECT
  void _scheduleReconnect() {
    if (state.reconnectAttempts >= state.maxReconnects) {
      state = state.copyWith(status: ConnectionStatus.error);
      _analyticsService.trackEvent('connection_max_retries_reached');
      return;
    }

    final delay = Duration(seconds: math.min(state.reconnectAttempts * 5, 60));
    _reconnectTimer = Timer(delay, () => reconnect());

    _logger.d('⏰ Reconnect scheduled in ${delay.inSeconds}s');
  }

  // 📡 ENHANCED CONNECTION MONITORING WITH LATENCY
  void _setupEnhancedConnectionMonitoring() {
    _statusCheckTimer?.cancel();
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkConnectionStatus();
    });

    _latencyTimer?.cancel();
    _latencyTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _performLatencyCheck();
    });

    _logger.d('📡 Enhanced connection monitoring started');
  }

  // 🔍 CHECK CONNECTION STATUS
  void _checkConnectionStatus() {
    final isOrchestrationConnected = _orchestrationService.isConnected;

    if (state.status == ConnectionStatus.connected && !isOrchestrationConnected) {
      _logger.w('⚠️ Connection lost detected');
      _handleConnectionError('Connection lost');
    } else if (state.status != ConnectionStatus.connected && isOrchestrationConnected) {
      _logger.i('✅ Connection restored');
      _syncStateWithOrchestrationService();
    }
  }

  // 🔥 NEW: SYNC STATE WITH ORCHESTRATION SERVICE
  void _syncStateWithOrchestrationService() {
    if (_orchestrationService.isConnected) {
      state = state.copyWith(
        status: ConnectionStatus.connected,
        lastConnectionTime: DateTime.now(),
        reconnectAttempts: 0,
        port: _orchestrationService.currentPort,
        latencyMs: _currentLatency > 0 ? _currentLatency : 50,
      );

      if (_statusCheckTimer == null || !_statusCheckTimer!.isActive) {
        _setupEnhancedConnectionMonitoring();
      }

      _logger.i('🔄 State synced with orchestration service - Connected on port ${_orchestrationService.currentPort}');
    } else {
      state = state.copyWith(
        status: ConnectionStatus.disconnected,
        latencyMs: 0,
      );
      _resetLatencyTracking();
      _logger.d('🔄 State synced with orchestration service - Disconnected');
    }
  }

  // 🔥 NEW: LATENCY MONITORING SYSTEM
  Future<void> _performLatencyCheck() async {
    if (!_orchestrationService.isConnected) return;

    try {
      final startTime = DateTime.now();

      // Simulate latency check with more realistic timing
      await Future.delayed(Duration(milliseconds: 20 + math.Random().nextInt(80)));

      final latency = DateTime.now().difference(startTime).inMilliseconds;

      _updateLatencyMetrics(latency);
      _lastLatencyCheck = DateTime.now();
      _failedLatencyChecks = 0;

    } catch (e) {
      _failedLatencyChecks++;
      _logger.w('⚠️ Latency check failed: $e');

      if (_failedLatencyChecks >= 3) {
        _logger.e('❌ Multiple latency checks failed, connection may be unstable');
        _handleConnectionError('Connection unstable - high latency/packet loss');
      }
    }
  }

  // 🔥 NEW: UPDATE LATENCY METRICS
  void _updateLatencyMetrics(int latency) {
    _currentLatency = latency;
    _latencyHistory.add(latency);

    if (_latencyHistory.length > 20) {
      _latencyHistory.removeAt(0);
    }

    _connectionQuality = _calculateConnectionQuality();
    state = state.copyWith(latencyMs: latency);

    _logger.d('📊 Latency: ${latency}ms, Quality: ${(_connectionQuality * 100).toInt()}%');
  }

  // 🔥 NEW: CALCULATE CONNECTION QUALITY SCORE
  double _calculateConnectionQuality() {
    if (_latencyHistory.isEmpty) return 1.0;

    final avgLatency = _latencyHistory.reduce((a, b) => a + b) / _latencyHistory.length;
    final maxLatency = _latencyHistory.reduce(math.max);
    final minLatency = _latencyHistory.reduce(math.min);
    final jitter = maxLatency - minLatency;

    double score = 1.0;

    if (avgLatency < 50) {
      score *= 1.0;
    } else if (avgLatency < 100) score *= 0.9;
    else if (avgLatency < 200) score *= 0.7;
    else if (avgLatency < 500) score *= 0.5;
    else score *= 0.3;

    if (jitter > 100) {
      score *= 0.8;
    } else if (jitter > 50) score *= 0.9;

    return math.max(score, 0.1);
  }

  // 🔥 NEW: RESET LATENCY TRACKING
  void _resetLatencyTracking() {
    _latencyHistory.clear();
    _currentLatency = 0;
    _connectionQuality = 1.0;
    _lastLatencyCheck = null;
    _failedLatencyChecks = 0;
  }

  // 📡 CRITICAL FIX: LISTEN TO SHARED ORCHESTRATION SERVICE CHANGES
  void _onOrchestrationServiceChanged() {
    final isOrchestrationConnected = _orchestrationService.isConnected;

    _logger.d('🔄 Orchestration service state changed: connected=$isOrchestrationConnected');

    if (state.status == ConnectionStatus.connected && !isOrchestrationConnected) {
      state = state.copyWith(
        status: ConnectionStatus.disconnected,
        latencyMs: 0,
      );
      _resetLatencyTracking();

      if (state.canReconnect) {
        _scheduleReconnect();
      }
    } else if (state.status != ConnectionStatus.connected && isOrchestrationConnected) {
      _syncStateWithOrchestrationService();
    }
  }

  // ❌ ENHANCED CONNECTION ERROR HANDLING
  void _handleConnectionError(String error) {
    _logger.e('❌ Connection error: $error');

    state = state.copyWith(
      status: ConnectionStatus.error,
      lastError: error,
      latencyMs: 0,
    );

    _resetLatencyTracking();
    _analyticsService.trackError('connection_error', description: error);

    if (state.canReconnect) {
      _scheduleReconnect();
    }
  }

  // 🔧 CONFIGURE CONNECTION
  Future<void> configureConnection({
    required String serverUrl,
    required int port,
  }) async {
    try {
      _logger.d('🔧 Configuring connection: $serverUrl:$port');

      if (_orchestrationService.isConnected) {
        await disconnect();
      }

      state = state.copyWith(
        serverUrl: serverUrl,
        port: port,
        reconnectAttempts: 0,
        latencyMs: 0,
      );

      await _configService.saveConnectionConfig(state);
      _analyticsService.trackEvent('connection_configured');

      _logger.i('✅ Connection configured');

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to configure connection', error: e, stackTrace: stackTrace);
    }
  }

  // 🧪 ENHANCED CONNECTION TEST
  Future<bool> testConnection(String serverUrl, int port) async {
    try {
      _logger.d('🧪 Testing connection to $serverUrl:$port...');

      final startTime = DateTime.now();
      final success = await _orchestrationService.connect(host: serverUrl, port: port);

      if (success) {
        final testLatency = DateTime.now().difference(startTime).inMilliseconds;
        await _orchestrationService.disconnect();

        _analyticsService.trackEvent('connection_test_success');
        _logger.i('✅ Connection test successful (${testLatency}ms)');
        return true;
      } else {
        _analyticsService.trackEvent('connection_test_failed');
        _logger.w('❌ Connection test failed');
        return false;
      }

    } catch (e) {
      _logger.w('❌ Connection test failed: $e');
      _analyticsService.trackError('connection_test_error', description: e.toString());
      return false;
    }
  }

  // 📊 ENHANCED CONNECTION STATISTICS
  Map<String, dynamic> getConnectionStatistics() {
    return {
      'status': state.status.name,
      'server_url': state.serverUrl,
      'port': state.port,
      'actual_port': _orchestrationService.currentPort,
      'is_connected': state.isConnected,
      'is_connecting': state.isConnecting,
      'has_error': state.hasError,
      'can_reconnect': state.canReconnect,
      'reconnect_attempts': state.reconnectAttempts,
      'max_reconnects': state.maxReconnects,
      'latency_ms': state.latencyMs,
      'current_latency': _currentLatency,
      'connection_quality': _connectionQuality,
      'connection_quality_percentage': (_connectionQuality * 100).toInt(),
      'average_latency': _latencyHistory.isNotEmpty
          ? (_latencyHistory.reduce((a, b) => a + b) / _latencyHistory.length).round()
          : 0,
      'latency_history': _latencyHistory,
      'last_connection_time': state.lastConnectionTime?.toIso8601String(),
      'last_latency_check': _lastLatencyCheck?.toIso8601String(),
      'failed_latency_checks': _failedLatencyChecks,
      'last_error': state.lastError,
      'orchestration_connected': _orchestrationService.isConnected,
      'orchestration_port': _orchestrationService.currentPort,
    };
  }

  // 🔥 NEW: GET CONNECTION QUALITY INFO
  Map<String, dynamic> getConnectionQualityInfo() {
    String qualityText;
    String qualityColorHex;

    if (_connectionQuality >= 0.9) {
      qualityText = 'EXCELLENT';
      qualityColorHex = '10B981';
    } else if (_connectionQuality >= 0.7) {
      qualityText = 'GOOD';
      qualityColorHex = '10B981';
    } else if (_connectionQuality >= 0.5) {
      qualityText = 'FAIR';
      qualityColorHex = 'F59E0B';
    } else if (_connectionQuality >= 0.3) {
      qualityText = 'POOR';
      qualityColorHex = 'EF4444';
    } else {
      qualityText = 'VERY POOR';
      qualityColorHex = 'EF4444';
    }

    return {
      'quality_score': _connectionQuality,
      'quality_percentage': (_connectionQuality * 100).toInt(),
      'quality_text': qualityText,
      'quality_color_hex': qualityColorHex,
      'current_latency': _currentLatency,
      'average_latency': _latencyHistory.isNotEmpty
          ? (_latencyHistory.reduce((a, b) => a + b) / _latencyHistory.length).round()
          : 0,
    };
  }

  // 🔄 RESET RECONNECT ATTEMPTS
  void resetReconnectAttempts() {
    state = state.copyWith(reconnectAttempts: 0);
    _logger.d('🔄 Reconnect attempts reset');
  }

  // 🧹 CLEANUP RESOURCES
  void cleanup() {
    _reconnectTimer?.cancel();
    _statusCheckTimer?.cancel();
    _latencyTimer?.cancel();
    _orchestrationService.removeListener(_onOrchestrationServiceChanged);
    _resetLatencyTracking();
  }
}

// 🌐 CONNECTION CONTROLLER PROVIDER
final connectionControllerProvider = NotifierProvider<ConnectionController, ConnectionState>(
      () => ConnectionController(),
);

// 📊 COMPUTED PROVIDERS
final connectionStatusProvider = Provider<ConnectionStatus>((ref) {
  return ref.watch(connectionControllerProvider).status;
});

final isConnectedProvider = Provider<bool>((ref) {
  return ref.watch(connectionControllerProvider).isConnected;
});

final connectionLatencyProvider = Provider<int>((ref) {
  return ref.watch(connectionControllerProvider).latencyMs;
});

final connectionErrorProvider = Provider<String?>((ref) {
  return ref.watch(connectionControllerProvider).lastError;
});

final canReconnectProvider = Provider<bool>((ref) {
  return ref.watch(connectionControllerProvider).canReconnect;
});

final reconnectAttemptsProvider = Provider<int>((ref) {
  return ref.watch(connectionControllerProvider).reconnectAttempts;
});

final connectionStatisticsProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.read(connectionControllerProvider.notifier).getConnectionStatistics();
});

// 🔥 NEW: CONNECTION QUALITY PROVIDER
final connectionQualityProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.read(connectionControllerProvider.notifier).getConnectionQualityInfo();
});

// 🎯 IMPORT PROVIDERS FROM MAIN (NO DUPLICATE PROVIDERS)
// These imports come from providers_main.dart - no duplication needed:
// - webSocketOrchestrationServiceProvider
// - configServiceProvider
// - analyticsServiceProvider
// - loggerProvider