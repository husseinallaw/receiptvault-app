import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:receipt_vault/domain/entities/user_preferences.dart';

/// Data model for UserPreferences with Firestore serialization
class UserPreferencesModel {
  final String userId;
  final String locale;
  final String primaryCurrency;
  final String secondaryCurrency;
  final ThemePreference themePreference;
  final bool notificationsEnabled;
  final bool budgetAlertsEnabled;
  final double budgetAlertThreshold;
  final bool biometricEnabled;
  final bool hasCompletedOnboarding;
  final DateTime? updatedAt;

  UserPreferencesModel({
    required this.userId,
    this.locale = 'en',
    this.primaryCurrency = 'USD',
    this.secondaryCurrency = 'LBP',
    this.themePreference = ThemePreference.system,
    this.notificationsEnabled = true,
    this.budgetAlertsEnabled = true,
    this.budgetAlertThreshold = 0.8,
    this.biometricEnabled = false,
    this.hasCompletedOnboarding = false,
    this.updatedAt,
  });

  /// Create from Firestore document
  factory UserPreferencesModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserPreferencesModel(
      userId: doc.id,
      locale: data['locale'] as String? ?? 'en',
      primaryCurrency: data['primaryCurrency'] as String? ?? 'USD',
      secondaryCurrency: data['secondaryCurrency'] as String? ?? 'LBP',
      themePreference: ThemePreference.values.firstWhere(
        (e) => e.name == (data['themePreference'] as String? ?? 'system'),
        orElse: () => ThemePreference.system,
      ),
      notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
      budgetAlertsEnabled: data['budgetAlertsEnabled'] as bool? ?? true,
      budgetAlertThreshold:
          (data['budgetAlertThreshold'] as num?)?.toDouble() ?? 0.8,
      biometricEnabled: data['biometricEnabled'] as bool? ?? false,
      hasCompletedOnboarding: data['hasCompletedOnboarding'] as bool? ?? false,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'locale': locale,
      'primaryCurrency': primaryCurrency,
      'secondaryCurrency': secondaryCurrency,
      'themePreference': themePreference.name,
      'notificationsEnabled': notificationsEnabled,
      'budgetAlertsEnabled': budgetAlertsEnabled,
      'budgetAlertThreshold': budgetAlertThreshold,
      'biometricEnabled': biometricEnabled,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Convert to domain entity
  UserPreferences toEntity() {
    return UserPreferences(
      userId: userId,
      locale: locale,
      primaryCurrency: primaryCurrency,
      secondaryCurrency: secondaryCurrency,
      themePreference: themePreference,
      notificationsEnabled: notificationsEnabled,
      budgetAlertsEnabled: budgetAlertsEnabled,
      budgetAlertThreshold: budgetAlertThreshold,
      biometricEnabled: biometricEnabled,
      hasCompletedOnboarding: hasCompletedOnboarding,
      updatedAt: updatedAt,
    );
  }

  /// Create from domain entity
  factory UserPreferencesModel.fromEntity(UserPreferences prefs) {
    return UserPreferencesModel(
      userId: prefs.userId,
      locale: prefs.locale,
      primaryCurrency: prefs.primaryCurrency,
      secondaryCurrency: prefs.secondaryCurrency,
      themePreference: prefs.themePreference,
      notificationsEnabled: prefs.notificationsEnabled,
      budgetAlertsEnabled: prefs.budgetAlertsEnabled,
      budgetAlertThreshold: prefs.budgetAlertThreshold,
      biometricEnabled: prefs.biometricEnabled,
      hasCompletedOnboarding: prefs.hasCompletedOnboarding,
      updatedAt: prefs.updatedAt,
    );
  }

  /// Create default preferences for new user
  factory UserPreferencesModel.defaultForUser(String userId) {
    return UserPreferencesModel(
      userId: userId,
      locale: 'en',
      primaryCurrency: 'USD',
      secondaryCurrency: 'LBP',
      themePreference: ThemePreference.system,
      notificationsEnabled: true,
      budgetAlertsEnabled: true,
      budgetAlertThreshold: 0.8,
      biometricEnabled: false,
      hasCompletedOnboarding: false,
    );
  }

  UserPreferencesModel copyWith({
    String? userId,
    String? locale,
    String? primaryCurrency,
    String? secondaryCurrency,
    ThemePreference? themePreference,
    bool? notificationsEnabled,
    bool? budgetAlertsEnabled,
    double? budgetAlertThreshold,
    bool? biometricEnabled,
    bool? hasCompletedOnboarding,
    DateTime? updatedAt,
  }) {
    return UserPreferencesModel(
      userId: userId ?? this.userId,
      locale: locale ?? this.locale,
      primaryCurrency: primaryCurrency ?? this.primaryCurrency,
      secondaryCurrency: secondaryCurrency ?? this.secondaryCurrency,
      themePreference: themePreference ?? this.themePreference,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      budgetAlertsEnabled: budgetAlertsEnabled ?? this.budgetAlertsEnabled,
      budgetAlertThreshold: budgetAlertThreshold ?? this.budgetAlertThreshold,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
