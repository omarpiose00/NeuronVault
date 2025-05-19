// lib/widgets/widget_manager.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Import models
import '../models/ai_agent.dart';
import '../models/conversation_mode.dart';  // Import corretto aggiunto

// Import UI widgets
import 'ui/glass_container.dart';
import 'ui/animated_button.dart';
import 'ui/shimmer_loading.dart';
import 'ui/dynamic_background.dart';
import 'ui/animated_app_bar.dart';
import 'ui/welcome_placeholder.dart';
import 'ui/mode_selector.dart';
import 'ui/agent_chip.dart';

// Import messaging widgets
import 'messaging/typing_indicator.dart';
import 'messaging/error_message_widget.dart';
import 'messaging/multimodal_message_bubble.dart';  // Corretto al nome del file esistente

// Import input widgets
import 'input/message_input.dart';
import 'input/photo_input_button.dart';
import 'input/voice_input_button.dart';

// Import utils
import 'utils/markdown_renderer.dart';
import 'utils/micro_animations.dart';

/// UIWidgets è un gestore centralizzato per tutti i widget personalizzati dell'app
/// Fornisce un accesso semplificato ai componenti dell'interfaccia utente
/// con configurazioni predefinite coerenti con il design system
class UIWidgets {
  // Implementazione Singleton
  static final UIWidgets _instance = UIWidgets._internal();
  factory UIWidgets() => _instance;
  UIWidgets._internal();

  //
  // SEZIONE 1: WIDGET UI
  //

  /// Restituisce un contenitore con effetto glassmorphism
  Widget glass({
    required Widget child,
    double borderRadius = 16,
    Color? backgroundColor,
    Color? borderColor,
    double blur = 10,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    EdgeInsetsGeometry margin = EdgeInsets.zero,
    double? width,
    double? height,
    BoxBorder? border,
  }) {
    return GlassContainer(
      child: child,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      blur: blur,
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      border: border,
    );
  }

  /// Restituisce un pulsante animato
  Widget button({
    required VoidCallback onPressed,
    required Widget child,
    Color? backgroundColor,
    Color? splashColor,
    double borderRadius = 12.0,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    bool isEnabled = true,
  }) {
    return AnimatedButton(
      onPressed: onPressed,
      child: child,
      backgroundColor: backgroundColor,
      splashColor: splashColor,
      borderRadius: borderRadius,
      padding: padding,
      isEnabled: isEnabled,
    );
  }

