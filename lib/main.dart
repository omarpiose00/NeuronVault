// 🧠 NEURONVAULT - ENTERPRISE MAIN APPLICATION
// Flutter Desktop App with Riverpod State Management
// Part of PHASE 2.5 - QUANTUM STATE MANAGEMENT - COMPLETED ✅

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:window_manager/window_manager.dart';

import 'core/providers/providers_main.dart';
import 'core/state/state_models.dart';
import 'core/design_system.dart';
import 'screens/main_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/error_screen.dart';

// 🚀 ENTERPRISE APPLICATION ENTRY POINT
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔧 DESKTOP WINDOW CONFIGURATION
  await _configureDesktopWindow();

  // 📱 FLUTTER CONFIGURATION
  await _configureFlutter();

  // 🧠 INITIALIZE CORE SERVICES
  final sharedPreferences = await SharedPreferences.getInstance();

  // 🎯 CREATE PROVIDER CONTAINER
  final container = ProviderContainer(
    overrides: [
      // Override SharedPreferences provider with actual instance
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    ],
    observers: [
      // Add provider observers for debugging in development
      if (kDebugMode) _NeuronVaultProviderObserver(),
    ],
  );

  // 🏃 RUN APPLICATION
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const NeuronVaultApp(),
    ),
  );
}

// 🖥️ DESKTOP WINDOW CONFIGURATION
Future<void> _configureDesktopWindow() async {
  try {
    await windowManager.ensureInitialized();

    final windowOptions = WindowOptions(
      size: const Size(1200, 800),
      minimumSize: const Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      windowButtonVisibility: true,
      title: 'NeuronVault - Enterprise AI Orchestration Platform',
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

  } catch (e) {
    debugPrint('❌ Failed to configure desktop window: $e');
  }
}

// 📱 FLUTTER FRAMEWORK CONFIGURATION
Future<void> _configureFlutter() async {
  // Set preferred orientations for desktop
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
  ]);

  // Configure system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
}

// 🧠 MAIN APPLICATION WIDGET
class NeuronVaultApp extends ConsumerWidget {
  const NeuronVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme providers
    final currentTheme = ref.watch(currentThemeProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    return MaterialApp(
      // 🎨 APPLICATION CONFIGURATION
      title: 'NeuronVault - Enterprise AI Platform',
      debugShowCheckedModeBanner: false,

      // 🎨 THEME CONFIGURATION
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // 🌍 LOCALIZATION
      locale: const Locale('en', 'US'),
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('it', 'IT'),
      ],

      // 🏠 HOME SCREEN
      home: const AppInitializationWrapper(),

      // 🧪 TESTING CONFIGURATION
      builder: (context, child) {
        // Add any global wrappers here (error handling, etc.)
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0), // Prevent text scaling issues
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }

  // 🎨 BUILD LIGHT THEME
  ThemeData _buildLightTheme() {
    const colorScheme = ColorScheme.light(
      primary: Color(0xFF6366F1),
      secondary: Color(0xFF10B981),
      tertiary: Color(0xFFF59E0B),
      surface: Color(0xFFFFFFFF),
      background: Color(0xFFF8FAFC),
      error: Color(0xFFEF4444),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
    );
  }

  // 🎨 BUILD DARK THEME
  ThemeData _buildDarkTheme() {
    const colorScheme = ColorScheme.dark(
      primary: Color(0xFF6366F1),
      secondary: Color(0xFF10B981),
      tertiary: Color(0xFFF59E0B),
      surface: Color(0xFF111827),
      background: Color(0xFF0F172A),
      error: Color(0xFFEF4444),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
    );
  }
}

// 🔄 APPLICATION INITIALIZATION WRAPPER
class AppInitializationWrapper extends ConsumerWidget {
  const AppInitializationWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initializationAsync = ref.watch(initializationProvider);

    return initializationAsync.when(
      // ⏳ LOADING STATE
      loading: () => const LoadingScreen(
        message: 'Initializing NeuronVault...',
        subtitle: 'Setting up enterprise AI orchestration',
      ),

      // ✅ SUCCESS STATE
      data: (isInitialized) {
        if (isInitialized) {
          return const MainApplicationScreen();
        } else {
          return const ErrorScreen(
            title: 'Initialization Failed',
            message: 'Failed to initialize the application. Please restart.',
            canRetry: true,
          );
        }
      },

      // ❌ ERROR STATE
      error: (error, stackTrace) {
        return ErrorScreen(
          title: 'Initialization Error',
          message: 'An error occurred during initialization: $error',
          canRetry: true,
        );
      },
    );
  }
}

