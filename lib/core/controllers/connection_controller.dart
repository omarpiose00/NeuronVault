// 🌐 NEURONVAULT - WEBSOCKET CONNECTION CONTROLLER
// Enterprise-grade WebSocket connection management with auto-recovery
// Part of PHASE 2.5 - QUANTUM STATE MANAGEMENT

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import '../state/models.dart';
import '../services/config_service.dart';
import '../services/analytics_service.dart';

// 🌐 CONNECTION CONTROLLER PROVIDER
final connectionControllerProvider = 
    StateNotifierProvider<ConnectionController, ConnectionState>((ref) {
  return ConnectionController(
    configService: ref.watch(configServiceProvider),
    analyticsService: ref.watch(analyticsServiceProvider),
    logger: ref.watch(loggerProvider),
  );
});

// 🧠 WEBSOCKET CONNECTION STATE CONTROLLER
class ConnectionController extends StateNotifier<ConnectionState> {
  final ConfigService _configService;
  final AnalyticsService _analyticsService;
  final Logger _logger;

  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  StreamSubscription? _channelSubscription;
  
  static const Duration _reconnectDelay = Duration(seconds: 5);
  static const Duration _pingInterval = Duration(seconds: 30);
  static const Duration _connectionTimeout = Duration(seconds: 10);

  final StreamController<Map<String, dynamic>> _messageController = 
      StreamController<Map<String, dynamic>>.broadcast();

  ConnectionController({
    required ConfigService configService,
    required AnalyticsService analyticsService,
    required Logger logger,
  }) : _configService = configService,
       _analyticsService = analyticsService,
       _logger = logger,
       super(const ConnectionState()) {
    _initializeConnection();
  }

  // 📡 MESSAGE STREAM
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  // 🚀 INITIALIZATION
  Future<void> _initializeConnection() async {
    try {
      _logger.i('🌐 Initializing Connection Controller...');
      
      // Load connection config
      final savedConfig = await _configService.getConnectionConfig();
      if (savedConfig != null) {
        state = savedConfig;
        _logger.i('✅ Connection config loaded: ${state.serverUrl}:${state.port}');
      } else {
        await _setDefaultConnection();
      }
      
      // Auto-connect if configured
      if (state.serverUrl.isNotEmpty) {
        await connect();
      }
      
      _analyticsService.trackEvent('connection_initialized', {
        'server_url': state.serverUrl,
        'port': state.port,
        'auto_connect': state.serverUrl.isNotEmpty,
      });
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to initialize connection', error: e, stackTrace: stackTrace);
      await _setDefaultConnection();
    }
  }

  // 🔗 CONNECTION MANAGEMENT
  Future<void> connect([String? customUrl, int? customPort]) async {
    if (state.status == ConnectionStatus.connecting) {
      _logger.w('⚠️ Already connecting...');
      return;
    }

    try {
      final url = customUrl ?? state.serverUrl;
      final port = customPort ?? state.port;
      
      _logger.i('🔗 Connecting to $url:$port...');
      
      state = state.copyWith(
        status: ConnectionStatus.connecting,
        serverUrl: url,
        port: port,
        lastError: null,
      );
      
      // Build WebSocket URL
      final wsUrl = _buildWebSocketUrl(url, port);
      
      // Create WebSocket connection with timeout
      await _connectWithTimeout(wsUrl);
      
    } catch (e, stackTrace) {
      _logger.e('❌ Connection failed', error: e, stackTrace: stackTrace);
      await _handleConnectionError(e.toString());
    }
  }

  Future<void> _connectWithTimeout(String wsUrl) async {
    final completer = Completer<void>();
    Timer? timeoutTimer;
    
    try {
      // Set connection timeout
      timeoutTimer = Timer(_connectionTimeout, () {
        if (!completer.isCompleted) {
          completer.completeError(TimeoutException('Connection timeout', _connectionTimeout));
        }
      });
      
      // Create WebSocket channel
      _channel = IOWebSocketChannel.connect(
        wsUrl,
        protocols: ['neuronvault-protocol'],
        headers: {
          'User-Agent': 'NeuronVault/2.5.0',
          'X-Client-Type': 'flutter-desktop',
        },
      );
      
      // Wait for connection
      await _channel!.ready;
      
      if (!completer.isCompleted) {
        completer.complete();
      }
      
      await completer.future;
      
      // Connection successful
      await _onConnectionEstablished();
      
    } finally {
      timeoutTimer?.cancel();
    }
  }

