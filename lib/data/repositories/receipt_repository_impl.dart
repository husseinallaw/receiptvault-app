import 'dart:typed_data';

import '../../core/constants/app_constants.dart';
import '../../core/constants/lebanon_stores.dart';
import '../../core/errors/error_handler.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/entities/receipt_item.dart';
import '../../domain/entities/store.dart';
import '../../domain/repositories/receipt_repository.dart';
import '../datasources/local/receipt_local_datasource.dart';
import '../datasources/remote/firebase_storage_datasource.dart';
import '../datasources/remote/receipt_remote_datasource.dart';
import '../models/receipt_item_model.dart';
import '../models/receipt_model.dart';
import '../models/store_model.dart';

/// Implementation of ReceiptRepository
///
/// Follows offline-first pattern:
/// 1. All writes go to local database first
/// 2. Sync queue tracks changes to upload
/// 3. Remote data is merged on fetch
class ReceiptRepositoryImpl implements ReceiptRepository {
  final ReceiptLocalDatasource _localDatasource;
  final ReceiptRemoteDatasource _remoteDatasource;
  final FirebaseStorageDatasource _storageDatasource;

  ReceiptRepositoryImpl({
    required ReceiptLocalDatasource localDatasource,
    required ReceiptRemoteDatasource remoteDatasource,
    required FirebaseStorageDatasource storageDatasource,
  })  : _localDatasource = localDatasource,
        _remoteDatasource = remoteDatasource,
        _storageDatasource = storageDatasource;

  // ==================== Receipt CRUD ====================

