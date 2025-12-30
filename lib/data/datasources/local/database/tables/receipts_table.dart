import 'package:drift/drift.dart';

/// Local receipts table for offline-first storage
class Receipts extends Table {
  /// Unique receipt ID (matches Firestore document ID)
  TextColumn get id => text()();

  /// User ID who owns this receipt
  TextColumn get userId => text()();

  /// Store name (detected or entered)
  TextColumn get storeName => text()();

  /// Store ID if recognized
  TextColumn get storeId => text().nullable()();

  /// Receipt date
  DateTimeColumn get date => dateTime()();

  /// Total amount in LBP
  RealColumn get totalAmountLbp => real().withDefault(const Constant(0))();

  /// Total amount in USD
  RealColumn get totalAmountUsd => real().withDefault(const Constant(0))();

  /// Original currency of receipt (LBP or USD)
  TextColumn get originalCurrency => text().withDefault(const Constant('LBP'))();

  /// Category ID
  TextColumn get categoryId => text().nullable()();

  /// Processing status: pending, processed, failed
  TextColumn get status => text().withDefault(const Constant('pending'))();

  /// OCR confidence score (0.0 - 1.0)
  RealColumn get ocrConfidence => real().nullable()();

  /// Raw OCR text
  TextColumn get rawOcrText => text().nullable()();

  /// Image URLs (JSON array)
  TextColumn get imageUrls => text().nullable()();

  /// Notes
  TextColumn get notes => text().nullable()();

  /// Created timestamp
  DateTimeColumn get createdAt => dateTime()();

  /// Updated timestamp
  DateTimeColumn get updatedAt => dateTime()();

  /// Synced to cloud timestamp
  DateTimeColumn get syncedAt => dateTime().nullable()();

  /// Needs sync flag
  BoolColumn get needsSync => boolean().withDefault(const Constant(true))();

  /// Deleted flag (soft delete)
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'CHECK(status IN (\'pending\', \'processed\', \'failed\'))',
        'CHECK(originalCurrency IN (\'LBP\', \'USD\'))',
      ];
}

/// Index for faster queries
@TableIndex(name: 'idx_receipts_user_date', columns: {#userId, #date})
@TableIndex(name: 'idx_receipts_needs_sync', columns: {#needsSync})
@TableIndex(name: 'idx_receipts_store', columns: {#userId, #storeId})
class ReceiptsIndex extends Receipts {}
