// lib/widgets/message_input.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'photo_input_button.dart';
import 'voice_input_button.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;
  final Function(XFile) onPhotoSelected;
  final bool isLoading;
  final String hintText;

  const MessageInput({
    Key? key,
    required this.controller,
    required this.onSubmitted,
    required this.onPhotoSelected,
    this.isLoading = false,
    this.hintText = 'Scrivi un messaggio...',
  }) : super(key: key);

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> with SingleTickerProviderStateMixin {
  bool _isListening = false;
  late AnimationController _sendButtonController;
  late Animation<double> _sendButtonAnimation;

  @override
  void initState() {
    super.initState();

    _sendButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _sendButtonAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _sendButtonController,
        curve: Curves.easeInOut,
      ),
    );

    widget.controller.addListener(_updateSendButtonAnimation);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateSendButtonAnimation);
    _sendButtonController.dispose();
    super.dispose();
  }

  void _updateSendButtonAnimation() {
    if (widget.controller.text.isNotEmpty) {
      _sendButtonController.forward();
    } else {
      _sendButtonController.reverse();
    }
  }

  void _handleSubmit() {
    final text = widget.controller.text.trim();
    if (text.isNotEmpty && !widget.isLoading) {
      widget.onSubmitted(text);
    }
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
    });
  }

  void _onTextRecognized(String recognizedText) {
    widget.controller.text = recognizedText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Pulsante per selezionare foto
          PhotoInputButton(
            onPhotoSelected: widget.onPhotoSelected,
            isLoading: widget.isLoading,
          ),
          const SizedBox(width: 12),

          // Campo di testo
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: widget.controller,
                enabled: !widget.isLoading,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                maxLines: 3,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSubmit(),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Pulsante input vocale
          VoiceInputButton(
            onTextRecognized: _onTextRecognized,
            isListening: _isListening,
            onListeningChanged: _toggleListening,
          ),
          const SizedBox(width: 12),

          // Pulsante invia
          AnimatedBuilder(
            animation: _sendButtonController,
            builder: (context, child) {
              return Transform.scale(
                scale: _sendButtonAnimation.value,
                child: GestureDetector(
                  onTap: _handleSubmit,
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: widget.controller.text.trim().isEmpty || widget.isLoading
                          ? theme.colorScheme.primary.withOpacity(0.5)
                          : theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: widget.controller.text.trim().isEmpty || widget.isLoading
                          ? []
                          : [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.send,
                      color: theme.colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}