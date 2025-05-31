import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../../../../lib/core/services/storage_service.dart';
import '../../../../lib/core/state/state_models.dart';
import '../../../unit/helpers/test_helpers.dart';
import '../../mocks/mock_services.dart';

void main() {
  group('💾 StorageService Tests', () {
    late StorageService storageService;
    late SharedPreferences mockPrefs;
    late MockFlutterSecureStorage mockSecureStorage; // Changed to MockFlutterSecureStorage
    late Logger mockLogger;

    setUp(() async {
      mockPrefs = await TestHelpers.setupTestPreferences();
      mockSecureStorage = MockFlutterSecureStorage(); // Use the proper mock
      mockLogger = TestHelpers.createTestLogger();

      storageService = StorageService(
        sharedPreferences: mockPrefs,
        secureStorage: mockSecureStorage,
        logger: mockLogger,
      );

      // Wait for directory initialization
      await TestHelpers.testDelay(200);
    });

    group('💬 Chat History Tests', () {
      test('should save and load chat messages', () async {
        final message = ChatMessage(
          id: 'test_message_1',
          content: 'Test message content',
          type: MessageType.user,
          timestamp: DateTime.now(),
        );

        await storageService.saveMessage(message);
        final history = await storageService.getChatHistory();

        expect(history, isNotEmpty);
        expect(history.first.id, equals(message.id));
        expect(history.first.content, equals(message.content));
      });

      test('should update existing messages', () async {
        final message = ChatMessage(
          id: 'test_message_1',
          content: 'Original content',
          type: MessageType.user,
          timestamp: DateTime.now(),
        );

        await storageService.saveMessage(message);

        final updatedMessage = message.copyWith(content: 'Updated content');
        await storageService.saveMessage(updatedMessage);

        final history = await storageService.getChatHistory();
        expect(history.length, equals(1));
        expect(history.first.content, equals('Updated content'));
      });

      test('should delete messages', () async {
        final message = ChatMessage(
          id: 'test_message_1',
          content: 'Test message',
          type: MessageType.user,
          timestamp: DateTime.now(),
        );

        await storageService.saveMessage(message);
        await storageService.deleteMessage(message.id);

        final history = await storageService.getChatHistory();
        expect(history, isEmpty);
      });

      test('should clear all chat history', () async {
        final message1 = ChatMessage(
          id: 'test_message_1',
          content: 'Test message 1',
          type: MessageType.user,
          timestamp: DateTime.now(),
        );

        final message2 = ChatMessage(
          id: 'test_message_2',
          content: 'Test message 2',
          type: MessageType.assistant,
          timestamp: DateTime.now(),
        );

        await storageService.saveMessage(message1);
        await storageService.saveMessage(message2);
        await storageService.clearChatHistory();

        final history = await storageService.getChatHistory();
        expect(history, isEmpty);
      });
    });

    group('🔍 Search and Filtering Tests', () {
      test('should search messages by content', () async {
        final message1 = ChatMessage(
          id: 'test_message_1',
          content: 'Hello world',
          type: MessageType.user,
          timestamp: DateTime.now(),
        );

        final message2 = ChatMessage(
          id: 'test_message_2',
          content: 'Goodbye world',
          type: MessageType.user,
          timestamp: DateTime.now(),
        );

        await storageService.saveMessage(message1);
        await storageService.saveMessage(message2);

        final searchResults = await storageService.searchMessages('Hello');

        expect(searchResults.length, equals(1));
        expect(searchResults.first.id, equals(message1.id));
      });

      test('should filter messages by date range', () async {
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        final tomorrow = now.add(const Duration(days: 1));

        final message = ChatMessage(
          id: 'test_message_1',
          content: 'Test message',
          type: MessageType.user,
          timestamp: now,
        );

        await storageService.saveMessage(message);

        final results = await storageService.getMessagesByDateRange(yesterday, tomorrow);

        expect(results, isNotEmpty);
        expect(results.first.id, equals(message.id));
      });

      test('should filter messages by type', () async {
        final userMessage = ChatMessage(
          id: 'user_message',
          content: 'User message',
          type: MessageType.user,
          timestamp: DateTime.now(),
        );

        final assistantMessage = ChatMessage(
          id: 'assistant_message',
          content: 'Assistant message',
          type: MessageType.assistant,
          timestamp: DateTime.now(),
        );

        await storageService.saveMessage(userMessage);
        await storageService.saveMessage(assistantMessage);

        final userMessages = await storageService.getMessagesByType(MessageType.user);

        expect(userMessages.length, equals(1));
        expect(userMessages.first.type, equals(MessageType.user));
      });
    });

    group('📤 Export/Import Tests', () {
      test('should export chat history', () async {
        final message = ChatMessage(
          id: 'test_message_1',
          content: 'Test message',
          type: MessageType.user,
          timestamp: DateTime.now(),
        );

        await storageService.saveMessage(message);

        final exportPath = await storageService.exportChatHistory();

        expect(exportPath, isNotEmpty);
        expect(exportPath, contains('.json'));
      });

      test('should handle empty export gracefully', () async {
        expect(
              () => storageService.exportChatHistory(),
          returnsNormally,
        );
      });
    });

    group('📊 Metadata and Statistics Tests', () {
      test('should provide chat metadata', () async {
        final userMessage = ChatMessage(
          id: 'user_message',
          content: 'User message',
          type: MessageType.user,
          timestamp: DateTime.now(),
        );

        final assistantMessage = ChatMessage(
          id: 'assistant_message',
          content: 'Assistant message',
          type: MessageType.assistant,
          timestamp: DateTime.now(),
        );

        await storageService.saveMessage(userMessage);
        await storageService.saveMessage(assistantMessage);

        final metadata = await storageService.getChatMetadata();

        expect(metadata['total_messages'], equals(2));
        expect(metadata['user_messages'], equals(1));
        expect(metadata['assistant_messages'], equals(1));
      });

      test('should provide storage statistics', () async {
        final stats = await storageService.getStorageStatistics();

        expect(stats, isA<Map<String, dynamic>>());
        expect(stats.containsKey('message_count'), isTrue);
        expect(stats.containsKey('backup_count'), isTrue);
        expect(stats.containsKey('total_size_bytes'), isTrue);
      });
    });

    group('🧹 Maintenance Tests', () {
      test('should perform maintenance', () async {
        expect(
              () => storageService.performMaintenance(),
          returnsNormally,
        );
      });

      test('should clear all data', () async {
        final message = ChatMessage(
          id: 'test_message',
          content: 'Test',
          type: MessageType.user,
          timestamp: DateTime.now(),
        );

        await storageService.saveMessage(message);
        await storageService.clearAllData();

        final metadata = await storageService.getChatMetadata();
        expect(metadata['total_messages'], equals(0));
      });
    });

    group('🔧 Error Handling Tests', () {
      test('should handle invalid message IDs gracefully', () async {
        expect(
              () => storageService.deleteMessage('invalid_id'),
          returnsNormally,
        );
      });

      test('should handle empty search queries', () async {
        final results = await storageService.searchMessages('');
        expect(results, isA<List<ChatMessage>>());
      });
    });
  });
}