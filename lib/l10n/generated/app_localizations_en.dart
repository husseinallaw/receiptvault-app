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
  String get appTitle => 'ReceiptVault';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get displayName => 'Display Name';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get enterConfirmPassword => 'Confirm your password';

  @override
  String get enterDisplayName => 'Enter your name';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordDescription =>
      'Enter your email and we\'ll send you a link to reset your password.';

  @override
  String get passwordResetEmailSent => 'Password reset email sent';

  @override
  String get send => 'Send';

  @override
  String get or => 'or';

  @override
  String get welcomeBack => 'Welcome back!';

  @override
  String get createAccount => 'Create your account';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get confirmPasswordRequired => 'Please confirm your password';

  @override
  String get invalidEmail => 'Please enter a valid email';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get welcomeToReceiptVault => 'Welcome to ReceiptVault';

  @override
  String get onboardingWelcomeDescription =>
      'Your smart receipt scanning wallet for Lebanon. Track spending in LBP and USD.';

  @override
  String get featureScanReceipts => 'Scan and organize your receipts';

  @override
  String get featureMultiCurrency => 'Track in LBP and USD simultaneously';

  @override
  String get featureTrackSpending => 'Monitor spending with smart analytics';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get selectLanguageDescription =>
      'Choose your preferred language. You can change this later in settings.';

  @override
  String get selectCurrencies => 'Set Your Currencies';

  @override
  String get selectCurrenciesDescription =>
      'Lebanon uses both LBP and USD. Set your primary and secondary currencies.';

  @override
  String get primaryCurrency => 'Primary Currency';

  @override
  String get secondaryCurrency => 'Secondary Currency';

  @override
  String get currencyChangeableInSettings =>
      'You can change your currency preferences anytime in Settings.';

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

  @override
  String get allReceipts => 'All Receipts';

  @override
  String get thisMonth => 'This Month';

  @override
  String get lastMonth => 'Last Month';

  @override
  String get noSearchResults => 'No search results';

  @override
  String get scanFirstReceipt => 'Scan your first receipt';

  @override
  String get noReceiptData => 'No receipt data available';

  @override
  String get storeName => 'Store Name';

  @override
  String get storeNameRequired => 'Store name is required';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get totalRequired => 'Total is required';

  @override
  String get invalidAmount => 'Invalid amount';

  @override
  String get discard => 'Discard';

  @override
  String get saveReceipt => 'Save Receipt';

  @override
  String get noItemsDetected => 'No items detected';

  @override
  String get highConfidence => 'High Confidence';

  @override
  String get moderateConfidence => 'Review Recommended';

  @override
  String get lowConfidence => 'Manual Review Required';

  @override
  String get pleaseReviewData => 'Please review the extracted data carefully';

  @override
  String get errorLoadingReceipt => 'Error loading receipt';

  @override
  String get receiptNotFound => 'Receipt not found';

  @override
  String get ocrConfidence => 'OCR Confidence';

  @override
  String get syncStatus => 'Sync Status';

  @override
  String get pendingSync => 'Pending Sync';

  @override
  String get synced => 'Synced';

  @override
  String get deleteReceipt => 'Delete Receipt';

  @override
  String get deleteReceiptConfirmation =>
      'Are you sure you want to delete this receipt? This action cannot be undone.';

  @override
  String get unknownError => 'An unknown error occurred';

  @override
  String get cameraPermissionDenied => 'Camera permission denied';

  @override
  String get enableCameraPermission =>
      'Please enable camera permission in settings to scan receipts';

  @override
  String get receiptSaved => 'Receipt saved successfully';

  @override
  String get cameraError => 'Camera error occurred';

  @override
  String get pickFromGallery => 'Pick from Gallery';

  @override
  String get noCameraAvailable => 'No camera available';

  @override
  String get processingReceipt => 'Processing receipt...';
}
