import 'package:drift/drift.dart';

/// User budgets table
class Budgets extends Table {
  /// Unique budget ID
  TextColumn get id => text()();

  /// User ID who owns this budget
  TextColumn get userId => text()();

  /// Budget name
  TextColumn get name => text()();

  /// Budget amount
  RealColumn get amount => real()();

  /// Currency (LBP or USD)
  TextColumn get currency => text().withDefault(const Constant('LBP'))();

  /// Category ID (null for overall budget)
  TextColumn get categoryId => text().nullable()();

  /// Period type: daily, weekly, monthly, yearly
  TextColumn get periodType => text().withDefault(const Constant('monthly'))();

  /// Period start date
  DateTimeColumn get startDate => dateTime()();

  /// Period end date
  DateTimeColumn get endDate => dateTime()();

  /// Current spent amount
  RealColumn get spentAmount => real().withDefault(const Constant(0))();

  /// Alert threshold (0.0 - 1.0, e.g., 0.8 = 80%)
  RealColumn get alertThreshold => real().withDefault(const Constant(0.8))();

  /// Whether alerts are enabled
  BoolColumn get alertsEnabled => boolean().withDefault(const Constant(true))();

  /// Whether budget is active
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// Created timestamp
  DateTimeColumn get createdAt => dateTime()();

  /// Updated timestamp
  DateTimeColumn get updatedAt => dateTime()();

  /// Synced to cloud timestamp
  DateTimeColumn get syncedAt => dateTime().nullable()();

  /// Needs sync flag
  BoolColumn get needsSync => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'CHECK(currency IN (\'LBP\', \'USD\'))',
        'CHECK(periodType IN (\'daily\', \'weekly\', \'monthly\', \'yearly\'))',
        'CHECK(alertThreshold >= 0 AND alertThreshold <= 1)',
      ];
}

/// Index for faster queries
@TableIndex(name: 'idx_budgets_user', columns: {#userId})
@TableIndex(name: 'idx_budgets_active', columns: {#userId, #isActive})
@TableIndex(name: 'idx_budgets_category', columns: {#userId, #categoryId})
class BudgetsIndex extends Budgets {}
