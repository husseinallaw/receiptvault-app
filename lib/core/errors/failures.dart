import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

/// Base failure class for all application failures
/// Uses freezed for immutable, pattern-matchable failure types
@freezed
class Failure with _$Failure {
  const Failure._();

  /// Server-related failures (API errors, Cloud Functions errors)
  const factory Failure.server({
    required String message,
    String? code,
    int? statusCode,
  }) = ServerFailure;

  /// Network failures (no connection, timeout)
  const factory Failure.network({
    @Default('No internet connection') String message,
  }) = NetworkFailure;

  /// Local cache/database failures
  const factory Failure.cache({
    required String message,
  }) = CacheFailure;

  /// Authentication failures
  const factory Failure.auth({
    required String message,
    String? code,
  }) = AuthFailure;

  /// Validation failures (invalid input)
  const factory Failure.validation({
    required String message,
    Map<String, String>? fieldErrors,
  }) = ValidationFailure;

  /// Permission failures (unauthorized access)
  const factory Failure.permission({
    @Default('Permission denied') String message,
  }) = PermissionFailure;

  /// Storage failures (file operations)
  const factory Failure.storage({
    required String message,
  }) = StorageFailure;

  /// OCR processing failures
  const factory Failure.ocr({
    required String message,
    double? confidence,
  }) = OcrFailure;

  /// Unknown/unexpected failures
  const factory Failure.unknown({
    @Default('An unexpected error occurred') String message,
    Object? error,
    StackTrace? stackTrace,
  }) = UnknownFailure;

  /// Get a user-friendly message for display
  String get displayMessage => when(
        server: (message, _, __) => message,
        network: (message) => message,
        cache: (message) => message,
        auth: (message, _) => message,
        validation: (message, _) => message,
        permission: (message) => message,
        storage: (message) => message,
        ocr: (message, _) => message,
        unknown: (message, _, __) => message,
      );

  /// Get Arabic message for display
  String get displayMessageArabic => when(
        server: (_, __, ___) => 'حدث خطأ في الخادم',
        network: (_) => 'لا يوجد اتصال بالإنترنت',
        cache: (_) => 'حدث خطأ في التخزين المحلي',
        auth: (_, __) => 'حدث خطأ في المصادقة',
        validation: (_, __) => 'البيانات المدخلة غير صالحة',
        permission: (_) => 'تم رفض الإذن',
        storage: (_) => 'حدث خطأ في التخزين',
        ocr: (_, __) => 'فشل في معالجة الإيصال',
        unknown: (_, __, ___) => 'حدث خطأ غير متوقع',
      );
}
