import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:receipt_vault/domain/entities/user.dart';

/// Data model for User with Firestore serialization
class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final bool emailVerified;
  final AuthProvider provider;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.emailVerified = false,
    this.provider = AuthProvider.email,
    this.createdAt,
    this.lastLoginAt,
  });

  /// Create from Firebase Auth user
  factory UserModel.fromFirebaseUser(firebase_auth.User firebaseUser) {
    AuthProvider provider = AuthProvider.email;

    // Determine provider from providerData
    for (final providerInfo in firebaseUser.providerData) {
      if (providerInfo.providerId == 'google.com') {
        provider = AuthProvider.google;
        break;
      } else if (providerInfo.providerId == 'apple.com') {
        provider = AuthProvider.apple;
        break;
      }
    }

    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      phoneNumber: firebaseUser.phoneNumber,
      emailVerified: firebaseUser.emailVerified,
      provider: provider,
      createdAt: firebaseUser.metadata.creationTime,
      lastLoginAt: firebaseUser.metadata.lastSignInTime,
    );
  }

  /// Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      emailVerified: data['emailVerified'] as bool? ?? false,
      provider: AuthProvider.values.firstWhere(
        (e) => e.name == (data['provider'] as String? ?? 'email'),
        orElse: () => AuthProvider.email,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'emailVerified': emailVerified,
      'provider': provider.name,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    };
  }

  /// Convert to domain entity
  User toEntity() {
    return User(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      phoneNumber: phoneNumber,
      emailVerified: emailVerified,
      provider: provider,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
    );
  }

  /// Create from domain entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      phoneNumber: user.phoneNumber,
      emailVerified: user.emailVerified,
      provider: user.provider,
      createdAt: user.createdAt,
      lastLoginAt: user.lastLoginAt,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    bool? emailVerified,
    AuthProvider? provider,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailVerified: emailVerified ?? this.emailVerified,
      provider: provider ?? this.provider,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
