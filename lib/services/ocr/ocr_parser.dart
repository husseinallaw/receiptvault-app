/// Parser for extracting structured data from raw OCR text
///
/// Handles Lebanese receipt formats including:
/// - Dual currency (LBP and USD)
/// - Arabic and English text
/// - Common Lebanese store patterns
/// - Date formats used in Lebanon
class OcrParser {
  // Lebanese store patterns for recognition
  static final Map<String, RegExp> storePatterns = {
    'spinneys': RegExp(r'spinneys|سبينيز', caseSensitive: false),
    'happy': RegExp(r'happy|هابي', caseSensitive: false),
    'al_makhazen': RegExp(r'al.?makhazen|المخازن', caseSensitive: false),
    'charcutier_aoun': RegExp(r'charcutier|aoun|عون', caseSensitive: false),
    'total': RegExp(r'\btotal\b|توتال', caseSensitive: false),
    'medco': RegExp(r'medco|ميدكو', caseSensitive: false),
  };

  // Currency patterns
  static final RegExp lbpPattern = RegExp(
    r'LBP|L\.L\.|ل\.ل|ليرة',
    caseSensitive: false,
  );
  static final RegExp usdPattern = RegExp(
    r'USD|\$|دولار',
    caseSensitive: false,
  );

  // Price patterns
  static final RegExp pricePattern = RegExp(
    r'([\d,]+(?:\.\d{1,2})?)\s*(LBP|L\.L\.|ل\.ل|USD|\$|دولار)?',
    caseSensitive: false,
  );

  // Total patterns
  static final RegExp totalPattern = RegExp(
    r'(total|المجموع|الإجمالي|الكلي|net|صافي)\s*:?\s*([\d,]+(?:\.\d{2})?)',
    caseSensitive: false,
  );

  // Date patterns
  static final List<RegExp> datePatterns = [
    RegExp(r'(\d{2})/(\d{2})/(\d{4})'), // DD/MM/YYYY
    RegExp(r'(\d{4})-(\d{2})-(\d{2})'), // YYYY-MM-DD
    RegExp(r'(\d{2})-(\d{2})-(\d{4})'), // DD-MM-YYYY
    RegExp(r'(\d{2})\.(\d{2})\.(\d{4})'), // DD.MM.YYYY
  ];

  // Item line patterns (name followed by quantity and price)
  static final RegExp itemLinePattern = RegExp(
    r'^(.+?)\s+(\d+(?:\.\d+)?)\s*[xX*×]?\s*([\d,]+(?:\.\d{2})?)\s*$',
  );

  // Quantity patterns
  static final RegExp quantityPattern = RegExp(
    r'(\d+(?:\.\d+)?)\s*(kg|g|L|ml|pcs|قطعة|كغ|غ|لتر)?',
    caseSensitive: false,
  );

  /// Detect store from text
  StoreMatch? detectStore(String text) {
    for (final entry in storePatterns.entries) {
      if (entry.value.hasMatch(text)) {
        return StoreMatch(
          id: entry.key,
          name: _formatStoreName(entry.key),
          confidence: 0.9,
        );
      }
    }
    return null;
  }

  /// Detect currency from text
  String detectCurrency(String text) {
    final hasLbp = lbpPattern.hasMatch(text);
    final hasUsd = usdPattern.hasMatch(text);

    // If only USD mentioned, use USD
    if (hasUsd && !hasLbp) return 'USD';

    // Default to LBP for Lebanese receipts
    return 'LBP';
  }

