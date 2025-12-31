import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import '../../core/errors/exceptions.dart';
import '../../data/models/ocr_result_model.dart';
import '../../domain/repositories/receipt_repository.dart';
import 'receipt_extractor.dart';

/// Service for OCR processing of receipt images
///
/// Uses Firebase Cloud Functions to call Google Cloud Vision API.
/// Also provides local parsing fallback for offline scenarios.
class OcrService {
  final FirebaseFunctions _functions;
  final ReceiptExtractor _extractor;

  OcrService({
    FirebaseFunctions? functions,
    ReceiptExtractor? extractor,
  })  : _functions = functions ?? FirebaseFunctions.instance,
        _extractor = extractor ?? ReceiptExtractor();

  /// Process a receipt image using Cloud Vision API via Cloud Function
  ///
  /// Parameters:
  /// - [imageUrl]: Firebase Storage URL of the uploaded image
  /// - [userId]: User ID for authentication
  ///
  /// Returns structured OCR result with extracted data
  Future<OcrResult> processReceipt({
    required String imageUrl,
    required String userId,
  }) async {
    try {
      final callable = _functions.httpsCallable(
        'processReceipt',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 60),
        ),
      );

      final result = await callable.call<Map<String, dynamic>>({
        'imageUrl': imageUrl,
        'userId': userId,
      });

      final data = result.data;

      if (data['success'] != true) {
        throw OcrException(
          'OCR processing failed',
          code: 'ocr_failed',
        );
      }

      final extractedData = data['data'] as Map<String, dynamic>?;
      if (extractedData == null) {
        throw const OcrException(
          'No data extracted from receipt',
          code: 'no_data',
        );
      }

      return _parseCloudFunctionResult(
        extractedData,
        data['receiptId'] as String?,
      );
    } on FirebaseFunctionsException catch (e) {
      throw OcrException(
        'OCR Cloud Function failed: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      if (e is OcrException) rethrow;
      throw OcrException('OCR processing failed: $e');
    }
  }

  /// Process receipt image locally (offline fallback)
  ///
  /// Uses local parsing without Cloud Vision API.
  /// Limited accuracy but works offline.
  Future<OcrResult> processReceiptLocally(Uint8List imageBytes) async {
    // For local processing, we would need ML Kit or similar
    // This is a placeholder that returns an empty result
    return const OcrResult(
      rawText: '',
      confidence: 0.0,
      currency: 'LBP',
    );
  }

  /// Parse raw OCR text locally
  ///
  /// Useful for re-parsing previously extracted text
  OcrResult parseOcrText(String rawText) {
    return _extractor.extract(rawText);
  }

  /// Parse Cloud Function result into OcrResult
  OcrResult _parseCloudFunctionResult(
    Map<String, dynamic> data,
    String? receiptId,
  ) {
    final items = <OcrLineItemModel>[];

    final itemsList = data['items'] as List<dynamic>?;
    if (itemsList != null) {
      for (final item in itemsList) {
        final itemMap = item as Map<String, dynamic>;
        items.add(OcrLineItemModel(
          name: itemMap['name'] as String? ?? '',
          quantity: (itemMap['quantity'] as num?)?.toDouble() ?? 1.0,
          unitPrice: (itemMap['unitPrice'] as num?)?.toDouble() ?? 0.0,
          totalPrice: (itemMap['totalPrice'] as num?)?.toDouble() ?? 0.0,
          currency: data['currency'] as String? ?? 'LBP',
          confidence: (itemMap['confidence'] as num?)?.toDouble() ?? 0.8,
        ));
      }
    }

    final currency = data['currency'] as String? ?? 'LBP';
    final totalLBP = (data['totalLBP'] as num?)?.toDouble();
    final totalUSD = (data['totalUSD'] as num?)?.toDouble();

    DateTime? date;
    final dateStr = data['date'] as String?;
    if (dateStr != null) {
      try {
        date = DateTime.parse(dateStr);
      } catch (_) {
        // Ignore invalid date
      }
    }

    return OcrResultModel.parsed(
      rawText: data['rawText'] as String? ?? '',
      confidence: (data['confidence'] as num?)?.toDouble() ?? 0.0,
      storeName: data['storeName'] as String?,
      storeId: data['storeId'] as String?,
      date: date,
      items: items,
      totalAmount: currency == 'USD' ? totalUSD : totalLBP,
      currency: currency,
    ).toEntity();
  }
}
