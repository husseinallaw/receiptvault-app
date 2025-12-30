import 'package:intl/intl.dart';

/// Currency codes used in the app
enum Currency {
  lbp('LBP', 'ل.ل', 'Lebanese Pound', 'ليرة لبنانية'),
  usd('USD', '\$', 'US Dollar', 'دولار أمريكي');

  final String code;
  final String symbol;
  final String name;
  final String nameArabic;

  const Currency(this.code, this.symbol, this.name, this.nameArabic);

  /// Get currency from code
  static Currency fromCode(String code) {
    return Currency.values.firstWhere(
      (c) => c.code.toUpperCase() == code.toUpperCase(),
      orElse: () => Currency.lbp,
    );
  }
}

/// Number extensions for currency formatting
extension CurrencyExtensions on num {
  /// Format as Lebanese Pounds (LBP)
  /// Example: 1500000 -> "1,500,000 ل.ل"
  String formatLBP({bool showSymbol = true, bool compact = false}) {
    if (compact) {
      return _formatCompactLBP(showSymbol);
    }

    final formatter = NumberFormat('#,###', 'en_US');
    final formatted = formatter.format(this);
    return showSymbol ? '$formatted ل.ل' : formatted;
  }

  /// Format as US Dollars (USD)
  /// Example: 150.50 -> "\$150.50"
  String formatUSD({bool showSymbol = true, bool compact = false}) {
    if (compact) {
      return _formatCompactUSD(showSymbol);
    }

    final formatter = NumberFormat.currency(
      symbol: showSymbol ? '\$' : '',
      decimalDigits: 2,
    );
    return formatter.format(this).trim();
  }

  /// Format with specified currency
  String formatCurrency(Currency currency,
      {bool showSymbol = true, bool compact = false}) {
    return switch (currency) {
      Currency.lbp => formatLBP(showSymbol: showSymbol, compact: compact),
      Currency.usd => formatUSD(showSymbol: showSymbol, compact: compact),
    };
  }

  /// Compact format for LBP (e.g., 1.5M, 250K)
  String _formatCompactLBP(bool showSymbol) {
    final value = toDouble();
    String formatted;

    if (value >= 1000000000) {
      formatted = '${(value / 1000000000).toStringAsFixed(1)}B';
    } else if (value >= 1000000) {
      formatted = '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      formatted = '${(value / 1000).toStringAsFixed(0)}K';
    } else {
      formatted = value.toStringAsFixed(0);
    }

    // Remove trailing .0
    formatted = formatted.replaceAll('.0', '');
    return showSymbol ? '$formatted ل.ل' : formatted;
  }

  /// Compact format for USD
  String _formatCompactUSD(bool showSymbol) {
    final value = toDouble();
    String formatted;

    if (value >= 1000000000) {
      formatted = '${(value / 1000000000).toStringAsFixed(1)}B';
    } else if (value >= 1000000) {
      formatted = '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      formatted = '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      formatted = value.toStringAsFixed(2);
    }

    // Remove trailing .0
    formatted = formatted
        .replaceAll('.00', '')
        .replaceAll(RegExp(r'\.0([KMB])'), r'\1');
    return showSymbol ? '\$$formatted' : formatted;
  }

  /// Convert LBP to USD at given rate
  double toLBPFromUSD(double rate) => toDouble() * rate;

  /// Convert USD to LBP at given rate
  double toUSDFromLBP(double rate) => rate > 0 ? toDouble() / rate : 0;
}

/// Currency amount value object
class Money {
  final double amount;
  final Currency currency;

  const Money(this.amount, this.currency);

  /// Create LBP money
  factory Money.lbp(double amount) => Money(amount, Currency.lbp);

  /// Create USD money
  factory Money.usd(double amount) => Money(amount, Currency.usd);

  /// Format with symbol
  String format({bool showSymbol = true, bool compact = false}) =>
      amount.formatCurrency(currency, showSymbol: showSymbol, compact: compact);

  /// Convert to other currency
  Money convert(Currency toCurrency, double rate) {
    if (currency == toCurrency) return this;

    final convertedAmount = currency == Currency.lbp
        ? amount.toUSDFromLBP(rate)
        : amount.toLBPFromUSD(rate);

    return Money(convertedAmount, toCurrency);
  }

  /// Add money (same currency only)
  Money operator +(Money other) {
    assert(currency == other.currency, 'Cannot add different currencies');
    return Money(amount + other.amount, currency);
  }

  /// Subtract money (same currency only)
  Money operator -(Money other) {
    assert(currency == other.currency, 'Cannot subtract different currencies');
    return Money(amount - other.amount, currency);
  }

  /// Multiply by factor
  Money operator *(num factor) => Money(amount * factor, currency);

  /// Divide by factor
  Money operator /(num factor) => Money(amount / factor, currency);

  @override
  String toString() => format();

  @override
  bool operator ==(Object other) =>
      other is Money && amount == other.amount && currency == other.currency;

  @override
  int get hashCode => Object.hash(amount, currency);
}
