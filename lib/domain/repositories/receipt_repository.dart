import 'dart:typed_data';

import '../../core/utils/result.dart';
import '../entities/receipt.dart';
import '../entities/receipt_item.dart';
import '../entities/store.dart';

/// Repository interface for receipt operations
///
/// This abstract class defines the contract for:
/// - CRUD operations on receipts
/// - Receipt scanning and OCR processing
/// - Image upload and management
/// - Local and remote data synchronization
/// - Receipt search and filtering
abstract class ReceiptRepository {
  // ==================== Receipt CRUD ====================

  /// Create a new receipt
  ///
  /// Creates the receipt locally first, then queues for sync
  Future<Result<Receipt>> createReceipt(Receipt receipt);

  /// Get a receipt by ID
  ///
  /// Fetches from local database first, then remote if needed
  Future<Result<Receipt?>> getReceiptById(String id);

  /// Get receipts with optional filters
  ///
  /// Returns paginated list based on filter criteria
  Future<Result<List<Receipt>>> getReceipts(ReceiptFilter filter);

  /// Update an existing receipt
  ///
  /// Updates locally and queues for sync
  Future<Result<Receipt>> updateReceipt(Receipt receipt);

  /// Delete a receipt (soft delete)
  ///
  /// Marks as deleted locally and queues for sync
  Future<Result<void>> deleteReceipt(String id);

  /// Permanently delete a receipt
  ///
  /// Removes from both local and remote storage
  Future<Result<void>> hardDeleteReceipt(String id);

  // ==================== Receipt Items ====================

  /// Get items for a specific receipt
  Future<Result<List<ReceiptItem>>> getReceiptItems(String receiptId);

  /// Update receipt items
  ///
  /// Replaces all items for the given receipt
  Future<Result<List<ReceiptItem>>> updateReceiptItems(
    String receiptId,
    List<ReceiptItem> items,
  );

  /// Add a single item to a receipt
  Future<Result<ReceiptItem>> addReceiptItem(ReceiptItem item);

  /// Remove an item from a receipt
  Future<Result<void>> removeReceiptItem(String itemId);

  // ==================== OCR & Scanning ====================

  /// Scan a receipt image using OCR
  ///
  /// Takes image bytes and returns OCR result with extracted data
  Future<Result<OcrResult>> scanReceipt(Uint8List imageBytes);

  /// Process an existing receipt with OCR
  ///
  /// Fetches image from storage and processes with OCR
  Future<Result<Receipt>> processReceiptWithOcr(String receiptId);

  /// Retry OCR processing for a failed receipt
  Future<Result<Receipt>> retryOcrProcessing(String receiptId);

  // ==================== Image Management ====================

  /// Upload receipt image to cloud storage
  ///
  /// Returns the download URL of the uploaded image
  Future<Result<String>> uploadReceiptImage({
    required String receiptId,
    required String userId,
    required Uint8List imageBytes,
    String? fileName,
  });

  /// Delete receipt image from cloud storage
  Future<Result<void>> deleteReceiptImage(String imageUrl);

  /// Get receipt image bytes
  ///
  /// Downloads from cloud storage or reads from local cache
  Future<Result<Uint8List>> getReceiptImage(String imageUrl);

  // ==================== Search ====================

  /// Search receipts by text query
  ///
  /// Searches in store name, item names, and notes
  Future<Result<List<Receipt>>> searchReceipts({
    required String userId,
    required String query,
    int limit = 20,
  });

  /// Get receipts by date range
  Future<Result<List<Receipt>>> getReceiptsByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get receipts by category
  Future<Result<List<Receipt>>> getReceiptsByCategory({
    required String userId,
    required String categoryId,
    int limit = 20,
  });

  /// Get receipts by store
  Future<Result<List<Receipt>>> getReceiptsByStore({
    required String userId,
    required String storeId,
    int limit = 20,
  });

  // ==================== Sync Operations ====================

  /// Get receipts that need to be synced
  Future<Result<List<Receipt>>> getReceiptsNeedingSync(String userId);

  /// Sync a single receipt to remote
  Future<Result<Receipt>> syncReceipt(Receipt receipt);

  /// Sync all pending receipts for a user
  Future<Result<int>> syncAllReceipts(String userId);

  /// Mark receipt as synced
  Future<Result<void>> markReceiptSynced(String id);

