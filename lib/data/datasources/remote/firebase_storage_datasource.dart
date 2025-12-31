import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import '../../../core/errors/exceptions.dart';

/// Data source for Firebase Storage operations (receipt images)
abstract class FirebaseStorageDatasource {
  /// Upload receipt image
  ///
  /// Returns the download URL of the uploaded image
  Future<String> uploadReceiptImage({
    required String userId,
    required String receiptId,
    required Uint8List imageBytes,
    String? fileName,
  });

  /// Delete receipt image
  Future<void> deleteReceiptImage(String imageUrl);

  /// Get receipt image bytes
  Future<Uint8List> getReceiptImage(String imageUrl);

  /// Delete all images for a receipt
  Future<void> deleteAllReceiptImages({
    required String userId,
    required String receiptId,
  });
}

/// Implementation of Firebase Storage data source
class FirebaseStorageDatasourceImpl implements FirebaseStorageDatasource {
  final FirebaseStorage _storage;

  FirebaseStorageDatasourceImpl({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  /// Get storage path for receipt images
  String _getReceiptImagePath({
    required String userId,
    required String receiptId,
    required String fileName,
  }) {
    return 'users/$userId/receipts/$receiptId/$fileName';
  }

  @override
  Future<String> uploadReceiptImage({
    required String userId,
    required String receiptId,
    required Uint8List imageBytes,
    String? fileName,
  }) async {
    try {
      // Generate filename if not provided
      final actualFileName =
          fileName ?? '${DateTime.now().millisecondsSinceEpoch}.jpg';

      final path = _getReceiptImagePath(
        userId: userId,
        receiptId: receiptId,
        fileName: actualFileName,
      );

      final ref = _storage.ref(path);

      // Upload with metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'receiptId': receiptId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      await ref.putData(imageBytes, metadata);

      // Get download URL
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      throw StorageException(
        'Failed to upload image: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw StorageException('Failed to upload image: $e');
    }
  }

  @override
  Future<void> deleteReceiptImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } on FirebaseException catch (e) {
      // Ignore not found errors (image may already be deleted)
      if (e.code == 'object-not-found') return;

      throw StorageException(
        'Failed to delete image: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw StorageException('Failed to delete image: $e');
    }
  }

  @override
  Future<Uint8List> getReceiptImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);

      // Download with max size limit (10 MB)
      const maxSize = 10 * 1024 * 1024; // 10 MB
      final data = await ref.getData(maxSize);

      if (data == null) {
        throw const StorageException('Image data is null');
      }

      return data;
    } on FirebaseException catch (e) {
      throw StorageException(
        'Failed to get image: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw StorageException('Failed to get image: $e');
    }
  }

  @override
  Future<void> deleteAllReceiptImages({
    required String userId,
    required String receiptId,
  }) async {
    try {
      final path = 'users/$userId/receipts/$receiptId';
      final ref = _storage.ref(path);

      // List all files in the directory
      final result = await ref.listAll();

      // Delete each file
      for (final item in result.items) {
        await item.delete();
      }
    } on FirebaseException catch (e) {
      // Ignore not found errors
      if (e.code == 'object-not-found') return;

      throw StorageException(
        'Failed to delete images: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw StorageException('Failed to delete images: $e');
    }
  }
}
