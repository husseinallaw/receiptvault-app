import '../../../core/utils/result.dart';
import '../../entities/receipt.dart';
import '../../repositories/receipt_repository.dart';

/// Use case for getting receipts with optional filters
///
/// Supports filtering by:
/// - Date range
/// - Category
/// - Store
/// - Amount range
/// - Status
/// - Search query
class GetReceipts {
  final ReceiptRepository _repository;

  GetReceipts(this._repository);

  /// Get receipts matching the filter criteria
  ///
  /// Parameters:
  /// - [filter]: Optional filter criteria
  ///
  /// Returns paginated list of receipts
  Future<Result<List<Receipt>>> call([ReceiptFilter? filter]) {
    return _repository.getReceipts(filter ?? const ReceiptFilter());
  }

  /// Get receipts for a specific user
  Future<Result<List<Receipt>>> forUser(String userId, {int limit = 20}) {
    return _repository.getReceipts(ReceiptFilter(
      userId: userId,
      limit: limit,
    ));
  }

  /// Get recent receipts
  Future<Result<List<Receipt>>> recent(String userId, {int limit = 10}) {
    return _repository.getReceipts(ReceiptFilter(
      userId: userId,
      limit: limit,
      sortBy: ReceiptSortField.date,
      sortDescending: true,
    ));
  }

  /// Get receipts by date range
  Future<Result<List<Receipt>>> byDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _repository.getReceiptsByDateRange(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Get receipts by category
  Future<Result<List<Receipt>>> byCategory({
    required String userId,
    required String categoryId,
    int limit = 20,
  }) {
    return _repository.getReceiptsByCategory(
      userId: userId,
      categoryId: categoryId,
      limit: limit,
    );
  }

  /// Get receipts by store
  Future<Result<List<Receipt>>> byStore({
    required String userId,
    required String storeId,
    int limit = 20,
  }) {
    return _repository.getReceiptsByStore(
      userId: userId,
      storeId: storeId,
      limit: limit,
    );
  }
}