  Future<void> _onConnectionEstablished() async {
    _logger.i('✅ WebSocket connection established');
    
    final now = DateTime.now();
    
    state = state.copyWith(
      status: ConnectionStatus.connected,
      lastConnectionTime: now,
      reconnectAttempts: 0,
      lastError: null,
      latencyMs: 0,
    );
    
    // Setup message listening
    _setupMessageListener();
    
    // Start ping monitoring
    _startPingMonitoring();
    
    // Save connection config
    await _configService.saveConnectionConfig(state);
    
    _analyticsService.trackEvent('connection_established', {
      'server_url': state.serverUrl,
      'port': state.port,
      'connection_time': now.toIso8601String(),
    });
  }

  // 📨 MESSAGE HANDLING
  void _setupMessageListener() {
    _channelSubscription?.cancel();
    _channelSubscription = _channel!.stream.listen(
      _onMessageReceived,
      onError: _onConnectionError,
      onDone: _onConnectionClosed,
    );
    
    _logger.d('👂 Message listener setup complete');
  }

  void _onMessageReceived(dynamic rawMessage) {
    try {
      final message = jsonDecode(rawMessage.toString()) as Map<String, dynamic>;
      
      _logger.d('📨 Message received: ${message['type'] ?? 'unknown'}');
      
      // Handle special message types
      switch (message['type']) {
        case 'pong':
          _handlePongMessage(message);
          break;
        case 'error':
          _handleErrorMessage(message);
          break;
        case 'health_check':
          _handleHealthCheckMessage(message);
          break;
        default:
          // Forward to message stream
          _messageController.add(message);
      }
      
    } catch (e) {
      _logger.w('⚠️ Failed to parse message: $e');
    }
  }

  void _onConnectionError(dynamic error) {
    _logger.e('❌ WebSocket error: $error');
    _handleConnectionError(error.toString());
  }

  void _onConnectionClosed() {
    _logger.w('🔌 WebSocket connection closed');
    
    if (state.status == ConnectionStatus.connected) {
      // Unexpected disconnection - attempt reconnect
      _handleUnexpectedDisconnection();
    } else {
      // Expected disconnection
      state = state.copyWith(status: ConnectionStatus.disconnected);
    }
  }

