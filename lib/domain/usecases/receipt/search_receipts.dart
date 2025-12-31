import '../../../core/constants/app_constants.dart';
import '../../../core/utils/result.dart';
import '../../entities/receipt.dart';
import '../../repositories/receipt_repository.dart';

/// Use case for searching receipts
///
/// Searches across store names, item names, and notes.
/// Supports full-text search with relevance ranking.
class SearchReceipts {
  final ReceiptRepository _repository;

  SearchReceipts(this._repository);

  /// Search receipts by text query
  ///
  /// Parameters:
  /// - [userId]: User identifier
  /// - [query]: Search query text
  /// - [limit]: Maximum number of results (default 20)
  ///
  /// Returns list of matching receipts sorted by relevance
  Future<Result<List<Receipt>>> call({
    required String userId,
    required String query,
    int limit = 20,
  }) {
    // Don't search with empty query
    if (query.trim().isEmpty) {
      return Future.value(const Result.success([]));
    }

    return _repository.searchReceipts(
      userId: userId,
      query: query.trim(),
      limit: limit,
    );
  }

  /// Search with advanced filters
  ///
  /// Combines text search with filter criteria
  Future<Result<List<Receipt>>> withFilters({
    required String userId,
    required String query,
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? storeId,
    double? minAmount,
    double? maxAmount,
    String? currency,
    int limit = 20,
  }) {
    final filter = ReceiptFilter(
      userId: userId,
      searchQuery: query.trim(),
      startDate: startDate,
      endDate: endDate,
      category: categoryId != null
          ? ExpenseCategory.values.firstWhere(
              (c) => c.name == categoryId,
              orElse: () => ExpenseCategory.other,
            )
          : null,
      storeId: storeId,
      minAmount: minAmount,
      maxAmount: maxAmount,
      currency: currency,
      limit: limit,
    );

    return _repository.getReceipts(filter);
  }

  /// Search by store name
  Future<Result<List<Receipt>>> byStoreName({
    required String userId,
    required String storeName,
    int limit = 20,
  }) {
    return _repository.searchReceipts(
      userId: userId,
      query: storeName,
      limit: limit,
    );
  }

  /// Search in item names
  Future<Result<List<Receipt>>> byItemName({
    required String userId,
    required String itemName,
    int limit = 20,
  }) {
    return _repository.searchReceipts(
      userId: userId,
      query: itemName,
      limit: limit,
    );
  }
}
