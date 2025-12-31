import 'package:freezed_annotation/freezed_annotation.dart';
import 'money.dart';

part 'receipt_item.freezed.dart';
part 'receipt_item.g.dart';

/// Entity representing a single line item on a receipt
///
/// Each item captures:
/// - Product name and optional product ID for catalog linking
/// - Quantity and unit (e.g., 2 kg, 3 pcs)
/// - Unit price and total price with currency
/// - Category for expense categorization
/// - Sort order for display sequence
@freezed
class ReceiptItem with _$ReceiptItem {
  const ReceiptItem._();

  const factory ReceiptItem({
    required String id,
    required String receiptId,
    required String name,
    @Default(1.0) double quantity,
    String? unit,
    required double unitPrice,
    required double totalPrice,
    @Default('LBP') String currency,
    String? productId,
    String? categoryId,
    @Default(0) int sortOrder,
    required DateTime createdAt,
  }) = _ReceiptItem;

  factory ReceiptItem.fromJson(Map<String, dynamic> json) =>
      _$ReceiptItemFromJson(json);

  /// Create a new item with default values
  factory ReceiptItem.create({
    required String id,
    required String receiptId,
    required String name,
    double quantity = 1.0,
    String? unit,
    required double unitPrice,
    double? totalPrice,
    String currency = 'LBP',
    String? productId,
    String? categoryId,
    int sortOrder = 0,
  }) {
    return ReceiptItem(
      id: id,
      receiptId: receiptId,
      name: name,
      quantity: quantity,
      unit: unit,
      unitPrice: unitPrice,
      totalPrice: totalPrice ?? (unitPrice * quantity),
      currency: currency,
      productId: productId,
      categoryId: categoryId,
      sortOrder: sortOrder,
      createdAt: DateTime.now(),
    );
  }

  /// Get total as Money value object
  Money get total => Money(amount: totalPrice, currency: currency);

  /// Get unit price as Money value object
  Money get pricePerUnit => Money(amount: unitPrice, currency: currency);

  /// Check if this item has a linked product
  bool get hasLinkedProduct => productId != null;

  /// Check if this item has a category
  bool get hasCategory => categoryId != null;

  /// Format quantity with unit
  ///
  /// Examples:
  /// - "2 kg"
  /// - "3 pcs"
  /// - "1.5"
  String get formattedQuantity {
    final qty = quantity == quantity.roundToDouble()
        ? quantity.toInt().toString()
        : quantity.toStringAsFixed(2);
    if (unit != null && unit!.isNotEmpty) {
      return '$qty $unit';
    }
    return qty;
  }

  /// Format the item for display
  ///
  /// Example: "Milk 1L x 2 = \$5.00"
  String formatForDisplay() {
    if (quantity == 1) {
      return '$name - ${total.format()}';
    }
    return '$name x $formattedQuantity - ${total.format()}';
  }
}

/// Common units used in Lebanese receipts
abstract class ItemUnits {
  static const String kilogram = 'kg';
  static const String gram = 'g';
  static const String liter = 'L';
  static const String milliliter = 'ml';
  static const String piece = 'pcs';
  static const String box = 'box';
  static const String pack = 'pack';
  static const String bottle = 'btl';
  static const String can = 'can';
  static const String bag = 'bag';

  static const List<String> all = [
    kilogram,
    gram,
    liter,
    milliliter,
    piece,
    box,
    pack,
    bottle,
    can,
    bag,
  ];

  /// Get Arabic name for unit
  static String getArabicName(String unit) {
    return switch (unit) {
      kilogram => 'كغ',
      gram => 'غ',
      liter => 'ل',
      milliliter => 'مل',
      piece => 'قطعة',
      box => 'علبة',
      pack => 'رزمة',
      bottle => 'زجاجة',
      can => 'علبة',
      bag => 'كيس',
      _ => unit,
    };
  }
}
