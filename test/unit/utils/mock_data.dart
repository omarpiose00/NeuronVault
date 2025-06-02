// 🧪 test/unit/utils/mock_data.dart
// Mock Data Foundation for NeuronVault Testing - Enterprise Grade 2025
// Comprehensive fake data for all testing scenarios

import 'dart:convert';

/// 🗄️ **ENTERPRISE MOCK DATA FOUNDATION**
///
/// Provides realistic test data for all NeuronVault components:
/// - Achievement system test data
/// - AI orchestration mock responses
/// - User interaction patterns
/// - Theme and audio preferences
/// - WebSocket message simulations
/// - Performance metrics
/// - Error scenarios

class MockData {
  // ==========================================================================
  // 🏆 ACHIEVEMENT SYSTEM MOCK DATA
  // ==========================================================================

  /// Mock unlocked achievements for testing achievement service
  static const List<String> unlockedAchievements = [
    'neural_awakening',
    'first_synthesis',
    'theme_collector',
    'sound_pioneer',
    'particle_whisperer',
  ];

  /// Mock achievement progress data
  static const Map<String, dynamic> achievementProgress = {
    'ai_conductor': {
      'current': 15,
      'target': 50,
      'progress': 0.3,
    },
    'neural_marathon': {
      'current': 120,
      'target': 1000,
      'progress': 0.12,
    },
    'speed_demon': {
      'current': 5,
      'target': 10,
      'progress': 0.5,
    },
    'feature_explorer': {
      'current': 8,
      'target': 12,
      'progress': 0.67,
    },
  };

  /// Mock user statistics for achievement calculations
  static const Map<String, dynamic> userStats = {
    'total_orchestrations': 156,
    'total_session_time': 7200, // 2 hours in seconds
    'models_used': ['claude', 'gpt', 'deepseek', 'gemini'],
    'themes_tried': ['cosmos', 'matrix', 'sunset'],
    'audio_enabled_sessions': 45,
    'fastest_response_time': 120, // milliseconds
    'consecutive_days': 7,
    'error_rate': 0.02,
  };

  /// Complete achievement definitions for testing
  static const List<Map<String, dynamic>> achievementDefinitions = [
    {
      'id': 'neural_awakening',
      'title': 'Neural Awakening',
      'description': 'Enable the 3D neural particle system',
      'category': 'particles',
      'rarity': 'common',
      'iconPath': 'assets/icons/achievements/neural_awakening.png',
      'unlocked': true,
      'unlockedAt': '2025-01-15T10:30:00Z',
    },
    {
      'id': 'ai_conductor',
      'title': 'AI Conductor',
      'description': 'Complete 50 orchestrations',
      'category': 'orchestration',
      'rarity': 'rare',
      'iconPath': 'assets/icons/achievements/ai_conductor.png',
      'unlocked': false,
      'progress': 0.3,
      'target': 50,
      'current': 15,
    },
    {
      'id': 'theme_collector',
      'title': 'Theme Collector',
      'description': 'Try all 6 neural luxury themes',
      'category': 'themes',
      'rarity': 'epic',
      'iconPath': 'assets/icons/achievements/theme_collector.png',
      'unlocked': true,
      'unlockedAt': '2025-01-20T15:45:00Z',
    },
  ];

  // ==========================================================================
  // 🤖 AI ORCHESTRATION MOCK DATA
  // ==========================================================================

  /// Mock AI model responses for testing orchestration
  static const Map<String, dynamic> mockAIResponses = {
    'claude': {
      'response': 'Here is a comprehensive analysis of your query...',
      'confidence': 0.92,
      'tokens_used': 150,
      'processing_time': 1200, // milliseconds
      'specialization_score': 0.88,
      'status': 'completed',
    },
    'gpt': {
      'response': 'Based on the context provided, I can offer this perspective...',
      'confidence': 0.87,
      'tokens_used': 120,
      'processing_time': 950,
      'specialization_score': 0.82,
      'status': 'completed',
    },
    'deepseek': {
      'response': 'Analyzing the technical aspects, here is my assessment...',
      'confidence': 0.91,
      'tokens_used': 135,
      'processing_time': 1100,
      'specialization_score': 0.85,
      'status': 'completed',
    },
    'gemini': {
      'response': 'From a multi-modal perspective, I observe...',
      'confidence': 0.85,
      'tokens_used': 110,
      'processing_time': 1050,
      'specialization_score': 0.79,
      'status': 'completed',
    },
  };

