import '../../../core/utils/result.dart';
import '../../entities/receipt.dart';
import '../../repositories/receipt_repository.dart';

/// Use case for getting a single receipt by ID
///
/// Fetches receipt data from local database first,
/// then from remote if not found locally.
class GetReceiptById {
  final ReceiptRepository _repository;

  GetReceiptById(this._repository);

  /// Get receipt by its unique identifier
  ///
  /// Parameters:
  /// - [id]: Receipt unique identifier
  ///
  /// Returns the receipt or null if not found
  Future<Result<Receipt?>> call(String id) {
    return _repository.getReceiptById(id);
  }
}
