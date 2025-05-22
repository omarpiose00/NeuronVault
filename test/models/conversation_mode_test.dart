import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_ai_flutter/models/conversation_mode.dart';

void main() {
  test('ConversationMode displayName returns correct name', () {
    expect(ConversationMode.chat.displayName, 'Chat');
    expect(ConversationMode.debate.displayName, 'Dibattito');
    expect(ConversationMode.brainstorm.displayName, 'Brainstorming');
  });

  test('ConversationMode description returns correct description', () {
    expect(ConversationMode.chat.description, "Le AI rispondono una dopo l'altra alle tue domande");
    expect(ConversationMode.debate.description, 'Le AI discutono il tema proposto, ciascuna offrendo un punto di vista diverso');
    expect(ConversationMode.brainstorm.description, 'Le AI collaborano per generare idee creative sul tema proposto');
  });

  test('ConversationMode icon returns correct icon', () {
    expect(ConversationMode.chat.icon, Icons.chat_bubble_outline);
    expect(ConversationMode.debate.icon, Icons.compare_arrows);
    expect(ConversationMode.brainstorm.icon, Icons.lightbulb_outline);
  });

  // Add more tests for placeholderText and welcomeMessage
}