import 'package:receipt_vault/core/utils/result.dart';
import 'package:receipt_vault/domain/entities/user.dart';
import 'package:receipt_vault/domain/repositories/auth_repository.dart';

/// Use case for signing in with email and password
class SignInWithEmail {
  final AuthRepository _repository;

  SignInWithEmail(this._repository);

  Future<Result<User>> call({
    required String email,
    required String password,
  }) {
    return _repository.signInWithEmail(
      email: email,
      password: password,
    );
  }
}