  /// Fetch and merge remote receipts
  ///
  /// Downloads receipts from remote and merges with local data
  Future<Result<int>> fetchRemoteReceipts(String userId);

  // ==================== Statistics ====================

  /// Get total spending for a date range
  Future<Result<ReceiptStats>> getReceiptStats({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get spending by category
  Future<Result<Map<String, double>>> getSpendingByCategory({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required String currency,
  });

  /// Get spending by store
  Future<Result<Map<String, double>>> getSpendingByStore({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required String currency,
  });

  // ==================== Store Operations ====================

  /// Get all known stores
  Future<Result<List<Store>>> getStores();

  /// Get store by ID
  Future<Result<Store?>> getStoreById(String id);

  /// Find store by receipt text (for OCR matching)
  Future<Result<Store?>> findStoreByText(String text);

  /// Refresh stores from remote
  Future<Result<List<Store>>> refreshStores();
}

/// OCR scanning result
class OcrResult {
  /// Raw text extracted from the image
  final String rawText;

  /// Confidence score (0.0 to 1.0)
  final double confidence;

  /// Detected store name
  final String? storeName;

  /// Matched store ID (if found in database)
  final String? storeId;

  /// Receipt date extracted from text
  final DateTime? date;

  /// Extracted line items
  final List<OcrLineItem> items;

  /// Total amount in original currency
  final double? totalAmount;

  /// Detected currency
  final String currency;

  /// Subtotal before tax/discounts
  final double? subtotal;

  /// Tax amount
  final double? tax;

  /// Discount amount
  final double? discount;

  /// Payment method (cash, card, etc.)
  final String? paymentMethod;

  /// Bounding boxes for detected regions (for UI highlighting)
  final List<OcrBoundingBox>? boundingBoxes;

  const OcrResult({
    required this.rawText,
    required this.confidence,
    this.storeName,
    this.storeId,
    this.date,
    this.items = const [],
    this.totalAmount,
    this.currency = 'LBP',
    this.subtotal,
    this.tax,
    this.discount,
    this.paymentMethod,
    this.boundingBoxes,
  });

  /// Check if OCR result is usable
  bool get isUsable => confidence >= 0.7;

  /// Check if store was detected
  bool get hasStore => storeName != null && storeName!.isNotEmpty;

  /// Check if date was extracted
  bool get hasDate => date != null;

  /// Check if items were extracted
  bool get hasItems => items.isNotEmpty;

  /// Check if total was extracted
  bool get hasTotal => totalAmount != null && totalAmount! > 0;
}

/// A single line item extracted by OCR
class OcrLineItem {
  final String name;
  final double quantity;
  final String? unit;
  final double unitPrice;
  final double totalPrice;
  final String currency;
  final double confidence;

  const OcrLineItem({
    required this.name,
    this.quantity = 1,
    this.unit,
    required this.unitPrice,
    required this.totalPrice,
    this.currency = 'LBP',
    this.confidence = 1.0,
  });
}

/// Bounding box for OCR detected regions
class OcrBoundingBox {
  final double left;
  final double top;
  final double width;
  final double height;
  final String type; // 'store', 'date', 'item', 'total'
  final String text;

  const OcrBoundingBox({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.type,
    required this.text,
  });
}

/// Receipt statistics summary
class ReceiptStats {
  final int totalReceipts;
  final double totalSpendingLbp;
  final double totalSpendingUsd;
  final double averageReceiptLbp;
  final double averageReceiptUsd;
  final Map<String, int> receiptsByCategory;
  final Map<String, int> receiptsByStore;
  final DateTime? oldestReceipt;
  final DateTime? newestReceipt;

  const ReceiptStats({
    required this.totalReceipts,
    required this.totalSpendingLbp,
    required this.totalSpendingUsd,
    required this.averageReceiptLbp,
    required this.averageReceiptUsd,
    required this.receiptsByCategory,
    required this.receiptsByStore,
    this.oldestReceipt,
    this.newestReceipt,
  });

  factory ReceiptStats.empty() => const ReceiptStats(
        totalReceipts: 0,
        totalSpendingLbp: 0,
        totalSpendingUsd: 0,
        averageReceiptLbp: 0,
        averageReceiptUsd: 0,
        receiptsByCategory: {},
        receiptsByStore: {},
      );
}
