// 🧪 test/unit/core/services/storage_service_test.dart
// NEURONVAULT ENTERPRISE - STORAGE SERVICE COMPLETE TESTING SUITE
// Comprehensive testing for secure data persistence and chat history management

import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import 'package:neuronvault/core/services/storage_service.dart';
import 'package:neuronvault/core/state/state_models.dart';
import '../../utils/test_helpers.dart';
import '../../utils/mock_data.dart';
import '../../utils/test_constants.dart';
import '../../../../test_config/flutter_test_config.dart';

// =============================================================================
// 🎭 MOCK CLASSES
// =============================================================================

class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
class MockLogger extends Mock implements Logger {}
class MockDirectory extends Mock implements Directory {}
class MockFile extends Mock implements File {}
class MockFileStat extends Mock implements FileStat {}

// =============================================================================
// 🧪 MAIN TEST SUITE
// =============================================================================

void main() {
  // Initialize enterprise test environment
  NeuronVaultTestConfig.initializeTestEnvironment();

  group('🧪 StorageService - Enterprise Testing Suite', () {
    late StorageService storageService;
    late MockSharedPreferences mockSharedPrefs;
    late MockFlutterSecureStorage mockSecureStorage;
    late MockLogger mockLogger;
    late MockDirectory mockAppDir;
    late MockDirectory mockChatBackupsDir;
    late MockDirectory mockExportsDir;
    late MockDirectory mockLogsDir;

    // Test data constants
    final testMessage1 = ChatMessage(
      id: 'msg_001',
      content: 'Hello NeuronVault!',
      type: MessageType.user,
      timestamp: DateTime(2025, 1, 15, 10, 30),
      sourceModel: AIModel.claude,
      requestId: 'req_001',
      metadata: {'test': true},
    );

    final testMessage2 = ChatMessage(
      id: 'msg_002',
      content: 'How can I help you today?',
      type: MessageType.assistant,
      timestamp: DateTime(2025, 1, 15, 10, 31),
      sourceModel: AIModel.gpt,
      requestId: 'req_001',
    );

    final testMessage3 = ChatMessage(
      id: 'msg_003',
      content: 'Error occurred',
      type: MessageType.error,
      timestamp: DateTime(2025, 1, 15, 10, 32),
      isError: true,
    );

    final testMessages = [testMessage1, testMessage2, testMessage3];

    // ==========================================================================
    // 🔧 SETUP & TEARDOWN
    // ==========================================================================

    setUp(() async {
      // Create mocks
      mockSharedPrefs = MockSharedPreferences();
      mockSecureStorage = MockFlutterSecureStorage();
      mockLogger = MockLogger();
      mockAppDir = MockDirectory();
      mockChatBackupsDir = MockDirectory();
      mockExportsDir = MockDirectory();
      mockLogsDir = MockDirectory();

      // Register fallback values
      registerFallbackValue(Level.debug);
      registerFallbackValue('test_key');
      registerFallbackValue('test_value');
      registerFallbackValue(<String>[]);
      registerFallbackValue(const Duration(seconds: 1));

      // Setup default behavior for directories
      when(() => mockAppDir.path).thenReturn('/test/documents');
      when(() => mockChatBackupsDir.path).thenReturn('/test/documents/chat_backups');
      when(() => mockExportsDir.path).thenReturn('/test/documents/exports');
      when(() => mockLogsDir.path).thenReturn('/test/documents/logs');

      when(() => mockChatBackupsDir.create(recursive: any(named: 'recursive')))
          .thenAnswer((_) async => mockChatBackupsDir);
      when(() => mockExportsDir.create(recursive: any(named: 'recursive')))
          .thenAnswer((_) async => mockExportsDir);
      when(() => mockLogsDir.create(recursive: any(named: 'recursive')))
          .thenAnswer((_) async => mockLogsDir);

      // Mock path_provider
      when(() => mockAppDir.path).thenReturn('/test/documents');

      // Setup default SharedPreferences behavior
      when(() => mockSharedPrefs.getString(any())).thenReturn(null);
      when(() => mockSharedPrefs.getStringList(any())).thenReturn(null);
      when(() => mockSharedPrefs.setString(any(), any()))
          .thenAnswer((_) async => true);
      when(() => mockSharedPrefs.setStringList(any(), any()))
          .thenAnswer((_) async => true);
      when(() => mockSharedPrefs.remove(any()))
          .thenAnswer((_) async => true);

      // Create service instance
      storageService = StorageService(
        sharedPreferences: mockSharedPrefs,
        secureStorage: mockSecureStorage,
        logger: mockLogger,
      );

      // Mock the private _initializeDirectories method by setting up the directories
      // Since we can't directly mock private methods, we setup the environment
      await Future.delayed(const Duration(milliseconds: 10)); // Allow initialization
    });

    tearDown(() async {
      await NeuronVaultTestConfig.cleanupResources();
    });

    // ==========================================================================
    // 💬 CHAT HISTORY MANAGEMENT TESTS
    // ==========================================================================

    group('💬 Chat History Management', () {
      test('should save new message successfully', () async {
        // Arrange
        const existingHistory = '[]';
        when(() => mockSharedPrefs.getString('neuronvault_chat_history'))
            .thenReturn(existingHistory);

        // Act
        await storageService.saveMessage(testMessage1);

        // Assert
        verify(() => mockSharedPrefs.getString('neuronvault_chat_history')).called(1);
        verify(() => mockSharedPrefs.setString('neuronvault_chat_history', any()))
            .called(1);
        verify(() => mockSharedPrefs.setString('neuronvault_chat_metadata', any()))
            .called(1);
        verify(() => mockLogger.d('💾 Saving message: msg_001')).called(1);
        verify(() => mockLogger.i('✅ Message saved successfully: msg_001')).called(1);
      });

      test('should update existing message when saving with same ID', () async {
        // Arrange
        final existingMessage = testMessage1.copyWith(content: 'Original content');
        final existingHistory = jsonEncode([existingMessage.toJson()]);
        when(() => mockSharedPrefs.getString('neuronvault_chat_history'))
            .thenReturn(existingHistory);

        final updatedMessage = testMessage1.copyWith(content: 'Updated content');

        // Act
        await storageService.saveMessage(updatedMessage);

        // Assert
        verify(() => mockLogger.d('🔄 Updated existing message: msg_001')).called(1);
      });

      test('should get chat history successfully', () async {
        // Arrange
        final historyJson = jsonEncode(testMessages.map((m) => m.toJson()).toList());
        when(() => mockSharedPrefs.getString('neuronvault_chat_history'))
            .thenReturn(historyJson);

        // Act
        final result = await storageService.getChatHistory();

        // Assert
        expect(result.length, equals(3));
        expect(result[0].id, equals('msg_001'));
        expect(result[0].content, equals('Hello NeuronVault!'));
        expect(result[0].type, equals(MessageType.user));
        verify(() => mockLogger.i('✅ Loaded 3 messages from history')).called(1);
      });

      test('should return empty list when no chat history exists', () async {
        // Arrange
        when(() => mockSharedPrefs.getString('neuronvault_chat_history'))
            .thenReturn(null);

        // Act
        final result = await storageService.getChatHistory();

        // Assert
        expect(result, isEmpty);
        verify(() => mockLogger.d('ℹ️ No chat history found')).called(1);
      });

      test('should handle malformed JSON gracefully', () async {
        // Arrange
        when(() => mockSharedPrefs.getString('neuronvault_chat_history'))
            .thenReturn('invalid_json{');

        // Act
        final result = await storageService.getChatHistory();

        // Assert
        expect(result, isEmpty);
        verify(() => mockLogger.e('❌ Failed to load chat history', 
            error: any(named: 'error'), stackTrace: any(named: 'stackTrace')))
            .called(1);
      });

      test('should delete message successfully', () async {
        // Arrange
        final historyJson = jsonEncode(testMessages.map((m) => m.toJson()).toList());
        when(() => mockSharedPrefs.getString('neuronvault_chat_history'))
            .thenReturn(historyJson);

        // Act
        await storageService.deleteMessage('msg_002');

        // Assert
        verify(() => mockLogger.d('🗑️ Deleting message: msg_002')).called(1);
        verify(() => mockLogger.i('✅ Message deleted successfully: msg_002')).called(1);
        verify(() => mockSharedPrefs.setString('neuronvault_chat_history', any()))
            .called(1);
      });

      test('should clear chat history with backup', () async {
        // Arrange
        final historyJson = jsonEncode(testMessages.map((m) => m.toJson()).toList());
        when(() => mockSharedPrefs.getString('neuronvault_chat_history'))
            .thenReturn(historyJson);

        // Mock file operations for backup
        final mockFile = MockFile();
        when(() => mockFile.writeAsString(any())).thenAnswer((_) async => mockFile);

        // Act
        await storageService.clearChatHistory();

        // Assert
        verify(() => mockLogger.w('🗑️ Clearing all chat history...')).called(1);
        verify(() => mockSharedPrefs.remove('neuronvault_chat_history')).called(1);
        verify(() => mockSharedPrefs.remove('neuronvault_chat_metadata')).called(1);
        verify(() => mockLogger.i('✅ Chat history cleared successfully')).called(1);
      });
    });

    // ==========================================================================
    // 🔍 SEARCH & FILTERING TESTS
    // ==========================================================================

    group('🔍 Search & Filtering', () {
      setUp(() {
        final historyJson = jsonEncode(testMessages.map((m) => m.toJson()).toList());
        when(() => mockSharedPrefs.getString('neuronvault_chat_history'))
            .thenReturn(historyJson);
      });

      test('should search messages by content', () async {
        // Act
        final result = await storageService.searchMessages('neuronvault');

        // Assert
        expect(result.length, equals(1));
        expect(result[0].content, contains('NeuronVault'));
        verify(() => mockLogger.d('🔍 Searching messages for: "neuronvault"')).called(1);
        verify(() => mockLogger.i('🔍 Found 1 messages matching "neuronvault"')).called(1);
      });

      test('should search case insensitively', () async {
        // Act
        final result = await storageService.searchMessages('HELLO');

        // Assert
        expect(result.length, equals(1));
        expect(result[0].content, contains('Hello'));
      });

      test('should filter messages by date range', () async {
        // Act
        final start = DateTime(2025, 1, 15, 10, 30);
        final end = DateTime(2025, 1, 15, 10, 31, 30);
        final result = await storageService.getMessagesByDateRange(start, end);

        // Assert
        expect(result.length, equals(2)); // msg_001 and msg_002
        verify(() => mockLogger.i('📅 Found 2 messages in date range')).called(1);
      });

      test('should filter messages by type', () async {
        // Act
        final result = await storageService.getMessagesByType(MessageType.assistant);

        // Assert
        expect(result.length, equals(1));
        expect(result[0].type, equals(MessageType.assistant));
        verify(() => mockLogger.i('🏷️ Found 1 messages of type MessageType.assistant'))
            .called(1);
      });

      test('should handle search errors gracefully', () async {
        // Arrange
        when(() => mockSharedPrefs.getString('neuronvault_chat_history'))
            .thenThrow(Exception('Storage error'));

        // Act
        final result = await storageService.searchMessages('test');

        // Assert
        expect(result, isEmpty);
        verify(() => mockLogger.e('❌ Message search failed',
            error: any(named: 'error'), stackTrace: any(named: 'stackTrace')))
            .called(1);
      });
    });

    // ==========================================================================
    // 💾 BACKUP & RESTORE TESTS
    // ==========================================================================

    group('💾 Backup & Restore', () {
      test('should get available backups', () async {
        // Arrange
        final mockFile1 = MockFile();
        final mockFile2 = MockFile();
        when(() => mockFile1.path).thenReturn('/path/backup1.json');
        when(() => mockFile2.path).thenReturn('/path/backup2.json');
        when(() => mockFile1.uri).thenReturn(Uri.parse('file:///path/backup1.json'));
        when(() => mockFile2.uri).thenReturn(Uri.parse('file:///path/backup2.json'));

        when(() => mockChatBackupsDir.listSync())
            .thenReturn([mockFile1, mockFile2]);

        // Act
        final result = await storageService.getAvailableBackups();

        // Assert
        expect(result.length, equals(2));
        expect(result, contains('backup1.json'));
        expect(result, contains('backup2.json'));
      });

      test('should restore from backup successfully', () async {
        // Arrange
        final backupData = {
          'version': '2.5.0',
          'messages': testMessages.map((m) => m.toJson()).toList(),
        };
        final backupJson = jsonEncode(backupData);

        final mockBackupFile = MockFile();
        when(() => mockBackupFile.exists()).thenAnswer((_) async => true);
        when(() => mockBackupFile.readAsString()).thenAnswer((_) async => backupJson);

        // Mock file constructor - need to handle this differently
        when(() => mockSharedPrefs.getString('neuronvault_chat_history'))
            .thenReturn('[]'); // Empty current history

        // Act
        await storageService.restoreFromBackup('test_backup.json');

        // Assert
        verify(() => mockLogger.i('🔄 Restoring from backup: test_backup.json')).called(1);
        verify(() => mockSharedPrefs.setString('neuronvault_chat_history', any()))
            .called(atLeast(1)); // Called for backup and restore
      });

      test('should handle missing backup file', () async {
        // Act & Assert
        expect(
          () => storageService.restoreFromBackup('missing_backup.json'),
          throwsA(isA<FileSystemException>()),
        );
      });
    });

    // ==========================================================================
    // 📤 EXPORT & IMPORT TESTS
    // ==========================================================================

    group('📤 Export & Import', () {
      test('should export chat history successfully', () async {
        // Arrange
        final historyJson = jsonEncode(testMessages.map((m) => m.toJson()).toList());
        when(() => mockSharedPrefs.getString('neuronvault_chat_history'))
            .thenReturn(historyJson);
        when(() => mockSharedPrefs.getString('neuronvault_chat_metadata'))
            .thenReturn('{"total_messages": 3}');

        final mockExportFile = MockFile();
        when(() => mockExportFile.writeAsString(any())).thenAnswer((_) async => mockExportFile);
        when(() => mockExportFile.path).thenReturn('/test/exports/export.json');

        // Act
        final result = await storageService.exportChatHistory();

        // Assert
        expect(result, isNotEmpty);
        verify(() => mockLogger.i('📤 Exporting chat history...')).called(1);
        verify(() => mockSharedPrefs.setStringList('neuronvault_export_history', any()))
            .called(1);
      });

      test('should import chat history successfully', () async {
        // Arrange
        final importData = {
          'version': '2.5.0',
          'messages': testMessages.map((m) => m.toJson()).toList(),
        };
        final importJson = jsonEncode(importData);

        final mockImportFile = MockFile();
        when(() => mockImportFile.exists()).thenAnswer((_) async => true);
        when(() => mockImportFile.readAsString()).thenAnswer((_) async => importJson);

        when(() => mockSharedPrefs.getString('neuronvault_chat_history'))
            .thenReturn('[]');

        // Act
        await storageService.importChatHistory('/test/import.json');

        // Assert
        verify(() => mockLogger.i('📥 Importing chat history from: /test/import.json')).called(1);
        verify(() => mockLogger.i('✅ Successfully imported 3 messages')).called(1);
      });

      test('should handle invalid import file format', () async {
        // Arrange
        final mockImportFile = MockFile();
        when(() => mockImportFile.exists()).thenAnswer((_) async => true);
        when(() => mockImportFile.readAsString()).thenAnswer((_) async => '{"invalid": true}');

        // Act & Assert
        expect(
          () => storageService.importChatHistory('/test/invalid.json'),
          throwsA(isA<FormatException>()),
        );
      });
    });

    // ==========================================================================
    // 📊 METADATA & STATISTICS TESTS
    // ==========================================================================

    group('📊 Metadata & Statistics', () {
      test('should get chat metadata', () async {
        // Arrange
        final metadata = {
          'total_messages': 5,
          'user_messages': 3,
          'assistant_messages': 2,
        };
        when(() => mockSharedPrefs.getString('neuronvault_chat_metadata'))
            .thenReturn(jsonEncode(metadata));

        // Act
        final result = await storageService.getChatMetadata();

        // Assert
        expect(result['total_messages'], equals(5));
        expect(result['user_messages'], equals(3));
        expect(result['assistant_messages'], equals(2));
      });

      test('should return default metadata when none exists', () async {
        // Arrange
        when(() => mockSharedPrefs.getString('neuronvault_chat_metadata'))
            .thenReturn(null);

        // Act
        final result = await storageService.getChatMetadata();

        // Assert
        expect(result['total_messages'], equals(0));
      });

      test('should get storage statistics', () async {
        // Arrange
        final historyJson = jsonEncode(testMessages.map((m) => m.toJson()).toList());
        when(() => mockSharedPrefs.getString('neuronvault_chat_history'))
            .thenReturn(historyJson);
        when(() => mockSharedPrefs.getString('neuronvault_chat_metadata'))
            .thenReturn('{"total_characters": 500}');

        // Mock directory listing for file sizes
        when(() => mockChatBackupsDir.listSync()).thenReturn([]);
        when(() => mockExportsDir.listSync()).thenReturn([]);

        // Act
        final result = await storageService.getStorageStatistics();

        // Assert
        expect(result['message_count'], equals(3));
        expect(result['total_characters'], equals(500));
        expect(result['backup_count'], equals(0));
        expect(result, containsKey('app_documents_path'));
      });
    });

    // ==========================================================================
    // 🧹 MAINTENANCE & CLEANUP TESTS
    // ==========================================================================

    group('🧹 Maintenance & Cleanup', () {
      test('should perform maintenance successfully', () async {
        // Arrange
        final historyJson = jsonEncode(testMessages.map((m) => m.toJson()).toList());
        when(() => mockSharedPrefs.getString('neuronvault_chat_history'))
            .thenReturn(historyJson);
        when(() => mockChatBackupsDir.listSync()).thenReturn([]);
        when(() => mockExportsDir.listSync()).thenReturn([]);

        // Act
        await storageService.performMaintenance();

        // Assert
        verify(() => mockLogger.i('🧹 Performing storage maintenance...')).called(1);
        verify(() => mockLogger.i('✅ Storage maintenance completed')).called(1);
        verify(() => mockSharedPrefs.setString('neuronvault_storage_stats', any()))
            .called(1);
      });

      test('should clear all data with final backup', () async {
        // Arrange
        final historyJson = jsonEncode(testMessages.map((m) => m.toJson()).toList());
        when(() => mockSharedPrefs.getString('neuronvault_chat_history'))
            .thenReturn(historyJson);

        // Act
        await storageService.clearAllData();

        // Assert
        verify(() => mockLogger.w('🗑️ Clearing all storage data...')).called(1);
        verify(() => mockSharedPrefs.remove('neuronvault_chat_history')).called(1);
        verify(() => mockSharedPrefs.remove('neuronvault_chat_metadata')).called(1);
        verify(() => mockSharedPrefs.remove('neuronvault_export_history')).called(1);
        verify(() => mockSharedPrefs.remove('neuronvault_storage_stats')).called(1);
        verify(() => mockLogger.i('✅ All storage data cleared')).called(1);
      });

      test('should handle maintenance errors gracefully', () async {
        // Arrange
        when(() => mockSharedPrefs.getString(any()))
            .thenThrow(Exception('Storage error'));

        // Act
        await storageService.performMaintenance();

        // Assert
        verify(() => mockLogger.e('❌ Storage maintenance failed',
            error: any(named: 'error'), stackTrace: any(named: 'stackTrace')))
            .called(1);
      });
    });

    // ==========================================================================
    // 🔧 UTILITIES & GETTERS TESTS
    // ==========================================================================

    group('🔧 Utilities & Getters', () {
      test('should provide correct path getters', () {
        // Act & Assert
        expect(storageService.appDocumentsPath, equals('/test/documents'));
        expect(storageService.chatBackupsPath, equals('/test/documents/chat_backups'));
        expect(storageService.exportsPath, equals('/test/documents/exports'));
        expect(storageService.logsPath, equals('/test/documents/logs'));
      });
    });

    // ==========================================================================
    // 🎯 EDGE CASES & ERROR HANDLING
    // ==========================================================================

    group('🎯 Edge Cases & Error Handling', () {
      test('should handle SharedPreferences errors during save', () async {
        // Arrange
        when(() => mockSharedPrefs.getString('neuronvault_chat_history'))
            .thenReturn('[]');
        when(() => mockSharedPrefs.setString(any(), any()))
            .thenThrow(Exception('Storage full'));

        // Act & Assert
        expect(
          () => storageService.saveMessage(testMessage1),
          throwsA(isA<Exception>()),
        );
        verify(() => mockLogger.e('❌ Failed to save message',
            error: any(named: 'error'), stackTrace: any(named: 'stackTrace')))
            .called(1);
      });

      test('should handle invalid JSON during getChatHistory', () async {
        // Arrange
        when(() => mockSharedPrefs.getString('neuronvault_chat_history'))
            .thenReturn('[invalid json}');

        // Act
        final result = await storageService.getChatHistory();

        // Assert
        expect(result, isEmpty);
        verify(() => mockLogger.e('❌ Failed to load chat history',
            error: any(named: 'error'), stackTrace: any(named: 'stackTrace')))
            .called(1);
      });

      test('should handle empty search query', () async {
        // Arrange
        when(() => mockSharedPrefs.getString('neuronvault_chat_history'))
            .thenReturn(jsonEncode(testMessages.map((m) => m.toJson()).toList()));

        // Act
        final result = await storageService.searchMessages('');

        // Assert
        expect(result, isEmpty);
      });

      test('should handle file system errors during backup operations', () async {
        // Arrange
        when(() => mockChatBackupsDir.listSync())
            .thenThrow(const FileSystemException('Permission denied'));

        // Act
        final result = await storageService.getAvailableBackups();

        // Assert
        expect(result, isEmpty);
        verify(() => mockLogger.e('❌ Failed to get available backups',
            error: any(named: 'error'), stackTrace: any(named: 'stackTrace')))
            .called(1);
      });

      test('should handle large message counts efficiently', () async {
        // Arrange - Create 1000 test messages
        final largeMessageList = List.generate(1000, (index) => 
          ChatMessage(
            id: 'msg_$index',
            content: 'Test message $index',
            type: MessageType.user,
            timestamp: DateTime.now().add(Duration(seconds: index)),
          )
        );

        final largeHistoryJson = jsonEncode(largeMessageList.map((m) => m.toJson()).toList());
        when(() => mockSharedPrefs.getString('neuronvault_chat_history'))
            .thenReturn(largeHistoryJson);

        // Act
        final result = await storageService.getChatHistory();

        // Assert
        expect(result.length, equals(1000));
        verify(() => mockLogger.i('✅ Loaded 1000 messages from history')).called(1);
      });
    });

    // ==========================================================================
    // 🔄 INTEGRATION-STYLE TESTS
    // ==========================================================================

    group('🔄 Integration Workflows', () {
      test('should handle complete save-search-delete workflow', () async {
        // Arrange
        when(() => mockSharedPrefs.getString('neuronvault_chat_history'))
            .thenReturn('[]');

        // Act 1: Save messages
        await storageService.saveMessage(testMessage1);
        await storageService.saveMessage(testMessage2);

        // Update mock to return saved messages
        final savedHistory = jsonEncode([testMessage1.toJson(), testMessage2.toJson()]);
        when(() => mockSharedPrefs.getString('neuronvault_chat_history'))
            .thenReturn(savedHistory);

        // Act 2: Search
        final searchResult = await storageService.searchMessages('Hello');
        expect(searchResult.length, equals(1));

        // Act 3: Delete
        await storageService.deleteMessage('msg_001');

        // Assert
        verify(() => mockSharedPrefs.setString('neuronvault_chat_history', any()))
            .called(atLeast(3)); // 2 saves + 1 delete
      });

      test('should handle export-clear-import workflow', () async {
        // Arrange
        final historyJson = jsonEncode(testMessages.map((m) => m.toJson()).toList());
        when(() => mockSharedPrefs.getString('neuronvault_chat_history'))
            .thenReturn(historyJson);
        when(() => mockSharedPrefs.getString('neuronvault_chat_metadata'))
            .thenReturn('{"total_messages": 3}');

        final mockFile = MockFile();
        when(() => mockFile.writeAsString(any())).thenAnswer((_) async => mockFile);
        when(() => mockFile.path).thenReturn('/test/export.json');
        when(() => mockFile.exists()).thenAnswer((_) async => true);
        when(() => mockFile.readAsString()).thenAnswer((_) async => jsonEncode({
          'version': '2.5.0',
          'messages': testMessages.map((m) => m.toJson()).toList(),
        }));

        // Act: Export, Clear, Import
        final exportPath = await storageService.exportChatHistory();
        await storageService.clearChatHistory();
        await storageService.importChatHistory(exportPath);

        // Assert
        verify(() => mockLogger.i(contains('Export completed'))).called(1);
        verify(() => mockLogger.i('✅ Chat history cleared successfully')).called(1);
        verify(() => mockLogger.i('✅ Successfully imported 3 messages')).called(1);
      });
    });
  });
}