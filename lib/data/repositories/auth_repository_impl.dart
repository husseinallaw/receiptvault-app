import 'package:receipt_vault/core/errors/exceptions.dart';
import 'package:receipt_vault/core/errors/failures.dart';
import 'package:receipt_vault/core/utils/result.dart';
import 'package:receipt_vault/data/datasources/local/secure_storage_datasource.dart';
import 'package:receipt_vault/data/datasources/remote/firebase_auth_datasource.dart';
import 'package:receipt_vault/data/datasources/remote/firestore_user_datasource.dart';
import 'package:receipt_vault/data/models/user_model.dart';
import 'package:receipt_vault/data/models/user_preferences_model.dart';
import 'package:receipt_vault/domain/entities/user.dart';
import 'package:receipt_vault/domain/entities/user_preferences.dart';
import 'package:receipt_vault/domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDatasource _authDatasource;
  final FirestoreUserDatasource _userDatasource;
  final SecureStorageDatasource _secureStorage;

  AuthRepositoryImpl({
    required FirebaseAuthDatasource authDatasource,
    required FirestoreUserDatasource userDatasource,
    required SecureStorageDatasource secureStorage,
  })  : _authDatasource = authDatasource,
        _userDatasource = userDatasource,
        _secureStorage = secureStorage;

  @override
  Stream<User?> get authStateChanges {
    return _authDatasource.authStateChanges.map((userModel) {
      return userModel?.toEntity();
    });
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final userModel = _authDatasource.currentUser;
      if (userModel == null) {
        return const Result.success(null);
      }
      return Result.success(userModel.toEntity());
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(message: e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<User>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await _authDatasource.signInWithEmail(
        email: email,
        password: password,
      );

      // Save user to Firestore
      await _userDatasource.createOrUpdateUser(userModel);

      // Cache user ID
      await _secureStorage.saveUserId(userModel.id);
      await _secureStorage.saveLastLogin(DateTime.now());

      return Result.success(userModel.toEntity());
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<User>> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final userModel = await _authDatasource.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );

      // Create user document in Firestore
      await _userDatasource.createOrUpdateUser(userModel);

      // Create default preferences
      await createUserPreferences(userModel.id);

      // Cache user ID
      await _secureStorage.saveUserId(userModel.id);
      await _secureStorage.saveLastLogin(DateTime.now());

      // Send email verification
      await _authDatasource.sendEmailVerification();

      return Result.success(userModel.toEntity());
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<User>> signInWithGoogle() async {
    try {
      final userModel = await _authDatasource.signInWithGoogle();

      // Check if user exists in Firestore
      final existingUser = await _userDatasource.getUser(userModel.id);
      if (existingUser == null) {
        // New user - create document and preferences
        await _userDatasource.createOrUpdateUser(userModel);
        await createUserPreferences(userModel.id);
      } else {
        // Existing user - update last login
        await _userDatasource.createOrUpdateUser(userModel);
      }

      // Cache user ID
      await _secureStorage.saveUserId(userModel.id);
      await _secureStorage.saveLastLogin(DateTime.now());

      return Result.success(userModel.toEntity());
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<User>> signInWithApple() async {
    try {
      final userModel = await _authDatasource.signInWithApple();

      // Check if user exists in Firestore
      final existingUser = await _userDatasource.getUser(userModel.id);
      if (existingUser == null) {
        // New user - create document and preferences
        await _userDatasource.createOrUpdateUser(userModel);
        await createUserPreferences(userModel.id);
      } else {
        // Existing user - update last login
        await _userDatasource.createOrUpdateUser(userModel);
      }

      // Cache user ID
      await _secureStorage.saveUserId(userModel.id);
      await _secureStorage.saveLastLogin(DateTime.now());

      return Result.success(userModel.toEntity());
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _authDatasource.signOut();
      await _secureStorage.clearAll();
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(message: e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _authDatasource.sendPasswordResetEmail(email);
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(message: e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<User>> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final userModel = await _authDatasource.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );

      // Update Firestore
      await _userDatasource.createOrUpdateUser(userModel);

      return Result.success(userModel.toEntity());
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      final userId = await _secureStorage.getUserId();
      if (userId != null) {
        await _userDatasource.deleteUser(userId);
      }
      await _authDatasource.deleteAccount();
      await _secureStorage.clearAll();
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<UserPreferences>> getUserPreferences(String userId) async {
    try {
      final prefsModel = await _userDatasource.getUserPreferences(userId);
      if (prefsModel == null) {
        // Create default preferences if none exist
        return createUserPreferences(userId);
      }
      return Result.success(prefsModel.toEntity());
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<UserPreferences>> updateUserPreferences(
    UserPreferences preferences,
  ) async {
    try {
      final prefsModel = UserPreferencesModel.fromEntity(preferences);
      await _userDatasource.createOrUpdatePreferences(prefsModel);
      return Result.success(preferences);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<UserPreferences>> createUserPreferences(String userId) async {
    try {
      final prefsModel = UserPreferencesModel.defaultForUser(userId);
      await _userDatasource.createOrUpdatePreferences(prefsModel);
      return Result.success(prefsModel.toEntity());
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<User>> reloadUser() async {
    try {
      final userModel = await _authDatasource.reloadUser();
      return Result.success(userModel.toEntity());
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(message: e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<bool>> isEmailRegistered(String email) async {
    try {
      final isRegistered = await _authDatasource.isEmailRegistered(email);
      return Result.success(isRegistered);
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(message: e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> sendEmailVerification() async {
    try {
      await _authDatasource.sendEmailVerification();
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(message: e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }
}
