import 'dart:typed_data';

import '../../../core/utils/result.dart';
import '../../entities/receipt.dart';
import '../../repositories/receipt_repository.dart';

/// Use case for saving a new receipt
///
/// Creates the receipt locally first for offline-first behavior,
/// then queues it for sync to cloud storage.
class SaveReceipt {
  final ReceiptRepository _repository;

  SaveReceipt(this._repository);

  /// Save a new receipt
  ///
  /// Parameters:
  /// - [receipt]: The receipt to save
  ///
  /// Returns the saved receipt with any server-generated fields
  Future<Result<Receipt>> call(Receipt receipt) {
    return _repository.createReceipt(receipt);
  }

  /// Save receipt with image upload
  ///
  /// Creates receipt and uploads images to cloud storage
  Future<Result<Receipt>> withImages({
    required Receipt receipt,
    required List<ImageData> images,
  }) async {
    // First create the receipt
    final createResult = await _repository.createReceipt(receipt);

    return createResult.when(
      success: (savedReceipt) async {
        // Upload each image
        final uploadedUrls = <String>[];

        for (final image in images) {
          final uploadResult = await _repository.uploadReceiptImage(
            receiptId: savedReceipt.id,
            userId: savedReceipt.userId,
            imageBytes: image.bytes,
            fileName: image.fileName,
          );

          final url = uploadResult.dataOrNull;
          if (url != null) {
            uploadedUrls.add(url);
          }
        }

        // Update receipt with image URLs
        if (uploadedUrls.isNotEmpty) {
          final updatedReceipt = savedReceipt.copyWith(
            imageUrls: uploadedUrls,
            localImagePaths: [], // Clear local paths after upload
            updatedAt: DateTime.now(),
          );
          return _repository.updateReceipt(updatedReceipt);
        }

        return Result.success(savedReceipt);
      },
      failure: (failure) => Result.failure(failure),
    );
  }
}

/// Image data for upload
class ImageData {
  final Uint8List bytes;
  final String? fileName;

  const ImageData({
    required this.bytes,
    this.fileName,
  });
}
