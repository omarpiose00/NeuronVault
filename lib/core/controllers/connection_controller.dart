// 🌐 NEURONVAULT - CONNECTION CONTROLLER
// Enterprise-grade connection management with auto-reconnect
// Part of PHASE 2.5 - QUANTUM STATE MANAGEMENT

import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

import '../state/state_models.dart';
import '../services/config_service.dart';
import '../services/analytics_service.dart';
import '../providers/providers_main.dart';

// 🌐 CONNECTION CONTROLLER
class ConnectionController extends Notifier<ConnectionState> {
  late final ConfigService _configService;
  late final AnalyticsService _analyticsService;
  late final Logger _logger;

  WebSocketChannel? _webSocketChannel;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  Timer? _latencyTimer;
  StreamSubscription? _connectionSubscription;

  DateTime? _lastPingTime;

  @override
  ConnectionState build() {
    // Initialize services
    _configService = ref.read(configServiceProvider);
    _analyticsService = ref.read(analyticsServiceProvider);
    _logger = ref.read(loggerProvider);

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
      _logger.i('🔗 Connecting to ${state.serverUrl}:${state.port}...');

      state = state.copyWith(
        status: ConnectionStatus.connecting,
        lastError: null,
      );

      final uri = Uri.parse('ws://${state.serverUrl}:${state.port}/ws');
      _webSocketChannel = IOWebSocketChannel.connect(uri);

      await _webSocketChannel!.ready;

      state = state.copyWith(
        status: ConnectionStatus.connected,
        lastConnectionTime: DateTime.now(),
        reconnectAttempts: 0,
        latencyMs: 0,
      );

      // Setup connection monitoring
      _setupConnectionMonitoring();

      // Save successful connection config
      await _configService.saveConnectionConfig(state);

      _analyticsService.trackEvent('connection_established', properties: {
        'server_url': state.serverUrl,
        'port': state.port,
      });

      _logger.i('✅ Connected successfully');

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
      _pingTimer?.cancel();
      _latencyTimer?.cancel();

      // Close connection
      await _connectionSubscription?.cancel();
      await _webSocketChannel?.sink.close();

      _webSocketChannel = null;
      _connectionSubscription = null;

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
    if (_webSocketChannel == null) return;

    // Listen to connection events
    _connectionSubscription = _webSocketChannel!.stream.listen(
      _handleMessage,
      onError: _handleConnectionError,
      onDone: _handleConnectionClosed,
    );

    // Start ping monitoring
    _startPingMonitoring();
  }

  // 📨 HANDLE MESSAGE
  void _handleMessage(dynamic message) {
    try {
      _logger.d('📨 Received message: $message');

      // Handle ping/pong for latency calculation
      if (message == 'pong' && _lastPingTime != null) {
        final latency = DateTime.now().difference(_lastPingTime!).inMilliseconds;
        state = state.copyWith(latencyMs: latency);
        _lastPingTime = null;
      }

    } catch (e) {
      _logger.w('⚠️ Failed to handle message: $e');
    }
  }

  // ❌ HANDLE CONNECTION ERROR
  void _handleConnectionError(dynamic error) {
    _logger.e('❌ Connection error: $error');

    state = state.copyWith(
      status: ConnectionStatus.error,
      lastError: error.toString(),
    );

    _analyticsService.trackError('connection_error', description: error.toString());

    if (state.canReconnect) {
      _scheduleReconnect();
    }
  }

  // 🔒 HANDLE CONNECTION CLOSED
  void _handleConnectionClosed() {
    _logger.w('🔒 Connection closed');

    if (state.status == ConnectionStatus.connected) {
      // Unexpected disconnection
      state = state.copyWith(status: ConnectionStatus.disconnected);

      if (state.canReconnect) {
        _scheduleReconnect();
      }
    }
  }

  // 🏓 START PING MONITORING
  void _startPingMonitoring() {
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (state.status == ConnectionStatus.connected && _webSocketChannel != null) {
        _sendPing();
      }
    });
  }

  // 📡 SEND PING
  void _sendPing() {
    try {
      _lastPingTime = DateTime.now();
      _webSocketChannel?.sink.add('ping');

      // Timeout for pong response
      _latencyTimer = Timer(const Duration(seconds: 5), () {
        if (_lastPingTime != null) {
          // No pong received, connection might be dead
          _handleConnectionError('Ping timeout');
        }
      });

    } catch (e) {
      _logger.w('⚠️ Failed to send ping: $e');
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

      final socket = await Socket.connect(serverUrl, port, timeout: const Duration(seconds: 5));
      await socket.close();

      _logger.i('✅ Connection test successful');
      return true;

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
      'is_connected': state.isConnected,
      'is_connecting': state.isConnecting,
      'has_error': state.hasError,
      'can_reconnect': state.canReconnect,
      'reconnect_attempts': state.reconnectAttempts,
      'max_reconnects': state.maxReconnects,
      'latency_ms': state.latencyMs,
      'last_connection_time': state.lastConnectionTime?.toIso8601String(),
      'last_error': state.lastError,
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
    _pingTimer?.cancel();
    _latencyTimer?.cancel();
    _connectionSubscription?.cancel();
    _webSocketChannel?.sink.close();
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

// 📡 CONNECTION MESSAGE STREAM
final connectionMessageStreamProvider = StreamProvider<String>((ref) {
  // This would be implemented to stream connection messages
  // For now, return an empty stream
  return const Stream<String>.empty();
});