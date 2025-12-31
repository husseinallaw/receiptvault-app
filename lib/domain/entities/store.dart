import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/constants/lebanon_stores.dart';

part 'store.freezed.dart';
part 'store.g.dart';

/// Entity representing a store/merchant
///
/// Stores are used for:
/// - Linking receipts to known merchants
/// - OCR pattern matching for automatic store detection
/// - Category inference based on store type
/// - Display of store branding (logo, color)
@freezed
class Store with _$Store {
  const Store._();

  const factory Store({
    required String id,
    required String name,
    String? nameArabic,
    @Default(StoreType.other) StoreType type,
    String? logoUrl,
    String? color,
    @Default([]) List<String> receiptPatterns,
    @Default(true) bool isActive,
    required DateTime updatedAt,
  }) = _Store;

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);

  /// Create from the static LebanonStores constant
  factory Store.fromStoreInfo(StoreInfo info) {
    return Store(
      id: info.id,
      name: info.name,
      nameArabic: info.nameArabic,
      type: info.type,
      logoUrl: info.logoAsset,
      color:
          '#${info.color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
      receiptPatterns: info.receiptPatterns,
      isActive: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Create a custom/unknown store
  factory Store.custom({
    required String id,
    required String name,
    String? nameArabic,
    StoreType type = StoreType.other,
  }) {
    return Store(
      id: id,
      name: name,
      nameArabic: nameArabic,
      type: type,
      updatedAt: DateTime.now(),
    );
  }

  /// Get display name based on locale
  String getDisplayName(String locale) {
    if (locale.startsWith('ar') && nameArabic != null) {
      return nameArabic!;
    }
    return name;
  }

  /// Get store type display name based on locale
  String getTypeDisplayName(String locale) {
    if (locale.startsWith('ar')) {
      return type.displayNameArabic;
    }
    return type.displayName;
  }

  /// Check if store matches given text (for OCR detection)
  bool matchesText(String text) {
    final lowerText = text.toLowerCase();
    for (final pattern in receiptPatterns) {
      if (lowerText.contains(pattern.toLowerCase())) {
        return true;
      }
    }
    // Also check name and Arabic name
    if (lowerText.contains(name.toLowerCase())) {
      return true;
    }
    if (nameArabic != null && text.contains(nameArabic!)) {
      return true;
    }
    return false;
  }

  /// Get default category for this store type
  String? get defaultCategoryId {
    return switch (type) {
      StoreType.supermarket => 'groceries',
      StoreType.gasStation => 'fuel',
      StoreType.pharmacy => 'health',
      StoreType.restaurant => 'dining',
      StoreType.other => null,
    };
  }

  /// Check if store has a logo
  bool get hasLogo => logoUrl != null && logoUrl!.isNotEmpty;

  /// Check if store has a custom color
  bool get hasColor => color != null && color!.isNotEmpty;
}

/// Receipt status enum
enum ReceiptStatus {
  /// Receipt is being processed by OCR
  pending,

  /// Receipt has been successfully processed
  processed,

  /// OCR processing failed
  failed;

  String get displayName {
    return switch (this) {
      ReceiptStatus.pending => 'Pending',
      ReceiptStatus.processed => 'Processed',
      ReceiptStatus.failed => 'Failed',
    };
  }

  String get displayNameArabic {
    return switch (this) {
      ReceiptStatus.pending => 'قيد المعالجة',
      ReceiptStatus.processed => 'تمت المعالجة',
      ReceiptStatus.failed => 'فشلت المعالجة',
    };
  }

  /// Parse from string value (used for database/API)
  static ReceiptStatus fromString(String value) {
    return switch (value.toLowerCase()) {
      'pending' => ReceiptStatus.pending,
      'processed' => ReceiptStatus.processed,
      'failed' => ReceiptStatus.failed,
      _ => ReceiptStatus.pending,
    };
  }
}
