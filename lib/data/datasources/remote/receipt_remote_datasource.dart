import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/receipt_model.dart';
import '../../models/store_model.dart';

/// Remote data source for receipt operations using Firestore
abstract class ReceiptRemoteDatasource {
  /// Get receipts for a user
  Future<List<ReceiptModel>> getReceipts({
    required String userId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  });

  /// Get a single receipt by ID
  Future<ReceiptModel?> getReceiptById({
    required String userId,
    required String receiptId,
  });

  /// Create or update a receipt
  Future<ReceiptModel> upsertReceipt({
    required String userId,
    required ReceiptModel receipt,
  });

  /// Delete a receipt (soft delete)
  Future<void> deleteReceipt({
    required String userId,
    required String receiptId,
  });

  /// Hard delete a receipt
  Future<void> hardDeleteReceipt({
    required String userId,
    required String receiptId,
  });

  /// Search receipts
  Future<List<ReceiptModel>> searchReceipts({
    required String userId,
    required String query,
    int limit = 20,
  });

  /// Get receipts by date range
  Future<List<ReceiptModel>> getReceiptsByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get all stores
  Future<List<StoreModel>> getStores();

  /// Get store by ID
  Future<StoreModel?> getStoreById(String id);
}

/// Implementation of remote receipt data source
class ReceiptRemoteDatasourceImpl implements ReceiptRemoteDatasource {
  final FirebaseFirestore _firestore;

  ReceiptRemoteDatasourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get reference to user's receipts collection
  CollectionReference<Map<String, dynamic>> _receiptsCollection(String userId) {
    return _firestore
        .collection(AppConstants.collectionUsers)
        .doc(userId)
        .collection(AppConstants.collectionReceipts);
  }

  /// Get reference to stores collection
  CollectionReference<Map<String, dynamic>> get _storesCollection {
    return _firestore.collection(AppConstants.collectionStores);
  }

  @override
  Future<List<ReceiptModel>> getReceipts({
    required String userId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _receiptsCollection(userId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('date', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => ReceiptModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        'Failed to get receipts: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw ServerException('Failed to get receipts: $e');
    }
  }

  @override
  Future<ReceiptModel?> getReceiptById({
    required String userId,
    required String receiptId,
  }) async {
    try {
      final doc = await _receiptsCollection(userId).doc(receiptId).get();

      if (!doc.exists) return null;

      return ReceiptModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(
        'Failed to get receipt: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw ServerException('Failed to get receipt: $e');
    }
  }

  @override
  Future<ReceiptModel> upsertReceipt({
    required String userId,
    required ReceiptModel receipt,
  }) async {
    try {
      final docRef = _receiptsCollection(userId).doc(receipt.id);

      await docRef.set(receipt.toFirestore(), SetOptions(merge: true));

      // Fetch the updated document
      final updatedDoc = await docRef.get();
      return ReceiptModel.fromFirestore(updatedDoc);
    } on FirebaseException catch (e) {
      throw ServerException(
        'Failed to save receipt: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw ServerException('Failed to save receipt: $e');
    }
  }

  @override
  Future<void> deleteReceipt({
    required String userId,
    required String receiptId,
  }) async {
    try {
      await _receiptsCollection(userId).doc(receiptId).update({
        'isDeleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(
        'Failed to delete receipt: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw ServerException('Failed to delete receipt: $e');
    }
  }

  @override
  Future<void> hardDeleteReceipt({
    required String userId,
    required String receiptId,
  }) async {
    try {
      await _receiptsCollection(userId).doc(receiptId).delete();
    } on FirebaseException catch (e) {
      throw ServerException(
        'Failed to delete receipt: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw ServerException('Failed to delete receipt: $e');
    }
  }

  @override
  Future<List<ReceiptModel>> searchReceipts({
    required String userId,
    required String query,
    int limit = 20,
  }) async {
    try {
      // Firestore doesn't support full-text search, so we use a simple prefix match
      // For production, consider using Algolia or ElasticSearch
      final lowerQuery = query.toLowerCase();

      final snapshot = await _receiptsCollection(userId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('date', descending: true)
          .limit(limit * 2) // Fetch more to filter client-side
          .get();

      // Filter client-side for store name match
      final results = snapshot.docs
          .map((doc) => ReceiptModel.fromFirestore(doc))
          .where((receipt) =>
              receipt.storeName.toLowerCase().contains(lowerQuery) ||
              (receipt.notes?.toLowerCase().contains(lowerQuery) ?? false))
          .take(limit)
          .toList();

      return results;
    } on FirebaseException catch (e) {
      throw ServerException(
        'Failed to search receipts: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw ServerException('Failed to search receipts: $e');
    }
  }

  @override
  Future<List<ReceiptModel>> getReceiptsByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snapshot = await _receiptsCollection(userId)
          .where('isDeleted', isEqualTo: false)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReceiptModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        'Failed to get receipts by date: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw ServerException('Failed to get receipts by date: $e');
    }
  }

  @override
  Future<List<StoreModel>> getStores() async {
    try {
      final snapshot = await _storesCollection
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) => StoreModel.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        'Failed to get stores: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw ServerException('Failed to get stores: $e');
    }
  }

  @override
  Future<StoreModel?> getStoreById(String id) async {
    try {
      final doc = await _storesCollection.doc(id).get();

      if (!doc.exists) return null;

      return StoreModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(
        'Failed to get store: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw ServerException('Failed to get store: $e');
    }
  }
}
