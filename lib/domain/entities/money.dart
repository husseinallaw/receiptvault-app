import 'package:freezed_annotation/freezed_annotation.dart';
import '../../app/constants/currencies.dart';

part 'money.freezed.dart';
part 'money.g.dart';

/// Value object representing a monetary amount with currency
///
/// This class provides:
/// - Immutable storage of amount and currency
/// - Arithmetic operations (add, subtract, multiply)
/// - Formatting with currency symbols
/// - Zero and comparison helpers
@freezed
class Money with _$Money {
  const Money._();

  const factory Money({
    required double amount,
    @Default('LBP') String currency,
  }) = _Money;

  factory Money.fromJson(Map<String, dynamic> json) => _$MoneyFromJson(json);

  /// Create zero amount in specified currency
  factory Money.zero([String currency = 'LBP']) => Money(
        amount: 0,
        currency: currency,
      );

  /// Create from LBP amount
  factory Money.lbp(double amount) => Money(
        amount: amount,
        currency: SupportedCurrencies.lbp,
      );

  /// Create from USD amount
  factory Money.usd(double amount) => Money(
        amount: amount,
        currency: SupportedCurrencies.usd,
      );

  /// Check if amount is zero
  bool get isZero => amount == 0;

  /// Check if amount is positive
  bool get isPositive => amount > 0;

  /// Check if amount is negative
  bool get isNegative => amount < 0;

  /// Get absolute value
  Money get abs => Money(amount: amount.abs(), currency: currency);

  /// Negate the amount
  Money get negated => Money(amount: -amount, currency: currency);

  /// Get currency symbol
  String get symbol => SupportedCurrencies.getSymbol(currency);

  /// Get decimal places for this currency
  int get decimalPlaces => SupportedCurrencies.getDecimalPlaces(currency);

  /// Add two money amounts (must be same currency)
  Money operator +(Money other) {
    _assertSameCurrency(other);
    return Money(amount: amount + other.amount, currency: currency);
  }

  /// Subtract two money amounts (must be same currency)
  Money operator -(Money other) {
    _assertSameCurrency(other);
    return Money(amount: amount - other.amount, currency: currency);
  }

  /// Multiply by a scalar
  Money operator *(double multiplier) {
    return Money(amount: amount * multiplier, currency: currency);
  }

  /// Divide by a scalar
  Money operator /(double divisor) {
    if (divisor == 0) {
      throw ArgumentError('Cannot divide by zero');
    }
    return Money(amount: amount / divisor, currency: currency);
  }

  /// Compare amounts (must be same currency)
  bool operator <(Money other) {
    _assertSameCurrency(other);
    return amount < other.amount;
  }

  /// Compare amounts (must be same currency)
  bool operator <=(Money other) {
    _assertSameCurrency(other);
    return amount <= other.amount;
  }

  /// Compare amounts (must be same currency)
  bool operator >(Money other) {
    _assertSameCurrency(other);
    return amount > other.amount;
  }

  /// Compare amounts (must be same currency)
  bool operator >=(Money other) {
    _assertSameCurrency(other);
    return amount >= other.amount;
  }

  void _assertSameCurrency(Money other) {
    if (currency != other.currency) {
      throw ArgumentError(
        'Cannot perform operation on different currencies: $currency vs ${other.currency}',
      );
    }
  }

  /// Format amount with currency symbol
  ///
  /// Examples:
  /// - LBP: "ل.ل 150,000"
  /// - USD: "\$25.99"
  String format({bool showSymbol = true, bool compact = false}) {
    final decimals = decimalPlaces;
    String formattedAmount;

    if (compact && amount.abs() >= 1000000) {
      // Show in millions for large LBP amounts
      final millions = amount / 1000000;
      formattedAmount = '${millions.toStringAsFixed(1)}M';
    } else if (compact && amount.abs() >= 1000) {
      // Show in thousands
      final thousands = amount / 1000;
      formattedAmount = '${thousands.toStringAsFixed(1)}K';
    } else {
      // Format with thousand separators
      formattedAmount = _formatWithSeparators(amount, decimals);
    }

    if (showSymbol) {
      // LBP symbol goes after amount in Arabic style
      if (currency == SupportedCurrencies.lbp) {
        return '$formattedAmount $symbol';
      }
      // USD/EUR symbol goes before amount
      return '$symbol$formattedAmount';
    }

    return formattedAmount;
  }

  String _formatWithSeparators(double value, int decimals) {
    final parts = value.toStringAsFixed(decimals).split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? parts[1] : '';

    // Add thousand separators
    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(intPart[i]);
    }

    if (decimals > 0 && decPart.isNotEmpty) {
      buffer.write('.');
      buffer.write(decPart);
    }

    return buffer.toString();
  }

  @override
  String toString() => format();
}

/// Extension for creating Money from numbers
extension MoneyNumExtension on num {
  /// Create Money in LBP
  Money get lbp => Money.lbp(toDouble());

  /// Create Money in USD
  Money get usd => Money.usd(toDouble());

  /// Create Money in specified currency
  Money money(String currency) => Money(amount: toDouble(), currency: currency);
}
