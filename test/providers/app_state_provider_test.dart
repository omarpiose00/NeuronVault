import 'package:flutter_test/flutter_test.dart';
import 'package:multi_ai_flutter/providers/app_state_provider.dart';

void main() {
  test('initial state is correct', () {
    final appState = AppStateProvider();
    expect(appState.isInitialSetupComplete, isFalse);
    expect(appState.isBackendRunning, isFalse);
    expect(appState.currentConversationId, '');
    expect(appState.isProcessing, isFalse);
    expect(appState.modelWeights, AppStateProvider.presets['balanced']);
  });

  test('markInitialSetupComplete sets isInitialSetupComplete to true', () {
    final appState = AppStateProvider();
    appState.markInitialSetupComplete();
    expect(appState.isInitialSetupComplete, isTrue);
  });

  test('setBackendStatus updates isBackendRunning', () {
    final appState = AppStateProvider();
    appState.setBackendStatus(true);
    expect(appState.isBackendRunning, isTrue);
  });

  test('startNewConversation generates a new conversationId', () {
    final appState = AppStateProvider();
    final oldConversationId = appState.currentConversationId;
    appState.startNewConversation();
    expect(appState.currentConversationId, isNot(oldConversationId));
  });

  test('setProcessing updates isProcessing', () {
    final appState = AppStateProvider();
    appState.setProcessing(true);
    expect(appState.isProcessing, isTrue);
  });

  test('updateModelWeight updates the weight for the given model', () {
    final appState = AppStateProvider();
    appState.updateModelWeight('gpt', 1.5);
    expect(appState.modelWeights['gpt'], 1.5);
  });

  test('resetModelWeights resets all weights to 1.0', () {
    final appState = AppStateProvider();
    appState.updateModelWeight('gpt', 1.5);
    appState.resetModelWeights();
    expect(appState.modelWeights['gpt'], 1.0);
  });

  test('applyPresetWeights applies the given preset weights', () {
    final appState = AppStateProvider();
    appState.applyPresetWeights(AppStateProvider.presets['creative']!);
    expect(appState.modelWeights, AppStateProvider.presets['creative']);
  });

  test('getNormalizedWeight returns the normalized weight for the given model', () {
    final appState = AppStateProvider();
    appState.updateModelWeight('gpt', 1.5);
    expect(appState.getNormalizedWeight('gpt'), 0.75);
  });

  test('setNormalizedWeight sets the weight from a normalized value', () {
    final appState = AppStateProvider();
    appState.setNormalizedWeight('gpt', 0.75);
    expect(appState.modelWeights['gpt'], 1.5);
  });
}