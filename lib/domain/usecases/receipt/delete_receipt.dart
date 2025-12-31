import '../../../core/utils/result.dart';
import '../../repositories/receipt_repository.dart';

/// Use case for deleting a receipt
///
/// Performs soft delete by default (marks as deleted but retains data).
/// Hard delete permanently removes all data including images.
class DeleteReceipt {
  final ReceiptRepository _repository;

  DeleteReceipt(this._repository);

  /// Soft delete a receipt
  ///
  /// Marks the receipt as deleted but retains data for recovery.
  /// The receipt will be excluded from queries but can be restored.
  ///
  /// Parameters:
  /// - [id]: Receipt unique identifier
  Future<Result<void>> call(String id) {
    return _repository.deleteReceipt(id);
  }

  /// Permanently delete a receipt
  ///
  /// Removes receipt from local and remote storage.
  /// Also deletes associated images from cloud storage.
  /// This action cannot be undone.
  ///
  /// Parameters:
  /// - [id]: Receipt unique identifier
  Future<Result<void>> permanently(String id) {
    return _repository.hardDeleteReceipt(id);
  }

  /// Delete receipt image
  ///
  /// Removes a specific image from the receipt.
  ///
  /// Parameters:
  /// - [imageUrl]: URL of the image to delete
  Future<Result<void>> deleteImage(String imageUrl) {
    return _repository.deleteReceiptImage(imageUrl);
  }
}
