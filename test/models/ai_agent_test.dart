import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_ai_flutter/models/ai_agent.dart';

void main() {
  test('agentName returns correct name for each AiAgent', () {
    expect(agentName(AiAgent.claude), 'Claude');
    expect(agentName(AiAgent.gpt), 'GPT-4');
    expect(agentName(AiAgent.deepseek), 'DeepSeek');
    expect(agentName(AiAgent.gemini), 'Gemini');
    expect(agentName(AiAgent.mistral), 'Mistral');
  });

  test('agentColor returns correct color for each AiAgent', () {
    expect(agentColor(AiAgent.claude), const Color(0xFFE0BBE4));
    expect(agentColor(AiAgent.gpt), const Color(0xFFB2DFDB));
    expect(agentColor(AiAgent.deepseek), const Color(0xFFFFF59D));
    expect(agentColor(AiAgent.gemini), const Color(0xFF4285F4));
    expect(agentColor(AiAgent.mistral), const Color(0xFFFF5722));
  });

  test('agentDarkColor returns correct dark color for each AiAgent', () {
    expect(agentDarkColor(AiAgent.claude), const Color(0xFF9C64A6));
    expect(agentDarkColor(AiAgent.gpt), const Color(0xFF00695C));
    expect(agentDarkColor(AiAgent.deepseek), const Color(0xFFFFEB3B));
    expect(agentDarkColor(AiAgent.gemini), const Color(0xFF0D47A1));
    expect(agentDarkColor(AiAgent.mistral), const Color(0xFFE64A19));
  });
}