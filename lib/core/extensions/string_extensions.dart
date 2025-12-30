/// String utility extensions
extension StringExtensions on String {
  /// Check if string is a valid email
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Check if string is a valid phone number (Lebanese format)
  bool get isValidLebanesePhone {
    // Lebanese phone: +961 or 00961 followed by 7x or 8x (8 digits)
    // Or local format: 03, 70, 71, 76, 78, 79, 81 followed by 6 digits
    final phoneRegex = RegExp(
      r'^(\+961|00961)?[378][0-9]{7}$|^0[378][0-9]{7}$',
    );
    return phoneRegex.hasMatch(replaceAll(RegExp(r'\s|-'), ''));
  }

  /// Capitalize first letter
  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize each word
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalized).join(' ');
  }

  /// Remove all whitespace
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Truncate with ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Check if string contains Arabic characters
  bool get containsArabic {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(this);
  }

  /// Check if string is primarily Arabic
  bool get isPrimarilyArabic {
    if (isEmpty) return false;
    final arabicChars = RegExp(r'[\u0600-\u06FF]').allMatches(this).length;
    final totalChars = replaceAll(RegExp(r'\s'), '').length;
    return totalChars > 0 && arabicChars / totalChars > 0.5;
  }

  /// Convert Arabic numerals to Western
  String get arabicToWesternNumerals {
    const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var result = this;
    for (var i = 0; i < arabicNumerals.length; i++) {
      result = result.replaceAll(arabicNumerals[i], i.toString());
    }
    return result;
  }

  /// Extract numbers from string
  List<double> get extractNumbers {
    final regex = RegExp(r'[\d,]+\.?\d*');
    return regex
        .allMatches(arabicToWesternNumerals)
        .map((m) => double.tryParse(m.group(0)?.replaceAll(',', '') ?? ''))
        .whereType<double>()
        .toList();
  }

  /// Check if string is null or empty (for nullable strings)
  bool get isNullOrEmpty => isEmpty;

  /// Return null if empty
  String? get nullIfEmpty => isEmpty ? null : this;

  /// Safe substring that won't throw
  String safeSubstring(int start, [int? end]) {
    if (start >= length) return '';
    final safeEnd = end != null && end > length ? length : end;
    return substring(start, safeEnd);
  }
}

/// Extension for nullable strings
extension NullableStringExtensions on String? {
  /// Check if string is null or empty
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Check if string is not null and not empty
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  /// Return empty string if null
  String get orEmpty => this ?? '';
}
