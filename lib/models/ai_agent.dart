// lib/models/ai_agent.dart
enum AiAgent { claude, gpt, deepseek }

String agentName(AiAgent agent) {
  switch (agent) {
    case AiAgent.claude:
      return 'Claude';
    case AiAgent.gpt:
      return 'GPT-4';
    case AiAgent.deepseek:
      return 'DeepSeek';
  }
}

String agentAvatar(AiAgent agent) {
  switch (agent) {
    case AiAgent.claude:
      return '🧠';
    case AiAgent.gpt:
      return '🤖';
    case AiAgent.deepseek:
      return '💻';
  }
}