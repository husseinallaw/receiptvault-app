import 'package:drift/drift.dart';

/// Sync queue for offline-first operations
class SyncQueue extends Table {
  /// Unique operation ID
  IntColumn get id => integer().autoIncrement()();

  /// Entity type: receipt, budget, user_preferences
  TextColumn get entityType => text()();

  /// Entity ID
  TextColumn get entityId => text()();

  /// Operation type: create, update, delete
  TextColumn get operation => text()();

  /// Payload data (JSON)
  TextColumn get payload => text()();

  /// Number of retry attempts
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  /// Last error message
  TextColumn get lastError => text().nullable()();

  /// Operation priority (higher = more urgent)
  IntColumn get priority => integer().withDefault(const Constant(0))();

  /// Created timestamp
  DateTimeColumn get createdAt => dateTime()();

  /// Last attempt timestamp
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();

  @override
  List<String> get customConstraints => [
        'CHECK(entityType IN (\'receipt\', \'receipt_item\', \'budget\', \'user_preferences\'))',
        'CHECK(operation IN (\'create\', \'update\', \'delete\'))',
      ];
}

/// Index for processing order
@TableIndex(name: 'idx_sync_queue_priority', columns: {#priority, #createdAt})
@TableIndex(name: 'idx_sync_queue_entity', columns: {#entityType, #entityId})
class SyncQueueIndex extends SyncQueue {}