  /// Mock synthesis result for final orchestration output
  static const Map<String, dynamic> mockSynthesisResult = {
    'final_response': 'After analyzing responses from multiple AI models, '
        'here is the synthesized comprehensive answer...',
    'confidence_score': 0.94,
    'synthesis_method': 'weighted_consensus',
    'contributing_models': ['claude', 'gpt', 'deepseek', 'gemini'],
    'quality_metrics': {
      'coherence': 0.96,
      'completeness': 0.91,
      'accuracy': 0.93,
      'relevance': 0.95,
    },
    'processing_time': 3200,
    'total_tokens': 515,
    'estimated_cost': 0.0023,
  };

  /// Mock Athena intelligence analysis
  static const Map<String, dynamic> mockAthenaAnalysis = {
    'prompt_category': 'technical_analysis',
    'complexity_score': 0.78,
    'recommended_models': ['claude', 'deepseek'],
    'confidence_in_recommendation': 0.92,
    'reasoning': [
      'Prompt contains technical terminology requiring specialized knowledge',
      'Claude excels at technical analysis and explanation',
      'DeepSeek provides strong technical verification',
    ],
    'estimated_processing_time': 2500,
    'quality_prediction': 0.89,
  };

  // ==========================================================================
  // 🌐 WEBSOCKET MOCK DATA
  // ==========================================================================

  /// Mock WebSocket messages for testing real-time communication
  static final List<Map<String, dynamic>> mockWebSocketMessages = [
    const {
      'type': 'connection_established',
      'timestamp': '2025-01-15T10:30:00.000Z',
      'data': {'client_id': 'test_client_123'},
    },
    const {
      'type': 'orchestration_start',
      'timestamp': '2025-01-15T10:30:05.000Z',
      'data': {
        'orchestration_id': 'orch_456',
        'prompt': 'Test prompt for orchestration',
        'selected_models': ['claude', 'gpt'],
        'strategy': 'parallel',
      },
    },
    const {
      'type': 'model_response',
      'timestamp': '2025-01-15T10:30:08.000Z',
      'data': {
        'orchestration_id': 'orch_456',
        'model': 'claude',
        'status': 'processing',
        'progress': 0.5,
      },
    },
    {
      'type': 'model_response',
      'timestamp': '2025-01-15T10:30:10.000Z',
      'data': {
        'orchestration_id': 'orch_456',
        'model': 'claude',
        'status': 'completed',
        'response': mockAIResponses['claude'],
      },
    },
    const {
      'type': 'synthesis_complete',
      'timestamp': '2025-01-15T10:30:15.000Z',
      'data': {
        'orchestration_id': 'orch_456',
        'result': mockSynthesisResult,
      },
    },
  ];

  /// Mock WebSocket error scenarios
  static const List<Map<String, dynamic>> mockWebSocketErrors = [
    {
      'type': 'connection_error',
      'timestamp': '2025-01-15T10:30:00.000Z',
      'data': {
        'error': 'connection_timeout',
        'message': 'Failed to establish WebSocket connection',
        'retry_in': 5000,
      },
    },
    {
      'type': 'orchestration_error',
      'timestamp': '2025-01-15T10:30:05.000Z',
      'data': {
        'orchestration_id': 'orch_789',
        'error': 'model_unavailable',
        'message': 'Claude service temporarily unavailable',
        'affected_models': ['claude'],
      },
    },
  ];

  // ==========================================================================
  // 🎨 THEME & UI MOCK DATA
  // ==========================================================================

