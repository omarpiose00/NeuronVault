import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class IPCService extends ChangeNotifier {
  // Configurazione server locale
  static const String baseUrl = 'http://localhost:4000';

  // Singleton
  static final IPCService _instance = IPCService._internal();
  factory IPCService() => _instance;
  IPCService._internal();

  // Stream controller per messaggi in tempo reale
  final Map<String, StreamController<Map<String, dynamic>>> _streamControllers = {};

  // Invia una richiesta al backend
  Future<Map<String, dynamic>> sendRequest(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        // Gestione errori
        final errorData = jsonDecode(response.body);
        throw Exception('Backend error: ${errorData['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      // Riconnessione in caso di errore
      if (e is http.ClientException) {
        // Prova a riconnettersi
        await Future.delayed(Duration(seconds: 1));
        return sendRequest(endpoint, data);
      }
      rethrow;
    }
  }

  // Ottiene uno stream di risposte dal backend per un dato ID conversazione
  Stream<Map<String, dynamic>> getResponseStream(String conversationId) {
    if (!_streamControllers.containsKey(conversationId)) {
      _streamControllers[conversationId] = StreamController<Map<String, dynamic>>.broadcast();

      // Avvia polling per aggiornamenti (sarà sostituito con WebSocket)
      _startPolling(conversationId);
    }

    return _streamControllers[conversationId]!.stream;
  }

  // Polling temporaneo (sarà sostituito con WebSocket)
  void _startPolling(String conversationId) {
    Timer.periodic(Duration(milliseconds: 500), (timer) async {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/multi-agent/conversation/$conversationId'),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          _streamControllers[conversationId]?.add(data);
        }
      } catch (e) {
        // Ignora errori temporanei durante il polling
      }
    });
  }

  // Chiudi tutti gli stream
  void dispose() {
    for (var controller in _streamControllers.values) {
      controller.close();
    }
    _streamControllers.clear();
    super.dispose();
  }
}