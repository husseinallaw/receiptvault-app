import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/constants/app_constants.dart';
import 'money.dart';
import 'receipt_item.dart';
import 'store.dart';

part 'receipt.freezed.dart';
part 'receipt.g.dart';

/// Entity representing a scanned receipt
///
/// This is the central entity for the receipt scanning feature.
/// It captures:
/// - Store information (name, optional linked store)
/// - Financial data (totals in LBP and USD for unified reporting)
/// - Receipt metadata (date, category, notes)
/// - OCR data (confidence, raw text)
/// - Image references (cloud URLs, local paths)
/// - Sync status for offline-first functionality
@freezed
class Receipt with _$Receipt {
  const Receipt._();

  const factory Receipt({
    required String id,
    required String userId,
    required String storeName,
    String? storeId,
    required DateTime date,
    @Default([]) List<ReceiptItem> items,
    @Default(0.0) double totalAmountLbp,
    @Default(0.0) double totalAmountUsd,
    @Default('LBP') String originalCurrency,
    @Default(ExpenseCategory.other) ExpenseCategory category,
    @Default(ReceiptStatus.pending) ReceiptStatus status,
    double? ocrConfidence,
    String? rawOcrText,
    @Default([]) List<String> imageUrls,
    @Default([]) List<String> localImagePaths,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? syncedAt,
    @Default(true) bool needsSync,
    @Default(false) bool isDeleted,
  }) = _Receipt;

  factory Receipt.fromJson(Map<String, dynamic> json) =>
      _$ReceiptFromJson(json);

  /// Create a new receipt for scanning
  factory Receipt.create({
    required String id,
    required String userId,
    String storeName = '',
    String? storeId,
    DateTime? date,
    List<ReceiptItem>? items,
    double totalAmountLbp = 0.0,
    double totalAmountUsd = 0.0,
    String originalCurrency = 'LBP',
    ExpenseCategory category = ExpenseCategory.other,
    List<String>? localImagePaths,
    String? notes,
  }) {
    final now = DateTime.now();
    return Receipt(
      id: id,
      userId: userId,
      storeName: storeName,
      storeId: storeId,
      date: date ?? now,
      items: items ?? [],
      totalAmountLbp: totalAmountLbp,
      totalAmountUsd: totalAmountUsd,
      originalCurrency: originalCurrency,
      category: category,
      status: ReceiptStatus.pending,
      localImagePaths: localImagePaths ?? [],
      notes: notes,
      createdAt: now,
      updatedAt: now,
      needsSync: true,
    );
  }

  /// Get total amount in original currency
  Money get total {
    if (originalCurrency == 'USD') {
      return Money.usd(totalAmountUsd);
    }
    return Money.lbp(totalAmountLbp);
  }

  /// Get total in LBP as Money
  Money get totalLbp => Money.lbp(totalAmountLbp);

  /// Get total in USD as Money
  Money get totalUsd => Money.usd(totalAmountUsd);

  /// Calculate total from items
  Money calculateItemsTotal() {
    if (items.isEmpty) return Money.zero(originalCurrency);

    double sum = 0;
    for (final item in items) {
      if (item.currency == originalCurrency) {
        sum += item.totalPrice;
      }
    }
    return Money(amount: sum, currency: originalCurrency);
  }

  /// Check if receipt has been processed by OCR
  bool get isProcessed => status == ReceiptStatus.processed;

  /// Check if receipt processing failed
  bool get isFailed => status == ReceiptStatus.failed;

  /// Check if receipt is still pending
  bool get isPending => status == ReceiptStatus.pending;

  /// Check if receipt has been synced to cloud
  bool get isSynced => syncedAt != null && !needsSync;

  /// Check if receipt has images
  bool get hasImages => imageUrls.isNotEmpty || localImagePaths.isNotEmpty;

  /// Get all image paths (prefer cloud URLs, fallback to local)
  List<String> get allImagePaths {
    if (imageUrls.isNotEmpty) return imageUrls;
    return localImagePaths;
  }

