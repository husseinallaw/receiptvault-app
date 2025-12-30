import 'package:drift/drift.dart';

/// Receipt line items table
class ReceiptItems extends Table {
  /// Unique item ID
  TextColumn get id => text()();

  /// Parent receipt ID
  TextColumn get receiptId => text()();

  /// Item name
  TextColumn get name => text()();

  /// Quantity
  RealColumn get quantity => real().withDefault(const Constant(1))();

  /// Unit (e.g., kg, pcs, L)
  TextColumn get unit => text().nullable()();

  /// Unit price
  RealColumn get unitPrice => real()();

  /// Total price (quantity * unitPrice)
  RealColumn get totalPrice => real()();

  /// Currency (LBP or USD)
  TextColumn get currency => text().withDefault(const Constant('LBP'))();

  /// Product ID if matched to product catalog
  TextColumn get productId => text().nullable()();

  /// Category ID for this item
  TextColumn get categoryId => text().nullable()();

  /// Sort order within receipt
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// Created timestamp
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'CHECK(currency IN (\'LBP\', \'USD\'))',
        'FOREIGN KEY (receiptId) REFERENCES receipts(id) ON DELETE CASCADE',
      ];
}

/// Index for faster queries
@TableIndex(name: 'idx_receipt_items_receipt', columns: {#receiptId})
@TableIndex(name: 'idx_receipt_items_product', columns: {#productId})
class ReceiptItemsIndex extends ReceiptItems {}
