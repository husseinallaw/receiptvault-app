import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:receipt_vault/core/errors/exceptions.dart';

/// Local data source for secure storage operations
class SecureStorageDatasource {
  final FlutterSecureStorage _storage;

  // Storage keys
  static const String _userIdKey = 'user_id';
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _lastLoginKey = 'last_login';
  static const String _cachedUserKey = 'cached_user';

  SecureStorageDatasource({
    FlutterSecureStorage? storage,
  }) : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    try {
      await _storage.write(key: _userIdKey, value: userId);
    } catch (e) {
      throw CacheException('Failed to save user ID: ${e.toString()}');
    }
  }

  /// Get saved user ID
  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _userIdKey);
    } catch (e) {
      throw CacheException('Failed to get user ID: ${e.toString()}');
    }
  }

  /// Save auth token
  Future<void> saveAuthToken(String token) async {
    try {
      await _storage.write(key: _authTokenKey, value: token);
    } catch (e) {
      throw CacheException('Failed to save auth token: ${e.toString()}');
    }
  }

  /// Get auth token
  Future<String?> getAuthToken() async {
    try {
      return await _storage.read(key: _authTokenKey);
    } catch (e) {
      throw CacheException('Failed to get auth token: ${e.toString()}');
    }
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
    } catch (e) {
      throw CacheException('Failed to save refresh token: ${e.toString()}');
    }
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      throw CacheException('Failed to get refresh token: ${e.toString()}');
    }
  }

  /// Set biometric enabled status
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _storage.write(
        key: _biometricEnabledKey,
        value: enabled.toString(),
      );
    } catch (e) {
      throw CacheException('Failed to save biometric setting: ${e.toString()}');
    }
  }

  /// Check if biometric is enabled
  Future<bool> isBiometricEnabled() async {
    try {
      final value = await _storage.read(key: _biometricEnabledKey);
      return value == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Save last login timestamp
  Future<void> saveLastLogin(DateTime dateTime) async {
    try {
      await _storage.write(
        key: _lastLoginKey,
        value: dateTime.toIso8601String(),
      );
    } catch (e) {
      throw CacheException('Failed to save last login: ${e.toString()}');
    }
  }

  /// Get last login timestamp
  Future<DateTime?> getLastLogin() async {
    try {
      final value = await _storage.read(key: _lastLoginKey);
      if (value == null) return null;
      return DateTime.parse(value);
    } catch (e) {
      return null;
    }
  }

  /// Cache user data
  Future<void> cacheUser(Map<String, dynamic> userData) async {
    try {
      await _storage.write(
        key: _cachedUserKey,
        value: jsonEncode(userData),
      );
    } catch (e) {
      throw CacheException('Failed to cache user: ${e.toString()}');
    }
  }

  /// Get cached user data
  Future<Map<String, dynamic>?> getCachedUser() async {
    try {
      final value = await _storage.read(key: _cachedUserKey);
      if (value == null) return null;
      return jsonDecode(value) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Clear all stored data (on logout)
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw CacheException('Failed to clear storage: ${e.toString()}');
    }
  }

  /// Delete specific key
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw CacheException('Failed to delete key: ${e.toString()}');
    }
  }

  /// Check if key exists
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      return false;
    }
  }
}
