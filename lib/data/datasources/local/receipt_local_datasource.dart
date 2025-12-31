import 'package:drift/drift.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/receipt_item_model.dart';
import '../../models/receipt_model.dart';
import '../../models/store_model.dart';
import 'database/app_database.dart';

/// Local data source for receipt operations using Drift database
abstract class ReceiptLocalDatasource {
  /// Get all receipts for a user
  Future<List<ReceiptModel>> getReceipts({
    required String userId,
    bool includeDeleted = false,
    int limit = 20,
    int offset = 0,
  });

  /// Get a receipt by ID
  Future<ReceiptModel?> getReceiptById(String id);

  /// Get receipts that need syncing
  Future<List<ReceiptModel>> getReceiptsNeedingSync(String userId);

  /// Insert or update a receipt
  Future<void> upsertReceipt(ReceiptModel receipt);

  /// Soft delete a receipt
  Future<void> softDeleteReceipt(String id);

  /// Hard delete a receipt
  Future<void> hardDeleteReceipt(String id);

  /// Mark receipt as synced
  Future<void> markReceiptSynced(String id);

  /// Get items for a receipt
  Future<List<ReceiptItemModel>> getItemsForReceipt(String receiptId);

  /// Insert receipt items
  Future<void> insertReceiptItems(List<ReceiptItemModel> items);

  /// Delete items for a receipt
  Future<void> deleteItemsForReceipt(String receiptId);

  /// Search receipts by query
  Future<List<ReceiptModel>> searchReceipts({
    required String userId,
    required String query,
    int limit = 20,
  });

  /// Get all stores
  Future<List<StoreModel>> getStores();

  /// Get store by ID
  Future<StoreModel?> getStoreById(String id);

  /// Upsert stores
  Future<void> upsertStores(List<StoreModel> stores);

  /// Clear all receipt data for a user
  Future<void> clearUserData(String userId);
}

/// Implementation of local receipt data source
class ReceiptLocalDatasourceImpl implements ReceiptLocalDatasource {
  final AppDatabase _database;

  ReceiptLocalDatasourceImpl(this._database);

  @override
  Future<List<ReceiptModel>> getReceipts({
    required String userId,
    bool includeDeleted = false,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final query = _database.select(_database.receipts)
        ..where((r) => r.userId.equals(userId));

      if (!includeDeleted) {
        query.where((r) => r.isDeleted.equals(false));
      }

      query
        ..orderBy([(r) => OrderingTerm.desc(r.date)])
        ..limit(limit, offset: offset);

      final rows = await query.get();

      // Fetch items for each receipt
      final models = <ReceiptModel>[];
      for (final row in rows) {
        final items = await getItemsForReceipt(row.id);
        models.add(_receiptFromRow(row, items));
      }

      return models;
    } catch (e) {
      throw CacheException('Failed to get receipts: $e');
    }
  }

  @override
  Future<ReceiptModel?> getReceiptById(String id) async {
    try {
      final query = _database.select(_database.receipts)
        ..where((r) => r.id.equals(id));

      final row = await query.getSingleOrNull();
      if (row == null) return null;

      final items = await getItemsForReceipt(id);
      return _receiptFromRow(row, items);
    } catch (e) {
      throw CacheException('Failed to get receipt: $e');
    }
  }

  @override
  Future<List<ReceiptModel>> getReceiptsNeedingSync(String userId) async {
    try {
      final query = _database.select(_database.receipts)
        ..where((r) =>
            r.userId.equals(userId) &
            r.needsSync.equals(true) &
            r.isDeleted.equals(false));

      final rows = await query.get();

      final models = <ReceiptModel>[];
      for (final row in rows) {
        final items = await getItemsForReceipt(row.id);
        models.add(_receiptFromRow(row, items));
      }

      return models;
    } catch (e) {
      throw CacheException('Failed to get receipts needing sync: $e');
    }
  }

