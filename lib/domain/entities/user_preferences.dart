import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:receipt_vault/app/constants/currencies.dart';

part 'user_preferences.freezed.dart';
part 'user_preferences.g.dart';

/// User preferences entity
@freezed
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    required String userId,
    @Default('en') String locale,
    @Default('USD') String primaryCurrency,
    @Default('LBP') String secondaryCurrency,
    @Default(ThemePreference.system) ThemePreference themePreference,
    @Default(true) bool notificationsEnabled,
    @Default(true) bool budgetAlertsEnabled,
    @Default(0.8) double budgetAlertThreshold,
    @Default(false) bool biometricEnabled,
    @Default(true) bool hasCompletedOnboarding,
    DateTime? updatedAt,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
}

/// Theme preference enum
enum ThemePreference {
  light,
  dark,
  system,
}

extension ThemePreferenceExtension on ThemePreference {
  String getDisplayName(String locale) {
    switch (this) {
      case ThemePreference.light:
        return locale == 'ar' ? 'فاتح' : 'Light';
      case ThemePreference.dark:
        return locale == 'ar' ? 'داكن' : 'Dark';
      case ThemePreference.system:
        return locale == 'ar' ? 'النظام' : 'System';
    }
  }
}

/// Extension for default user preferences
extension UserPreferencesDefaults on UserPreferences {
  static UserPreferences forNewUser(String userId) {
    return UserPreferences(
      userId: userId,
      locale: 'en',
      primaryCurrency: SupportedCurrencies.usd,
      secondaryCurrency: SupportedCurrencies.lbp,
      themePreference: ThemePreference.system,
      notificationsEnabled: true,
      budgetAlertsEnabled: true,
      budgetAlertThreshold: 0.8,
      biometricEnabled: false,
      hasCompletedOnboarding: false,
      updatedAt: DateTime.now(),
    );
  }
}
