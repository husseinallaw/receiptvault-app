/// Supported currencies for the Lebanese market
class SupportedCurrencies {
  SupportedCurrencies._();

  /// Lebanese Pound
  static const String lbp = 'LBP';

  /// US Dollar
  static const String usd = 'USD';

  /// Euro
  static const String eur = 'EUR';

  /// All supported currency codes
  static const List<String> all = [usd, lbp, eur];

  /// Default primary currency
  static const String defaultPrimary = usd;

  /// Default secondary currency
  static const String defaultSecondary = lbp;

  /// Get currency symbol
  static String getSymbol(String code) {
    return switch (code) {
      lbp => 'ل.ل',
      usd => '\$',
      eur => '€',
      _ => code,
    };
  }

  /// Get currency name in English
  static String getName(String code) {
    return switch (code) {
      lbp => 'Lebanese Pound',
      usd => 'US Dollar',
      eur => 'Euro',
      _ => code,
    };
  }

  /// Get currency name in Arabic
  static String getNameArabic(String code) {
    return switch (code) {
      lbp => 'الليرة اللبنانية',
      usd => 'الدولار الأمريكي',
      eur => 'اليورو',
      _ => code,
    };
  }

  /// Get decimal places for currency
  static int getDecimalPlaces(String code) {
    return switch (code) {
      lbp => 0, // LBP typically doesn't use decimals
      _ => 2,
    };
  }
}
