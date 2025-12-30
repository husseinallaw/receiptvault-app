import 'package:receipt_vault/core/utils/result.dart';
import 'package:receipt_vault/domain/entities/user.dart';
import 'package:receipt_vault/domain/repositories/auth_repository.dart';

/// Use case for signing in with Apple
class SignInWithApple {
  final AuthRepository _repository;

  SignInWithApple(this._repository);

  Future<Result<User>> call() {
    return _repository.signInWithApple();
  }
}
