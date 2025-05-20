import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

// Import dei servizi e provider
import 'desktop/services/node_service.dart';
import 'desktop/services/ipc_service.dart';
import 'providers/app_state_provider.dart';
import 'providers/theme_provider.dart';
import 'services/api_key_manager.dart';

// Import delle schermate
import 'screens/splash_screen.dart';
import 'screens/api_config_screen.dart';

void main() async {
  // Assicurati che Flutter sia inizializzato
  WidgetsFlutterBinding.ensureInitialized();

  // Configurazione per desktop
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = WindowOptions(
        size: Size(1200, 800),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.hidden,
        title: "Multi-AI Team",
        minimumSize: Size(800, 600)
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // Imposta l'orientamento preferito
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Imposta lo stile della status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Inizializza i servizi principali
  final nodeService = NodeService();
  final apiKeyManager = ApiKeyManager();

  // Carica le preferenze e le chiavi API
  await apiKeyManager.loadKeys();
  final isFirstRun = await apiKeyManager.isFirstRun();

  // Avvia il backend Node.js
  await nodeService.startBackend();

  // Avvia l'app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => nodeService),
        ChangeNotifierProvider(create: (_) => apiKeyManager),
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider(false)),
        Provider(create: (_) => IPCService()),
      ],
      child: MultiAiTeamApp(isFirstRun: isFirstRun),
    ),
  );
}

class MultiAiTeamApp extends StatelessWidget {
  final bool isFirstRun;

  const MultiAiTeamApp({
    Key? key,
    required this.isFirstRun,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Multi-AI Team',
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,

      // Determina la schermata iniziale in base al primo avvio
      initialRoute: isFirstRun ? '/setup' : '/',

      routes: {
        '/': (context) => const SplashScreen(),
        '/setup': (context) => const ApiConfigScreen(isInitialSetup: true),
      },
    );
  }
}