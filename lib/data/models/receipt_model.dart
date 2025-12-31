import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/entities/store.dart';
import 'receipt_item_model.dart';

/// Data model for Receipt with Firestore and Drift serialization
class ReceiptModel {
  final String id;
  final String userId;
  final String storeName;
  final String? storeId;
  final DateTime date;
  final List<ReceiptItemModel> items;
  final double totalAmountLbp;
  final double totalAmountUsd;
  final String originalCurrency;
  final ExpenseCategory category;
  final ReceiptStatus status;
  final double? ocrConfidence;
  final String? rawOcrText;
  final List<String> imageUrls;
  final List<String> localImagePaths;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;
  final bool needsSync;
  final bool isDeleted;

  ReceiptModel({
    required this.id,
    required this.userId,
    required this.storeName,
    this.storeId,
    required this.date,
    this.items = const [],
    this.totalAmountLbp = 0.0,
    this.totalAmountUsd = 0.0,
    this.originalCurrency = 'LBP',
    this.category = ExpenseCategory.other,
    this.status = ReceiptStatus.pending,
    this.ocrConfidence,
    this.rawOcrText,
    this.imageUrls = const [],
    this.localImagePaths = const [],
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
    this.needsSync = true,
    this.isDeleted = false,
  });

  /// Create from Firestore document
  factory ReceiptModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ReceiptModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      storeName: data['storeName'] as String? ?? '',
      storeId: data['storeId'] as String?,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      items: (data['items'] as List<dynamic>?)
              ?.map((e) => ReceiptItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmountLbp: (data['totalAmountLbp'] as num?)?.toDouble() ?? 0.0,
      totalAmountUsd: (data['totalAmountUsd'] as num?)?.toDouble() ?? 0.0,
      originalCurrency: data['originalCurrency'] as String? ?? 'LBP',
      category: ExpenseCategory.values.firstWhere(
        (e) => e.name == (data['category'] as String? ?? 'other'),
        orElse: () => ExpenseCategory.other,
      ),
      status: ReceiptStatus.fromString(data['status'] as String? ?? 'pending'),
      ocrConfidence: (data['ocrConfidence'] as num?)?.toDouble(),
      rawOcrText: data['rawOcrText'] as String?,
      imageUrls: (data['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      localImagePaths: [], // Not stored in Firestore
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      syncedAt: (data['syncedAt'] as Timestamp?)?.toDate(),
      needsSync: false, // Freshly fetched from Firestore
      isDeleted: data['isDeleted'] as bool? ?? false,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'storeName': storeName,
      'storeId': storeId,
      'date': Timestamp.fromDate(date),
      'items': items.map((e) => e.toJson()).toList(),
      'totalAmountLbp': totalAmountLbp,
      'totalAmountUsd': totalAmountUsd,
      'originalCurrency': originalCurrency,
      'category': category.name,
      'status': status.name,
      'ocrConfidence': ocrConfidence,
      'rawOcrText': rawOcrText,
      'imageUrls': imageUrls,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'syncedAt': FieldValue.serverTimestamp(),
      'isDeleted': isDeleted,
    };
  }

  /// Create from domain entity
  factory ReceiptModel.fromEntity(Receipt entity) {
    return ReceiptModel(
      id: entity.id,
      userId: entity.userId,
      storeName: entity.storeName,
      storeId: entity.storeId,
      date: entity.date,
      items: entity.items.map((e) => ReceiptItemModel.fromEntity(e)).toList(),
      totalAmountLbp: entity.totalAmountLbp,
      totalAmountUsd: entity.totalAmountUsd,
      originalCurrency: entity.originalCurrency,
      category: entity.category,
      status: entity.status,
      ocrConfidence: entity.ocrConfidence,
      rawOcrText: entity.rawOcrText,
      imageUrls: entity.imageUrls,
      localImagePaths: entity.localImagePaths,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      syncedAt: entity.syncedAt,
      needsSync: entity.needsSync,
      isDeleted: entity.isDeleted,
    );
  }

  /// Convert to domain entity
  Receipt toEntity() {
    return Receipt(
      id: id,
      userId: userId,
      storeName: storeName,
      storeId: storeId,
      date: date,
      items: items.map((e) => e.toEntity()).toList(),
      totalAmountLbp: totalAmountLbp,
      totalAmountUsd: totalAmountUsd,
      originalCurrency: originalCurrency,
      category: category,
      status: status,
      ocrConfidence: ocrConfidence,
      rawOcrText: rawOcrText,
      imageUrls: imageUrls,
      localImagePaths: localImagePaths,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncedAt: syncedAt,
      needsSync: needsSync,
      isDeleted: isDeleted,
    );
  }

  /// Create from Drift database row
  factory ReceiptModel.fromDrift({
    required String id,
    required String userId,
    required String storeName,
    String? storeId,
    required DateTime date,
    required double totalAmountLbp,
    required double totalAmountUsd,
    required String originalCurrency,
    String? categoryId,
    required String status,
    double? ocrConfidence,
    String? rawOcrText,
    String? imageUrls,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? syncedAt,
    required bool needsSync,
    required bool isDeleted,
    List<ReceiptItemModel>? items,
  }) {
    return ReceiptModel(
      id: id,
      userId: userId,
      storeName: storeName,
      storeId: storeId,
      date: date,
      items: items ?? [],
      totalAmountLbp: totalAmountLbp,
      totalAmountUsd: totalAmountUsd,
      originalCurrency: originalCurrency,
      category: ExpenseCategory.values.firstWhere(
        (e) => e.name == (categoryId ?? 'other'),
        orElse: () => ExpenseCategory.other,
      ),
      status: ReceiptStatus.fromString(status),
      ocrConfidence: ocrConfidence,
      rawOcrText: rawOcrText,
      imageUrls:
          imageUrls != null && imageUrls.isNotEmpty ? imageUrls.split(',') : [],
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncedAt: syncedAt,
      needsSync: needsSync,
      isDeleted: isDeleted,
    );
  }

  /// Convert to Drift companion
  Map<String, dynamic> toDriftCompanion() {
    return {
      'id': id,
      'userId': userId,
      'storeName': storeName,
      'storeId': storeId,
      'date': date,
      'totalAmountLbp': totalAmountLbp,
      'totalAmountUsd': totalAmountUsd,
      'originalCurrency': originalCurrency,
      'categoryId': category.name,
      'status': status.name,
      'ocrConfidence': ocrConfidence,
      'rawOcrText': rawOcrText,
      'imageUrls': imageUrls.join(','),
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'syncedAt': syncedAt,
      'needsSync': needsSync,
      'isDeleted': isDeleted,
    };
  }

  ReceiptModel copyWith({
    String? id,
    String? userId,
    String? storeName,
    String? storeId,
    DateTime? date,
    List<ReceiptItemModel>? items,
    double? totalAmountLbp,
    double? totalAmountUsd,
    String? originalCurrency,
    ExpenseCategory? category,
    ReceiptStatus? status,
    double? ocrConfidence,
    String? rawOcrText,
    List<String>? imageUrls,
    List<String>? localImagePaths,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
    bool? needsSync,
    bool? isDeleted,
  }) {
    return ReceiptModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      storeName: storeName ?? this.storeName,
      storeId: storeId ?? this.storeId,
      date: date ?? this.date,
      items: items ?? this.items,
      totalAmountLbp: totalAmountLbp ?? this.totalAmountLbp,
      totalAmountUsd: totalAmountUsd ?? this.totalAmountUsd,
      originalCurrency: originalCurrency ?? this.originalCurrency,
      category: category ?? this.category,
      status: status ?? this.status,
      ocrConfidence: ocrConfidence ?? this.ocrConfidence,
      rawOcrText: rawOcrText ?? this.rawOcrText,
      imageUrls: imageUrls ?? this.imageUrls,
      localImagePaths: localImagePaths ?? this.localImagePaths,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      needsSync: needsSync ?? this.needsSync,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