  /// Mock theme preferences for testing theme service
  static const Map<String, dynamic> mockThemePreferences = {
    'current_theme': 'cosmos',
    'theme_history': ['matrix', 'sunset', 'cosmos'],
    'auto_switch_enabled': false,
    'theme_sync_with_system': true,
    'custom_colors': {
      'primary': '#6366f1',
      'secondary': '#8b5cf6',
      'accent': '#06b6d4',
    },
  };

  /// Mock neural particle system configuration
  static const Map<String, dynamic> mockParticleConfig = {
    'particle_count': 150,
    'connection_density': 0.7,
    'animation_speed': 1.0,
    'particle_types': ['neuron', 'synapse', 'electrical', 'quantum', 'data'],
    'enable_3d_effects': true,
    'performance_mode': 'balanced',
    'color_theme': 'cosmos',
  };

  // ==========================================================================
  // 🔊 AUDIO & HAPTICS MOCK DATA
  // ==========================================================================

  /// Mock spatial audio configuration
  static const Map<String, dynamic> mockAudioConfig = {
    'master_volume': 0.7,
    'spatial_audio_enabled': true,
    'haptic_feedback_enabled': true,
    'audio_themes': {
      'neural_fire': 0.8,
      'synapse_connect': 0.6,
      'ai_thinking': 0.5,
      'orchestration_complete': 0.9,
    },
    'preferred_audio_quality': 'high',
    'enable_background_ambience': true,
  };

  /// Mock audio event data for testing
  static const List<Map<String, dynamic>> mockAudioEvents = [
    {
      'event': 'neural_fire',
      'position': {'x': 0.3, 'y': 0.7, 'z': 0.0},
      'volume': 0.8,
      'duration': 200,
      'timestamp': '2025-01-15T10:30:00.000Z',
    },
    {
      'event': 'orchestration_start',
      'position': {'x': 0.5, 'y': 0.5, 'z': 0.0},
      'volume': 0.9,
      'duration': 500,
      'timestamp': '2025-01-15T10:30:05.000Z',
    },
  ];

  // ==========================================================================
  // 📊 ANALYTICS MOCK DATA
  // ==========================================================================

  /// Mock analytics data for model profiling dashboard
  static const Map<String, dynamic> mockAnalyticsData = {
    'session_stats': {
      'session_duration': 1800, // 30 minutes
      'orchestrations_count': 12,
      'average_response_time': 1350,
      'success_rate': 0.958,
      'user_satisfaction': 0.92,
    },
    'model_performance': {
      'claude': {
        'usage_count': 8,
        'average_response_time': 1200,
        'success_rate': 0.975,
        'user_rating': 4.7,
        'specializations': ['analysis', 'writing', 'reasoning'],
      },
      'gpt': {
        'usage_count': 6,
        'average_response_time': 950,
        'success_rate': 0.942,
        'user_rating': 4.5,
        'specializations': ['creativity', 'conversation', 'coding'],
      },
      'deepseek': {
        'usage_count': 4,
        'average_response_time': 1100,
        'success_rate': 0.950,
        'user_rating': 4.6,
        'specializations': ['technical', 'math', 'analysis'],
      },
    },
    'cost_analysis': {
      'total_tokens': 2450,
      'estimated_cost': 0.0087,
      'cost_per_orchestration': 0.000725,
      'most_expensive_model': 'claude',
      'cost_efficiency_score': 0.89,
    },
  };

  // ==========================================================================
  // 🔧 SYSTEM CONFIGURATION MOCK DATA
  // ==========================================================================

  /// Mock app configuration for testing config service
  static const Map<String, dynamic> mockAppConfig = {
    'app_version': '1.0.0+1',
    'api_endpoints': {
      'websocket': 'ws://localhost:3000',
      'health_check': 'http://localhost:3000/health',
    },
    'feature_flags': {
      'athena_intelligence': true,
      'spatial_audio': true,
      'achievement_system': true,
      'model_profiling': true,
      'neural_particles': true,
    },
    'performance_settings': {
      'max_concurrent_models': 4,
      'response_timeout': 30000,
      'connection_retry_attempts': 3,
      'particle_performance_mode': 'balanced',
    },
  };

