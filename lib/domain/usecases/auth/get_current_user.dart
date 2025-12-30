import 'package:receipt_vault/core/utils/result.dart';
import 'package:receipt_vault/domain/entities/user.dart';
import 'package:receipt_vault/domain/repositories/auth_repository.dart';

/// Use case for getting the current authenticated user
class GetCurrentUser {
  final AuthRepository _repository;

  GetCurrentUser(this._repository);

  Future<Result<User?>> call() {
    return _repository.getCurrentUser();
  }

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _repository.authStateChanges;
}
