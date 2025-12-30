import 'package:drift/drift.dart';

/// Stores reference table (cached from Firestore)
class Stores extends Table {
  /// Unique store ID
  TextColumn get id => text()();

  /// Store name (English)
  TextColumn get name => text()();

  /// Store name (Arabic)
  TextColumn get nameArabic => text().nullable()();

  /// Store type: supermarket, gas_station, pharmacy, restaurant, other
  TextColumn get type => text()();

  /// Logo URL
  TextColumn get logoUrl => text().nullable()();

  /// Brand color (hex)
  TextColumn get color => text().nullable()();

  /// Receipt patterns for OCR matching (JSON array)
  TextColumn get receiptPatterns => text().nullable()();

  /// Whether store is active
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// Last updated timestamp
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'CHECK(type IN (\'supermarket\', \'gas_station\', \'pharmacy\', \'restaurant\', \'other\'))',
      ];
}
