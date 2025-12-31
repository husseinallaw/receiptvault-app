import '../../../core/utils/result.dart';
import '../../entities/receipt.dart';
import '../../repositories/receipt_repository.dart';

/// Use case for syncing receipts between local and remote storage
///
/// Handles both upload (local to remote) and download (remote to local)
/// synchronization with conflict resolution.
class SyncReceipts {
  final ReceiptRepository _repository;

  SyncReceipts(this._repository);

  /// Sync all pending receipts for a user
  ///
  /// Uploads all receipts that have needsSync=true to the remote server.
  ///
  /// Parameters:
  /// - [userId]: User identifier
  ///
  /// Returns the number of receipts successfully synced
  Future<Result<int>> call(String userId) {
    return _repository.syncAllReceipts(userId);
  }

  /// Sync a single receipt
  ///
  /// Uploads the receipt to remote storage and marks as synced.
  Future<Result<Receipt>> single(Receipt receipt) {
    return _repository.syncReceipt(receipt);
  }

  /// Get receipts that need to be synced
  ///
  /// Returns list of receipts with needsSync=true
  Future<Result<List<Receipt>>> getPending(String userId) {
    return _repository.getReceiptsNeedingSync(userId);
  }

  /// Fetch and merge remote receipts
  ///
  /// Downloads receipts from remote server and merges with local data.
  /// Handles conflict resolution based on updatedAt timestamps.
  ///
  /// Returns the number of receipts fetched/merged
  Future<Result<int>> fetchRemote(String userId) {
    return _repository.fetchRemoteReceipts(userId);
  }

  /// Full two-way sync
  ///
  /// Uploads pending local changes and downloads remote changes.
  /// Returns total number of receipts synced in both directions.
  Future<Result<SyncSummary>> fullSync(String userId) async {
    int uploaded = 0;
    int downloaded = 0;

    // First upload local changes
    final uploadResult = await _repository.syncAllReceipts(userId);
    uploadResult.onSuccess((count) => uploaded = count);

    if (uploadResult.isFailure) {
      return Result.failure(uploadResult.failureOrNull!);
    }

    // Then download remote changes
    final downloadResult = await _repository.fetchRemoteReceipts(userId);
    downloadResult.onSuccess((count) => downloaded = count);

    if (downloadResult.isFailure) {
      return Result.failure(downloadResult.failureOrNull!);
    }

    return Result.success(SyncSummary(
      uploaded: uploaded,
      downloaded: downloaded,
      syncedAt: DateTime.now(),
    ));
  }
}

/// Summary of a sync operation
class SyncSummary {
  final int uploaded;
  final int downloaded;
  final DateTime syncedAt;

  const SyncSummary({
    required this.uploaded,
    required this.downloaded,
    required this.syncedAt,
  });

  int get total => uploaded + downloaded;

  bool get hasChanges => total > 0;

  @override
  String toString() =>
      'SyncSummary(uploaded: $uploaded, downloaded: $downloaded)';
}
