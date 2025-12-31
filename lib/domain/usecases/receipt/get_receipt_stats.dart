import '../../../core/utils/result.dart';
import '../../repositories/receipt_repository.dart';

/// Use case for getting receipt statistics
///
/// Calculates spending totals, averages, and breakdowns
/// for a given date range.
class GetReceiptStats {
  final ReceiptRepository _repository;

  GetReceiptStats(this._repository);

  /// Get overall receipt statistics
  ///
  /// Parameters:
  /// - [userId]: User identifier
  /// - [startDate]: Start of date range
  /// - [endDate]: End of date range
  ///
  /// Returns comprehensive statistics including totals,
  /// averages, and breakdowns by category and store.
  Future<Result<ReceiptStats>> call({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _repository.getReceiptStats(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Get spending breakdown by category
  ///
  /// Returns map of category ID to total spending
  Future<Result<Map<String, double>>> byCategory({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String currency = 'LBP',
  }) {
    return _repository.getSpendingByCategory(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
      currency: currency,
    );
  }

  /// Get spending breakdown by store
  ///
  /// Returns map of store ID to total spending
  Future<Result<Map<String, double>>> byStore({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String currency = 'LBP',
  }) {
    return _repository.getSpendingByStore(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
      currency: currency,
    );
  }

  /// Get statistics for current month
  Future<Result<ReceiptStats>> currentMonth(String userId) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return call(
      userId: userId,
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
  }

  /// Get statistics for current year
  Future<Result<ReceiptStats>> currentYear(String userId) {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31, 23, 59, 59);

    return call(
      userId: userId,
      startDate: startOfYear,
      endDate: endOfYear,
    );
  }
}