  /// Extract date from text
  DateTime? extractDate(String text) {
    for (final pattern in datePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        try {
          final groups = [match.group(1)!, match.group(2)!, match.group(3)!];

          // Determine format based on which group is 4 digits
          if (groups[0].length == 4) {
            // YYYY-MM-DD
            return DateTime(
              int.parse(groups[0]),
              int.parse(groups[1]),
              int.parse(groups[2]),
            );
          } else if (groups[2].length == 4) {
            // DD-MM-YYYY or DD/MM/YYYY
            return DateTime(
              int.parse(groups[2]),
              int.parse(groups[1]),
              int.parse(groups[0]),
            );
          }
        } catch (_) {
          continue;
        }
      }
    }
    return null;
  }

  /// Extract total amount from text
  PriceMatch? extractTotal(String text) {
    // First try explicit total patterns
    final totalMatch = totalPattern.firstMatch(text);
    if (totalMatch != null) {
      final amount = _parseAmount(totalMatch.group(2)!);
      if (amount != null && amount > 0) {
        return PriceMatch(
          amount: amount,
          currency: detectCurrency(text),
          confidence: 0.95,
        );
      }
    }

    // Fall back to finding the largest price
    final prices = extractAllPrices(text);
    if (prices.isNotEmpty) {
      prices.sort((a, b) => b.amount.compareTo(a.amount));
      return PriceMatch(
        amount: prices.first.amount,
        currency: prices.first.currency,
        confidence: 0.7,
      );
    }

    return null;
  }

  /// Extract all prices from text
  List<PriceMatch> extractAllPrices(String text) {
    final prices = <PriceMatch>[];
    final currency = detectCurrency(text);

    for (final match in pricePattern.allMatches(text)) {
      final amountStr = match.group(1);
      if (amountStr != null) {
        final amount = _parseAmount(amountStr);
        if (amount != null && amount > 0) {
          // Determine currency from match or default
          String matchCurrency = currency;
          final currencyMatch = match.group(2);
          if (currencyMatch != null) {
            if (usdPattern.hasMatch(currencyMatch)) {
              matchCurrency = 'USD';
            } else if (lbpPattern.hasMatch(currencyMatch)) {
              matchCurrency = 'LBP';
            }
          }

          prices.add(PriceMatch(
            amount: amount,
            currency: matchCurrency,
            confidence: 0.8,
          ));
        }
      }
    }

    return prices;
  }

  /// Extract line items from text
  List<ItemMatch> extractItems(String text) {
    final items = <ItemMatch>[];
    final lines = text.split('\n');
    final currency = detectCurrency(text);

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Skip lines that look like headers or totals
      if (_isHeaderOrTotal(trimmed)) continue;

      final itemMatch = itemLinePattern.firstMatch(trimmed);
      if (itemMatch != null) {
        final name = itemMatch.group(1)?.trim() ?? '';
        final quantity = double.tryParse(itemMatch.group(2) ?? '1') ?? 1.0;
        final price = _parseAmount(itemMatch.group(3) ?? '0') ?? 0.0;

        if (name.isNotEmpty && price > 0) {
          items.add(ItemMatch(
            name: name,
            quantity: quantity,
            totalPrice: price,
            unitPrice: price / quantity,
            currency: currency,
            confidence: 0.8,
          ));
        }
      }
    }

    return items;
  }

  /// Parse amount string to double
  double? _parseAmount(String str) {
    try {
      // Remove commas and parse
      return double.parse(str.replaceAll(',', ''));
    } catch (_) {
      return null;
    }
  }

  /// Format store ID to display name
  String _formatStoreName(String id) {
    return id
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) =>
            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join(' ');
  }

  /// Check if line is a header or total line
  bool _isHeaderOrTotal(String line) {
    final lower = line.toLowerCase();
    return lower.contains('total') ||
        lower.contains('المجموع') ||
        lower.contains('subtotal') ||
        lower.contains('tax') ||
        lower.contains('vat') ||
        lower.contains('discount') ||
        lower.contains('change') ||
        lower.contains('الباقي') ||
        lower.contains('receipt') ||
        lower.contains('invoice') ||
        lower.contains('فاتورة');
  }
}

/// Store match result
class StoreMatch {
  final String id;
  final String name;
  final double confidence;

  const StoreMatch({
    required this.id,
    required this.name,
    required this.confidence,
  });
}

/// Price match result
class PriceMatch {
  final double amount;
  final String currency;
  final double confidence;

  const PriceMatch({
    required this.amount,
    required this.currency,
    required this.confidence,
  });
}

/// Item match result
class ItemMatch {
  final String name;
  final double quantity;
  final double unitPrice;
  final double totalPrice;
  final String currency;
  final double confidence;

  const ItemMatch({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.currency,
    required this.confidence,
  });
}
