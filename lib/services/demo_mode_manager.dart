// lib/services/demo_mode_manager.dart - Gestione centralizzata modalità demo
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class DemoModeManager extends ChangeNotifier {
  static DemoModeManager? _instance;
  static DemoModeManager get instance => _instance ??= DemoModeManager._internal();

  DemoModeManager._internal();

  bool _isDemoMode = true;
  bool _showDemoToggle = true;
  bool _isInitialized = false;

  bool get isDemoMode => _isDemoMode;
  bool get showDemoToggle => _showDemoToggle;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _isDemoMode = prefs.getBool('demo_mode') ?? true;
      _showDemoToggle = prefs.getBool('show_demo_toggle') ?? true;

      // Sincronizza con ApiService
      ApiService.useMockData = _isDemoMode;

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing DemoModeManager: $e');
    }
  }

  Future<void> setDemoMode(bool enabled, {bool savePreference = true}) async {
    if (_isDemoMode == enabled) return;

    _isDemoMode = enabled;
    ApiService.useMockData = enabled;

    if (savePreference) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('demo_mode', enabled);
      } catch (e) {
        debugPrint('Error saving demo mode preference: $e');
      }
    }

    notifyListeners();
  }

  Future<void> toggleDemoMode() async {
    await setDemoMode(!_isDemoMode);
  }

  Future<void> setShowDemoToggle(bool show) async {
    if (_showDemoToggle == show) return;

    _showDemoToggle = show;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('show_demo_toggle', show);
    } catch (e) {
      debugPrint('Error saving demo toggle preference: $e');
    }

    notifyListeners();
  }

  String get statusText => _isDemoMode ? 'Modalità Demo' : 'Modalità Live';
  IconData get statusIcon => _isDemoMode ? Icons.science : Icons.cloud;
  Color get statusColor => _isDemoMode ? Colors.orange : Colors.green;

  // Metodi di utilità per i widget
  Widget buildDemoIndicator(BuildContext context, {bool compact = false}) {
    if (!_isDemoMode) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 4 : 6
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(compact ? 12 : 16),
        border: Border.all(color: statusColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
              statusIcon,
              size: compact ? 14 : 16,
              color: statusColor
          ),
          if (!compact) ...[
            const SizedBox(width: 6),
            Text(
              statusText,
              style: TextStyle(
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildDemoToggle(BuildContext context) {
    if (!_showDemoToggle) return const SizedBox.shrink();

    return SwitchListTile(
      title: const Text('Modalità Demo'),
      subtitle: Text(_isDemoMode
          ? 'Usa risposte simulate per testare l\'app'
          : 'Usa le API reali dei modelli AI'),
      value: _isDemoMode,
      onChanged: (value) => setDemoMode(value),
      secondary: Icon(statusIcon, color: statusColor),
    );
  }
}