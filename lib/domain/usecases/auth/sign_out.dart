import 'package:receipt_vault/core/utils/result.dart';
import 'package:receipt_vault/domain/repositories/auth_repository.dart';

/// Use case for signing out
class SignOut {
  final AuthRepository _repository;

  SignOut(this._repository);

  Future<Result<void>> call() {
    return _repository.signOut();
  }
}
