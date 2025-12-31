import '../../domain/entities/receipt_item.dart';

/// Data model for ReceiptItem with JSON serialization
class ReceiptItemModel {
  final String id;
  final String receiptId;
  final String name;
  final double quantity;
  final String? unit;
  final double unitPrice;
  final double totalPrice;
  final String currency;
  final String? productId;
  final String? categoryId;
  final int sortOrder;
  final DateTime createdAt;

  ReceiptItemModel({
    required this.id,
    required this.receiptId,
    required this.name,
    this.quantity = 1.0,
    this.unit,
    required this.unitPrice,
    required this.totalPrice,
    this.currency = 'LBP',
    this.productId,
    this.categoryId,
    this.sortOrder = 0,
    required this.createdAt,
  });

  /// Create from JSON (Firestore)
  factory ReceiptItemModel.fromJson(Map<String, dynamic> json) {
    return ReceiptItemModel(
      id: json['id'] as String? ?? '',
      receiptId: json['receiptId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: json['unit'] as String?,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'LBP',
      productId: json['productId'] as String?,
      categoryId: json['categoryId'] as String?,
      sortOrder: json['sortOrder'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  /// Convert to JSON (Firestore)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receiptId': receiptId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'currency': currency,
      'productId': productId,
      'categoryId': categoryId,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from domain entity
  factory ReceiptItemModel.fromEntity(ReceiptItem entity) {
    return ReceiptItemModel(
      id: entity.id,
      receiptId: entity.receiptId,
      name: entity.name,
      quantity: entity.quantity,
      unit: entity.unit,
      unitPrice: entity.unitPrice,
      totalPrice: entity.totalPrice,
      currency: entity.currency,
      productId: entity.productId,
      categoryId: entity.categoryId,
      sortOrder: entity.sortOrder,
      createdAt: entity.createdAt,
    );
  }

  /// Convert to domain entity
  ReceiptItem toEntity() {
    return ReceiptItem(
      id: id,
      receiptId: receiptId,
      name: name,
      quantity: quantity,
      unit: unit,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      currency: currency,
      productId: productId,
      categoryId: categoryId,
      sortOrder: sortOrder,
      createdAt: createdAt,
    );
  }

  /// Create from Drift database row
  factory ReceiptItemModel.fromDrift({
    required String id,
    required String receiptId,
    required String name,
    required double quantity,
    String? unit,
    required double unitPrice,
    required double totalPrice,
    required String currency,
    String? productId,
    String? categoryId,
    required int sortOrder,
    required DateTime createdAt,
  }) {
    return ReceiptItemModel(
      id: id,
      receiptId: receiptId,
      name: name,
      quantity: quantity,
      unit: unit,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      currency: currency,
      productId: productId,
      categoryId: categoryId,
      sortOrder: sortOrder,
      createdAt: createdAt,
    );
  }

  /// Convert to Drift companion
  Map<String, dynamic> toDriftCompanion() {
    return {
      'id': id,
      'receiptId': receiptId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'currency': currency,
      'productId': productId,
      'categoryId': categoryId,
      'sortOrder': sortOrder,
      'createdAt': createdAt,
    };
  }

  ReceiptItemModel copyWith({
    String? id,
    String? receiptId,
    String? name,
    double? quantity,
    String? unit,
    double? unitPrice,
    double? totalPrice,
    String? currency,
    String? productId,
    String? categoryId,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return ReceiptItemModel(
      id: id ?? this.id,
      receiptId: receiptId ?? this.receiptId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      currency: currency ?? this.currency,
      productId: productId ?? this.productId,
      categoryId: categoryId ?? this.categoryId,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
