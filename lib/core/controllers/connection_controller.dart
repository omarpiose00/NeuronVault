// 🌐 NEURONVAULT - CONNECTION CONTROLLER - SIMPLIFIED VERSION
// Simplified enterprise-grade connection management that WORKS
// Compatible with WebSocketOrchestrationService

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../state/state_models.dart';
import '../services/config_service.dart';
import '../services/analytics_service.dart';
import '../services/websocket_orchestration_service.dart';
import '../providers/providers_main.dart' hide ConnectionStatus;

// 🌐 SIMPLIFIED CONNECTION CONTROLLER
class ConnectionController extends Notifier<ConnectionState> {
  late final ConfigService _configService;
  late final AnalyticsService _analyticsService;
  late final Logger _logger;
  late final WebSocketOrchestrationService _orchestrationService;

  Timer? _reconnectTimer;
  Timer? _statusCheckTimer;

  @override
  ConnectionState build() {
    // Initialize services
    _configService = ref.read(configServiceProvider);
    _analyticsService = ref.read(analyticsServiceProvider);
    _logger = ref.read(loggerProvider);
    _orchestrationService = ref.read(webSocketOrchestrationServiceProvider);

    // Listen to orchestration service connection state
    _orchestrationService.addListener(_onOrchestrationServiceChanged);

    // Load configuration and auto-connect
    _loadConnectionConfig();

    return const ConnectionState();
  }

