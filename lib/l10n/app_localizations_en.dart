// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'ReceiptVault';

  @override
  String get appTagline => 'Smart Receipt Scanning for Lebanon';

  @override
  String get getStarted => 'Get Started';

  @override
  String get continueButton => 'Continue';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get done => 'Done';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get navHome => 'Home';

  @override
  String get navReceipts => 'Receipts';

  @override
  String get navScanner => 'Scan';

  @override
  String get navBudget => 'Budget';

  @override
  String get navSettings => 'Settings';

  @override
  String get homeWelcome => 'Welcome back!';

  @override
  String get homeSpendingThisMonth => 'Spending This Month';

  @override
  String get homeRecentReceipts => 'Recent Receipts';

  @override
  String get homeQuickScan => 'Quick Scan';

  @override
  String get homeViewAll => 'View All';

  @override
  String get homeNoReceipts => 'No receipts yet';

  @override
  String get homeStartScanning => 'Start scanning your receipts';

  @override
  String get receiptsTitle => 'Receipts';

  @override
  String get receiptsEmpty => 'No receipts found';

  @override
  String get receiptsSearch => 'Search receipts...';

  @override
  String get receiptsFilter => 'Filter';

  @override
  String get receiptsSort => 'Sort';

  @override
  String get receiptsSortByDate => 'Sort by Date';

  @override
  String get receiptsSortByAmount => 'Sort by Amount';

  @override
  String get receiptsSortByStore => 'Sort by Store';

  @override
  String get receiptDetailTitle => 'Receipt Details';

  @override
  String get receiptStore => 'Store';

  @override
  String get receiptDate => 'Date';

  @override
  String get receiptTotal => 'Total';

  @override
  String get receiptItems => 'Items';

  @override
  String get receiptCategory => 'Category';

  @override
  String get receiptNotes => 'Notes';

  @override
  String get receiptAddNote => 'Add a note...';

  @override
  String get receiptStatus => 'Status';

  @override
  String get receiptStatusPending => 'Pending';

  @override
  String get receiptStatusProcessed => 'Processed';

  @override
  String get receiptStatusFailed => 'Failed';

  @override
  String get scannerTitle => 'Scan Receipt';

  @override
  String get scannerTakePhoto => 'Take Photo';

  @override
  String get scannerChooseGallery => 'Choose from Gallery';

  @override
  String get scannerProcessing => 'Processing receipt...';

  @override
  String get scannerReview => 'Review Receipt';

  @override
  String get scannerConfirm => 'Confirm & Save';

  @override
  String get scannerRetake => 'Retake';

  @override
  String get scannerFlash => 'Flash';

  @override
  String get budgetTitle => 'Budgets';

  @override
  String get budgetCreate => 'Create Budget';

  @override
  String get budgetEmpty => 'No budgets set';

  @override
  String get budgetCreateFirst => 'Create your first budget';

  @override
  String get budgetName => 'Budget Name';

  @override
  String get budgetAmount => 'Amount';

  @override
  String get budgetPeriod => 'Period';

  @override
  String get budgetCategory => 'Category';

  @override
  String get budgetDaily => 'Daily';

  @override
  String get budgetWeekly => 'Weekly';

  @override
  String get budgetMonthly => 'Monthly';

  @override
  String get budgetYearly => 'Yearly';

  @override
  String budgetProgress(String spent, String total) {
    return '$spent of $total';
  }

  @override
  String budgetRemaining(String amount) {
    return '$amount remaining';
  }

  @override
  String budgetOverLimit(String amount) {
    return 'Over budget by $amount';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsProfile => 'Profile';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsData => 'Data & Storage';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsCurrency => 'Default Currency';

  @override
  String get settingsSignOut => 'Sign Out';

  @override
  String get settingsDeleteAccount => 'Delete Account';

  @override
  String get authSignIn => 'Sign In';

  @override
  String get authSignUp => 'Sign Up';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authForgotPassword => 'Forgot Password?';

  @override
  String get authContinueWith => 'Or continue with';

  @override
  String get authGoogle => 'Continue with Google';

  @override
  String get authApple => 'Continue with Apple';

  @override
  String get authTerms =>
      'By continuing, you agree to our Terms of Service and Privacy Policy';

  @override
  String get onboardingTitle1 => 'Scan Receipts';

  @override
  String get onboardingDesc1 =>
      'Simply take a photo of your receipt and we\'ll extract all the details automatically';

  @override
  String get onboardingTitle2 => 'Track Spending';

  @override
  String get onboardingDesc2 =>
      'Monitor your expenses in both Lebanese Pounds and US Dollars';

  @override
  String get onboardingTitle3 => 'Compare Prices';

  @override
  String get onboardingDesc3 => 'Find the best deals across Lebanese stores';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get categoryGroceries => 'Groceries';

  @override
  String get categoryFuel => 'Fuel';

  @override
  String get categoryDining => 'Dining';

  @override
  String get categoryUtilities => 'Utilities';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryOther => 'Other';

  @override
  String get currencyLBP => 'Lebanese Pound';

  @override
  String get currencyUSD => 'US Dollar';

  @override
  String get exchangeRate => 'Exchange Rate';

  @override
  String exchangeRateUpdated(String time) {
    return 'Updated $time';
  }

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get errorNetwork => 'No internet connection';

  @override
  String get errorServer => 'Server error. Please try again';

  @override
  String get errorAuth => 'Authentication failed';

  @override
  String get errorPermission => 'Permission denied';

  @override
  String get errorOcr => 'Could not process receipt';

  @override
  String get confirmDelete => 'Are you sure you want to delete this?';

  @override
  String get confirmSignOut => 'Are you sure you want to sign out?';

  @override
  String get confirmDeleteAccount =>
      'This action cannot be undone. All your data will be permanently deleted.';

  @override
  String get syncInProgress => 'Syncing...';

  @override
  String get syncComplete => 'Sync complete';

  @override
  String get syncFailed => 'Sync failed';

  @override
  String get syncOffline =>
      'You\'re offline. Changes will sync when you\'re back online.';
}
