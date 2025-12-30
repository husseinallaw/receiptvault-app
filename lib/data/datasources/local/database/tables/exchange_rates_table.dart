import 'package:drift/drift.dart';

/// Exchange rates table (cached from Firestore)
class ExchangeRates extends Table {
  /// Unique rate ID
  TextColumn get id => text()();

  /// Rate source: official, black_market, sayrafa
  TextColumn get source => text()();

  /// LBP to USD rate (how many LBP per 1 USD)
  RealColumn get lbpToUsd => real()();

  /// Whether this is the currently active rate for this source
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// Rate fetched timestamp
  DateTimeColumn get fetchedAt => dateTime()();

  /// Valid until timestamp
  DateTimeColumn get validUntil => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'CHECK(source IN (\'official\', \'black_market\', \'sayrafa\'))',
      ];
}

/// Index for faster queries
@TableIndex(name: 'idx_exchange_rates_active', columns: {#source, #isActive})
class ExchangeRatesIndex extends ExchangeRates {}
