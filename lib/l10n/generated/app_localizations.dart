import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// The application name
  ///
  /// In en, this message translates to:
  /// **'ReceiptVault'**
  String get appName;

  /// The application tagline
  ///
  /// In en, this message translates to:
  /// **'Smart Receipt Scanning for Lebanon'**
  String get appTagline;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navReceipts.
  ///
  /// In en, this message translates to:
  /// **'Receipts'**
  String get navReceipts;

  /// No description provided for @navScanner.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get navScanner;

  /// No description provided for @navBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get navBudget;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get homeWelcome;

  /// No description provided for @homeSpendingThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Spending This Month'**
  String get homeSpendingThisMonth;

  /// No description provided for @homeRecentReceipts.
  ///
  /// In en, this message translates to:
  /// **'Recent Receipts'**
  String get homeRecentReceipts;

  /// No description provided for @homeQuickScan.
  ///
  /// In en, this message translates to:
  /// **'Quick Scan'**
  String get homeQuickScan;

  /// No description provided for @homeViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get homeViewAll;

  /// No description provided for @homeNoReceipts.
  ///
  /// In en, this message translates to:
  /// **'No receipts yet'**
  String get homeNoReceipts;

  /// No description provided for @homeStartScanning.
  ///
  /// In en, this message translates to:
  /// **'Start scanning your receipts'**
  String get homeStartScanning;

  /// No description provided for @receiptsTitle.
  ///
  /// In en, this message translates to:
  /// **'Receipts'**
  String get receiptsTitle;

  /// No description provided for @receiptsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No receipts found'**
  String get receiptsEmpty;

  /// No description provided for @receiptsSearch.
  ///
  /// In en, this message translates to:
  /// **'Search receipts...'**
  String get receiptsSearch;

  /// No description provided for @receiptsFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get receiptsFilter;

  /// No description provided for @receiptsSort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get receiptsSort;

  /// No description provided for @receiptsSortByDate.
  ///
  /// In en, this message translates to:
  /// **'Sort by Date'**
  String get receiptsSortByDate;

  /// No description provided for @receiptsSortByAmount.
  ///
  /// In en, this message translates to:
  /// **'Sort by Amount'**
  String get receiptsSortByAmount;

  /// No description provided for @receiptsSortByStore.
  ///
  /// In en, this message translates to:
  /// **'Sort by Store'**
  String get receiptsSortByStore;

  /// No description provided for @receiptDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Receipt Details'**
  String get receiptDetailTitle;

  /// No description provided for @receiptStore.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get receiptStore;

  /// No description provided for @receiptDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get receiptDate;

  /// No description provided for @receiptTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get receiptTotal;

  /// No description provided for @receiptItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get receiptItems;

  /// No description provided for @receiptCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get receiptCategory;

  /// No description provided for @receiptNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get receiptNotes;

  /// No description provided for @receiptAddNote.
  ///
  /// In en, this message translates to:
  /// **'Add a note...'**
  String get receiptAddNote;

  /// No description provided for @receiptStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get receiptStatus;

  /// No description provided for @receiptStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get receiptStatusPending;

  /// No description provided for @receiptStatusProcessed.
  ///
  /// In en, this message translates to:
  /// **'Processed'**
  String get receiptStatusProcessed;

  /// No description provided for @receiptStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get receiptStatusFailed;

  /// No description provided for @scannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Receipt'**
  String get scannerTitle;

  /// No description provided for @scannerTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get scannerTakePhoto;

  /// No description provided for @scannerChooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get scannerChooseGallery;

  /// No description provided for @scannerProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing receipt...'**
  String get scannerProcessing;

  /// No description provided for @scannerReview.
  ///
  /// In en, this message translates to:
  /// **'Review Receipt'**
  String get scannerReview;

  /// No description provided for @scannerConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Save'**
  String get scannerConfirm;

  /// No description provided for @scannerRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get scannerRetake;

  /// No description provided for @scannerFlash.
  ///
  /// In en, this message translates to:
  /// **'Flash'**
  String get scannerFlash;

  /// No description provided for @budgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgetTitle;

  /// No description provided for @budgetCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Budget'**
  String get budgetCreate;

  /// No description provided for @budgetEmpty.
  ///
  /// In en, this message translates to:
  /// **'No budgets set'**
  String get budgetEmpty;

  /// No description provided for @budgetCreateFirst.
  ///
  /// In en, this message translates to:
  /// **'Create your first budget'**
  String get budgetCreateFirst;

  /// No description provided for @budgetName.
  ///
  /// In en, this message translates to:
  /// **'Budget Name'**
  String get budgetName;

  /// No description provided for @budgetAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get budgetAmount;

  /// No description provided for @budgetPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get budgetPeriod;

  /// No description provided for @budgetCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get budgetCategory;

  /// No description provided for @budgetDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get budgetDaily;

  /// No description provided for @budgetWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get budgetWeekly;

  /// No description provided for @budgetMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get budgetMonthly;

  /// No description provided for @budgetYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get budgetYearly;

  /// No description provided for @budgetProgress.
  ///
  /// In en, this message translates to:
  /// **'{spent} of {total}'**
  String budgetProgress(String spent, String total);

  /// No description provided for @budgetRemaining.
  ///
  /// In en, this message translates to:
  /// **'{amount} remaining'**
  String budgetRemaining(String amount);

  /// No description provided for @budgetOverLimit.
  ///
  /// In en, this message translates to:
  /// **'Over budget by {amount}'**
  String budgetOverLimit(String amount);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfile;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Data & Storage'**
  String get settingsData;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsCurrency.
  ///
  /// In en, this message translates to:
  /// **'Default Currency'**
  String get settingsCurrency;

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get settingsSignOut;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settingsDeleteAccount;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ReceiptVault'**
  String get appTitle;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @enterConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get enterConfirmPassword;

  /// No description provided for @enterDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterDisplayName;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a link to reset your password.'**
  String get resetPasswordDescription;

  /// No description provided for @passwordResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent'**
  String get passwordResetEmailSent;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @welcomeToReceiptVault.
  ///
  /// In en, this message translates to:
  /// **'Welcome to ReceiptVault'**
  String get welcomeToReceiptVault;

  /// No description provided for @onboardingWelcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Your smart receipt scanning wallet for Lebanon. Track spending in LBP and USD.'**
  String get onboardingWelcomeDescription;

  /// No description provided for @featureScanReceipts.
  ///
  /// In en, this message translates to:
  /// **'Scan and organize your receipts'**
  String get featureScanReceipts;

  /// No description provided for @featureMultiCurrency.
  ///
  /// In en, this message translates to:
  /// **'Track in LBP and USD simultaneously'**
  String get featureMultiCurrency;

  /// No description provided for @featureTrackSpending.
  ///
  /// In en, this message translates to:
  /// **'Monitor spending with smart analytics'**
  String get featureTrackSpending;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @selectLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language. You can change this later in settings.'**
  String get selectLanguageDescription;

  /// No description provided for @selectCurrencies.
  ///
  /// In en, this message translates to:
  /// **'Set Your Currencies'**
  String get selectCurrencies;

  /// No description provided for @selectCurrenciesDescription.
  ///
  /// In en, this message translates to:
  /// **'Lebanon uses both LBP and USD. Set your primary and secondary currencies.'**
  String get selectCurrenciesDescription;

  /// No description provided for @primaryCurrency.
  ///
  /// In en, this message translates to:
  /// **'Primary Currency'**
  String get primaryCurrency;

  /// No description provided for @secondaryCurrency.
  ///
  /// In en, this message translates to:
  /// **'Secondary Currency'**
  String get secondaryCurrency;

  /// No description provided for @currencyChangeableInSettings.
  ///
  /// In en, this message translates to:
  /// **'You can change your currency preferences anytime in Settings.'**
  String get currencyChangeableInSettings;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Scan Receipts'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Simply take a photo of your receipt and we\'ll extract all the details automatically'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Track Spending'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Monitor your expenses in both Lebanese Pounds and US Dollars'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Compare Prices'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Find the best deals across Lebanese stores'**
  String get onboardingDesc3;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @categoryGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get categoryGroceries;

  /// No description provided for @categoryFuel.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get categoryFuel;

  /// No description provided for @categoryDining.
  ///
  /// In en, this message translates to:
  /// **'Dining'**
  String get categoryDining;

  /// No description provided for @categoryUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get categoryUtilities;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categoryTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get categoryTransport;

  /// No description provided for @categoryShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryShopping;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @currencyLBP.
  ///
  /// In en, this message translates to:
  /// **'Lebanese Pound'**
  String get currencyLBP;

  /// No description provided for @currencyUSD.
  ///
  /// In en, this message translates to:
  /// **'US Dollar'**
  String get currencyUSD;

  /// No description provided for @exchangeRate.
  ///
  /// In en, this message translates to:
  /// **'Exchange Rate'**
  String get exchangeRate;

  /// No description provided for @exchangeRateUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String exchangeRateUpdated(String time);

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get errorNetwork;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again'**
  String get errorServer;

  /// No description provided for @errorAuth.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed'**
  String get errorAuth;

  /// No description provided for @errorPermission.
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get errorPermission;

  /// No description provided for @errorOcr.
  ///
  /// In en, this message translates to:
  /// **'Could not process receipt'**
  String get errorOcr;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this?'**
  String get confirmDelete;

  /// No description provided for @confirmSignOut.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get confirmSignOut;

  /// No description provided for @confirmDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All your data will be permanently deleted.'**
  String get confirmDeleteAccount;

  /// No description provided for @syncInProgress.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncInProgress;

  /// No description provided for @syncComplete.
  ///
  /// In en, this message translates to:
  /// **'Sync complete'**
  String get syncComplete;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncFailed;

  /// No description provided for @syncOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Changes will sync when you\'re back online.'**
  String get syncOffline;

  /// No description provided for @allReceipts.
  ///
  /// In en, this message translates to:
  /// **'All Receipts'**
  String get allReceipts;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No search results'**
  String get noSearchResults;

  /// No description provided for @scanFirstReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan your first receipt'**
  String get scanFirstReceipt;

  /// No description provided for @noReceiptData.
  ///
  /// In en, this message translates to:
  /// **'No receipt data available'**
  String get noReceiptData;

  /// No description provided for @storeName.
  ///
  /// In en, this message translates to:
  /// **'Store Name'**
  String get storeName;

  /// No description provided for @storeNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Store name is required'**
  String get storeNameRequired;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @totalRequired.
  ///
  /// In en, this message translates to:
  /// **'Total is required'**
  String get totalRequired;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get invalidAmount;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @saveReceipt.
  ///
  /// In en, this message translates to:
  /// **'Save Receipt'**
  String get saveReceipt;

  /// No description provided for @noItemsDetected.
  ///
  /// In en, this message translates to:
  /// **'No items detected'**
  String get noItemsDetected;

  /// No description provided for @highConfidence.
  ///
  /// In en, this message translates to:
  /// **'High Confidence'**
  String get highConfidence;

  /// No description provided for @moderateConfidence.
  ///
  /// In en, this message translates to:
  /// **'Review Recommended'**
  String get moderateConfidence;

  /// No description provided for @lowConfidence.
  ///
  /// In en, this message translates to:
  /// **'Manual Review Required'**
  String get lowConfidence;

  /// No description provided for @pleaseReviewData.
  ///
  /// In en, this message translates to:
  /// **'Please review the extracted data carefully'**
  String get pleaseReviewData;

  /// No description provided for @errorLoadingReceipt.
  ///
  /// In en, this message translates to:
  /// **'Error loading receipt'**
  String get errorLoadingReceipt;

  /// No description provided for @receiptNotFound.
  ///
  /// In en, this message translates to:
  /// **'Receipt not found'**
  String get receiptNotFound;

  /// No description provided for @ocrConfidence.
  ///
  /// In en, this message translates to:
  /// **'OCR Confidence'**
  String get ocrConfidence;

  /// No description provided for @syncStatus.
  ///
  /// In en, this message translates to:
  /// **'Sync Status'**
  String get syncStatus;

  /// No description provided for @pendingSync.
  ///
  /// In en, this message translates to:
  /// **'Pending Sync'**
  String get pendingSync;

  /// No description provided for @synced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get synced;

  /// No description provided for @deleteReceipt.
  ///
  /// In en, this message translates to:
  /// **'Delete Receipt'**
  String get deleteReceipt;

  /// No description provided for @deleteReceiptConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this receipt? This action cannot be undone.'**
  String get deleteReceiptConfirmation;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get unknownError;

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission denied'**
  String get cameraPermissionDenied;

  /// No description provided for @enableCameraPermission.
  ///
  /// In en, this message translates to:
  /// **'Please enable camera permission in settings to scan receipts'**
  String get enableCameraPermission;

  /// No description provided for @receiptSaved.
  ///
  /// In en, this message translates to:
  /// **'Receipt saved successfully'**
  String get receiptSaved;

  /// No description provided for @cameraError.
  ///
  /// In en, this message translates to:
  /// **'Camera error occurred'**
  String get cameraError;

  /// No description provided for @pickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Pick from Gallery'**
  String get pickFromGallery;

  /// No description provided for @noCameraAvailable.
  ///
  /// In en, this message translates to:
  /// **'No camera available'**
  String get noCameraAvailable;

  /// No description provided for @processingReceipt.
  ///
  /// In en, this message translates to:
  /// **'Processing receipt...'**
  String get processingReceipt;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