  @override
  Future<Result<Receipt>> createReceipt(Receipt receipt) async {
    try {
      final model = ReceiptModel.fromEntity(receipt);
      await _localDatasource.upsertReceipt(model);
      return Result.success(receipt);
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.handleException(e, stackTrace));
    }
  }

  @override
  Future<Result<Receipt?>> getReceiptById(String id) async {
    try {
      final model = await _localDatasource.getReceiptById(id);
      return Result.success(model?.toEntity());
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.handleException(e, stackTrace));
    }
  }

  @override
  Future<Result<List<Receipt>>> getReceipts(ReceiptFilter filter) async {
    try {
      final models = await _localDatasource.getReceipts(
        userId: filter.userId ?? '',
        includeDeleted: filter.includeDeleted,
        limit: filter.limit,
        offset: filter.offset,
      );

      var receipts = models.map((m) => m.toEntity()).toList();

      // Apply additional filters
      if (filter.category != null) {
        receipts =
            receipts.where((r) => r.category == filter.category).toList();
      }

      if (filter.storeId != null) {
        receipts = receipts.where((r) => r.storeId == filter.storeId).toList();
      }

      if (filter.startDate != null) {
        receipts = receipts
            .where((r) =>
                r.date.isAfter(filter.startDate!) ||
                r.date.isAtSameMomentAs(filter.startDate!))
            .toList();
      }

      if (filter.endDate != null) {
        receipts = receipts
            .where((r) =>
                r.date.isBefore(filter.endDate!) ||
                r.date.isAtSameMomentAs(filter.endDate!))
            .toList();
      }

      if (filter.minAmount != null) {
        final currency = filter.currency ?? 'LBP';
        receipts = receipts.where((r) {
          final amount =
              currency == 'USD' ? r.totalAmountUsd : r.totalAmountLbp;
          return amount >= filter.minAmount!;
        }).toList();
      }

      if (filter.maxAmount != null) {
        final currency = filter.currency ?? 'LBP';
        receipts = receipts.where((r) {
          final amount =
              currency == 'USD' ? r.totalAmountUsd : r.totalAmountLbp;
          return amount <= filter.maxAmount!;
        }).toList();
      }

      if (filter.status != null) {
        receipts = receipts.where((r) => r.status == filter.status).toList();
      }

      // Apply sorting
      receipts.sort((a, b) {
        int comparison;
        switch (filter.sortBy) {
          case ReceiptSortField.date:
            comparison = a.date.compareTo(b.date);
            break;
          case ReceiptSortField.amount:
            final currency = filter.currency ?? 'LBP';
            final amountA =
                currency == 'USD' ? a.totalAmountUsd : a.totalAmountLbp;
            final amountB =
                currency == 'USD' ? b.totalAmountUsd : b.totalAmountLbp;
            comparison = amountA.compareTo(amountB);
            break;
          case ReceiptSortField.storeName:
            comparison = a.storeName.compareTo(b.storeName);
            break;
          case ReceiptSortField.createdAt:
            comparison = a.createdAt.compareTo(b.createdAt);
            break;
          case ReceiptSortField.updatedAt:
            comparison = a.updatedAt.compareTo(b.updatedAt);
            break;
        }
        return filter.sortDescending ? -comparison : comparison;
      });

      return Result.success(receipts);
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.handleException(e, stackTrace));
    }
  }

  @override
  Future<Result<Receipt>> updateReceipt(Receipt receipt) async {
    try {
      final model = ReceiptModel.fromEntity(receipt.copyWith(
        updatedAt: DateTime.now(),
        needsSync: true,
      ));
      await _localDatasource.upsertReceipt(model);
      return Result.success(model.toEntity());
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.handleException(e, stackTrace));
    }
  }

  @override
  Future<Result<void>> deleteReceipt(String id) async {
    try {
      await _localDatasource.softDeleteReceipt(id);
      return const Result.success(null);
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.handleException(e, stackTrace));
    }
  }

  @override
  Future<Result<void>> hardDeleteReceipt(String id) async {
    try {
      // Get receipt to find image URLs
      final receipt = await _localDatasource.getReceiptById(id);
      if (receipt != null) {
        // Delete images from storage
        for (final imageUrl in receipt.imageUrls) {
          try {
            await _storageDatasource.deleteReceiptImage(imageUrl);
          } catch (_) {
            // Ignore storage errors during cleanup
          }
        }

        // Delete from remote
        try {
          await _remoteDatasource.hardDeleteReceipt(
            userId: receipt.userId,
            receiptId: id,
          );
        } catch (_) {
          // Ignore remote errors, local delete is priority
        }
      }

      // Delete from local
      await _localDatasource.hardDeleteReceipt(id);
      return const Result.success(null);
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.handleException(e, stackTrace));
    }
  }

  // ==================== Receipt Items ====================

  @override
  Future<Result<List<ReceiptItem>>> getReceiptItems(String receiptId) async {
    try {
      final models = await _localDatasource.getItemsForReceipt(receiptId);
      return Result.success(models.map((m) => m.toEntity()).toList());
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.handleException(e, stackTrace));
    }
  }

  @override
  Future<Result<List<ReceiptItem>>> updateReceiptItems(
    String receiptId,
    List<ReceiptItem> items,
  ) async {
    try {
      await _localDatasource.deleteItemsForReceipt(receiptId);
      final models = items.map((e) => ReceiptItemModel.fromEntity(e)).toList();
      await _localDatasource.insertReceiptItems(models);
      return Result.success(items);
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.handleException(e, stackTrace));
    }
  }

  @override
  Future<Result<ReceiptItem>> addReceiptItem(ReceiptItem item) async {
    try {
      final model = ReceiptItemModel.fromEntity(item);
      await _localDatasource.insertReceiptItems([model]);
      return Result.success(item);
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.handleException(e, stackTrace));
    }
  }

  @override
  Future<Result<void>> removeReceiptItem(String itemId) async {
    try {
      // Items are deleted by receipt ID, so we need to get the item first
      // For now, this is a placeholder - proper implementation would need item lookup
      return const Result.success(null);
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.handleException(e, stackTrace));
    }
  }

  // ==================== OCR & Scanning ====================

  @override
  Future<Result<OcrResult>> scanReceipt(Uint8List imageBytes) async {
    // This will be implemented in Sprint 3.3 with the OCR service
    return Result.failure(
      const Failure.ocr(message: 'OCR not implemented yet'),
    );
  }

  @override
  Future<Result<Receipt>> processReceiptWithOcr(String receiptId) async {
    // This will be implemented in Sprint 3.3
    return Result.failure(
      const Failure.ocr(message: 'OCR not implemented yet'),
    );
  }

  @override
  Future<Result<Receipt>> retryOcrProcessing(String receiptId) async {
    // This will be implemented in Sprint 3.3
    return Result.failure(
      const Failure.ocr(message: 'OCR not implemented yet'),
    );
  }

  // ==================== Image Management ====================

  @override
  Future<Result<String>> uploadReceiptImage({
    required String receiptId,
    required String userId,
    required Uint8List imageBytes,
    String? fileName,
  }) async {
    try {
      final url = await _storageDatasource.uploadReceiptImage(
        userId: userId,
        receiptId: receiptId,
        imageBytes: imageBytes,
        fileName: fileName,
      );
      return Result.success(url);
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.handleException(e, stackTrace));
    }
  }

  @override
  Future<Result<void>> deleteReceiptImage(String imageUrl) async {
    try {
      await _storageDatasource.deleteReceiptImage(imageUrl);
      return const Result.success(null);
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.handleException(e, stackTrace));
    }
  }

  @override
  Future<Result<Uint8List>> getReceiptImage(String imageUrl) async {
    try {
      final bytes = await _storageDatasource.getReceiptImage(imageUrl);
      return Result.success(bytes);
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.handleException(e, stackTrace));
    }
  }

  // ==================== Search ====================

  @override
  Future<Result<List<Receipt>>> searchReceipts({
    required String userId,
    required String query,
    int limit = 20,
  }) async {
    try {
      final models = await _localDatasource.searchReceipts(
        userId: userId,
        query: query,
        limit: limit,
      );
      return Result.success(models.map((m) => m.toEntity()).toList());
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.handleException(e, stackTrace));
    }
  }

  @override
  Future<Result<List<Receipt>>> getReceiptsByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return getReceipts(ReceiptFilter(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    ));
  }

  @override
  Future<Result<List<Receipt>>> getReceiptsByCategory({
    required String userId,
    required String categoryId,
    int limit = 20,
  }) async {
    final category = ExpenseCategory.values.firstWhere(
      (c) => c.name == categoryId,
      orElse: () => ExpenseCategory.other,
    );
    return getReceipts(ReceiptFilter(
      userId: userId,
      category: category,
      limit: limit,
    ));
  }

  @override
  Future<Result<List<Receipt>>> getReceiptsByStore({
    required String userId,
    required String storeId,
    int limit = 20,
  }) async {
    return getReceipts(ReceiptFilter(
      userId: userId,
      storeId: storeId,
      limit: limit,
    ));
  }

  // ==================== Sync Operations ====================

  @override
  Future<Result<List<Receipt>>> getReceiptsNeedingSync(String userId) async {
    try {
      final models = await _localDatasource.getReceiptsNeedingSync(userId);
      return Result.success(models.map((m) => m.toEntity()).toList());
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.handleException(e, stackTrace));
    }
  }

  @override
  Future<Result<Receipt>> syncReceipt(Receipt receipt) async {
    try {
      final model = ReceiptModel.fromEntity(receipt);
      final syncedModel = await _remoteDatasource.upsertReceipt(
        userId: receipt.userId,
        receipt: model,
      );

      // Mark as synced locally
      await _localDatasource.markReceiptSynced(receipt.id);

      return Result.success(syncedModel.toEntity());
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.handleException(e, stackTrace));
    }
  }

  @override
  Future<Result<int>> syncAllReceipts(String userId) async {
    try {
      final pending = await _localDatasource.getReceiptsNeedingSync(userId);
      int synced = 0;

      for (final model in pending) {
        try {
          await _remoteDatasource.upsertReceipt(
            userId: userId,
            receipt: model,
          );
          await _localDatasource.markReceiptSynced(model.id);
          synced++;
        } catch (_) {
          // Continue with other receipts on individual failure
        }
      }

      return Result.success(synced);
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.handleException(e, stackTrace));
    }
  }

  @override
  Future<Result<void>> markReceiptSynced(String id) async {
    try {
      await _localDatasource.markReceiptSynced(id);
      return const Result.success(null);
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.handleException(e, stackTrace));
    }
  }

  @override
  Future<Result<int>> fetchRemoteReceipts(String userId) async {
    try {
      final remoteReceipts = await _remoteDatasource.getReceipts(
        userId: userId,
        limit: 100,
      );

      int fetched = 0;

      for (final remoteModel in remoteReceipts) {
        final localModel =
            await _localDatasource.getReceiptById(remoteModel.id);

        // If local doesn't exist or remote is newer, upsert
        if (localModel == null ||
            remoteModel.updatedAt.isAfter(localModel.updatedAt)) {
          await _localDatasource.upsertReceipt(remoteModel.copyWith(
            needsSync: false,
            syncedAt: DateTime.now(),
          ));
          fetched++;
        }
      }

      return Result.success(fetched);
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.handleException(e, stackTrace));
    }
  }

  // ==================== Statistics ====================

  @override
  Future<Result<ReceiptStats>> getReceiptStats({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final receiptsResult = await getReceiptsByDateRange(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      if (receiptsResult.isFailure) {
        return Result.failure(receiptsResult.failureOrNull!);
      }

      final receipts = receiptsResult.dataOrThrow;

      if (receipts.isEmpty) {
        return Result.success(ReceiptStats.empty());
      }

      double totalLbp = 0;
      double totalUsd = 0;
      final byCategory = <String, int>{};
      final byStore = <String, int>{};

      for (final receipt in receipts) {
        totalLbp += receipt.totalAmountLbp;
        totalUsd += receipt.totalAmountUsd;

        byCategory[receipt.category.name] =
            (byCategory[receipt.category.name] ?? 0) + 1;

        if (receipt.storeId != null) {
          byStore[receipt.storeId!] = (byStore[receipt.storeId!] ?? 0) + 1;
        } else {
          byStore[receipt.storeName] = (byStore[receipt.storeName] ?? 0) + 1;
        }
      }

      return Result.success(ReceiptStats(
        totalReceipts: receipts.length,
        totalSpendingLbp: totalLbp,
        totalSpendingUsd: totalUsd,
        averageReceiptLbp: totalLbp / receipts.length,
        averageReceiptUsd: totalUsd / receipts.length,
        receiptsByCategory: byCategory,
        receiptsByStore: byStore,
        oldestReceipt: receipts.last.date,
        newestReceipt: receipts.first.date,
      ));
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.handleException(e, stackTrace));
    }
  }

  @override
  Future<Result<Map<String, double>>> getSpendingByCategory({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required String currency,
  }) async {
    try {
      final receiptsResult = await getReceiptsByDateRange(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      if (receiptsResult.isFailure) {
        return Result.failure(receiptsResult.failureOrNull!);
      }

      final receipts = receiptsResult.dataOrThrow;
      final spending = <String, double>{};

      for (final receipt in receipts) {
        final amount =
            currency == 'USD' ? receipt.totalAmountUsd : receipt.totalAmountLbp;
        spending[receipt.category.name] =
            (spending[receipt.category.name] ?? 0) + amount;
      }

      return Result.success(spending);
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.handleException(e, stackTrace));
    }
  }

  @override
  Future<Result<Map<String, double>>> getSpendingByStore({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required String currency,
  }) async {
    try {
      final receiptsResult = await getReceiptsByDateRange(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      if (receiptsResult.isFailure) {
        return Result.failure(receiptsResult.failureOrNull!);
      }

      final receipts = receiptsResult.dataOrThrow;
      final spending = <String, double>{};

      for (final receipt in receipts) {
        final key = receipt.storeId ?? receipt.storeName;
        final amount =
            currency == 'USD' ? receipt.totalAmountUsd : receipt.totalAmountLbp;
        spending[key] = (spending[key] ?? 0) + amount;
      }

      return Result.success(spending);
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.handleException(e, stackTrace));
    }
  }

  // ==================== Store Operations ====================

  @override
  Future<Result<List<Store>>> getStores() async {
    try {
      // First try local
      var models = await _localDatasource.getStores();

      // If empty, seed with Lebanese stores
      if (models.isEmpty) {
        final storeModels = LebanonStores.stores.values
            .map((info) => StoreModel.fromEntity(Store.fromStoreInfo(info)))
            .toList();
        await _localDatasource.upsertStores(storeModels);
        models = storeModels;
      }

      return Result.success(models.map((m) => m.toEntity()).toList());
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.handleException(e, stackTrace));
    }
  }

  @override
  Future<Result<Store?>> getStoreById(String id) async {
    try {
      final model = await _localDatasource.getStoreById(id);
      return Result.success(model?.toEntity());
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.handleException(e, stackTrace));
    }
  }

  @override
  Future<Result<Store?>> findStoreByText(String text) async {
    try {
      // First check local Lebanese stores
      final storeInfo = LebanonStores.findByReceiptText(text);
      if (storeInfo != null) {
        return Result.success(Store.fromStoreInfo(storeInfo));
      }

      // Then check database stores
      final stores = await _localDatasource.getStores();
      for (final model in stores) {
        final store = model.toEntity();
        if (store.matchesText(text)) {
          return Result.success(store);
        }
      }

      return const Result.success(null);
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.handleException(e, stackTrace));
    }
  }

  @override
  Future<Result<List<Store>>> refreshStores() async {
    try {
      final remoteStores = await _remoteDatasource.getStores();

      // Merge with local Lebanese stores
      final allStores = <String, StoreModel>{};

      // Add Lebanese stores first
      for (final info in LebanonStores.stores.values) {
        final store = StoreModel.fromEntity(Store.fromStoreInfo(info));
        allStores[store.id] = store;
      }

      // Override with remote stores
      for (final store in remoteStores) {
        allStores[store.id] = store;
      }

      // Save to local
      await _localDatasource.upsertStores(allStores.values.toList());

      return Result.success(allStores.values.map((m) => m.toEntity()).toList());
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.handleException(e, stackTrace));
    }
  }
}