  /// Restituisce un effetto shimmer durante il caricamento
  Widget shimmer({
    required Widget child,
    required bool isLoading,
    Color baseColor = const Color(0xFFE0E0E0),
    Color highlightColor = const Color(0xFFF5F5F5),
  }) {
    return ShimmerLoading(
      child: child,
      isLoading: isLoading,
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
  }

  /// Restituisce uno sfondo dinamico
  Widget dynamicBackground({
    required Widget child,
  }) {
    return DynamicBackground(
      child: child,
    );
  }

  /// Restituisce un'app bar animata
  Widget appBar({
    required String title,
    required ConversationMode currentMode,
    required Function(ConversationMode) onModeChanged,
    required VoidCallback onResetChat,
    bool isScrolled = false,
  }) {
    return AnimatedAppBar(
      title: title,
      currentMode: currentMode,
      onModeChanged: onModeChanged,
      onResetChat: onResetChat,
      isScrolled: isScrolled,
    );
  }

  /// Restituisce un placeholder di benvenuto
  Widget welcomePlaceholder({
    required ConversationMode mode,
    VoidCallback? onTap,
  }) {
    return WelcomePlaceholder(
      mode: mode,
      onTap: onTap,
    );
  }

  /// Restituisce un selettore di modalità
  Widget modeSelector({
    required ConversationMode currentMode,
    required Function(ConversationMode) onModeChanged,
  }) {
    return ModeSelector(
      currentMode: currentMode,
      onModeChanged: onModeChanged,
    );
  }

  /// Restituisce un chip per un agente AI
  Widget agentChip({
    required AiAgent agent,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return AgentChip(
      agent: agent,
      isActive: isActive,
      onTap: onTap,
    );
  }

  //
  // SEZIONE 2: WIDGET DI MESSAGGISTICA
  //

  /// Restituisce un indicatore di digitazione
  Widget typingIndicator({
    Color dotColor = Colors.grey,
    String text = "Sta scrivendo",
  }) {
    return TypingIndicator(
      dotColor: dotColor,
      text: text,
    );
  }

  /// Restituisce un messaggio di errore
  Widget errorMessage({
    required String errorMessage,
    VoidCallback? onRetry,
  }) {
    return ErrorMessageWidget(
      errorMessage: errorMessage,
      onRetry: onRetry,
    );
  }

  /// Restituisce una bolla di messaggio multimodale
  Widget messageBubble({
    AiAgent? agent,
    required String text,
    bool selectable = false,
    String? mediaUrl,
    String? mediaType,
    bool isThinking = false,
    DateTime? timestamp,
  }) {
    return MultimodalMessageBubble(
      agent: agent,
      text: text,
      selectable: selectable,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      isThinking: isThinking,
      timestamp: timestamp,
    );
  }

  //
  // SEZIONE 3: WIDGET DI INPUT
  //

  /// Restituisce un campo di input completo
  Widget messageInput({
    required TextEditingController controller,
    required Function(String) onSubmitted,
    required Function(XFile) onPhotoSelected,
    bool isLoading = false,
    String hintText = 'Scrivi un messaggio...',
    // Rimuovo i parametri che non sono definiti
    // Color? primaryColor,
    // VoidCallback? onTypingStarted,
  }) {
    return MessageInput(
      controller: controller,
      onSubmitted: onSubmitted,
      onPhotoSelected: onPhotoSelected,
      isLoading: isLoading,
      hintText: hintText,
      // primaryColor: primaryColor,
      // onTypingStarted: onTypingStarted,
    );
  }

  /// Restituisce un pulsante per selezionare foto
  Widget photoButton({
    required Function(XFile) onPhotoSelected,
    bool isLoading = false,
    ImageSource source = ImageSource.gallery,
  }) {
    return PhotoInputButton(
      onPhotoSelected: onPhotoSelected,
      isLoading: isLoading,
      source: source,
    );
  }

  /// Restituisce un pulsante per input vocale
  Widget voiceButton({
    required Function(String) onTextRecognized,
    required bool isListening,
    required VoidCallback onListeningChanged,
  }) {
    return VoiceInputButton(
      onTextRecognized: onTextRecognized,
      isListening: isListening,
      onListeningChanged: onListeningChanged,
    );
  }

  //
  // SEZIONE 4: WIDGET DI UTILITÀ
  //

  /// Restituisce un renderer markdown
  Widget markdown({
    required String data,
    bool selectable = false,
  }) {
    return AiMarkdownRenderer(
      data: data,
      selectable: selectable,
    );
  }

  /// Crea un'animazione di pulsazione
  Widget pulse({
    required Widget child,
    required bool isActive,
    double maxScale = 1.15,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return MicroAnimations.pulse(
      child: child,
      isActive: isActive,
      maxScale: maxScale,
      duration: duration,
    );
  }

  /// Crea un effetto di hover
  Widget hover({
    required Widget child,
    required bool isHovering,
    double elevation = 4.0,
    Duration duration = const Duration(milliseconds: 200),
  }) {
    return MicroAnimations.hover(
      child: child,
      isHovering: isHovering,
      elevation: elevation,
      duration: duration,
    );
  }

  /// Crea un'animazione di espansione
  Widget expand({
    required Widget child,
    required bool isExpanded,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return MicroAnimations.expand(
      child: child,
      isExpanded: isExpanded,
      duration: duration,
    );
  }

  /// Crea un effetto di ripple
  Widget ripple({
    required Widget child,
    required bool triggerRipple,
    Duration duration = const Duration(milliseconds: 700),
    Color rippleColor = Colors.white,
  }) {
    return MicroAnimations.ripple(
      child: child,
      triggerRipple: triggerRipple,
      duration: duration,
      rippleColor: rippleColor,
    );
  }
}

/// Estensione globale per accedere facilmente ai widget
extension BuildContextExtension on BuildContext {
  UIWidgets get ui => UIWidgets();
}