import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// User entity representing an authenticated user
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    @Default(false) bool emailVerified,
    @Default(AuthProvider.email) AuthProvider provider,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

/// Authentication provider enum
enum AuthProvider {
  email,
  google,
  apple,
}

extension AuthProviderExtension on AuthProvider {
  String get displayName {
    switch (this) {
      case AuthProvider.email:
        return 'Email';
      case AuthProvider.google:
        return 'Google';
      case AuthProvider.apple:
        return 'Apple';
    }
  }

  String get iconAsset {
    switch (this) {
      case AuthProvider.email:
        return 'assets/icons/email.svg';
      case AuthProvider.google:
        return 'assets/icons/google.svg';
      case AuthProvider.apple:
        return 'assets/icons/apple.svg';
    }
  }
}
