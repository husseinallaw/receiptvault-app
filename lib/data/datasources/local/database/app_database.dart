import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/receipts_table.dart';
import 'tables/receipt_items_table.dart';
import 'tables/budgets_table.dart';
import 'tables/stores_table.dart';
import 'tables/exchange_rates_table.dart';
import 'tables/sync_queue_table.dart';

part 'app_database.g.dart';

/// Main application database
@DriftDatabase(
  tables: [
    Receipts,
    ReceiptItems,
    Budgets,
    Stores,
    ExchangeRates,
    SyncQueue,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// For testing with in-memory database
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle future migrations here
        // Example:
        // if (from < 2) {
        //   await m.addColumn(receipts, receipts.newColumn);
        // }
      },
      beforeOpen: (details) async {
        // Enable foreign keys
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  // ==================== Receipt Operations ====================

  /// Get all receipts for a user
  Future<List<Receipt>> getReceiptsForUser(String userId) {
    return (select(receipts)
          ..where((r) => r.userId.equals(userId) & r.isDeleted.equals(false))
          ..orderBy([(r) => OrderingTerm.desc(r.date)]))
        .get();
  }

  /// Get receipts that need syncing
  Future<List<Receipt>> getReceiptsNeedingSync(String userId) {
    return (select(receipts)
          ..where((r) =>
              r.userId.equals(userId) &
              r.needsSync.equals(true) &
              r.isDeleted.equals(false)))
        .get();
  }

  /// Get receipt by ID
  Future<Receipt?> getReceiptById(String id) {
    return (select(receipts)..where((r) => r.id.equals(id))).getSingleOrNull();
  }

  /// Insert or update receipt
  Future<void> upsertReceipt(ReceiptsCompanion receipt) {
    return into(receipts).insertOnConflictUpdate(receipt);
  }

  /// Soft delete receipt
  Future<void> softDeleteReceipt(String id) {
    return (update(receipts)..where((r) => r.id.equals(id))).write(
      ReceiptsCompanion(
        isDeleted: const Value(true),
        needsSync: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Mark receipt as synced
  Future<void> markReceiptSynced(String id) {
    return (update(receipts)..where((r) => r.id.equals(id))).write(
      ReceiptsCompanion(
        needsSync: const Value(false),
        syncedAt: Value(DateTime.now()),
      ),
    );
  }

  // ==================== Receipt Items Operations ====================

  /// Get items for a receipt
  Future<List<ReceiptItem>> getItemsForReceipt(String receiptId) {
    return (select(receiptItems)
          ..where((i) => i.receiptId.equals(receiptId))
          ..orderBy([(i) => OrderingTerm.asc(i.sortOrder)]))
        .get();
  }

  /// Insert receipt items
  Future<void> insertReceiptItems(List<ReceiptItemsCompanion> items) {
    return batch((batch) {
      batch.insertAll(receiptItems, items);
    });
  }

  /// Delete items for a receipt
  Future<void> deleteItemsForReceipt(String receiptId) {
    return (delete(receiptItems)..where((i) => i.receiptId.equals(receiptId)))
        .go();
  }

  // ==================== Budget Operations ====================

  /// Get active budgets for a user
  Future<List<Budget>> getActiveBudgetsForUser(String userId) {
    return (select(budgets)
          ..where((b) => b.userId.equals(userId) & b.isActive.equals(true))
          ..orderBy([(b) => OrderingTerm.desc(b.startDate)]))
        .get();
  }

  /// Get budget by ID
  Future<Budget?> getBudgetById(String id) {
    return (select(budgets)..where((b) => b.id.equals(id))).getSingleOrNull();
  }

  /// Insert or update budget
  Future<void> upsertBudget(BudgetsCompanion budget) {
    return into(budgets).insertOnConflictUpdate(budget);
  }

  /// Update budget spent amount
  Future<void> updateBudgetSpent(String id, double spentAmount) {
    return (update(budgets)..where((b) => b.id.equals(id))).write(
      BudgetsCompanion(
        spentAmount: Value(spentAmount),
        needsSync: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ==================== Store Operations ====================

  /// Get all active stores
  Future<List<Store>> getAllStores() {
    return (select(stores)..where((s) => s.isActive.equals(true))).get();
  }

  /// Get store by ID
  Future<Store?> getStoreById(String id) {
    return (select(stores)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  /// Upsert stores (bulk update from Firestore)
  Future<void> upsertStores(List<StoresCompanion> storeList) {
    return batch((batch) {
      for (final store in storeList) {
        batch.insert(stores, store, onConflict: DoUpdate((_) => store));
      }
    });
  }

  // ==================== Exchange Rate Operations ====================

  /// Get active exchange rate for source
  Future<ExchangeRate?> getActiveRateForSource(String source) {
    return (select(exchangeRates)
          ..where((r) => r.source.equals(source) & r.isActive.equals(true))
          ..orderBy([(r) => OrderingTerm.desc(r.fetchedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Get latest black market rate
  Future<ExchangeRate?> getBlackMarketRate() {
    return getActiveRateForSource('black_market');
  }

  /// Upsert exchange rate
  Future<void> upsertExchangeRate(ExchangeRatesCompanion rate) {
    return into(exchangeRates).insertOnConflictUpdate(rate);
  }

  // ==================== Sync Queue Operations ====================

  /// Add operation to sync queue
  Future<int> addToSyncQueue(SyncQueueCompanion operation) {
    return into(syncQueue).insert(operation);
  }

  /// Get pending sync operations
  Future<List<SyncQueueData>> getPendingSyncOperations({int limit = 50}) {
    return (select(syncQueue)
          ..orderBy([
            (q) => OrderingTerm.desc(q.priority),
            (q) => OrderingTerm.asc(q.createdAt),
          ])
          ..limit(limit))
        .get();
  }

  /// Remove from sync queue
  Future<void> removeFromSyncQueue(int id) {
    return (delete(syncQueue)..where((q) => q.id.equals(id))).go();
  }

  /// Update sync operation after failure
  Future<void> updateSyncOperationError(int id, String error) async {
    await customStatement(
      'UPDATE sync_queue SET retry_count = retry_count + 1, last_error = ?, last_attempt_at = ? WHERE id = ?',
      [error, DateTime.now().millisecondsSinceEpoch, id],
    );
  }

  /// Clear all sync queue entries for an entity
  Future<void> clearSyncQueueForEntity(String entityType, String entityId) {
    return (delete(syncQueue)
          ..where((q) =>
              q.entityType.equals(entityType) & q.entityId.equals(entityId)))
        .go();
  }

  // ==================== Utility Operations ====================

  /// Clear all data (for logout)
  Future<void> clearAllData() async {
    await delete(syncQueue).go();
    await delete(receiptItems).go();
    await delete(receipts).go();
    await delete(budgets).go();
    // Keep stores and exchange rates as they're shared data
  }

  /// Get database stats
  Future<Map<String, int>> getDatabaseStats() async {
    final receiptCount = await (selectOnly(receipts)
          ..addColumns([receipts.id.count()]))
        .map((row) => row.read(receipts.id.count()))
        .getSingle();

    final budgetCount = await (selectOnly(budgets)
          ..addColumns([budgets.id.count()]))
        .map((row) => row.read(budgets.id.count()))
        .getSingle();

    final pendingSyncCount = await (selectOnly(syncQueue)
          ..addColumns([syncQueue.id.count()]))
        .map((row) => row.read(syncQueue.id.count()))
        .getSingle();

    return {
      'receipts': receiptCount ?? 0,
      'budgets': budgetCount ?? 0,
      'pendingSync': pendingSyncCount ?? 0,
    };
  }
}

/// Opens database connection
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'receipt_vault.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

/// Database provider
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});
