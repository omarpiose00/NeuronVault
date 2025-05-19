// lib/widgets/voice_input_button.dart
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceInputButton extends StatefulWidget {
  final Function(String) onTextRecognized;
  final bool isListening;
  final VoidCallback onListeningChanged;

  const VoiceInputButton({
    Key? key,
    required this.onTextRecognized,
    required this.isListening,
    required this.onListeningChanged,
  }) : super(key: key);

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> with SingleTickerProviderStateMixin {
  final SpeechToText _speechToText = SpeechToText();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initSpeech();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isListening) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(VoiceInputButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening != oldWidget.isListening) {
      if (widget.isListening) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _initSpeech() async {
    await _speechToText.initialize();
  }

  void _startListening() async {
    widget.onListeningChanged();

    if (widget.isListening) {
      bool available = await _speechToText.initialize(
        onStatus: (status) {
          if (status == 'done') {
            widget.onListeningChanged();
          }
        },
        onError: (errorNotification) {
          widget.onListeningChanged();
        },
      );

      if (available) {
        _speechToText.listen(
          onResult: (result) {
            widget.onTextRecognized(result.recognizedWords);
          },
        );
      }
    } else {
      _speechToText.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: _startListening,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isListening ? _pulseAnimation.value : 1.0,
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: widget.isListening
                    ? Colors.red.withOpacity(0.8)
                    : (isDark
                    ? theme.colorScheme.secondaryContainer.withOpacity(0.5)
                    : theme.colorScheme.secondaryContainer),
                borderRadius: BorderRadius.circular(20),
                boxShadow: widget.isListening
                    ? [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
                    : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                widget.isListening ? Icons.mic : Icons.mic_none,
                color: widget.isListening
                    ? Colors.white
                    : theme.colorScheme.onSecondaryContainer,
                size: 20,
              ),
            ),
          );
        },
      ),
    );
  }
}