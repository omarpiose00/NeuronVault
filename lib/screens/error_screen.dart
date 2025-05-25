// ❌ NEURONVAULT - ENTERPRISE ERROR HANDLING SCREEN
// Professional error recovery with detailed diagnostics
// Part of PHASE 2.5 - QUANTUM STATE MANAGEMENT

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/design_system.dart';
import '../core/providers/providers_main.dart' hide ConnectionStatus;
import '../core/services/analytics_service.dart';
import '../core/state/state_models.dart';

enum ErrorSeverity {
  low,      // Non-critical errors, app continues
  medium,   // Important errors, some features affected
  high,     // Critical errors, major functionality broken
  critical, // System-breaking errors, app unusable
}

class ErrorScreen extends ConsumerStatefulWidget {
  final String title;
  final String message;
  final String? technicalDetails;
  final ErrorSeverity severity;
  final bool canRetry;
  final bool canReport;
  final VoidCallback? onRetry;
  final VoidCallback? onReport;
  final VoidCallback? onBack;
  final Map<String, dynamic>? errorContext;

  const ErrorScreen({
    super.key,
    required this.title,
    required this.message,
    this.technicalDetails,
    this.severity = ErrorSeverity.medium,
    this.canRetry = false,
    this.canReport = true,
    this.onRetry,
    this.onReport,
    this.onBack,
    this.errorContext,
  });

