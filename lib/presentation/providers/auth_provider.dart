import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_vault/core/utils/result.dart';
import 'package:receipt_vault/data/datasources/local/secure_storage_datasource.dart';
import 'package:receipt_vault/data/datasources/remote/firebase_auth_datasource.dart';
import 'package:receipt_vault/data/datasources/remote/firestore_user_datasource.dart';
import 'package:receipt_vault/data/repositories/auth_repository_impl.dart';
import 'package:receipt_vault/domain/entities/user.dart';
import 'package:receipt_vault/domain/entities/user_preferences.dart';
import 'package:receipt_vault/domain/repositories/auth_repository.dart';

/// Auth state enum
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Auth state class
class AuthState {
  final AuthStatus status;
  final User? user;
  final UserPreferences? preferences;
  final String? errorMessage;
  final bool isNewUser;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.preferences,
    this.errorMessage,
    this.isNewUser = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    UserPreferences? preferences,
    String? errorMessage,
    bool? isNewUser,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      preferences: preferences ?? this.preferences,
      errorMessage: errorMessage ?? this.errorMessage,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error;
  bool get needsOnboarding =>
      isNewUser || (preferences?.hasCompletedOnboarding == false);
}

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    authDatasource: FirebaseAuthDatasource(),
    userDatasource: FirestoreUserDatasource(),
    secureStorage: SecureStorageDatasource(),
  );
});

/// Auth state stream provider
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

/// Auth notifier provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository, ref);
});

/// Auth notifier class
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final Ref _ref;

  AuthNotifier(this._repository, this._ref) : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    // Listen to auth state changes
    _repository.authStateChanges.listen((user) async {
      if (user != null) {
        // Load user preferences
        final prefsResult = await _repository.getUserPreferences(user.id);
        final prefs = prefsResult.dataOrNull;

        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          preferences: prefs,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
          preferences: null,
          errorMessage: null,
        );
      }
    });

    // Check current user
    final result = await _repository.getCurrentUser();
    result.when(
      success: (user) async {
        if (user != null) {
          final prefsResult = await _repository.getUserPreferences(user.id);
          final prefs = prefsResult.dataOrNull;

          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            preferences: prefs,
          );
        } else {
          state = state.copyWith(status: AuthStatus.unauthenticated);
        }
      },
      failure: (failure) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: failure.displayMessage,
        );
      },
    );
  }

  /// Sign in with email and password
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _repository.signInWithEmail(
      email: email,
      password: password,
    );

    return result.when(
      success: (user) async {
        final prefsResult = await _repository.getUserPreferences(user.id);
        final prefs = prefsResult.dataOrNull;

        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          preferences: prefs,
          isNewUser: false,
        );
        return true;
      },
      failure: (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.displayMessage,
        );
        return false;
      },
    );
  }

  /// Sign up with email and password
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _repository.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );

    return result.when(
      success: (user) async {
        final prefsResult = await _repository.getUserPreferences(user.id);
        final prefs = prefsResult.dataOrNull;

        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          preferences: prefs,
          isNewUser: true,
        );
        return true;
      },
      failure: (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.displayMessage,
        );
        return false;
      },
    );
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _repository.signInWithGoogle();

    return result.when(
      success: (user) async {
        final prefsResult = await _repository.getUserPreferences(user.id);
        final prefs = prefsResult.dataOrNull;

        final isNew = prefs?.hasCompletedOnboarding == false;

        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          preferences: prefs,
          isNewUser: isNew,
        );
        return true;
      },
      failure: (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.displayMessage,
        );
        return false;
      },
    );
  }

  /// Sign in with Apple
  Future<bool> signInWithApple() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _repository.signInWithApple();

    return result.when(
      success: (user) async {
        final prefsResult = await _repository.getUserPreferences(user.id);
        final prefs = prefsResult.dataOrNull;

        final isNew = prefs?.hasCompletedOnboarding == false;

        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          preferences: prefs,
          isNewUser: isNew,
        );
        return true;
      },
      failure: (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.displayMessage,
        );
        return false;
      },
    );
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _repository.signOut();

    result.when(
      success: (_) {
        state = const AuthState(status: AuthStatus.unauthenticated);
      },
      failure: (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.displayMessage,
        );
      },
    );
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    final result = await _repository.sendPasswordResetEmail(email);

    return result.when(
      success: (_) => true,
      failure: (failure) {
        state = state.copyWith(errorMessage: failure.displayMessage);
        return false;
      },
    );
  }

  /// Update user preferences
  Future<bool> updatePreferences(UserPreferences preferences) async {
    final result = await _repository.updateUserPreferences(preferences);

    return result.when(
      success: (prefs) {
        state = state.copyWith(preferences: prefs);
        return true;
      },
      failure: (failure) {
        state = state.copyWith(errorMessage: failure.displayMessage);
        return false;
      },
    );
  }

  /// Complete onboarding
  Future<void> completeOnboarding() async {
    if (state.preferences != null) {
      final updatedPrefs = state.preferences!.copyWith(
        hasCompletedOnboarding: true,
      );
      await updatePreferences(updatedPrefs);
      state = state.copyWith(isNewUser: false);
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
