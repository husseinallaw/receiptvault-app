import '../../domain/repositories/receipt_repository.dart';

/// Data model for OCR result from Cloud Vision API
class OcrResultModel {
  final String rawText;
  final double confidence;
  final String? storeName;
  final String? storeId;
  final DateTime? date;
  final List<OcrLineItemModel> items;
  final double? totalAmount;
  final String currency;
  final double? subtotal;
  final double? tax;
  final double? discount;
  final String? paymentMethod;
  final List<OcrBoundingBoxModel>? boundingBoxes;

  OcrResultModel({
    required this.rawText,
    required this.confidence,
    this.storeName,
    this.storeId,
    this.date,
    this.items = const [],
    this.totalAmount,
    this.currency = 'LBP',
    this.subtotal,
    this.tax,
    this.discount,
    this.paymentMethod,
    this.boundingBoxes,
  });

  /// Create from Cloud Vision API response
  factory OcrResultModel.fromCloudVision(Map<String, dynamic> response) {
    final fullTextAnnotation = response['fullTextAnnotation'];
    final rawText = fullTextAnnotation?['text'] as String? ?? '';

    // Extract confidence from block/paragraph/word level annotations
    double confidence = 0.0;
    if (fullTextAnnotation != null) {
      final pages = fullTextAnnotation['pages'] as List<dynamic>?;
      if (pages != null && pages.isNotEmpty) {
        final blocks = pages[0]['blocks'] as List<dynamic>?;
        if (blocks != null && blocks.isNotEmpty) {
          double totalConfidence = 0.0;
          int count = 0;
          for (final block in blocks) {
            final blockConfidence = (block['confidence'] as num?)?.toDouble();
            if (blockConfidence != null) {
              totalConfidence += blockConfidence;
              count++;
            }
          }
          if (count > 0) {
            confidence = totalConfidence / count;
          }
        }
      }
    }

    // Extract bounding boxes for text regions
    final boundingBoxes = <OcrBoundingBoxModel>[];
    final textAnnotations = response['textAnnotations'] as List<dynamic>?;
    if (textAnnotations != null) {
      for (int i = 1; i < textAnnotations.length; i++) {
        // Skip first (full text)
        final annotation = textAnnotations[i] as Map<String, dynamic>;
        final description = annotation['description'] as String? ?? '';
        final boundingPoly =
            annotation['boundingPoly'] as Map<String, dynamic>?;
        if (boundingPoly != null) {
          final vertices = boundingPoly['vertices'] as List<dynamic>?;
          if (vertices != null && vertices.length >= 4) {
            final x1 = (vertices[0]['x'] as num?)?.toDouble() ?? 0;
            final y1 = (vertices[0]['y'] as num?)?.toDouble() ?? 0;
            final x2 = (vertices[2]['x'] as num?)?.toDouble() ?? 0;
            final y2 = (vertices[2]['y'] as num?)?.toDouble() ?? 0;
            boundingBoxes.add(OcrBoundingBoxModel(
              left: x1,
              top: y1,
              width: x2 - x1,
              height: y2 - y1,
              type: 'text',
              text: description,
            ));
          }
        }
      }
    }

    return OcrResultModel(
      rawText: rawText,
      confidence: confidence,
      boundingBoxes: boundingBoxes,
    );
  }

  /// Create from parsed/processed result
  factory OcrResultModel.parsed({
    required String rawText,
    required double confidence,
    String? storeName,
    String? storeId,
    DateTime? date,
    List<OcrLineItemModel>? items,
    double? totalAmount,
    String currency = 'LBP',
    double? subtotal,
    double? tax,
    double? discount,
    String? paymentMethod,
    List<OcrBoundingBoxModel>? boundingBoxes,
  }) {
    return OcrResultModel(
      rawText: rawText,
      confidence: confidence,
      storeName: storeName,
      storeId: storeId,
      date: date,
      items: items ?? [],
      totalAmount: totalAmount,
      currency: currency,
      subtotal: subtotal,
      tax: tax,
      discount: discount,
      paymentMethod: paymentMethod,
      boundingBoxes: boundingBoxes,
    );
  }

  /// Convert to domain entity
  OcrResult toEntity() {
    return OcrResult(
      rawText: rawText,
      confidence: confidence,
      storeName: storeName,
      storeId: storeId,
      date: date,
      items: items.map((e) => e.toEntity()).toList(),
      totalAmount: totalAmount,
      currency: currency,
      subtotal: subtotal,
      tax: tax,
      discount: discount,
      paymentMethod: paymentMethod,
      boundingBoxes: boundingBoxes?.map((e) => e.toEntity()).toList(),
    );
  }

  OcrResultModel copyWith({
    String? rawText,
    double? confidence,
    String? storeName,
    String? storeId,
    DateTime? date,
    List<OcrLineItemModel>? items,
    double? totalAmount,
    String? currency,
    double? subtotal,
    double? tax,
    double? discount,
    String? paymentMethod,
    List<OcrBoundingBoxModel>? boundingBoxes,
  }) {
    return OcrResultModel(
      rawText: rawText ?? this.rawText,
      confidence: confidence ?? this.confidence,
      storeName: storeName ?? this.storeName,
      storeId: storeId ?? this.storeId,
      date: date ?? this.date,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      boundingBoxes: boundingBoxes ?? this.boundingBoxes,
    );
  }
}

/// Line item model from OCR
class OcrLineItemModel {
  final String name;
  final double quantity;
  final String? unit;
  final double unitPrice;
  final double totalPrice;
  final String currency;
  final double confidence;

  OcrLineItemModel({
    required this.name,
    this.quantity = 1,
    this.unit,
    required this.unitPrice,
    required this.totalPrice,
    this.currency = 'LBP',
    this.confidence = 1.0,
  });

  OcrLineItem toEntity() {
    return OcrLineItem(
      name: name,
      quantity: quantity,
      unit: unit,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      currency: currency,
      confidence: confidence,
    );
  }
}

/// Bounding box model for OCR regions
class OcrBoundingBoxModel {
  final double left;
  final double top;
  final double width;
  final double height;
  final String type;
  final String text;

  OcrBoundingBoxModel({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.type,
    required this.text,
  });

  OcrBoundingBox toEntity() {
    return OcrBoundingBox(
      left: left,
      top: top,
      width: width,
      height: height,
      type: type,
      text: text,
    );
  }
}
