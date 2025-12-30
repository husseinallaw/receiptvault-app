/// Route path constants
class AppRoutes {
  const AppRoutes._();

  // ==================== Auth Routes ====================
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';

  // ==================== Main App Routes (Shell) ====================
  static const String home = '/home';
  static const String receipts = '/receipts';
  static const String scanner = '/scanner';
  static const String budget = '/budget';
  static const String settings = '/settings';

  // ==================== Nested Routes ====================
  // Receipts
  static const String receiptDetail = '/receipts/:id';
  static String receiptDetailPath(String id) => '/receipts/$id';

  // Scanner
  static const String receiptReview = '/scanner/review';

  // Budget
  static const String createBudget = '/budget/create';
  static const String budgetDetail = '/budget/:id';
  static String budgetDetailPath(String id) => '/budget/$id';

  // Settings
  static const String profile = '/settings/profile';
  static const String appearance = '/settings/appearance';
  static const String notifications = '/settings/notifications';
  static const String dataManagement = '/settings/data';
  static const String about = '/settings/about';

  // ==================== Other Routes ====================
  static const String analytics = '/analytics';
  static const String priceComparison = '/price-comparison';
  static const String subscription = '/subscription';
}

/// Route names for named navigation
class RouteNames {
  const RouteNames._();

  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String auth = 'auth';
  static const String home = 'home';
  static const String receipts = 'receipts';
  static const String receiptDetail = 'receiptDetail';
  static const String scanner = 'scanner';
  static const String receiptReview = 'receiptReview';
  static const String budget = 'budget';
  static const String createBudget = 'createBudget';
  static const String budgetDetail = 'budgetDetail';
  static const String settings = 'settings';
  static const String profile = 'profile';
  static const String appearance = 'appearance';
  static const String notifications = 'notifications';
  static const String dataManagement = 'dataManagement';
  static const String about = 'about';
  static const String analytics = 'analytics';
  static const String priceComparison = 'priceComparison';
  static const String subscription = 'subscription';
}
