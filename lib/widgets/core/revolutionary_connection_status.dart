// 🔗 REVOLUTIONARY CONNECTION STATUS WIDGET - FINAL FIXED VERSION
// lib/widgets/core/revolutionary_connection_status.dart
// FIXED: Import conflicts and null safety issues

import 'package:flutter/material.dart' hide ConnectionState; // 🔧 HIDE Flutter's ConnectionState
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'dart:async';

import '../../core/state/state_models.dart'; // 🔧 Our ConnectionState
import '../../core/theme/neural_theme_system.dart';
import '../../core/providers/providers_main.dart';

/// 🌟 Revolutionary Connection Status Widget
class RevolutionaryConnectionStatus extends ConsumerStatefulWidget {
  final bool isCompact;
  final VoidCallback? onTap;

  const RevolutionaryConnectionStatus({
    super.key,
    this.isCompact = false,
    this.onTap,
  });

  @override
  ConsumerState<RevolutionaryConnectionStatus> createState() =>
      _RevolutionaryConnectionStatusState();
}

class _RevolutionaryConnectionStatusState
    extends ConsumerState<RevolutionaryConnectionStatus>
    with TickerProviderStateMixin {

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _retryController;
  late AnimationController _qualityController;
  late AnimationController _neuralController;

  // Animations
  late Animation<double> _pulseAnimation;
  late Animation<double> _retryAnimation;
  late Animation<double> _qualityAnimation;
  late Animation<double> _neuralPulseAnimation;

  // Connection quality tracking
  Timer? _latencyTimer;
  final List<int> _latencyHistory = [];
  int _currentLatency = 0;
  double _connectionQuality = 1.0;
  int _retryCountdown = 0;
  Timer? _retryCountdownTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startLatencyMonitoring();
  }

  void _initializeAnimations() {
    // Pulse animation for connection dot
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.4,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Retry progress animation
    _retryController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _retryAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _retryController,
      curve: Curves.easeInOut,
    ));

    // Connection quality meter animation
    _qualityController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _qualityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _qualityController,
      curve: Curves.easeOutCubic,
    ));

    // Neural pulse animation
    _neuralController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _neuralPulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _neuralController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _pulseController.repeat(reverse: true);
    _neuralController.repeat();
    _qualityController.forward();
  }

  void _startLatencyMonitoring() {
    _latencyTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _simulateLatencyCheck();
    });
  }

  void _simulateLatencyCheck() {
    final connectionState = ref.read(connectionControllerProvider);
    if (connectionState.isConnected) {
      // Simulate realistic latency (in real app, this would be actual ping)
      final latency = 20 + math.Random().nextInt(80); // 20-100ms
      setState(() {
        _currentLatency = latency;
        _latencyHistory.add(latency);
        if (_latencyHistory.length > 10) {
          _latencyHistory.removeAt(0);
        }
        _connectionQuality = _calculateConnectionQuality();
      });
    }
  }

  double _calculateConnectionQuality() {
    if (_latencyHistory.isEmpty) return 1.0;

    final avgLatency = _latencyHistory.reduce((a, b) => a + b) / _latencyHistory.length;

    if (avgLatency < 50) return 1.0;      // Excellent
    if (avgLatency < 100) return 0.8;     // Good
    if (avgLatency < 200) return 0.6;     // Fair
    if (avgLatency < 500) return 0.4;     // Poor
    return 0.2;                           // Very Poor
  }

  String _getConnectionQualityText() {
    if (_connectionQuality >= 0.9) return 'EXCELLENT';
    if (_connectionQuality >= 0.7) return 'GOOD';
    if (_connectionQuality >= 0.5) return 'FAIR';
    if (_connectionQuality >= 0.3) return 'POOR';
    return 'VERY POOR';
  }

  Color _getConnectionQualityColor(NeuralThemeData theme) {
    if (_connectionQuality >= 0.7) return theme.colors.connectionActive;
    if (_connectionQuality >= 0.4) return const Color(0xFFF59E0B); // Orange
    return const Color(0xFFEF4444); // Red
  }

  void _startRetryCountdown(int seconds) {
    setState(() {
      _retryCountdown = seconds;
    });

    _retryCountdownTimer?.cancel();
    _retryCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _retryCountdown--;
      });

      if (_retryCountdown <= 0) {
        timer.cancel();
        _retryController.reset();
      } else {
        _retryController.forward();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _retryController.dispose();
    _qualityController.dispose();
    _neuralController.dispose();
    _latencyTimer?.cancel();
    _retryCountdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = NeuralThemeSystem().currentTheme;
    final connectionState = ref.watch(connectionControllerProvider);
    final isConnected = connectionState.isConnected;
    final isConnecting = connectionState.isConnecting;
    final isReconnecting = connectionState.status == ConnectionStatus.reconnecting;
    final hasError = connectionState.hasError;

    return GestureDetector(
      onTap: widget.onTap ?? () => _showConnectionDialog(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: EdgeInsets.symmetric(
          horizontal: widget.isCompact ? 12 : 18,
          vertical: widget.isCompact ? 8 : 12,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getStatusColor(theme, connectionState).withOpacity(0.25),
              _getStatusColor(theme, connectionState).withOpacity(0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(widget.isCompact ? 16 : 25),
          border: Border.all(
            color: _getStatusColor(theme, connectionState).withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _getStatusColor(theme, connectionState).withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.isCompact ? 16 : 25),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: widget.isCompact
                ? _buildCompactView(theme, connectionState)
                : _buildFullView(theme, connectionState),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactView(NeuralThemeData theme, ConnectionState connectionState) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatusIndicator(theme, connectionState, 8),
        const SizedBox(width: 8),
        Text(
          _getStatusText(connectionState),
          style: TextStyle(
            color: _getStatusColor(theme, connectionState),
            fontWeight: FontWeight.w800,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildFullView(NeuralThemeData theme, ConnectionState connectionState) {
    final isConnected = connectionState.isConnected;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Status indicator with neural pulse animation
        _buildStatusIndicator(theme, connectionState, 12),

        const SizedBox(width: 12),

        // Status info column
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Primary status
            Row(
              children: [
                Text(
                  _getStatusText(connectionState),
                  style: TextStyle(
                    color: _getStatusColor(theme, connectionState),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),

                // Connection quality indicator
                if (isConnected) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _getConnectionQualityColor(theme),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),

            // Secondary status info
            if (isConnected) ...[
              Text(
                '${_getConnectionQualityText()} • ${_currentLatency}ms',
                style: TextStyle(
                  color: theme.colors.connectionActive.withOpacity(0.8),
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else if (connectionState.isConnecting || connectionState.status == ConnectionStatus.reconnecting) ...[
              Row(
                children: [
                  SizedBox(
                    width: 8,
                    height: 8,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation(_getStatusColor(theme, connectionState)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _retryCountdown > 0 ? 'RETRY IN ${_retryCountdown}s' : 'CONNECTING...',
                    style: TextStyle(
                      color: _getStatusColor(theme, connectionState).withOpacity(0.8),
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),

        // Quick action buttons
        if (!widget.isCompact) ...[
          const SizedBox(width: 12),
          _buildQuickActions(theme, connectionState),
        ],
      ],
    );
  }

  Widget _buildStatusIndicator(NeuralThemeData theme, ConnectionState connectionState, double size) {
    final statusColor = _getStatusColor(theme, connectionState);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: statusColor,
            boxShadow: [
              BoxShadow(
                color: statusColor.withOpacity(0.6),
                blurRadius: 8 * _pulseAnimation.value,
                spreadRadius: 2 * _pulseAnimation.value,
              ),
            ],
          ),
          child: connectionState.isConnecting || connectionState.status == ConnectionStatus.reconnecting
              ? Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor.withOpacity(0.3),
            ),
            child: Transform.scale(
              scale: 0.6,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation(statusColor),
              ),
            ),
          )
              : null,
        );
      },
    );
  }

  Widget _buildQuickActions(NeuralThemeData theme, ConnectionState connectionState) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Reconnect button
        if (!connectionState.isConnected) ...[
          _buildQuickActionButton(
            icon: Icons.refresh,
            onTap: () => _handleQuickReconnect(),
            color: theme.colors.primary,
            size: 16,
          ),
          const SizedBox(width: 6),
        ],

        // Diagnostics button
        _buildQuickActionButton(
          icon: Icons.analytics,
          onTap: () => _showConnectionDiagnostics(context),
          color: theme.colors.secondary,
          size: 16,
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required double size,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.2),
          border: Border.all(
            color: color.withOpacity(0.4),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: size,
          color: color,
        ),
      ),
    );
  }

  // 🔧 FIXED: Added return statements for all cases
  Color _getStatusColor(NeuralThemeData theme, ConnectionState connectionState) {
    switch (connectionState.status) {
      case ConnectionStatus.connected:
        return theme.colors.connectionActive;
      case ConnectionStatus.connecting:
      case ConnectionStatus.reconnecting:
        return theme.colors.primary;
      case ConnectionStatus.disconnected:
        return theme.colors.connectionInactive;
      case ConnectionStatus.error:
        return const Color(0xFFEF4444);
    }
  }

  // 🔧 FIXED: Added return statements for all cases
  String _getStatusText(ConnectionState connectionState) {
    switch (connectionState.status) {
      case ConnectionStatus.connected:
        return 'CONNECTED';
      case ConnectionStatus.connecting:
        return 'CONNECTING';
      case ConnectionStatus.reconnecting:
        return 'RECONNECTING';
      case ConnectionStatus.disconnected:
        return 'DISCONNECTED';
      case ConnectionStatus.error:
        return 'ERROR';
    }
  }

  void _handleQuickReconnect() async {
    final controller = ref.read(connectionControllerProvider.notifier);
    _startRetryCountdown(5);
    await controller.reconnect();
  }

  void _showConnectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ConnectionDiagnosticsDialog(),
    );
  }

  void _showConnectionDiagnostics(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ConnectionDiagnosticsDialog(),
    );
  }
}

/// 🔍 Connection Diagnostics Dialog - Advanced connection information
class ConnectionDiagnosticsDialog extends ConsumerWidget {
  const ConnectionDiagnosticsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = NeuralThemeSystem().currentTheme;
    final connectionStats = ref.watch(connectionStatisticsProvider);
    final connectionState = ref.watch(connectionControllerProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colors.surface.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.analytics,
                      color: theme.colors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Connection Diagnostics',
                      style: TextStyle(
                        color: theme.colors.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: theme.colors.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Connection stats
                _buildDiagnosticRow(theme, 'Status', connectionStats['status'] ?? 'Unknown'),
                _buildDiagnosticRow(theme, 'Server URL', connectionStats['server_url']?.toString() ?? 'N/A'),
                _buildDiagnosticRow(theme, 'Port', connectionStats['port']?.toString() ?? 'N/A'),
                _buildDiagnosticRow(theme, 'Actual Port', connectionStats['actual_port']?.toString() ?? 'N/A'),
                _buildDiagnosticRow(theme, 'Latency', '${connectionStats['latency_ms'] ?? 0}ms'),
                _buildDiagnosticRow(theme, 'Retry Attempts', '${connectionStats['reconnect_attempts']}/${connectionStats['max_reconnects']}'),

                if (connectionStats['last_error'] != null)
                  _buildDiagnosticRow(theme, 'Last Error', connectionStats['last_error'], isError: true),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: connectionState.isConnected
                            ? null
                            : () async {
                          Navigator.of(context).pop();
                          await ref.read(connectionControllerProvider.notifier).connect();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reconnect'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref.read(connectionControllerProvider.notifier).resetReconnectAttempts();
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.settings_backup_restore),
                        label: const Text('Reset'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colors.onSurface,
                          side: BorderSide(color: theme.colors.primary.withOpacity(0.3)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosticRow(NeuralThemeData theme, String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: theme.colors.onSurface.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isError
                    ? const Color(0xFFEF4444)
                    : theme.colors.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}