import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class NodeService extends ChangeNotifier {
  Process? _nodeProcess;
  bool _isRunning = false;
  final StreamController<String> _outputController = StreamController<String>.broadcast();

  Stream<String> get output => _outputController.stream;
  bool get isRunning => _isRunning;

  // Inizializza e avvia il backend
  Future<bool> startBackend() async {
    if (_isRunning) return true;

    try {
      // Ottieni il percorso dell'applicazione
      final appDir = await getApplicationSupportDirectory();
      final backendDir = Directory('${appDir.path}/backend');

      // Controlla se la directory esiste, altrimenti copiala da assets
      if (!await backendDir.exists()) {
        await backendDir.create(recursive: true);
        await _extractBackendFiles(backendDir.path);
      }

      // Definisci variabili d'ambiente per il processo Node.js
      final Map<String, String> environment = {};

      // Aggiungi eventuali chiavi API dalle impostazioni
      // Le chiavi saranno caricate dinamicamente da api_key_manager.dart

      _outputController.add('Starting Node.js backend...');

      // Avvia il processo Node.js
      _nodeProcess = await Process.start(
        'node',
        ['index.js'],
        workingDirectory: backendDir.path,
        environment: environment,
      );

      _isRunning = true;

      // Stream per l'output standard
      _nodeProcess!.stdout.transform(utf8.decoder).listen((data) {
        _outputController.add(data);
      });

      // Stream per gli errori
      _nodeProcess!.stderr.transform(utf8.decoder).listen((data) {
        _outputController.add('ERROR: $data');
      });

      // Listener per quando il processo termina
      _nodeProcess!.exitCode.then((exitCode) {
        _isRunning = false;
        _outputController.add('Backend stopped with exit code: $exitCode');
        notifyListeners();
      });

      _outputController.add('Backend started successfully');
      notifyListeners();
      return true;
    } catch (e) {
      _outputController.add('Failed to start backend: $e');
      return false;
    }
  }

  // Estrae i file del backend dalle risorse dell'app
  Future<void> _extractBackendFiles(String destinationPath) async {
    try {
      // Qui implementeremo la logica per estrarre i file del backend
      // dalle risorse dell'app alla directory di destinazione
      _outputController.add('Extracting backend files...');

      // Questo sarà implementato in modo più dettagliato
      // una volta preparati i file backend

      _outputController.add('Backend files extracted');
    } catch (e) {
      _outputController.add('Error extracting backend files: $e');
      rethrow;
    }
  }

  // Arresta il backend
  Future<void> stopBackend() async {
    if (!_isRunning || _nodeProcess == null) return;

    _outputController.add('Stopping backend...');
    _nodeProcess!.kill();
    _isRunning = false;
    notifyListeners();
  }

  // Riavvia il backend
  Future<bool> restartBackend() async {
    await stopBackend();
    return startBackend();
  }

  // Dispose delle risorse
  void dispose() {
    stopBackend();
    _outputController.close();
    super.dispose();
  }
}