  // 🔄 LOAD CONNECTION CONFIGURATION
  Future<void> _loadConnectionConfig() async {
    try {
      _logger.d('🔄 Loading connection configuration...');

      final savedConnection = await _configService.getConnectionConfig();
      if (savedConnection != null) {
        state = savedConnection.copyWith(
          status: ConnectionStatus.disconnected,
          reconnectAttempts: 0,
        );
        _logger.i('✅ Connection configuration loaded: ${savedConnection.serverUrl}:${savedConnection.port}');
      } else {
        _logger.d('ℹ️ No saved connection found, using defaults');
      }

      // Auto-connect if we have configuration
      if (state.serverUrl.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 500));
        await connect();
      }

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to load connection config', error: e, stackTrace: stackTrace);
    }
  }

  // 🔗 CONNECT
  Future<void> connect() async {
    if (state.status == ConnectionStatus.connecting ||
        state.status == ConnectionStatus.connected) {
      return;
    }

    try {
      _logger.i('🔗 Connecting to backend...');

      state = state.copyWith(
        status: ConnectionStatus.connecting,
        lastError: null,
      );

      // Use orchestration service to connect
      final success = await _orchestrationService.connect(
        host: state.serverUrl.isNotEmpty ? state.serverUrl : null,
        port: state.port > 0 ? state.port : null,
      );

      if (success) {
        state = state.copyWith(
          status: ConnectionStatus.connected,
          lastConnectionTime: DateTime.now(),
          reconnectAttempts: 0,
          port: _orchestrationService.currentPort, // Update with actual port used
        );

        // Setup connection monitoring
        _setupConnectionMonitoring();

        // Save successful connection config
        await _configService.saveConnectionConfig(state);

        _analyticsService.trackEvent('connection_established', properties: {
          'server_url': state.serverUrl,
          'port': state.port,
        });

        _logger.i('✅ Connected successfully to port ${_orchestrationService.currentPort}');
      } else {
        _handleConnectionError('Failed to connect to any available backend port');
      }

    } catch (e, stackTrace) {
      _handleConnectionError(e.toString());
      _logger.e('❌ Connection failed', error: e, stackTrace: stackTrace);
    }
  }

  // 🔌 DISCONNECT
  Future<void> disconnect() async {
    try {
      _logger.i('🔌 Disconnecting...');

      // Cancel timers
      _reconnectTimer?.cancel();
      _statusCheckTimer?.cancel();

      // Disconnect orchestration service
      await _orchestrationService.disconnect();

      state = state.copyWith(
        status: ConnectionStatus.disconnected,
        latencyMs: 0,
      );

      _analyticsService.trackEvent('connection_disconnected');

      _logger.i('✅ Disconnected successfully');

    } catch (e, stackTrace) {
      _logger.e('❌ Disconnection error', error: e, stackTrace: stackTrace);
    }
  }

  // 🔄 RECONNECT
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

      // Wait before reconnecting
      await Future.delayed(Duration(seconds: state.reconnectAttempts * 2));

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
      return;
    }

    final delay = Duration(seconds: state.reconnectAttempts * 5);
    _reconnectTimer = Timer(delay, () => reconnect());

    _logger.d('⏰ Reconnect scheduled in ${delay.inSeconds}s');
  }

  // 📡 SETUP CONNECTION MONITORING
  void _setupConnectionMonitoring() {
    // Start status check timer
    _statusCheckTimer?.cancel();
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkConnectionStatus();
    });
  }

  // 🔍 CHECK CONNECTION STATUS
  void _checkConnectionStatus() {
    final isOrchestrationConnected = _orchestrationService.isConnected;

    if (state.status == ConnectionStatus.connected && !isOrchestrationConnected) {
      _logger.w('⚠️ Connection lost detected');
      _handleConnectionError('Connection lost');
    } else if (state.status != ConnectionStatus.connected && isOrchestrationConnected) {
      _logger.i('✅ Connection restored');
      state = state.copyWith(
        status: ConnectionStatus.connected,
        lastConnectionTime: DateTime.now(),
        reconnectAttempts: 0,
      );
    }
  }

  // 📡 LISTEN TO ORCHESTRATION SERVICE CHANGES
  void _onOrchestrationServiceChanged() {
    final isOrchestrationConnected = _orchestrationService.isConnected;

    if (state.status == ConnectionStatus.connected && !isOrchestrationConnected) {
      // Connection was lost
      state = state.copyWith(status: ConnectionStatus.disconnected);
      if (state.canReconnect) {
        _scheduleReconnect();
      }
    } else if (state.status != ConnectionStatus.connected && isOrchestrationConnected) {
      // Connection was established
      state = state.copyWith(
        status: ConnectionStatus.connected,
        lastConnectionTime: DateTime.now(),
        reconnectAttempts: 0,
        port: _orchestrationService.currentPort,
      );
    }
  }

  // ❌ HANDLE CONNECTION ERROR
  void _handleConnectionError(String error) {
    _logger.e('❌ Connection error: $error');

    state = state.copyWith(
      status: ConnectionStatus.error,
      lastError: error,
    );

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

      // Disconnect if currently connected
      if (state.status == ConnectionStatus.connected) {
        await disconnect();
      }

      state = state.copyWith(
        serverUrl: serverUrl,
        port: port,
        reconnectAttempts: 0,
      );

      await _configService.saveConnectionConfig(state);

      _analyticsService.trackEvent('connection_configured', properties: {
        'server_url': serverUrl,
        'port': port,
      });

      _logger.i('✅ Connection configured');

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to configure connection', error: e, stackTrace: stackTrace);
    }
  }

  // 🧪 TEST CONNECTION
  Future<bool> testConnection(String serverUrl, int port) async {
    try {
      _logger.d('🧪 Testing connection to $serverUrl:$port...');

      // Use orchestration service to test connection
      final success = await _orchestrationService.connect(host: serverUrl, port: port);

      if (success) {
        // Disconnect after test
        await _orchestrationService.disconnect();
        _logger.i('✅ Connection test successful');
        return true;
      } else {
        _logger.w('❌ Connection test failed');
        return false;
      }

    } catch (e) {
      _logger.w('❌ Connection test failed: $e');
      return false;
    }
  }

  // 📊 GET CONNECTION STATISTICS
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
      'last_connection_time': state.lastConnectionTime?.toIso8601String(),
      'last_error': state.lastError,
      'orchestration_connected': _orchestrationService.isConnected,
    };
  }

  // 🔄 RESET RECONNECT ATTEMPTS
  void resetReconnectAttempts() {
    state = state.copyWith(reconnectAttempts: 0);
    _logger.d('🔄 Reconnect attempts reset');
  }

  // 🧹 DISPOSE
  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _statusCheckTimer?.cancel();
    _orchestrationService.removeListener(_onOrchestrationServiceChanged);

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

// 🧠 ORCHESTRATION SERVICE PROVIDER (if not already defined)
final webSocketOrchestrationServiceProvider = Provider<WebSocketOrchestrationService>((ref) {
  return WebSocketOrchestrationService();
});