  // 📤 MESSAGE SENDING
  Future<void> sendMessage(Map<String, dynamic> message) async {
    if (!state.isConnected) {
      throw StateError('Not connected to server');
    }
    
    try {
      final jsonMessage = jsonEncode(message);
      _channel!.sink.add(jsonMessage);
      
      _logger.d('📤 Message sent: ${message['type'] ?? 'unknown'}');
      
      _analyticsService.trackEvent('message_sent', {
        'type': message['type'],
        'size': jsonMessage.length,
      });
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to send message', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // 💓 PING/PONG MONITORING
  void _startPingMonitoring() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(_pingInterval, (_) {
      _sendPing();
    });
    
    _logger.d('💓 Ping monitoring started');
  }

  void _sendPing() async {
    if (!state.isConnected) return;
    
    try {
      final pingTime = DateTime.now().millisecondsSinceEpoch;
      
      await sendMessage({
        'type': 'ping',
        'timestamp': pingTime,
      });
      
      _logger.d('📡 Ping sent');
      
    } catch (e) {
      _logger.w('⚠️ Failed to send ping: $e');
    }
  }

  void _handlePongMessage(Map<String, dynamic> message) {
    try {
      final pingTime = message['timestamp'] as int?;
      if (pingTime != null) {
        final latency = DateTime.now().millisecondsSinceEpoch - pingTime;
        state = state.copyWith(latencyMs: latency);
        
        _logger.d('🏓 Pong received, latency: ${latency}ms');
      }
    } catch (e) {
      _logger.w('⚠️ Failed to process pong: $e');
    }
  }

  // ⚠️ ERROR HANDLING
  Future<void> _handleConnectionError(String error) async {
    _logger.e('⚠️ Handling connection error: $error');
    
    state = state.copyWith(
      status: ConnectionStatus.error,
      lastError: error,
    );
    
    // Cleanup
    await _cleanup();
    
    // Attempt reconnection if within limits
    if (state.canReconnect) {
      await _scheduleReconnect();
    } else {
      _logger.e('❌ Max reconnection attempts reached');
      _analyticsService.trackEvent('connection_failed', {
        'error': error,
        'attempts': state.reconnectAttempts,
      });
    }
  }

  void _handleUnexpectedDisconnection() {
    _logger.w('🔌 Unexpected disconnection detected');
    
    state = state.copyWith(status: ConnectionStatus.disconnected);
    
    // Schedule immediate reconnect
    _scheduleReconnect();
  }

  void _handleErrorMessage(Map<String, dynamic> message) {
    final error = message['error'] ?? 'Unknown server error';
    _logger.e('🚨 Server error: $error');
    
    _analyticsService.trackEvent('server_error', {
      'error': error,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _handleHealthCheckMessage(Map<String, dynamic> message) {
    _logger.d('🩺 Server health check received');
    
    // Respond to health check
    sendMessage({
      'type': 'health_response',
      'status': 'healthy',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // 🔄 RECONNECTION
  Future<void> _scheduleReconnect() async {
    if (state.reconnectAttempts >= state.maxReconnects) {
      return;
    }
    
    _logger.i('🔄 Scheduling reconnect in ${_reconnectDelay.inSeconds}s (attempt ${state.reconnectAttempts + 1})');
    
    state = state.copyWith(
      status: ConnectionStatus.reconnecting,
      reconnectAttempts: state.reconnectAttempts + 1,
    );
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () {
      connect();
    });
  }

  // 🔌 DISCONNECTION
  Future<void> disconnect() async {
    _logger.i('🔌 Disconnecting...');
    
    // Cancel timers
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    
    // Update state
    state = state.copyWith(status: ConnectionStatus.disconnected);
    
    // Cleanup connection
    await _cleanup();
    
    _analyticsService.trackEvent('connection_disconnected', {
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    _logger.i('✅ Disconnected successfully');
  }

  // 🧹 CLEANUP
  Future<void> _cleanup() async {
    try {
      await _channelSubscription?.cancel();
      await _channel?.sink.close();
      _channel = null;
      _channelSubscription = null;
      
      _logger.d('🧹 Connection cleanup completed');
      
    } catch (e) {
      _logger.w('⚠️ Cleanup error: $e');
    }
  }

  // 🔧 CONFIGURATION
  Future<void> updateConnectionConfig({
    String? serverUrl,
    int? port,
    int? maxReconnects,
  }) async {
    state = state.copyWith(
      serverUrl: serverUrl ?? state.serverUrl,
      port: port ?? state.port,
      maxReconnects: maxReconnects ?? state.maxReconnects,
    );
    
    await _configService.saveConnectionConfig(state);
    
    _logger.i('🔧 Connection config updated');
  }

  // 🎯 UTILITIES
  String _buildWebSocketUrl(String host, int port) {
    final scheme = host.startsWith('localhost') || host.startsWith('127.0.0.1') 
        ? 'ws' 
        : 'wss';
    return '$scheme://$host:$port/ws';
  }

  Future<void> _setDefaultConnection() async {
    const defaultState = ConnectionState(
      serverUrl: 'localhost',
      port: 8080,
      maxReconnects: 3,
    );
    
    state = defaultState;
    await _configService.saveConnectionConfig(state);
    
    _logger.i('🎯 Default connection configuration applied');
  }

  // 🔄 RESET & STATUS
  Future<void> resetConnection() async {
    _logger.i('🔄 Resetting connection...');
    
    await disconnect();
    await _setDefaultConnection();
    
    _analyticsService.trackEvent('connection_reset', {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  bool get isHealthy => state.isConnected && state.latencyMs < 1000;

  // 🧹 DISPOSAL
  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _channelSubscription?.cancel();
    _channel?.sink.close();
    _messageController.close();
    
    _logger.d('🧹 Connection Controller disposed');
    super.dispose();
  }
}

// 🎯 COMPUTED PROVIDERS FOR CONNECTION
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

// 📡 MESSAGE STREAM PROVIDER
final connectionMessageStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final controller = ref.watch(connectionControllerProvider.notifier);
  return controller.messageStream;
});