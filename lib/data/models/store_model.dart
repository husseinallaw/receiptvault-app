import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/lebanon_stores.dart';
import '../../domain/entities/store.dart';

/// Data model for Store with Firestore and Drift serialization
class StoreModel {
  final String id;
  final String name;
  final String? nameArabic;
  final StoreType type;
  final String? logoUrl;
  final String? color;
  final List<String> receiptPatterns;
  final bool isActive;
  final DateTime updatedAt;

  StoreModel({
    required this.id,
    required this.name,
    this.nameArabic,
    this.type = StoreType.other,
    this.logoUrl,
    this.color,
    this.receiptPatterns = const [],
    this.isActive = true,
    required this.updatedAt,
  });

  /// Create from Firestore document
  factory StoreModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return StoreModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      nameArabic: data['nameArabic'] as String?,
      type: StoreType.values.firstWhere(
        (e) => e.name == (data['type'] as String? ?? 'other'),
        orElse: () => StoreType.other,
      ),
      logoUrl: data['logoUrl'] as String?,
      color: data['color'] as String?,
      receiptPatterns: (data['receiptPatterns'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isActive: data['isActive'] as bool? ?? true,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'nameArabic': nameArabic,
      'type': type.name,
      'logoUrl': logoUrl,
      'color': color,
      'receiptPatterns': receiptPatterns,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create from domain entity
  factory StoreModel.fromEntity(Store entity) {
    return StoreModel(
      id: entity.id,
      name: entity.name,
      nameArabic: entity.nameArabic,
      type: entity.type,
      logoUrl: entity.logoUrl,
      color: entity.color,
      receiptPatterns: entity.receiptPatterns,
      isActive: entity.isActive,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert to domain entity
  Store toEntity() {
    return Store(
      id: id,
      name: name,
      nameArabic: nameArabic,
      type: type,
      logoUrl: logoUrl,
      color: color,
      receiptPatterns: receiptPatterns,
      isActive: isActive,
      updatedAt: updatedAt,
    );
  }

  /// Create from Drift database row
  factory StoreModel.fromDrift({
    required String id,
    required String name,
    String? nameArabic,
    required String type,
    String? logoUrl,
    String? color,
    String? receiptPatterns,
    required bool isActive,
    required DateTime updatedAt,
  }) {
    return StoreModel(
      id: id,
      name: name,
      nameArabic: nameArabic,
      type: StoreType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => StoreType.other,
      ),
      logoUrl: logoUrl,
      color: color,
      receiptPatterns: receiptPatterns != null && receiptPatterns.isNotEmpty
          ? receiptPatterns.split(',')
          : [],
      isActive: isActive,
      updatedAt: updatedAt,
    );
  }

  /// Convert to Drift companion
  Map<String, dynamic> toDriftCompanion() {
    return {
      'id': id,
      'name': name,
      'nameArabic': nameArabic,
      'type': type.name,
      'logoUrl': logoUrl,
      'color': color,
      'receiptPatterns': receiptPatterns.join(','),
      'isActive': isActive,
      'updatedAt': updatedAt,
    };
  }

  StoreModel copyWith({
    String? id,
    String? name,
    String? nameArabic,
    StoreType? type,
    String? logoUrl,
    String? color,
    List<String>? receiptPatterns,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return StoreModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameArabic: nameArabic ?? this.nameArabic,
      type: type ?? this.type,
      logoUrl: logoUrl ?? this.logoUrl,
      color: color ?? this.color,
      receiptPatterns: receiptPatterns ?? this.receiptPatterns,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