  @override
  ConsumerState<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends ConsumerState<ErrorScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool _showTechnicalDetails = false;
  bool _isReporting = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _trackError();
  }

  void _initializeAnimations() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));

    // Start shake animation for critical errors
    if (widget.severity == ErrorSeverity.critical) {
      _shakeController.forward();
    }
  }

  void _trackError() {
    // Track error occurrence in analytics
    final analyticsService = ref.read(analyticsServiceProvider);
    analyticsService.trackError(
      widget.message,
      description: widget.technicalDetails,
      // details: {
      //   'title': widget.title,
      //   'severity': widget.severity.name,
      //   'context': widget.errorContext ?? {},
      //   'timestamp': DateTime.now().toIso8601String(),
      // },
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Container(
        decoration: _buildBackgroundDecoration(theme),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  _shakeAnimation.value * 10 * (1 - _shakeAnimation.value),
                  0,
                ),
                child: Column(
                  children: [
                    // 🎨 Header
                    _buildHeader(theme),
                    
                    // ❌ Error content
                    Expanded(
                      child: _buildErrorContent(theme),
                    ),
                    
                    // 🔧 Action buttons
                    _buildActionButtons(theme),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration(ThemeData theme) {
    final severityColor = _getSeverityColor(theme);
    
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          theme.colorScheme.background,
          severityColor.withOpacity(0.05),
        ],
      ),
    );
  }

  Color _getSeverityColor(ThemeData theme) {
    switch (widget.severity) {
      case ErrorSeverity.low:
        return Colors.orange;
      case ErrorSeverity.medium:
        return Colors.amber;
      case ErrorSeverity.high:
        return theme.colorScheme.error;
      case ErrorSeverity.critical:
        return Colors.red;
    }
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          // 🧠 Neural logo (dimmed)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: theme.colorScheme.onBackground.withOpacity(0.1),
            ),
            child: Icon(
              Icons.psychology,
              color: theme.colorScheme.onBackground.withOpacity(0.6),
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 📱 App title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NeuronVault',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.8),
                  ),
                ),
                Text(
                  'Error Recovery',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          
          // 🔙 Back button
          if (widget.onBack != null)
            IconButton(
              onPressed: widget.onBack,
              icon: const Icon(Icons.close),
              tooltip: 'Close',
            ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 32),
          
          // ⚠️ Error icon
          _buildErrorIcon(theme),
          
          const SizedBox(height: 32),
          
          // 📝 Error message
          _buildErrorMessage(theme),
          
          const SizedBox(height: 24),
          
          // 🔍 Technical details
          if (widget.technicalDetails != null)
            _buildTechnicalDetails(theme),
          
          const SizedBox(height: 24),
          
          // 📊 System diagnostics
          _buildSystemDiagnostics(theme),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildErrorIcon(ThemeData theme) {
    final severityColor = _getSeverityColor(theme);
    final (icon, size) = _getSeverityIcon();
    
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: severityColor.withOpacity(0.1),
        border: Border.all(
          color: severityColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Icon(
        icon,
        size: size,
        color: severityColor,
      ),
    );
  }

  (IconData, double) _getSeverityIcon() {
    switch (widget.severity) {
      case ErrorSeverity.low:
        return (Icons.warning_amber, 36.0);
      case ErrorSeverity.medium:
        return (Icons.error_outline, 40.0);
      case ErrorSeverity.high:
        return (Icons.error, 44.0);
      case ErrorSeverity.critical:
        return (Icons.dangerous, 48.0);
    }
  }

  Widget _buildErrorMessage(ThemeData theme) {
    return Column(
      children: [
        // 📋 Error title
        Text(
          widget.title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 12),
        
        // 📝 Error description
        Text(
          widget.message,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onBackground.withOpacity(0.8),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        
        // 🏷️ Severity badge  
        const SizedBox(height: 16),
        _buildSeverityBadge(theme),
      ],
    );
  }

  Widget _buildSeverityBadge(ThemeData theme) {
    final severityColor = _getSeverityColor(theme);
    final severityText = _getSeverityText();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: severityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: severityColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        severityText,
        style: theme.textTheme.bodySmall?.copyWith(
          color: severityColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getSeverityText() {
    switch (widget.severity) {
      case ErrorSeverity.low:
        return 'LOW PRIORITY';
      case ErrorSeverity.medium:
        return 'MEDIUM PRIORITY';
      case ErrorSeverity.high:
        return 'HIGH PRIORITY';
      case ErrorSeverity.critical:
        return 'CRITICAL ERROR';
    }
  }

  Widget _buildTechnicalDetails(ThemeData theme) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔧 Header
          InkWell(
            onTap: () {
              setState(() {
                _showTechnicalDetails = !_showTechnicalDetails;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.code,
                    size: 20,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Technical Details',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _showTechnicalDetails 
                        ? Icons.expand_less 
                        : Icons.expand_more,
                  ),
                ],
              ),
            ),
          ),
          
          // 📋 Technical content
          if (_showTechnicalDetails) ...[
            const Divider(height: 1),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔍 Error details
                  SelectableText(
                    widget.technicalDetails!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 📋 Copy button
                  Row(
                    children: [
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => _copyTechnicalDetails(),
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Copy Details'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSystemDiagnostics(ThemeData theme) {
    return Consumer(
      builder: (context, ref, child) {
        final systemStatus = ref.watch(systemStatusProvider);
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🏥 Header
                Row(
                  children: [
                    Icon(
                      Icons.health_and_safety,
                      size: 20,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'System Diagnostics',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 📊 Diagnostic items
                _buildDiagnosticItem(
                  theme,
                  'Connection',
                  systemStatus.connectionStatus.name.toUpperCase(),
                  systemStatus.connectionStatus == ConnectionStatus.connected,
                ),
                
                _buildDiagnosticItem(
                  theme,
                  'AI Models',
                  '${systemStatus.healthyModelCount} healthy',
                  systemStatus.healthyModelCount > 0,
                ),
                
                _buildDiagnosticItem(
                  theme,
                  'Processing',
                  systemStatus.isGenerating ? 'ACTIVE' : 'IDLE',
                  !systemStatus.isGenerating,
                ),
                
                _buildDiagnosticItem(
                  theme,
                  'Last Update',
                  systemStatus.lastUpdate != null
                      ? _formatTimestamp(systemStatus.lastUpdate!)
                      : 'N/A',
                  true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiagnosticItem(
    ThemeData theme,
    String label,
    String value,
    bool isHealthy,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          // 🟢 Status indicator
          Container(
            width: 8,
            height: 8,  
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isHealthy ? Colors.green : Colors.red,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 🏷️ Label
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          
          // 📊 Value
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: isHealthy 
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // 🔄 Primary actions
          Row(
            children: [
              // 🔄 Retry button
              if (widget.canRetry)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              
              if (widget.canRetry && widget.canReport)
                const SizedBox(width: 12),
              
              // 📋 Report button
              if (widget.canReport)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isReporting ? null : _reportError,
                    icon: _isReporting 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.bug_report),
                    label: Text(_isReporting ? 'Reporting...' : 'Report Issue'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 🔧 Secondary actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: _restartApp,
                icon: const Icon(Icons.restart_alt, size: 16),
                label: const Text('Restart App'),
              ),
              
              TextButton.icon(
                onPressed: _contactSupport,
                icon: const Icon(Icons.support_agent, size: 16),
                label: const Text('Contact Support'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🔧 ACTION HANDLERS
  void _copyTechnicalDetails() {
    final details = '''
Error: ${widget.title}
Message: ${widget.message}
Severity: ${widget.severity.name}
Technical Details: ${widget.technicalDetails ?? 'None'}
Timestamp: ${DateTime.now().toIso8601String()}
Context: ${widget.errorContext ?? {}}
''';
    
    Clipboard.setData(ClipboardData(text: details));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Technical details copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _reportError() async {
    setState(() {
      _isReporting = true;
    });
    
    try {
      // Simulate error reporting
      await Future.delayed(const Duration(seconds: 2));
      
      if (widget.onReport != null) {
        widget.onReport!();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error report sent successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send error report'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isReporting = false;
      });
    }
  }

  void _restartApp() {
    // This would restart the application
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restart Application'),
        content: const Text('Are you sure you want to restart NeuronVault?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement app restart logic
              Navigator.of(context).pop();
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }

  void _contactSupport() {
    // This would open support contact
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? Contact our support team:'),
            SizedBox(height: 12),
            SelectableText('Email: support@neuronvault.ai'),
            SelectableText('Discord: NeuronVault Community'),
            SelectableText('GitHub: github.com/neuronvault/issues'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // 🔧 UTILITIES
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

// 🎯 ERROR SCREEN VARIANTS
class ConnectionErrorScreen extends ErrorScreen {
  ConnectionErrorScreen({super.key})
      : super(
          title: 'Connection Failed',
          message: 'Unable to connect to AI services. Please check your internet connection and try again.',
          severity: ErrorSeverity.high,
          canRetry: true,
          technicalDetails: 'WebSocket connection timeout after 30 seconds',
        );
}

class ModelErrorScreen extends ErrorScreen {
  ModelErrorScreen({super.key})
      : super(
          title: 'AI Model Error',
          message: 'One or more AI models are currently unavailable. Some features may be limited.',
          severity: ErrorSeverity.medium,
          canRetry: true,
        );
}

class CriticalErrorScreen extends ErrorScreen {
  CriticalErrorScreen({super.key})
      : super(
          title: 'Critical System Error',
          message: 'A critical error has occurred. The application may need to be restarted.',
          severity: ErrorSeverity.critical,
          canRetry: false,
          canReport: true,
        );
}