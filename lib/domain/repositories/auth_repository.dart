import 'package:receipt_vault/core/utils/result.dart';
import 'package:receipt_vault/domain/entities/user.dart';
import 'package:receipt_vault/domain/entities/user_preferences.dart';

/// Abstract repository for authentication operations
abstract class AuthRepository {
  /// Stream of authentication state changes
  Stream<User?> get authStateChanges;

  /// Get the currently authenticated user
  Future<Result<User?>> getCurrentUser();

  /// Sign in with email and password
  Future<Result<User>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<Result<User>> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  /// Sign in with Google
  Future<Result<User>> signInWithGoogle();

  /// Sign in with Apple
  Future<Result<User>> signInWithApple();

  /// Sign out the current user
  Future<Result<void>> signOut();

  /// Send password reset email
  Future<Result<void>> sendPasswordResetEmail(String email);

  /// Update user profile
  Future<Result<User>> updateProfile({
    String? displayName,
    String? photoUrl,
  });

  /// Delete user account
  Future<Result<void>> deleteAccount();

  /// Get user preferences
  Future<Result<UserPreferences>> getUserPreferences(String userId);

  /// Update user preferences
  Future<Result<UserPreferences>> updateUserPreferences(
    UserPreferences preferences,
  );

  /// Create initial user preferences for new user
  Future<Result<UserPreferences>> createUserPreferences(String userId);

  /// Reload current user data from server
  Future<Result<User>> reloadUser();

  /// Check if email is already registered
  Future<Result<bool>> isEmailRegistered(String email);

  /// Verify email address
  Future<Result<void>> sendEmailVerification();
}