// 🏠 MAIN APPLICATION SCREEN
class MainApplicationScreen extends ConsumerWidget {
  const MainApplicationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch global state
    final appReady = ref.watch(appReadyProvider);
    final overallHealth = ref.watch(overallHealthProvider);
    final systemStatus = ref.watch(systemStatusProvider);

    return Scaffold(
      // 🧠 NEURAL APP BAR
      appBar: AppBar(
        title: Row(
          children: [
            // 🧠 Logo
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: _getPrimaryGradient(),
              ),
              child: const Icon(Icons.psychology, color: Colors.white, size: 20),
            ),

            // 📱 Title
            const Text(
              'NeuronVault',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),

            // 🏷️ Version Badge
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'v2.5.0',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),

        // 🔧 ACTION BUTTONS
        actions: [
          // 🩺 Health Indicator
          _HealthIndicator(health: overallHealth),

          // 🌐 Connection Status
          const _ConnectionStatusIndicator(),

          // ⚙️ Settings Button
          IconButton(
            onPressed: () => _showSettingsModal(context, ref),
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
          ),

          const SizedBox(width: 8),
        ],

        elevation: 0,
        backgroundColor: Colors.transparent,
      ),

      // 🏠 MAIN CONTENT
      body: appReady
          ? const MainScreen()
          : const _SetupRequiredScreen(),
    );
  }

  LinearGradient _getPrimaryGradient() {
    return const LinearGradient(
      colors: [
        Color(0xFF6366F1),
        Color(0xFF8B5CF6),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  void _showSettingsModal(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const Text('Settings panel coming soon in Phase 2!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// 🩺 HEALTH INDICATOR WIDGET
class _HealthIndicator extends StatelessWidget {
  final AppHealth health;

  const _HealthIndicator({required this.health});

  @override
  Widget build(BuildContext context) {
    final (color, icon, tooltip) = switch (health) {
      AppHealth.healthy => (Colors.green, Icons.check_circle, 'System Healthy'),
      AppHealth.degraded => (Colors.orange, Icons.warning, 'System Degraded'),
      AppHealth.unhealthy => (Colors.red, Icons.error, 'System Unhealthy'),
      AppHealth.critical => (Colors.red, Icons.dangerous, 'System Critical'),
    };

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Tooltip(
        message: tooltip,
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

// 🌐 CONNECTION STATUS INDICATOR
class _ConnectionStatusIndicator extends ConsumerWidget {
  const _ConnectionStatusIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For now, show a placeholder since providers aren't fully implemented
    const connectionStatus = ConnectionStatus.connected;
    const latency = 50;

    final (color, icon, tooltip) = switch (connectionStatus) {
      ConnectionStatus.connected => (
      Colors.green,
      Icons.wifi,
      'Connected (${latency}ms)'
      ),
      ConnectionStatus.connecting => (
      Colors.orange,
      Icons.wifi_find,
      'Connecting...'
      ),
      ConnectionStatus.disconnected => (
      Colors.grey,
      Icons.wifi_off,
      'Disconnected'
      ),
      ConnectionStatus.error => (
      Colors.red,
      Icons.error_outline,
      'Connection Error'
      ),
      ConnectionStatus.reconnecting => (
      Colors.amber,
      Icons.refresh,
      'Reconnecting...'
      ),
    };

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Tooltip(
        message: tooltip,
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

// 🔧 SETUP REQUIRED SCREEN
class _SetupRequiredScreen extends ConsumerWidget {
  const _SetupRequiredScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Setup Required',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Please configure your AI models and connection settings.',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 24),
          // TODO: Add setup wizard button
        ],
      ),
    );
  }
}

// 🧪 PROVIDER OBSERVER FOR DEBUGGING
class _NeuronVaultProviderObserver extends ProviderObserver {
  final Logger _logger = Logger();

  @override
  void didUpdateProvider(
      ProviderBase provider,
      Object? previousValue,
      Object? newValue,
      ProviderContainer container,
      ) {
    if (provider.name != null) {
      _logger.d('🔄 Provider Updated: ${provider.name} -> $newValue');
    }
  }

  @override
  void didDisposeProvider(
      ProviderBase provider,
      ProviderContainer container,
      ) {
    if (provider.name != null) {
      _logger.d('🗑️ Provider Disposed: ${provider.name}');
    }
  }
}

// 🎯 COMPILE-TIME CONSTANTS
const bool kDebugMode = bool.fromEnvironment('dart.vm.product') == false;