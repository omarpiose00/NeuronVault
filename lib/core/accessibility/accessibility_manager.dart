// lib/core/accessibility/accessibility_manager.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 🧸 ACCESSIBILITY MANAGER - Sistema centralizzato di accessibilità
/// Gestisce focus, keyboard shortcuts, screen reader e high contrast
class AccessibilityManager {
  static final AccessibilityManager _instance = AccessibilityManager._internal();
  factory AccessibilityManager() => _instance;
  AccessibilityManager._internal();

  // Focus Management
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  FocusNode? _currentFocus;

  // State Management
  bool _isHighContrastMode = false;
  bool _isScreenReaderEnabled = false;
  final List<VoidCallback> _screenReaderListeners = [];

  // Getters
  bool get isHighContrastMode => _isHighContrastMode;
  bool get isScreenReaderEnabled => _isScreenReaderEnabled;
  BuildContext? get currentContext => navigatorKey.currentContext;

  /// 🎯 Initialize Accessibility System
  Future<void> initialize() async {
    await _setupKeyboardShortcuts();
    _detectScreenReaderStatus();
  }

  /// ⌨️ Setup Global Keyboard Shortcuts
  Future<void> _setupKeyboardShortcuts() async {
    // Global shortcuts will be handled by individual widgets
    // This is a placeholder for system-wide shortcuts
  }

  /// 👁️ Detect Screen Reader Status
  void _detectScreenReaderStatus() {
    // Flutter automatically detects screen readers
    _isScreenReaderEnabled = WidgetsBinding.instance.accessibilityFeatures.accessibleNavigation;
  }

  /// 🔄 Toggle High Contrast Mode
  void toggleHighContrast() {
    _isHighContrastMode = !_isHighContrastMode;
    _notifyScreenReader('High contrast mode ${_isHighContrastMode ? 'enabled' : 'disabled'}');
  }

  /// 🔊 Screen Reader Announcements
  void announce(String message, {bool assertive = false}) {
    if (currentContext != null) {
      // Create a temporary live region for announcements
      final overlay = Overlay.of(currentContext!);
      final overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: -100, // Off-screen
          child: Semantics(
            liveRegion: true,
            child: Text(
              message,
              style: const TextStyle(fontSize: 0), // Invisible but readable by screen readers
            ),
          ),
        ),
      );

      overlay.insert(overlayEntry);

      // Remove after a short delay
      Future.delayed(const Duration(milliseconds: 100), () {
        overlayEntry.remove();
      });
    }
  }

  /// 🎙️ Notify Screen Reader
  void _notifyScreenReader(String message) {
    for (final listener in _screenReaderListeners) {
      listener();
    }
    // Provide haptic feedback as alternative to audio announcement
    HapticFeedback.lightImpact();
    announce(message);
  }

  /// 🎯 Focus Management
  void requestFocus(FocusNode focusNode) {
    _currentFocus = focusNode;
    focusNode.requestFocus();
  }

  /// 🔄 Focus Navigation
  void focusNext() {
    if (currentContext != null) {
      FocusScope.of(currentContext!).nextFocus();
    }
  }

  void focusPrevious() {
    if (currentContext != null) {
      FocusScope.of(currentContext!).previousFocus();
    }
  }

  /// 🧸 Add Screen Reader Listener
  void addScreenReaderListener(VoidCallback listener) {
    _screenReaderListeners.add(listener);
  }

  /// 🗑️ Remove Screen Reader Listener
  void removeScreenReaderListener(VoidCallback listener) {
    _screenReaderListeners.remove(listener);
  }

  /// 🧹 Dispose
  void dispose() {
    _screenReaderListeners.clear();
    _currentFocus?.dispose();
  }
}

/// 🎭 ACCESSIBLE WIDGET WRAPPER
/// Widget wrapper che aggiunge supporto accessibilità completo
class AccessibleWidget extends StatelessWidget {
  final Widget child;
  final String? semanticLabel;
  final String? semanticHint;
  final bool excludeSemantics;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final FocusNode? focusNode;
  final bool autofocus;
  final Map<ShortcutActivator, Intent>? shortcuts;

  const AccessibleWidget({
    super.key,
    required this.child,
    this.semanticLabel,
    this.semanticHint,
    this.excludeSemantics = false,
    this.onTap,
    this.onLongPress,
    this.focusNode,
    this.autofocus = false,
    this.shortcuts,
  });

  @override
  Widget build(BuildContext context) {
    Widget widget = child;

    // Add keyboard shortcuts se forniti
    if (shortcuts != null && shortcuts!.isNotEmpty) {
      widget = Shortcuts(
        shortcuts: shortcuts!,
        child: widget,
      );
    }

    // Add gesture detection se forniti
    if (onTap != null || onLongPress != null) {
      widget = GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: widget,
      );
    }

    // Add focus SOLO se necessario (evita nesting)
    if (focusNode != null && widget is! Focus) {
      widget = Focus(
        focusNode: focusNode,
        autofocus: autofocus,
        child: widget,
      );
    }

    // Add semantics se non esclusi
    if (!excludeSemantics) {
      widget = Semantics(
        label: semanticLabel,
        hint: semanticHint,
        button: onTap != null,
        focusable: focusNode != null || onTap != null,
        child: widget,
      );
    }

    return widget;
  }
}

/// 🎯 MODERN INTENTS FOR SHORTCUTS
/// Intent system for modern Flutter shortcuts
class ToggleHighContrastIntent extends Intent {
  const ToggleHighContrastIntent();
}

class ShowHelpIntent extends Intent {
  const ShowHelpIntent();
}

class ToggleStrategyIntent extends Intent {
  const ToggleStrategyIntent();
}

class ToggleConnectionIntent extends Intent {
  const ToggleConnectionIntent();
}

/// ⌨️ KEYBOARD SHORTCUTS MANAGER
/// Gestisce gli shortcuts globali dell'applicazione con Intent system moderno
class KeyboardShortcutsManager {
  static const Map<ShortcutActivator, Intent> globalShortcuts = {
    SingleActivator(LogicalKeyboardKey.keyH, control: true): ToggleHighContrastIntent(),
    SingleActivator(LogicalKeyboardKey.f1): ShowHelpIntent(),
    SingleActivator(LogicalKeyboardKey.keyS, control: true, shift: true): ToggleStrategyIntent(),
    SingleActivator(LogicalKeyboardKey.keyC, control: true, shift: true): ToggleConnectionIntent(),
  };

  static Map<Type, Action<Intent>> getActions(BuildContext context) {
    return {
      ToggleHighContrastIntent: CallbackAction<ToggleHighContrastIntent>(
        onInvoke: (intent) {
          AccessibilityManager().toggleHighContrast();
          return null;
        },
      ),
      ShowHelpIntent: CallbackAction<ShowHelpIntent>(
        onInvoke: (intent) {
          _showHelpDialog(context);
          return null;
        },
      ),
      ToggleStrategyIntent: CallbackAction<ToggleStrategyIntent>(
        onInvoke: (intent) {
          AccessibilityManager().announce('Strategy selector focused');
          return null;
        },
      ),
      ToggleConnectionIntent: CallbackAction<ToggleConnectionIntent>(
        onInvoke: (intent) {
          AccessibilityManager().announce('Connection status toggled');
          return null;
        },
      ),
    };
  }

  static void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keyboard Shortcuts'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ctrl+H: Toggle High Contrast'),
            Text('F1: Show Help'),
            Text('Ctrl+Shift+S: Focus Strategy Selector'),
            Text('Ctrl+Shift+C: Toggle Connection'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}