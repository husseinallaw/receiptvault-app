import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:receipt_vault/core/errors/exceptions.dart';
import 'package:receipt_vault/data/models/user_model.dart';
import 'package:receipt_vault/data/models/user_preferences_model.dart';

/// Remote data source for Firestore user operations
class FirestoreUserDatasource {
  final FirebaseFirestore _firestore;

  static const String _usersCollection = 'users';
  static const String _preferencesCollection = 'preferences';

  FirestoreUserDatasource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get user document reference
  DocumentReference<Map<String, dynamic>> _userDoc(String userId) {
    return _firestore.collection(_usersCollection).doc(userId);
  }

  /// Get preferences document reference
  DocumentReference<Map<String, dynamic>> _preferencesDoc(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_preferencesCollection)
        .doc('settings');
  }

  /// Create or update user document
  Future<void> createOrUpdateUser(UserModel user) async {
    try {
      await _userDoc(user.id).set(
        user.toFirestore(),
        SetOptions(merge: true),
      );
    } on FirebaseException catch (e) {
      throw ServerException('Failed to save user: ${e.message}');
    }
  }

  /// Get user by ID
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _userDoc(userId).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException('Failed to get user: ${e.message}');
    }
  }

  /// Delete user document
  Future<void> deleteUser(String userId) async {
    try {
      // Delete preferences subcollection first
      final preferencesDoc = await _preferencesDoc(userId).get();
      if (preferencesDoc.exists) {
        await _preferencesDoc(userId).delete();
      }

      // Delete user document
      await _userDoc(userId).delete();
    } on FirebaseException catch (e) {
      throw ServerException('Failed to delete user: ${e.message}');
    }
  }

  /// Get user preferences
  Future<UserPreferencesModel?> getUserPreferences(String userId) async {
    try {
      final doc = await _preferencesDoc(userId).get();
      if (!doc.exists) return null;
      return UserPreferencesModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException('Failed to get preferences: ${e.message}');
    }
  }

  /// Create or update user preferences
  Future<UserPreferencesModel> createOrUpdatePreferences(
    UserPreferencesModel preferences,
  ) async {
    try {
      await _preferencesDoc(preferences.userId).set(
        preferences.toFirestore(),
        SetOptions(merge: true),
      );
      return preferences;
    } on FirebaseException catch (e) {
      throw ServerException('Failed to save preferences: ${e.message}');
    }
  }

  /// Update specific preference fields
  Future<void> updatePreferenceFields(
    String userId,
    Map<String, dynamic> fields,
  ) async {
    try {
      fields['updatedAt'] = FieldValue.serverTimestamp();
      await _preferencesDoc(userId).update(fields);
    } on FirebaseException catch (e) {
      throw ServerException('Failed to update preferences: ${e.message}');
    }
  }

  /// Check if user document exists
  Future<bool> userExists(String userId) async {
    try {
      final doc = await _userDoc(userId).get();
      return doc.exists;
    } on FirebaseException catch (e) {
      throw ServerException('Failed to check user: ${e.message}');
    }
  }

  /// Listen to user preferences changes
  Stream<UserPreferencesModel?> watchUserPreferences(String userId) {
    return _preferencesDoc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return UserPreferencesModel.fromFirestore(snapshot);
    });
  }

  /// Listen to user document changes
  Stream<UserModel?> watchUser(String userId) {
    return _userDoc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return UserModel.fromFirestore(snapshot);
    });
  }
}
