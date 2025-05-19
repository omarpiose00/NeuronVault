// lib/widgets/multimodal_message_bubble.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:io';
import '../models/ai_agent.dart';
import 'markdown_renderer.dart';

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
    // Determina il colore di sfondo in base all'agente
    Color bg;

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
              // Avatar dell'agente
              Text(
                  agent == null ? '👤' : _agentAvatar(agent!),
                  style: const TextStyle(fontSize: 22)
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome dell'agente
                    if (agent != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          agentName(agent!),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                    // Indicatore di "sta pensando..."
                    if (isThinking)
                      _buildThinkingIndicator(),

                    // Contenuto multimediale (immagine, audio, ecc.)
                    if (mediaUrl != null && mediaType != null)
                      _buildMediaContent(context),

                    // Testo con supporto markdown
                    const SizedBox(height: 8),

                    selectable
                        ? AiMarkdownRenderer(
                      data: text,
                      selectable: true,
                    )
                        : AiMarkdownRenderer(
                      data: text,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Pulsanti di azione (rispondi, copia, ecc.)
          if (agent != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionButton(
                    icon: Icons.content_copy,
                    tooltip: 'Copia testo',
                    onTap: () {
                      // Implementa la funzionalità di copia
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.reply,
                    tooltip: 'Rispondi',
                    onTap: () {
                      // Implementa la funzionalità di risposta
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThinkingIndicator() {
    return Row(
      children: [
        const Text("Sta pensando", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
        const SizedBox(width: 10),
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ],
    );
  }

  Widget _buildMediaContent(BuildContext context) {
    if (mediaUrl == null) return const SizedBox.shrink();

    // Immagine da URL
    if (mediaType?.startsWith('image/') == true) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: mediaUrl!.startsWith('http')
                ? Image.network(
              mediaUrl!,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
              const Text('Impossibile caricare l\'immagine'),
            )
                : Image.file(
              File(mediaUrl!),
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
              const Text('Impossibile caricare l\'immagine'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    }
    // Contenuto audio
    else if (mediaType?.startsWith('audio/') == true) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () {
                // Implementa la logica di riproduzione audio
              },
            ),
            const Expanded(
              child: Text("Registrazione audio"),
            ),
          ],
        ),
      );
    }

    // Tipo di media non supportato
    return const SizedBox.shrink();
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Tooltip(
          message: tooltip,
          child: Icon(
            icon,
            size: 18,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
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