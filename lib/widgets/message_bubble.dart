// Nuovo widget: multimodal_message_bubble.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/ai_agent.dart';

class MultimodalMessageBubble extends StatelessWidget {
  final AiAgent? agent;
  final String text;
  final bool selectable;
  final String? mediaUrl;
  final String? mediaType;
  final bool isThinking;

  const MultimodalMessageBubble({
    super.key,
    this.agent,
    required this.text,
    this.selectable = false,
    this.mediaUrl,
    this.mediaType,
    this.isThinking = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;

    // Determina il colore in base all'agente
    if (agent == null) {
      // Messaggio utente
      bg = Theme.of(context).colorScheme.primaryContainer;
    } else {
      switch (agent) {
        case AiAgent.claude:
          bg = const Color(0xFFE0BBE4);
          break;
        case AiAgent.gpt:
          bg = const Color(0xFFB2DFDB);
          break;
        case AiAgent.deepseek:
          bg = const Color(0xFFFFF59D);
          break;
        default:
          bg = Colors.grey.shade200;
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  agent == null ? '👤' : _agentAvatar(agent!),
                  style: const TextStyle(fontSize: 22)
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mostra nome dell'agente
                    if (agent != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          agentName(agent!),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),

                    // Indicatore "sta scrivendo..."
                    if (isThinking)
                      _buildThinkingIndicator(),

                    // Mostra contenuto multimediale se presente
                    if (mediaUrl != null && mediaType != null)
                      _buildMediaContent(),

                    // Mostra testo con supporto markdown
                    if (selectable)
                      Markdown(
                        data: text,
                        selectable: true,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                      )
                    else
                      Markdown(
                        data: text,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThinkingIndicator() {
    return Row(
      children: [
        Text("Sta pensando", style: TextStyle(fontStyle: FontStyle.italic)),
        SizedBox(width: 10),
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ],
    );
  }

  Widget _buildMediaContent() {
    if (mediaType?.startsWith('image/') == true) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          mediaUrl!,
          height: 200,
          fit: BoxFit.cover,
        ),
      );
    } else if (mediaType?.startsWith('audio/') == true) {
      // Widget per riprodurre audio
      return Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.play_arrow),
              onPressed: () {
                // Implementa la riproduzione audio
              },
            ),
            Expanded(
              child: Text("Audio recording"),
            ),
          ],
        ),
      );
    }
    return SizedBox.shrink();
  }

  String _agentAvatar(AiAgent agent) {
    switch (agent) {
      case AiAgent.claude:
        return '🧠';
      case AiAgent.gpt:
        return '🤖';
      case AiAgent.deepseek:
        return '💻';
    }
  }
}