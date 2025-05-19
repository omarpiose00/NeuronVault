// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/ai_agent.dart';

class AiConversationMessage {
  final String agent; // "user", "claude", "gpt", "deepseek", "system"
  final String message;
  final DateTime timestamp;
  final String? mediaUrl;
  final String? mediaType;

  AiConversationMessage({
    required this.agent,
    required this.message,
    this.mediaUrl,
    this.mediaType,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory AiConversationMessage.fromJson(Map<String, dynamic> json) {
    return AiConversationMessage(
      agent: json['agent'] ?? '',
      message: json['message'] ?? '',
      mediaUrl: json['mediaUrl'],
      mediaType: json['mediaType'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'agent': agent,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    if (mediaUrl != null) 'mediaUrl': mediaUrl,
    if (mediaType != null) 'mediaType': mediaType,
  };

  AiAgent? toAiAgent() {
    switch (agent) {
      case "claude": return AiAgent.claude;
      case "gpt": return AiAgent.gpt;
      case "deepseek": return AiAgent.deepseek;
      default: return null;
    }
  }
}

class AiServiceResponse {
  final List<AiConversationMessage> conversation;

  AiServiceResponse({required this.conversation});

  factory AiServiceResponse.fromJson(Map<String, dynamic> json) {
    final conversationJson = json['conversation'] as List;
    return AiServiceResponse(
      conversation: conversationJson
          .map((msgJson) => AiConversationMessage.fromJson(msgJson))
          .toList(),
    );
  }
}

enum ConversationMode {
  chat, debate, brainstorm
}

class ApiService {
  static const String backendUrl = 'http://localhost:4000';

  static Future<AiServiceResponse> askAgents(
      String prompt, {
        String conversationId = 'default',
        ConversationMode mode = ConversationMode.chat
      }) async {
    final response = await http.post(
      Uri.parse('$backendUrl/multi-agent'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'prompt': prompt,
        'conversationId': conversationId,
        'mode': mode.toString().split('.').last,
      }),
    );

    if (response.statusCode == 200) {
      return AiServiceResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Errore AI: ${response.body}');
    }
  }

  static Future<AiServiceResponse> uploadImage(
      String prompt,
      File imageFile, {
        String conversationId = 'default',
      }) async {
    var request = http.MultipartRequest(
        'POST',
        Uri.parse('$backendUrl/multi-agent/image')
    );

    request.fields['prompt'] = prompt;
    request.fields['conversationId'] = conversationId;
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
    ));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return AiServiceResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Errore caricamento immagine: ${response.body}');
    }
  }
}