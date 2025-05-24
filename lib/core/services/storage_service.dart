// 💾 NEURONVAULT - SECURE STORAGE SERVICE
// Enterprise-grade data persistence and chat history management
// Part of PHASE 2.5 - QUANTUM STATE MANAGEMENT

import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../state/state_models.dart';

class StorageService {
  final SharedPreferences _sharedPreferences;
  final FlutterSecureStorage _secureStorage;
  final Logger _logger;
  final Uuid _uuid = const Uuid();

  // 🗂️ STORAGE KEYS
  static const String _chatHistoryKey = 'neuronvault_chat_history';
  static const String _chatMetadataKey = 'neuronvault_chat_metadata';
  static const String _exportHistoryKey = 'neuronvault_export_history';
  static const String _storageStatsKey = 'neuronvault_storage_stats';

  // 📁 FILE PATHS
  late final Directory _appDocumentsDir;
  late final Directory _chatBackupsDir;
  late final Directory _exportsDir;
  late final Directory _logsDir;

  StorageService({
    required SharedPreferences sharedPreferences,
    required FlutterSecureStorage secureStorage,
    required Logger logger,
  }) : _sharedPreferences = sharedPreferences,
       _secureStorage = secureStorage,
       _logger = logger {
    _initializeDirectories();
  }