  @override
  Future<void> upsertReceipt(ReceiptModel receipt) async {
    try {
      final companion = ReceiptsCompanion(
        id: Value(receipt.id),
        userId: Value(receipt.userId),
        storeName: Value(receipt.storeName),
        storeId: Value(receipt.storeId),
        date: Value(receipt.date),
        totalAmountLbp: Value(receipt.totalAmountLbp),
        totalAmountUsd: Value(receipt.totalAmountUsd),
        originalCurrency: Value(receipt.originalCurrency),
        categoryId: Value(receipt.category.name),
        status: Value(receipt.status.name),
        ocrConfidence: Value(receipt.ocrConfidence),
        rawOcrText: Value(receipt.rawOcrText),
        imageUrls: Value(receipt.imageUrls.join(',')),
        notes: Value(receipt.notes),
        createdAt: Value(receipt.createdAt),
        updatedAt: Value(receipt.updatedAt),
        syncedAt: Value(receipt.syncedAt),
        needsSync: Value(receipt.needsSync),
        isDeleted: Value(receipt.isDeleted),
      );

      await _database
          .into(_database.receipts)
          .insertOnConflictUpdate(companion);

      // Update items
      await deleteItemsForReceipt(receipt.id);
      if (receipt.items.isNotEmpty) {
        await insertReceiptItems(receipt.items);
      }
    } catch (e) {
      throw CacheException('Failed to upsert receipt: $e');
    }
  }

  @override
  Future<void> softDeleteReceipt(String id) async {
    try {
      await (_database.update(_database.receipts)
            ..where((r) => r.id.equals(id)))
          .write(ReceiptsCompanion(
        isDeleted: const Value(true),
        needsSync: const Value(true),
        updatedAt: Value(DateTime.now()),
      ));
    } catch (e) {
      throw CacheException('Failed to soft delete receipt: $e');
    }
  }

  @override
  Future<void> hardDeleteReceipt(String id) async {
    try {
      await deleteItemsForReceipt(id);
      await (_database.delete(_database.receipts)
            ..where((r) => r.id.equals(id)))
          .go();
    } catch (e) {
      throw CacheException('Failed to hard delete receipt: $e');
    }
  }

  @override
  Future<void> markReceiptSynced(String id) async {
    try {
      await (_database.update(_database.receipts)
            ..where((r) => r.id.equals(id)))
          .write(ReceiptsCompanion(
        needsSync: const Value(false),
        syncedAt: Value(DateTime.now()),
      ));
    } catch (e) {
      throw CacheException('Failed to mark receipt synced: $e');
    }
  }

  @override
  Future<List<ReceiptItemModel>> getItemsForReceipt(String receiptId) async {
    try {
      final query = _database.select(_database.receiptItems)
        ..where((i) => i.receiptId.equals(receiptId))
        ..orderBy([(i) => OrderingTerm.asc(i.sortOrder)]);

      final rows = await query.get();
      return rows.map(_itemFromRow).toList();
    } catch (e) {
      throw CacheException('Failed to get items: $e');
    }
  }

  @override
  Future<void> insertReceiptItems(List<ReceiptItemModel> items) async {
    try {
      await _database.batch((batch) {
        for (final item in items) {
          batch.insert(
            _database.receiptItems,
            ReceiptItemsCompanion(
              id: Value(item.id),
              receiptId: Value(item.receiptId),
              name: Value(item.name),
              quantity: Value(item.quantity),
              unit: Value(item.unit),
              unitPrice: Value(item.unitPrice),
              totalPrice: Value(item.totalPrice),
              currency: Value(item.currency),
              productId: Value(item.productId),
              categoryId: Value(item.categoryId),
              sortOrder: Value(item.sortOrder),
              createdAt: Value(item.createdAt),
            ),
          );
        }
      });
    } catch (e) {
      throw CacheException('Failed to insert items: $e');
    }
  }

  @override
  Future<void> deleteItemsForReceipt(String receiptId) async {
    try {
      await (_database.delete(_database.receiptItems)
            ..where((i) => i.receiptId.equals(receiptId)))
          .go();
    } catch (e) {
      throw CacheException('Failed to delete items: $e');
    }
  }