  /// Get primary image URL
  String? get primaryImageUrl {
    if (imageUrls.isNotEmpty) return imageUrls.first;
    if (localImagePaths.isNotEmpty) return localImagePaths.first;
    return null;
  }

  /// Check if receipt has items
  bool get hasItems => items.isNotEmpty;

  /// Get number of items
  int get itemCount => items.length;

  /// Check if receipt has a linked store
  bool get hasLinkedStore => storeId != null;

  /// Check if OCR confidence is high
  bool get hasHighConfidence =>
      ocrConfidence != null && ocrConfidence! >= AppConstants.highOcrConfidence;

  /// Check if OCR confidence is acceptable
  bool get hasAcceptableConfidence =>
      ocrConfidence != null && ocrConfidence! >= AppConstants.minOcrConfidence;

  /// Get confidence as percentage string
  String get confidencePercentage {
    if (ocrConfidence == null) return 'N/A';
    return '${(ocrConfidence! * 100).toStringAsFixed(0)}%';
  }

  /// Get category display name based on locale
  String getCategoryDisplayName(String locale) {
    if (locale.startsWith('ar')) {
      return category.displayNameArabic;
    }
    return category.displayName;
  }

  /// Get status display name based on locale
  String getStatusDisplayName(String locale) {
    if (locale.startsWith('ar')) {
      return status.displayNameArabic;
    }
    return status.displayName;
  }

  /// Check if receipt needs review (low confidence or missing data)
  bool get needsReview {
    if (isFailed) return true;
    if (!hasAcceptableConfidence) return true;
    if (storeName.isEmpty) return true;
    if (total.isZero && hasImages) return true;
    return false;
  }

  /// Mark receipt as synced
  Receipt markSynced() {
    return copyWith(
      needsSync: false,
      syncedAt: DateTime.now(),
    );
  }

  /// Mark receipt for sync
  Receipt markForSync() {
    return copyWith(
      needsSync: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Update OCR results
  Receipt withOcrResults({
    required String storeName,
    required double totalAmountLbp,
    required double totalAmountUsd,
    required String originalCurrency,
    required List<ReceiptItem> items,
    required double confidence,
    required String rawText,
    String? storeId,
    ExpenseCategory? category,
    DateTime? receiptDate,
  }) {
    return copyWith(
      storeName: storeName,
      storeId: storeId,
      totalAmountLbp: totalAmountLbp,
      totalAmountUsd: totalAmountUsd,
      originalCurrency: originalCurrency,
      items: items,
      ocrConfidence: confidence,
      rawOcrText: rawText,
      category: category ?? this.category,
      date: receiptDate ?? date,
      status: confidence >= AppConstants.minOcrConfidence
          ? ReceiptStatus.processed
          : ReceiptStatus.failed,
      updatedAt: DateTime.now(),
      needsSync: true,
    );
  }

  /// Soft delete receipt
  Receipt softDelete() {
    return copyWith(
      isDeleted: true,
      updatedAt: DateTime.now(),
      needsSync: true,
    );
  }
}

/// Filter options for querying receipts
@freezed
class ReceiptFilter with _$ReceiptFilter {
  const factory ReceiptFilter({
    String? userId,
    String? storeId,
    ExpenseCategory? category,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    double? minAmount,
    double? maxAmount,
    String? currency,
    ReceiptStatus? status,
    @Default(false) bool includeDeleted,
    @Default(20) int limit,
    @Default(0) int offset,
    @Default(ReceiptSortField.date) ReceiptSortField sortBy,
    @Default(true) bool sortDescending,
  }) = _ReceiptFilter;

  factory ReceiptFilter.fromJson(Map<String, dynamic> json) =>
      _$ReceiptFilterFromJson(json);
}

/// Sort fields for receipt queries
enum ReceiptSortField {
  date,
  amount,
  storeName,
  createdAt,
  updatedAt;

  String get displayName {
    return switch (this) {
      ReceiptSortField.date => 'Date',
      ReceiptSortField.amount => 'Amount',
      ReceiptSortField.storeName => 'Store',
      ReceiptSortField.createdAt => 'Created',
      ReceiptSortField.updatedAt => 'Updated',
    };
  }
}