  // ==========================================================================
  // 🧪 TEST SCENARIOS DATA
  // ==========================================================================

  /// Mock user interaction patterns for integration testing
  static const List<Map<String, dynamic>> mockUserJourneys = [
    {
      'name': 'first_time_user',
      'steps': [
        {'action': 'app_launch', 'duration': 2000},
        {'action': 'enable_particles', 'duration': 1000},
        {'action': 'select_theme', 'theme': 'cosmos', 'duration': 1500},
        {'action': 'first_orchestration', 'prompt': 'Hello world', 'duration': 3000},
        {'action': 'view_achievement', 'achievement': 'neural_awakening', 'duration': 2000},
      ],
    },
    {
      'name': 'power_user',
      'steps': [
        {'action': 'app_launch', 'duration': 1000},
        {'action': 'enable_athena', 'duration': 500},
        {'action': 'complex_orchestration', 'prompt': 'Analyze quantum computing', 'duration': 5000},
        {'action': 'view_analytics', 'duration': 3000},
        {'action': 'change_theme', 'theme': 'matrix', 'duration': 1000},
      ],
    },
  ];

  /// Mock error scenarios for testing error handling
  static const List<Map<String, dynamic>> mockErrorScenarios = [
    {
      'scenario': 'network_failure',
      'trigger': 'websocket_disconnection',
      'expected_behavior': 'auto_retry_with_backoff',
      'recovery_time': 5000,
    },
    {
      'scenario': 'model_timeout',
      'trigger': 'slow_ai_response',
      'expected_behavior': 'fallback_to_cached_response',
      'recovery_time': 2000,
    },
    {
      'scenario': 'invalid_prompt',
      'trigger': 'empty_or_malformed_input',
      'expected_behavior': 'show_helpful_error_message',
      'recovery_time': 0,
    },
  ];

  // ==========================================================================
  // 🔧 UTILITY METHODS
  // ==========================================================================

  /// Generates random realistic orchestration data
  static Map<String, dynamic> generateRandomOrchestration({
    String? prompt,
    List<String>? models,
    String? strategy,
  }) {
    final defaultModels = ['claude', 'gpt', 'deepseek'];
    final strategies = ['parallel', 'sequential', 'consensus', 'weighted'];

    return {
      'id': 'orch_${DateTime.now().millisecondsSinceEpoch}',
      'prompt': prompt ?? 'Test prompt ${DateTime.now().millisecond}',
      'models': models ?? defaultModels,
      'strategy': strategy ?? strategies[DateTime.now().millisecond % strategies.length],
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'pending',
    };
  }

  /// Creates mock achievement with specified properties
  static Map<String, dynamic> createMockAchievement({
    required String id,
    required String title,
    String category = 'general',
    String rarity = 'common',
    bool unlocked = false,
    double? progress,
  }) {
    return {
      'id': id,
      'title': title,
      'description': 'Mock achievement for testing: $title',
      'category': category,
      'rarity': rarity,
      'iconPath': 'assets/icons/achievements/$id.png',
      'unlocked': unlocked,
      'progress': progress,
      'unlockedAt': unlocked ? DateTime.now().toIso8601String() : null,
    };
  }

  /// Converts mock data to JSON strings for SharedPreferences testing
  static Map<String, String> toSharedPreferencesFormat() {
    return {
      'achievements_unlocked': jsonEncode(unlockedAchievements),
      'achievement_progress': jsonEncode(achievementProgress),
      'user_stats': jsonEncode(userStats),
      'theme_preferences': jsonEncode(mockThemePreferences),
      'audio_config': jsonEncode(mockAudioConfig),
      'app_config': jsonEncode(mockAppConfig),
    };
  }
}