  @override
  Future<List<ReceiptModel>> searchReceipts({
    required String userId,
    required String query,
    int limit = 20,
  }) async {
    try {
      final lowerQuery = '%${query.toLowerCase()}%';

      // Search in store name and notes
      final receiptsQuery = _database.select(_database.receipts)
        ..where((r) =>
            r.userId.equals(userId) &
            r.isDeleted.equals(false) &
            (r.storeName.lower().like(lowerQuery) |
                r.notes.lower().like(lowerQuery)))
        ..orderBy([(r) => OrderingTerm.desc(r.date)])
        ..limit(limit);

      final rows = await receiptsQuery.get();

      final models = <ReceiptModel>[];
      for (final row in rows) {
        final items = await getItemsForReceipt(row.id);
        models.add(_receiptFromRow(row, items));
      }

      return models;
    } catch (e) {
      throw CacheException('Failed to search receipts: $e');
    }
  }

  @override
  Future<List<StoreModel>> getStores() async {
    try {
      final query = _database.select(_database.stores)
        ..where((s) => s.isActive.equals(true));

      final rows = await query.get();
      return rows.map(_storeFromRow).toList();
    } catch (e) {
      throw CacheException('Failed to get stores: $e');
    }
  }

  @override
  Future<StoreModel?> getStoreById(String id) async {
    try {
      final query = _database.select(_database.stores)
        ..where((s) => s.id.equals(id));

      final row = await query.getSingleOrNull();
      return row != null ? _storeFromRow(row) : null;
    } catch (e) {
      throw CacheException('Failed to get store: $e');
    }
  }

  @override
  Future<void> upsertStores(List<StoreModel> stores) async {
    try {
      await _database.batch((batch) {
        for (final store in stores) {
          final companion = StoresCompanion(
            id: Value(store.id),
            name: Value(store.name),
            nameArabic: Value(store.nameArabic),
            type: Value(store.type.name),
            logoUrl: Value(store.logoUrl),
            color: Value(store.color),
            receiptPatterns: Value(store.receiptPatterns.join(',')),
            isActive: Value(store.isActive),
            updatedAt: Value(store.updatedAt),
          );
          batch.insert(_database.stores, companion,
              onConflict: DoUpdate((_) => companion));
        }
      });
    } catch (e) {
      throw CacheException('Failed to upsert stores: $e');
    }
  }

  @override
  Future<void> clearUserData(String userId) async {
    try {
      // Get all receipt IDs for the user
      final receipts = await (_database.select(_database.receipts)
            ..where((r) => r.userId.equals(userId)))
          .get();

      // Delete items for each receipt
      for (final receipt in receipts) {
        await deleteItemsForReceipt(receipt.id);
      }

      // Delete all receipts
      await (_database.delete(_database.receipts)
            ..where((r) => r.userId.equals(userId)))
          .go();
    } catch (e) {
      throw CacheException('Failed to clear user data: $e');
    }
  }

  // Helper methods to convert database rows to models
  ReceiptModel _receiptFromRow(Receipt row, List<ReceiptItemModel> items) {
    return ReceiptModel.fromDrift(
      id: row.id,
      userId: row.userId,
      storeName: row.storeName,
      storeId: row.storeId,
      date: row.date,
      totalAmountLbp: row.totalAmountLbp,
      totalAmountUsd: row.totalAmountUsd,
      originalCurrency: row.originalCurrency,
      categoryId: row.categoryId,
      status: row.status,
      ocrConfidence: row.ocrConfidence,
      rawOcrText: row.rawOcrText,
      imageUrls: row.imageUrls,
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      syncedAt: row.syncedAt,
      needsSync: row.needsSync,
      isDeleted: row.isDeleted,
      items: items,
    );
  }

  ReceiptItemModel _itemFromRow(ReceiptItem row) {
    return ReceiptItemModel.fromDrift(
      id: row.id,
      receiptId: row.receiptId,
      name: row.name,
      quantity: row.quantity,
      unit: row.unit,
      unitPrice: row.unitPrice,
      totalPrice: row.totalPrice,
      currency: row.currency,
      productId: row.productId,
      categoryId: row.categoryId,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
    );
  }

  StoreModel _storeFromRow(Store row) {
    return StoreModel.fromDrift(
      id: row.id,
      name: row.name,
      nameArabic: row.nameArabic,
      type: row.type,
      logoUrl: row.logoUrl,
      color: row.color,
      receiptPatterns: row.receiptPatterns,
      isActive: row.isActive,
      updatedAt: row.updatedAt,
    );
  }
}
