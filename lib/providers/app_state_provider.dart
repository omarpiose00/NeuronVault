import 'package:flutter/material.dart';

class AppStateProvider extends ChangeNotifier {
  // Stato dell'applicazione
  bool _isInitialSetupComplete = false;
  bool _isBackendRunning = false;
  String _currentConversationId = '';
  bool _isProcessing = false;

  // Getter
  bool get isInitialSetupComplete => _isInitialSetupComplete;
  bool get isBackendRunning => _isBackendRunning;
  String get currentConversationId => _currentConversationId;
  bool get isProcessing => _isProcessing;

  // Setter
  void markInitialSetupComplete() {
    _isInitialSetupComplete = true;
    notifyListeners();
  }

  void setBackendStatus(bool isRunning) {
    _isBackendRunning = isRunning;
    notifyListeners();
  }

  void startNewConversation() {
    _currentConversationId = DateTime.now().millisecondsSinceEpoch.toString();
    notifyListeners();
  }

  void setProcessing(bool isProcessing) {
    _isProcessing = isProcessing;
    notifyListeners();
  }
}