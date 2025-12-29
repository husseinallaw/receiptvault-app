/// Global application constants
abstract class AppConstants {
  // App info
  static const String appName = 'ReceiptVault';
  static const String appNameArabic = 'ريسيت فولت';
  static const String appVersion = '1.0.0';

  // Supported currencies
  static const String currencyLBP = 'LBP';
  static const String currencyUSD = 'USD';
  static const String currencySymbolLBP = 'L.L.';
  static const String currencySymbolUSD = '\$';

  // Supported languages
  static const String languageEnglish = 'en';
  static const String languageArabic = 'ar';

  // Date formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String monthYearFormat = 'MMMM yyyy';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxReceiptsPerPage = 50;

  // OCR
  static const double minOcrConfidence = 0.7;
  static const double highOcrConfidence = 0.9;
  static const int maxReceiptImages = 5;
  static const int maxImageSizeMB = 10;

  // Budget
  static const double defaultBudgetAlertThreshold = 0.8; // 80%

  // Subscription
  static const int freeReceiptScansPerMonth = 5;
  static const int freeBudgetsLimit = 1;

  // Cache
  static const int exchangeRateCacheMinutes = 60;
  static const int receiptsCacheMinutes = 5;

  // Sync
  static const int syncRetryAttempts = 3;
  static const int syncRetryDelaySeconds = 5;

  // Animation
  static const int defaultAnimationDurationMs = 300;
  static const int shortAnimationDurationMs = 150;
  static const int longAnimationDurationMs = 500;

  // Timeouts
  static const int apiTimeoutSeconds = 30;
  static const int ocrTimeoutSeconds = 60;

  // Storage keys (for flutter_secure_storage)
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyPreferredCurrency = 'preferred_currency';
  static const String keyPreferredLanguage = 'preferred_language';
  static const String keyThemeMode = 'theme_mode';
  static const String keyIsOnboarded = 'is_onboarded';
  static const String keyLastSyncTime = 'last_sync_time';

  // Firestore collections
  static const String collectionUsers = 'users';
  static const String collectionReceipts = 'receipts';
  static const String collectionBudgets = 'budgets';
  static const String collectionStores = 'stores';
  static const String collectionProducts = 'products';
  static const String collectionCategories = 'categories';
  static const String collectionExchangeRates = 'exchange_rates';
  static const String collectionPriceIndex = 'price_index';

  // Cloud Storage paths
  static const String storageReceiptsPath = 'users/{userId}/receipts/{receiptId}';
  static const String storageProfilePath = 'users/{userId}/profile';
}

/// Expense categories
enum ExpenseCategory {
  groceries,
  fuel,
  dining,
  utilities,
  entertainment,
  health,
  transport,
  shopping,
  other;

  String get displayName {
    switch (this) {
      case ExpenseCategory.groceries:
        return 'Groceries';
      case ExpenseCategory.fuel:
        return 'Fuel';
      case ExpenseCategory.dining:
        return 'Dining';
      case ExpenseCategory.utilities:
        return 'Utilities';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
      case ExpenseCategory.health:
        return 'Health';
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  String get displayNameArabic {
    switch (this) {
      case ExpenseCategory.groceries:
        return 'بقالة';
      case ExpenseCategory.fuel:
        return 'وقود';
      case ExpenseCategory.dining:
        return 'طعام';
      case ExpenseCategory.utilities:
        return 'خدمات';
      case ExpenseCategory.entertainment:
        return 'ترفيه';
      case ExpenseCategory.health:
        return 'صحة';
      case ExpenseCategory.transport:
        return 'نقل';
      case ExpenseCategory.shopping:
        return 'تسوق';
      case ExpenseCategory.other:
        return 'آخر';
    }
  }

  String get icon {
    switch (this) {
      case ExpenseCategory.groceries:
        return '🛒';
      case ExpenseCategory.fuel:
        return '⛽';
      case ExpenseCategory.dining:
        return '🍽️';
      case ExpenseCategory.utilities:
        return '💡';
      case ExpenseCategory.entertainment:
        return '🎬';
      case ExpenseCategory.health:
        return '💊';
      case ExpenseCategory.transport:
        return '🚗';
      case ExpenseCategory.shopping:
        return '🛍️';
      case ExpenseCategory.other:
        return '📦';
    }
  }
}
