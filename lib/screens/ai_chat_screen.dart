// Aggiornamento di ai_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:io';
import '../models/ai_agent.dart';
import '../services/api_service.dart';
import '../widgets/multimodal_message_bubble.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final SpeechToText _speechToText = SpeechToText();
  bool _isLoading = false;
  bool _isListening = false;
  List<AiConversationMessage> _conversation = [];
  String _conversationId = DateTime.now().millisecondsSinceEpoch.toString();
  ConversationMode _currentMode = ConversationMode.chat;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize(
        onStatus: (status) {
          if (status == 'done') {
            setState(() {
              _isListening = false;
            });
          }
        },
        onError: (errorNotification) {
          setState(() {
            _isListening = false;
          });
        },
      );

      if (available) {
        setState(() {
          _isListening = true;
        });
        _speechToText.listen(
          onResult: (result) {
            setState(() {
              _controller.text = result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() {
        _isListening = false;
        _speechToText.stop();
      });
    }
  }

  void _sendPrompt() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _isLoading = true;
      // Aggiungiamo il messaggio dell'utente subito
      _conversation.add(AiConversationMessage(agent: 'user', message: prompt));
      _controller.clear();
    });

    try {
      final aiResp = await ApiService.askAgents(
        prompt,
        conversationId: _conversationId,
        mode: _currentMode,
      );
      setState(() {
        _conversation = aiResp.conversation;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _conversation.add(AiConversationMessage(agent: 'system', message: 'Errore: $e'));
        _isLoading = false;
      });
    }
  }

  void _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      String prompt = _controller.text.trim().isEmpty
          ? "Descrivi questa immagine"
          : _controller.text.trim();

      setState(() {
        _isLoading = true;
        _conversation.add(AiConversationMessage(
          agent: 'user',
          message: prompt,
          mediaUrl: image.path,
          mediaType: 'image/jpeg',
        ));
        _controller.clear();
      });

      try {
        final aiResp = await ApiService.uploadImage(
          prompt,
          File(image.path),
          conversationId: _conversationId,
        );
        setState(() {
          _conversation = aiResp.conversation;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _conversation.add(AiConversationMessage(agent: 'system', message: 'Errore: $e'));
          _isLoading = false;
        });
      }
    }
  }

  void _resetChat() {
    setState(() {
      _conversation.clear();
      _controller.clear();
      _conversationId = DateTime.now().millisecondsSinceEpoch.toString();
    });
  }

  void _changeMode(ConversationMode mode) {
    setState(() {
      _currentMode = mode;
    });

    // Mostra un messaggio che spiega la modalità
    String modeExplanation = "";
    switch(mode) {
      case ConversationMode.chat:
        modeExplanation = "Modalità Chat: Le AI risponderanno normalmente alle tue domande, una dopo l'altra.";
        break;
      case ConversationMode.debate:
        modeExplanation = "Modalità Dibattito: Le AI discuteranno il tema proposto, ciascuna offrendo un punto di vista diverso.";
        break;
      case ConversationMode.brainstorm:
        modeExplanation = "Modalità Brainstorming: Le AI collaboreranno per generare idee creative sul tema proposto.";
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(modeExplanation))
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Team Conversation'),
        backgroundColor: theme.colorScheme.primaryContainer,
        elevation: 0,
        actions: [
          PopupMenuButton<ConversationMode>(
            icon: Icon(Icons.mode_edit),
            onSelected: _changeMode,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: ConversationMode.chat,
                child: Text('Modalità Chat'),
              ),
              PopupMenuItem(
                value: ConversationMode.debate,
                child: Text('Modalità Dibattito'),
              ),
              PopupMenuItem(
                value: ConversationMode.brainstorm,
                child: Text('Modalità Brainstorming'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetChat,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Column(
            children: [
              Expanded(
                child: _conversation.isEmpty && !_isLoading
                    ? Center(
                  child: Text(
                    'Scrivi una richiesta per iniziare una conversazione tra le AI!',
                    style: GoogleFonts.montserrat(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: _conversation.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, i) {
                    // Mostra il spinner di caricamento come ultimo elemento se isLoading
                    if (_isLoading && i == _conversation.length) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 8),
                              Text("Le AI stanno pensando..."),
                            ],
                          ),
                        ),
                      );
                    }

                    final message = _conversation[i];
                    final aiAgent = message.toAiAgent();

                    return MultimodalMessageBubble(
                      agent: aiAgent,
                      text: message.message,
                      selectable: true,
                      mediaUrl: message.mediaUrl,
                      mediaType: message.mediaType,
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                color: theme.colorScheme.surface,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            enabled: !_isLoading,
                            decoration: InputDecoration(
                              hintText: 'Chiedi qualcosa al team AI...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            onSubmitted: (_) => _sendPrompt(),
                            maxLines: 3,
                            minLines: 1,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(Icons.image),
                          color: theme.colorScheme.secondary,
                          onPressed: _isLoading ? null : _pickImage,
                          tooltip: 'Allega immagine',
                        ),
                        IconButton(
                          icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                          color: _isListening ? Colors.red : theme.colorScheme.secondary,
                          onPressed: _isLoading ? null : _startListening,
                          tooltip: 'Input vocale',
                        ),
                        IconButton(
                          icon: Icon(Icons.send),
                          color: theme.colorScheme.primary,
                          onPressed: _isLoading ? null : _sendPrompt,
                          tooltip: 'Invia messaggio',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}