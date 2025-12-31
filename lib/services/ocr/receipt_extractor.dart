import '../../data/models/ocr_result_model.dart';
import '../../domain/repositories/receipt_repository.dart';
import 'ocr_parser.dart';

/// Extracts structured receipt data from raw OCR text
///
/// Uses [OcrParser] for low-level parsing and combines
/// results into a complete [OcrResult].
class ReceiptExtractor {
  final OcrParser _parser;

  ReceiptExtractor({OcrParser? parser}) : _parser = parser ?? OcrParser();

  /// Extract structured data from raw OCR text
  OcrResult extract(String rawText) {
    if (rawText.isEmpty) {
      return const OcrResult(
        rawText: '',
        confidence: 0.0,
        currency: 'LBP',
      );
    }

    // Detect store
    final storeMatch = _parser.detectStore(rawText);

    // Detect currency
    final currency = _parser.detectCurrency(rawText);

    // Extract date
    final date = _parser.extractDate(rawText);

    // Extract total
    final totalMatch = _parser.extractTotal(rawText);

    // Extract items
    final itemMatches = _parser.extractItems(rawText);

    // Convert items to models
    final items = itemMatches
        .map((m) => OcrLineItemModel(
              name: m.name,
              quantity: m.quantity,
              unitPrice: m.unitPrice,
              totalPrice: m.totalPrice,
              currency: m.currency,
              confidence: m.confidence,
            ))
        .toList();

    // Calculate overall confidence
    final confidence = _calculateConfidence(
      hasStore: storeMatch != null,
      hasDate: date != null,
      hasTotal: totalMatch != null,
      itemCount: items.length,
      storeConfidence: storeMatch?.confidence ?? 0,
      totalConfidence: totalMatch?.confidence ?? 0,
    );

    return OcrResultModel.parsed(
      rawText: rawText,
      confidence: confidence,
      storeName: storeMatch?.name,
      storeId: storeMatch?.id,
      date: date,
      items: items,
      totalAmount: totalMatch?.amount,
      currency: currency,
    ).toEntity();
  }

  /// Calculate overall extraction confidence
  double _calculateConfidence({
    required bool hasStore,
    required bool hasDate,
    required bool hasTotal,
    required int itemCount,
    required double storeConfidence,
    required double totalConfidence,
  }) {
    double score = 0;

    // Store detected: +30%
    if (hasStore) score += 0.3 * storeConfidence;

    // Date detected: +15%
    if (hasDate) score += 0.15;

    // Total detected: +35%
    if (hasTotal) score += 0.35 * totalConfidence;

    // Items detected: up to +20%
    if (itemCount > 0) {
      score += 0.2 * (itemCount > 5 ? 1.0 : itemCount / 5);
    }

    return score.clamp(0.0, 1.0);
  }

  /// Re-extract with custom store detection
  OcrResult extractWithStore({
    required String rawText,
    required String storeName,
    required String? storeId,
  }) {
    final baseResult = extract(rawText);

    return OcrResultModel.parsed(
      rawText: baseResult.rawText,
      confidence: baseResult.confidence,
      storeName: storeName,
      storeId: storeId,
      date: baseResult.date,
      items: baseResult.items
          .map((i) => OcrLineItemModel(
                name: i.name,
                quantity: i.quantity,
                unitPrice: i.unitPrice,
                totalPrice: i.totalPrice,
                currency: i.currency,
                confidence: i.confidence,
              ))
          .toList(),
      totalAmount: baseResult.totalAmount,
      currency: baseResult.currency,
    ).toEntity();
  }

  /// Validate extraction result
  ExtractionValidation validate(OcrResult result) {
    final issues = <String>[];

    if (result.storeName == null || result.storeName!.isEmpty) {
      issues.add('Store not detected');
    }

    if (result.date == null) {
      issues.add('Date not detected');
    }

    if (result.totalAmount == null || result.totalAmount! <= 0) {
      issues.add('Total amount not detected');
    }

    if (result.items.isEmpty) {
      issues.add('No items detected');
    }

    // Check for reasonable values
    if (result.totalAmount != null) {
      final itemsTotal = result.items.fold<double>(
        0,
        (sum, item) => sum + item.totalPrice,
      );

      if (itemsTotal > 0 && result.totalAmount! > 0) {
        final difference = (itemsTotal - result.totalAmount!).abs();
        final percentDiff = difference / result.totalAmount!;

        if (percentDiff > 0.1) {
          issues.add(
              'Items total differs from receipt total by ${(percentDiff * 100).toStringAsFixed(0)}%');
        }
      }
    }

    return ExtractionValidation(
      isValid: issues.isEmpty,
      issues: issues,
      confidence: result.confidence,
    );
  }
}

/// Validation result for extraction
class ExtractionValidation {
  final bool isValid;
  final List<String> issues;
  final double confidence;

  const ExtractionValidation({
    required this.isValid,
    required this.issues,
    required this.confidence,
  });

  bool get needsReview => !isValid || confidence < 0.8;
}
