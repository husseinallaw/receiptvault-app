import 'package:receipt_vault/core/utils/result.dart';
import 'package:receipt_vault/domain/entities/user.dart';
import 'package:receipt_vault/domain/repositories/auth_repository.dart';

/// Use case for signing up with email and password
class SignUpWithEmail {
  final AuthRepository _repository;

  SignUpWithEmail(this._repository);

  Future<Result<User>> call({
    required String email,
    required String password,
    String? displayName,
  }) {
    return _repository.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}