  // 🗂️ DIRECTORY INITIALIZATION
  Future<void> _initializeDirectories() async {
    try {
      _logger.d('🗂️ Initializing storage directories...');
      
      _appDocumentsDir = await getApplicationDocumentsDirectory();
      
      // Create subdirectories
      _chatBackupsDir = Directory('${_appDocumentsDir.path}/chat_backups');
      _exportsDir = Directory('${_appDocumentsDir.path}/exports');
      _logsDir = Directory('${_appDocumentsDir.path}/logs');
      
      // Ensure directories exist
      await _chatBackupsDir.create(recursive: true);
      await _exportsDir.create(recursive: true);
      await _logsDir.create(recursive: true);
      
      _logger.i('✅ Storage directories initialized successfully');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to initialize directories', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // 💬 CHAT HISTORY MANAGEMENT
  Future<void> saveMessage(ChatMessage message) async {
    try {
      _logger.d('💾 Saving message: ${message.id}');
      
      // Get current chat history
      final currentHistory = await getChatHistory();
      
      // Check if message already exists (update case)
      final existingIndex = currentHistory.indexWhere((msg) => msg.id == message.id);
      
      if (existingIndex != -1) {
        // Update existing message
        currentHistory[existingIndex] = message;
        _logger.d('🔄 Updated existing message: ${message.id}');
      } else {
        // Add new message
        currentHistory.add(message);
        _logger.d('➕ Added new message: ${message.id}');
      }
      
      // Save updated history
      await _saveChatHistory(currentHistory);
      
      // Update metadata
      await _updateChatMetadata(currentHistory);
      
      _logger.i('✅ Message saved successfully: ${message.id}');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to save message', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<ChatMessage>> getChatHistory() async {
    try {
      _logger.d('📖 Loading chat history...');
      
      final historyJson = _sharedPreferences.getString(_chatHistoryKey);
      if (historyJson == null) {
        _logger.d('ℹ️ No chat history found');
        return [];
      }
      
      final historyList = jsonDecode(historyJson) as List<dynamic>;
      final messages = historyList
          .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
          .toList();
      
      _logger.i('✅ Loaded ${messages.length} messages from history');
      return messages;
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to load chat history', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  Future<void> _saveChatHistory(List<ChatMessage> messages) async {
    try {
      final historyJson = jsonEncode(messages.map((msg) => msg.toJson()).toList());
      await _sharedPreferences.setString(_chatHistoryKey, historyJson);
      
      // Create periodic backup
      if (messages.length % 10 == 0) { // Backup every 10 messages
        await _createChatBackup(messages);
      }
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to save chat history', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      _logger.d('🗑️ Deleting message: $messageId');
      
      final currentHistory = await getChatHistory();
      final updatedHistory = currentHistory.where((msg) => msg.id != messageId).toList();
      
      await _saveChatHistory(updatedHistory);
      await _updateChatMetadata(updatedHistory);
      
      _logger.i('✅ Message deleted successfully: $messageId');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to delete message', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> clearChatHistory() async {
    try {
      _logger.w('🗑️ Clearing all chat history...');
      
      // Create final backup before clearing
      final currentHistory = await getChatHistory();
      if (currentHistory.isNotEmpty) {
        await _createChatBackup(currentHistory, isFullClear: true);
      }
      
      // Clear from SharedPreferences
      await _sharedPreferences.remove(_chatHistoryKey);
      await _sharedPreferences.remove(_chatMetadataKey);
      
      _logger.i('✅ Chat history cleared successfully');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to clear chat history', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // 🔍 CHAT SEARCH & FILTERING
  Future<List<ChatMessage>> searchMessages(String query) async {
    try {
      _logger.d('🔍 Searching messages for: "$query"');
      
      final allMessages = await getChatHistory();
      final filteredMessages = allMessages
          .where((msg) => msg.content.toLowerCase().contains(query.toLowerCase()))
          .toList();
      
      _logger.i('🔍 Found ${filteredMessages.length} messages matching "$query"');
      return filteredMessages;
      
    } catch (e, stackTrace) {
      _logger.e('❌ Message search failed', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  Future<List<ChatMessage>> getMessagesByDateRange(DateTime start, DateTime end) async {
    try {
      _logger.d('📅 Getting messages from ${start.toIso8601String()} to ${end.toIso8601String()}');
      
      final allMessages = await getChatHistory();
      final filteredMessages = allMessages
          .where((msg) => 
              msg.timestamp.isAfter(start) && 
              msg.timestamp.isBefore(end))
          .toList();
      
      _logger.i('📅 Found ${filteredMessages.length} messages in date range');
      return filteredMessages;
      
    } catch (e, stackTrace) {
      _logger.e('❌ Date range filtering failed', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  Future<List<ChatMessage>> getMessagesByType(MessageType type) async {
    try {
      _logger.d('🏷️ Getting messages of type: $type');
      
      final allMessages = await getChatHistory();
      final filteredMessages = allMessages
          .where((msg) => msg.type == type)
          .toList();
      
      _logger.i('🏷️ Found ${filteredMessages.length} messages of type $type');
      return filteredMessages;
      
    } catch (e, stackTrace) {
      _logger.e('❌ Type filtering failed', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // 💾 BACKUP & RESTORE
  Future<void> _createChatBackup(List<ChatMessage> messages, {bool isFullClear = false}) async {
    try {
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupType = isFullClear ? 'full_clear' : 'periodic';
      final filename = 'chat_backup_${backupType}_$timestamp.json';
      
      final backupFile = File('${_chatBackupsDir.path}/$filename');
      
      final backupData = {
        'version': '2.5.0',
        'backup_type': backupType,
        'timestamp': timestamp,
        'message_count': messages.length,
        'messages': messages.map((msg) => msg.toJson()).toList(),
      };
      
      await backupFile.writeAsString(jsonEncode(backupData));
      
      _logger.i('💾 Chat backup created: $filename');
      
      // Cleanup old backups (keep last 10)
      await _cleanupOldBackups();
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to create chat backup', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> _cleanupOldBackups() async {
    try {
      final backupFiles = _chatBackupsDir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .toList();
      
      if (backupFiles.length <= 10) return;
      
      // Sort by modification time (oldest first)
      backupFiles.sort((a, b) => a.statSync().modified.compareTo(b.statSync().modified));
      
      // Delete oldest files to keep only 10
      final filesToDelete = backupFiles.take(backupFiles.length - 10);
      for (final file in filesToDelete) {
        await file.delete();
        _logger.d('🗑️ Deleted old backup: ${file.path}');
      }
      
    } catch (e) {
      _logger.w('⚠️ Failed to cleanup old backups: $e');
    }
  }

  Future<List<String>> getAvailableBackups() async {
    try {
      final backupFiles = _chatBackupsDir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .map((file) => file.uri.pathSegments.last)
          .toList();
      
      backupFiles.sort((a, b) => b.compareTo(a)); // Newest first
      return backupFiles;
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to get available backups', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  Future<void> restoreFromBackup(String backupFilename) async {
    try {
      _logger.i('🔄 Restoring from backup: $backupFilename');
      
      final backupFile = File('${_chatBackupsDir.path}/$backupFilename');
      if (!await backupFile.exists()) {
        throw FileSystemException('Backup file not found: $backupFilename');
      }
      
      final backupContent = await backupFile.readAsString();
      final backupData = jsonDecode(backupContent) as Map<String, dynamic>;
      
      final messages = (backupData['messages'] as List<dynamic>)
          .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
          .toList();
      
      // Create backup of current state before restore
      final currentHistory = await getChatHistory();
      if (currentHistory.isNotEmpty) {
        await _createChatBackup(currentHistory);
      }
      
      // Restore messages
      await _saveChatHistory(messages);
      await _updateChatMetadata(messages);
      
      _logger.i('✅ Successfully restored ${messages.length} messages from backup');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to restore from backup', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // 📤 EXPORT & IMPORT
  Future<String> exportChatHistory([String? format]) async {
    try {
      _logger.i('📤 Exporting chat history...');
      
      final messages = await getChatHistory();
      final metadata = await getChatMetadata();
      
      final exportData = {
        'version': '2.5.0',
        'export_timestamp': DateTime.now().toIso8601String(),
        'format': format ?? 'json',
        'metadata': metadata,
        'message_count': messages.length,
        'messages': messages.map((msg) => msg.toJson()).toList(),
      };
      
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final filename = 'neuronvault_export_$timestamp.json';
      final exportFile = File('${_exportsDir.path}/$filename');
      
      final exportJson = jsonEncode(exportData);
      await exportFile.writeAsString(exportJson);
      
      // Track export
      await _trackExport(filename, messages.length);
      
      _logger.i('✅ Export completed: $filename');
      return exportFile.path;
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to export chat history', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> importChatHistory(String filePath) async {
    try {
      _logger.i('📥 Importing chat history from: $filePath');
      
      final importFile = File(filePath);
      if (!await importFile.exists()) {
        throw FileSystemException('Import file not found: $filePath');
      }
      
      final importContent = await importFile.readAsString();
      final importData = jsonDecode(importContent) as Map<String, dynamic>;
      
      // Validate import data
      if (importData['version'] == null || importData['messages'] == null) {
        throw const FormatException('Invalid import file format');
      }
      
      final messages = (importData['messages'] as List<dynamic>)
          .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
          .toList();
      
      // Create backup before import
      final currentHistory = await getChatHistory();
      if (currentHistory.isNotEmpty) {
        await _createChatBackup(currentHistory);
      }
      
      // Import messages
      await _saveChatHistory(messages);
      await _updateChatMetadata(messages);
      
      _logger.i('✅ Successfully imported ${messages.length} messages');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to import chat history', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // 📊 METADATA & STATISTICS
  Future<void> _updateChatMetadata(List<ChatMessage> messages) async {
    try {
      final metadata = {
        'total_messages': messages.length,
        'user_messages': messages.where((msg) => msg.type == MessageType.user).length,
        'assistant_messages': messages.where((msg) => msg.type == MessageType.assistant).length,
        'error_messages': messages.where((msg) => msg.type == MessageType.error).length,
        'last_updated': DateTime.now().toIso8601String(),
        'first_message': messages.isNotEmpty ? messages.first.timestamp.toIso8601String() : null,
        'last_message': messages.isNotEmpty ? messages.last.timestamp.toIso8601String() : null,
        'total_characters': messages.fold<int>(0, (sum, msg) => sum + msg.content.length),
      };
      
      await _sharedPreferences.setString(_chatMetadataKey, jsonEncode(metadata));
      
    } catch (e) {
      _logger.w('⚠️ Failed to update chat metadata: $e');
    }
  }

  Future<Map<String, dynamic>> getChatMetadata() async {
    try {
      final metadataJson = _sharedPreferences.getString(_chatMetadataKey);
      if (metadataJson == null) {
        return {'total_messages': 0};
      }
      
      return jsonDecode(metadataJson) as Map<String, dynamic>;
      
    } catch (e) {
      _logger.w('⚠️ Failed to get chat metadata: $e');
      return {'total_messages': 0};
    }
  }

  Future<void> _trackExport(String filename, int messageCount) async {
    try {
      final exportHistory = _sharedPreferences.getStringList(_exportHistoryKey) ?? [];
      
      final exportRecord = jsonEncode({
        'filename': filename,
        'timestamp': DateTime.now().toIso8601String(),
        'message_count': messageCount,
      });
      
      exportHistory.add(exportRecord);
      
      // Keep only last 20 export records
      if (exportHistory.length > 20) {
        exportHistory.removeAt(0);
      }
      
      await _sharedPreferences.setStringList(_exportHistoryKey, exportHistory);
      
    } catch (e) {
      _logger.w('⚠️ Failed to track export: $e');
    }
  }

  // 📊 STORAGE STATISTICS
  Future<Map<String, dynamic>> getStorageStatistics() async {
    try {
      final messages = await getChatHistory();
      final metadata = await getChatMetadata();
      
      // Calculate file sizes
      int backupSize = 0;
      int exportSize = 0;
      
      try {
        final backupFiles = _chatBackupsDir.listSync().whereType<File>();
        backupSize = backupFiles.fold<int>(0, (sum, file) => sum + file.lengthSync());
        
        final exportFiles = _exportsDir.listSync().whereType<File>();
        exportSize = exportFiles.fold<int>(0, (sum, file) => sum + file.lengthSync());
      } catch (e) {
        _logger.w('⚠️ Failed to calculate file sizes: $e');
      }
      
      return {
        'message_count': messages.length,
        'total_characters': metadata['total_characters'] ?? 0,
        'backup_count': (await getAvailableBackups()).length,
        'backup_size_bytes': backupSize,
        'export_size_bytes': exportSize,
        'total_size_bytes': backupSize + exportSize,
        'last_backup': null, // Would need to track this separately
        'app_documents_path': _appDocumentsDir.path,
      };
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to get storage statistics', error: e, stackTrace: stackTrace);
      return {};
    }
  }

  // 🧹 CLEANUP & MAINTENANCE
  Future<void> performMaintenance() async {
    try {
      _logger.i('🧹 Performing storage maintenance...');
      
      // Cleanup old backups
      await _cleanupOldBackups();
      
      // Update metadata
      final messages = await getChatHistory();
      await _updateChatMetadata(messages);
      
      // Update storage statistics
      final stats = await getStorageStatistics();
      await _sharedPreferences.setString(_storageStatsKey, jsonEncode(stats));
      
      _logger.i('✅ Storage maintenance completed');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Storage maintenance failed', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> clearAllData() async {
    try {
      _logger.w('🗑️ Clearing all storage data...');
      
      // Create final backup
      final messages = await getChatHistory();
      if (messages.isNotEmpty) {
        await _createChatBackup(messages, isFullClear: true);
      }
      
      // Clear SharedPreferences
      await _sharedPreferences.remove(_chatHistoryKey);
      await _sharedPreferences.remove(_chatMetadataKey);
      await _sharedPreferences.remove(_exportHistoryKey);
      await _sharedPreferences.remove(_storageStatsKey);
      
      _logger.i('✅ All storage data cleared');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to clear all data', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // 🔧 UTILITIES
  String get appDocumentsPath => _appDocumentsDir.path;
  String get chatBackupsPath => _chatBackupsDir.path;
  String get exportsPath => _exportsDir.path;
  String get logsPath => _logsDir.path;
}