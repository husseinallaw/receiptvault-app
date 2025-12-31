import 'dart:typed_data';

import '../../../core/utils/result.dart';
import '../../repositories/receipt_repository.dart';

/// Use case for scanning a receipt image with OCR
///
/// Takes raw image bytes and returns an OCR result with
/// extracted store name, items, total, and other data.
class ScanReceipt {
  final ReceiptRepository _repository;

  ScanReceipt(this._repository);

  /// Scan receipt image and extract data
  ///
  /// Parameters:
  /// - [imageBytes]: Raw image data (PNG/JPEG)
  ///
  /// Returns [OcrResult] containing:
  /// - Raw OCR text
  /// - Confidence score
  /// - Extracted store, items, total
  Future<Result<OcrResult>> call(Uint8List imageBytes) {
    return _repository.scanReceipt(imageBytes);
  }
}
