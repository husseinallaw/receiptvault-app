import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ==================== External Services ====================

/// Firebase Auth instance provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Firestore instance provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Firebase Storage instance provider
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

/// Secure Storage provider for sensitive data
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
});

/// Shared Preferences provider (must be initialized before use)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'SharedPreferences must be overridden in ProviderScope',
  );
});

// ==================== Auth State ====================

/// Current Firebase user stream
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

/// Current user (nullable)
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateChangesProvider).valueOrNull;
});

/// Check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

/// Current user ID (nullable)
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider)?.uid;
});

// ==================== App State ====================

/// App initialization state
final appInitializedProvider = StateProvider<bool>((ref) => false);

/// App theme mode
final themeModeProvider = StateProvider<ThemeModePreference>((ref) {
  return ThemeModePreference.system;
});

/// App locale
final localeProvider = StateProvider<AppLocale>((ref) {
  return AppLocale.english;
});

// ==================== Enums ====================

/// Theme mode preference
enum ThemeModePreference {
  light,
  dark,
  system;

  String get displayName => switch (this) {
        light => 'Light',
        dark => 'Dark',
        system => 'System',
      };

  String get displayNameArabic => switch (this) {
        light => 'فاتح',
        dark => 'داكن',
        system => 'تلقائي',
      };
}

/// App locale
enum AppLocale {
  english('en', 'English', 'الإنجليزية'),
  arabic('ar', 'العربية', 'Arabic');

  final String code;
  final String displayName;
  final String displayNameOther;

  const AppLocale(this.code, this.displayName, this.displayNameOther);

  bool get isRTL => this == AppLocale.arabic;
}
