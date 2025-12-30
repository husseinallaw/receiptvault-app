import 'package:receipt_vault/core/utils/result.dart';
import 'package:receipt_vault/domain/repositories/auth_repository.dart';

/// Use case for sending password reset email
class SendPasswordReset {
  final AuthRepository _repository;

  SendPasswordReset(this._repository);

  Future<Result<void>> call(String email) {
    return _repository.sendPasswordResetEmail(email);
  }
}
