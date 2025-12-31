import '../../../core/constants/app_constants.dart';
import '../../../core/utils/result.dart';
import '../../entities/receipt.dart';
import '../../entities/receipt_item.dart';
import '../../repositories/receipt_repository.dart';

/// Use case for updating an existing receipt
///
/// Updates the receipt locally and queues for sync.
/// Handles both full receipt updates and partial updates.
class UpdateReceipt {
  final ReceiptRepository _repository;

  UpdateReceipt(this._repository);

  /// Update an existing receipt
  ///
  /// Parameters:
  /// - [receipt]: The updated receipt data
  ///
  /// Returns the updated receipt
  Future<Result<Receipt>> call(Receipt receipt) {
    // Ensure updatedAt is set and needsSync is true
    final updatedReceipt = receipt.copyWith(
      updatedAt: DateTime.now(),
      needsSync: true,
    );
    return _repository.updateReceipt(updatedReceipt);
  }

  /// Update receipt items
  ///
  /// Replaces all items for the given receipt
  Future<Result<List<ReceiptItem>>> updateItems({
    required String receiptId,
    required List<ReceiptItem> items,
  }) {
    return _repository.updateReceiptItems(receiptId, items);
  }

  /// Add a single item to a receipt
  Future<Result<ReceiptItem>> addItem(ReceiptItem item) {
    return _repository.addReceiptItem(item);
  }

  /// Remove an item from a receipt
  Future<Result<void>> removeItem(String itemId) {
    return _repository.removeReceiptItem(itemId);
  }

  /// Mark receipt as processed with OCR data
  Future<Result<Receipt>> markProcessed({
    required Receipt receipt,
    required OcrUpdateData ocrData,
  }) async {
    final updated = receipt.withOcrResults(
      storeName: ocrData.storeName,
      storeId: ocrData.storeId,
      totalAmountLbp: ocrData.totalAmountLbp,
      totalAmountUsd: ocrData.totalAmountUsd,
      originalCurrency: ocrData.originalCurrency,
      items: ocrData.items,
      confidence: ocrData.confidence,
      rawText: ocrData.rawText,
      category: ocrData.category,
      receiptDate: ocrData.receiptDate,
    );

    return _repository.updateReceipt(updated);
  }
}

/// Data from OCR processing to update receipt
class OcrUpdateData {
  final String storeName;
  final String? storeId;
  final double totalAmountLbp;
  final double totalAmountUsd;
  final String originalCurrency;
  final List<ReceiptItem> items;
  final double confidence;
  final String rawText;
  final ExpenseCategory? category;
  final DateTime? receiptDate;

  const OcrUpdateData({
    required this.storeName,
    this.storeId,
    required this.totalAmountLbp,
    required this.totalAmountUsd,
    required this.originalCurrency,
    required this.items,
    required this.confidence,
    required this.rawText,
    this.category,
    this.receiptDate,
  });
}
