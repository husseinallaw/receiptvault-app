// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'ReceiptVault';

  @override
  String get appTagline => 'ماسح إيصالات ذكي للبنان';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get continueButton => 'متابعة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get close => 'إغلاق';

  @override
  String get done => 'تم';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get error => 'خطأ';

  @override
  String get success => 'نجاح';

  @override
  String get warning => 'تحذير';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navReceipts => 'الإيصالات';

  @override
  String get navScanner => 'مسح';

  @override
  String get navBudget => 'الميزانية';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get homeWelcome => 'مرحباً بعودتك!';

  @override
  String get homeSpendingThisMonth => 'المصروفات هذا الشهر';

  @override
  String get homeRecentReceipts => 'الإيصالات الأخيرة';

  @override
  String get homeQuickScan => 'مسح سريع';

  @override
  String get homeViewAll => 'عرض الكل';

  @override
  String get homeNoReceipts => 'لا توجد إيصالات بعد';

  @override
  String get homeStartScanning => 'ابدأ بمسح إيصالاتك';

  @override
  String get receiptsTitle => 'الإيصالات';

  @override
  String get receiptsEmpty => 'لم يتم العثور على إيصالات';

  @override
  String get receiptsSearch => 'البحث في الإيصالات...';

  @override
  String get receiptsFilter => 'تصفية';

  @override
  String get receiptsSort => 'ترتيب';

  @override
  String get receiptsSortByDate => 'ترتيب حسب التاريخ';

  @override
  String get receiptsSortByAmount => 'ترتيب حسب المبلغ';

  @override
  String get receiptsSortByStore => 'ترتيب حسب المتجر';

  @override
  String get receiptDetailTitle => 'تفاصيل الإيصال';

  @override
  String get receiptStore => 'المتجر';

  @override
  String get receiptDate => 'التاريخ';

  @override
  String get receiptTotal => 'المجموع';

  @override
  String get receiptItems => 'العناصر';

  @override
  String get receiptCategory => 'الفئة';

  @override
  String get receiptNotes => 'ملاحظات';

  @override
  String get receiptAddNote => 'أضف ملاحظة...';

  @override
  String get receiptStatus => 'الحالة';

  @override
  String get receiptStatusPending => 'قيد الانتظار';

  @override
  String get receiptStatusProcessed => 'تمت المعالجة';

  @override
  String get receiptStatusFailed => 'فشل';

  @override
  String get scannerTitle => 'مسح الإيصال';

  @override
  String get scannerTakePhoto => 'التقاط صورة';

  @override
  String get scannerChooseGallery => 'اختيار من المعرض';

  @override
  String get scannerProcessing => 'جاري معالجة الإيصال...';

  @override
  String get scannerReview => 'مراجعة الإيصال';

  @override
  String get scannerConfirm => 'تأكيد وحفظ';

  @override
  String get scannerRetake => 'إعادة التصوير';

  @override
  String get scannerFlash => 'الفلاش';

  @override
  String get budgetTitle => 'الميزانيات';

  @override
  String get budgetCreate => 'إنشاء ميزانية';

  @override
  String get budgetEmpty => 'لا توجد ميزانيات';

  @override
  String get budgetCreateFirst => 'أنشئ ميزانيتك الأولى';

  @override
  String get budgetName => 'اسم الميزانية';

  @override
  String get budgetAmount => 'المبلغ';

  @override
  String get budgetPeriod => 'الفترة';

  @override
  String get budgetCategory => 'الفئة';

  @override
  String get budgetDaily => 'يومي';

  @override
  String get budgetWeekly => 'أسبوعي';

  @override
  String get budgetMonthly => 'شهري';

  @override
  String get budgetYearly => 'سنوي';

  @override
  String budgetProgress(String spent, String total) {
    return '$spent من $total';
  }

  @override
  String budgetRemaining(String amount) {
    return '$amount متبقي';
  }

  @override
  String budgetOverLimit(String amount) {
    return 'تجاوز الميزانية بـ $amount';
  }

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsProfile => 'الملف الشخصي';

  @override
  String get settingsAppearance => 'المظهر';

  @override
  String get settingsNotifications => 'الإشعارات';

  @override
  String get settingsData => 'البيانات والتخزين';

  @override
  String get settingsAbout => 'حول التطبيق';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsTheme => 'السمة';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsThemeSystem => 'تلقائي';

  @override
  String get settingsCurrency => 'العملة الافتراضية';

  @override
  String get settingsSignOut => 'تسجيل الخروج';

  @override
  String get settingsDeleteAccount => 'حذف الحساب';

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
  String get onboardingTitle1 => 'مسح الإيصالات';

  @override
  String get onboardingDesc1 =>
      'ببساطة التقط صورة لإيصالك وسنستخرج جميع التفاصيل تلقائياً';

  @override
  String get onboardingTitle2 => 'تتبع المصروفات';

  @override
  String get onboardingDesc2 =>
      'راقب مصروفاتك بالليرة اللبنانية والدولار الأمريكي';

  @override
  String get onboardingTitle3 => 'مقارنة الأسعار';

  @override
  String get onboardingDesc3 => 'اعثر على أفضل العروض في المتاجر اللبنانية';

  @override
  String get onboardingSkip => 'تخطي';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get categoryGroceries => 'البقالة';

  @override
  String get categoryFuel => 'الوقود';

  @override
  String get categoryDining => 'المطاعم';

  @override
  String get categoryUtilities => 'الفواتير';

  @override
  String get categoryEntertainment => 'الترفيه';

  @override
  String get categoryHealth => 'الصحة';

  @override
  String get categoryTransport => 'المواصلات';

  @override
  String get categoryShopping => 'التسوق';

  @override
  String get categoryOther => 'أخرى';

  @override
  String get currencyLBP => 'الليرة اللبنانية';

  @override
  String get currencyUSD => 'الدولار الأمريكي';

  @override
  String get exchangeRate => 'سعر الصرف';

  @override
  String exchangeRateUpdated(String time) {
    return 'آخر تحديث $time';
  }

  @override
  String get errorGeneric => 'حدث خطأ ما';

  @override
  String get errorNetwork => 'لا يوجد اتصال بالإنترنت';

  @override
  String get errorServer => 'خطأ في الخادم. يرجى المحاولة مرة أخرى';

  @override
  String get errorAuth => 'فشل التحقق من الهوية';

  @override
  String get errorPermission => 'تم رفض الإذن';

  @override
  String get errorOcr => 'لم نتمكن من معالجة الإيصال';

  @override
  String get confirmDelete => 'هل أنت متأكد من الحذف؟';

  @override
  String get confirmSignOut => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get confirmDeleteAccount =>
      'لا يمكن التراجع عن هذا الإجراء. سيتم حذف جميع بياناتك نهائياً.';

  @override
  String get syncInProgress => 'جاري المزامنة...';

  @override
  String get syncComplete => 'تمت المزامنة';

  @override
  String get syncFailed => 'فشلت المزامنة';

  @override
  String get syncOffline => 'أنت غير متصل. ستتم مزامنة التغييرات عند الاتصال.';
}
