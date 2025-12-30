/// Base exception for all application exceptions
/// These are thrown in the data layer and caught/converted to Failures
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Server/API exceptions
class ServerException extends AppException {
  final int? statusCode;

  const ServerException(
    super.message, {
    super.code,
    this.statusCode,
  });

  @override
  String toString() =>
      'ServerException: $message (code: $code, status: $statusCode)';
}

/// Network connectivity exceptions
class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

/// Local cache/database exceptions
class CacheException extends AppException {
  const CacheException(super.message, {super.code});
}

/// Authentication exceptions
class AuthException extends AppException {
  const AuthException(super.message, {super.code});

  /// Common auth error codes
  static const String invalidEmail = 'invalid-email';
  static const String userDisabled = 'user-disabled';
  static const String userNotFound = 'user-not-found';
  static const String wrongPassword = 'wrong-password';
  static const String emailAlreadyInUse = 'email-already-in-use';
  static const String weakPassword = 'weak-password';
  static const String operationNotAllowed = 'operation-not-allowed';
  static const String tooManyRequests = 'too-many-requests';
  static const String tokenExpired = 'token-expired';
}

/// Validation exceptions
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException(
    super.message, {
    this.fieldErrors,
  });
}

/// Permission exceptions
class PermissionException extends AppException {
  const PermissionException([super.message = 'Permission denied']);
}

/// Storage (file operations) exceptions
class StorageException extends AppException {
  const StorageException(super.message, {super.code});
}

/// OCR processing exceptions
class OcrException extends AppException {
  final double? confidence;

  const OcrException(
    super.message, {
    super.code,
    this.confidence,
  });
}

/// Sync exceptions
class SyncException extends AppException {
  const SyncException(super.message, {super.code});
}
