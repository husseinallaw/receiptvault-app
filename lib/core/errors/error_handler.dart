import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'exceptions.dart';
import 'failures.dart';

/// Centralized error handler for converting exceptions to failures
class ErrorHandler {
  const ErrorHandler._();

  /// Convert any exception to a Failure
  static Failure handleException(Object error, [StackTrace? stackTrace]) {
    if (error is Failure) {
      return error;
    }

    if (error is AppException) {
      return _handleAppException(error);
    }

    if (error is FirebaseAuthException) {
      return _handleFirebaseAuthException(error);
    }

    if (error is FirebaseException) {
      return _handleFirebaseException(error);
    }

    if (error is SocketException || error is HttpException) {
      return const Failure.network();
    }

    if (error is TimeoutException) {
      return const Failure.network(message: 'Connection timed out');
    }

    if (error is FormatException) {
      return Failure.validation(message: 'Invalid data format: ${error.message}');
    }

    return Failure.unknown(
      message: error.toString(),
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Handle custom app exceptions
  static Failure _handleAppException(AppException exception) {
    return switch (exception) {
      ServerException e => Failure.server(
          message: e.message,
          code: e.code,
          statusCode: e.statusCode,
        ),
      NetworkException e => Failure.network(message: e.message),
      CacheException e => Failure.cache(message: e.message),
      AuthException e => Failure.auth(message: e.message, code: e.code),
      ValidationException e => Failure.validation(
          message: e.message,
          fieldErrors: e.fieldErrors,
        ),
      PermissionException e => Failure.permission(message: e.message),
      StorageException e => Failure.storage(message: e.message),
      OcrException e => Failure.ocr(message: e.message, confidence: e.confidence),
      _ => Failure.unknown(message: exception.message),
    };
  }

  /// Handle Firebase Auth exceptions
  static Failure _handleFirebaseAuthException(FirebaseAuthException exception) {
    final message = switch (exception.code) {
      'invalid-email' => 'The email address is invalid',
      'user-disabled' => 'This account has been disabled',
      'user-not-found' => 'No account found with this email',
      'wrong-password' => 'Incorrect password',
      'email-already-in-use' => 'An account already exists with this email',
      'weak-password' => 'Password is too weak',
      'operation-not-allowed' => 'This sign-in method is not allowed',
      'too-many-requests' => 'Too many attempts. Please try again later',
      'network-request-failed' => 'Network error. Please check your connection',
      'invalid-credential' => 'Invalid credentials',
      'account-exists-with-different-credential' =>
        'An account already exists with a different sign-in method',
      'requires-recent-login' => 'Please sign in again to continue',
      'provider-already-linked' => 'This account is already linked',
      'credential-already-in-use' => 'This credential is already in use',
      _ => exception.message ?? 'Authentication failed',
    };

    return Failure.auth(message: message, code: exception.code);
  }

  /// Handle general Firebase exceptions
  static Failure _handleFirebaseException(FirebaseException exception) {
    if (exception.code == 'unavailable') {
      return const Failure.network(message: 'Service temporarily unavailable');
    }

    if (exception.code == 'permission-denied') {
      return const Failure.permission();
    }

    if (exception.code == 'not-found') {
      return Failure.server(
        message: 'Resource not found',
        code: exception.code,
      );
    }

    return Failure.server(
      message: exception.message ?? 'Firebase error occurred',
      code: exception.code,
    );
  }

  /// Get Arabic error message
  static String getArabicMessage(Failure failure) {
    return failure.displayMessageArabic;
  }

  /// Get English error message
  static String getEnglishMessage(Failure failure) {
    return failure.displayMessage;
  }

  /// Get localized message based on language code
  static String getLocalizedMessage(Failure failure, String languageCode) {
    return languageCode == 'ar'
        ? getArabicMessage(failure)
        : getEnglishMessage(failure);
  }
}

/// Extension for async error handling
extension FutureErrorHandler<T> on Future<T> {
  /// Converts exceptions to failures using ErrorHandler
  Future<T> handleErrors() async {
    try {
      return await this;
    } catch (e, stackTrace) {
      throw ErrorHandler.handleException(e, stackTrace);
    }
  }
}
