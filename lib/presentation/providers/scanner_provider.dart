import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/lebanon_stores.dart';
import '../../core/utils/logger.dart';
import '../../data/datasources/local/database/app_database.dart'
    show appDatabaseProvider;
import '../../data/datasources/local/receipt_local_datasource.dart';
import '../../data/datasources/remote/firebase_storage_datasource.dart';
import '../../data/datasources/remote/receipt_remote_datasource.dart';
import '../../data/repositories/receipt_repository_impl.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/entities/receipt_item.dart';
import '../../domain/entities/store.dart';
import '../../domain/repositories/receipt_repository.dart';
import '../../services/image_processing/image_processor.dart';
import '../../services/ocr/ocr_service.dart';
import 'auth_provider.dart';

/// Scanner state
enum ScannerStatus {
  idle,
  capturing,
  processing,
  reviewing,
  saving,
  success,
  error,
}

/// Scanner state class
class ScannerState {
  final ScannerStatus status;
  final Uint8List? capturedImage;
  final Receipt? scannedReceipt;
  final OcrResult? ocrResult;
  final String? errorMessage;
  final double processingProgress;

  const ScannerState({
    this.status = ScannerStatus.idle,
    this.capturedImage,
    this.scannedReceipt,
    this.ocrResult,
    this.errorMessage,
    this.processingProgress = 0,
  });

  ScannerState copyWith({
    ScannerStatus? status,
    Uint8List? capturedImage,
    Receipt? scannedReceipt,
    OcrResult? ocrResult,
    String? errorMessage,
    double? processingProgress,
  }) {
    return ScannerState(
      status: status ?? this.status,
      capturedImage: capturedImage ?? this.capturedImage,
      scannedReceipt: scannedReceipt ?? this.scannedReceipt,
      ocrResult: ocrResult ?? this.ocrResult,
      errorMessage: errorMessage,
      processingProgress: processingProgress ?? this.processingProgress,
    );
  }

  bool get isIdle => status == ScannerStatus.idle;
  bool get isCapturing => status == ScannerStatus.capturing;
  bool get isProcessing => status == ScannerStatus.processing;
  bool get isReviewing => status == ScannerStatus.reviewing;
  bool get isSaving => status == ScannerStatus.saving;
  bool get isSuccess => status == ScannerStatus.success;
  bool get hasError => status == ScannerStatus.error;
}

/// Receipt repository provider
final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ReceiptRepositoryImpl(
    localDatasource: ReceiptLocalDatasourceImpl(db),
    remoteDatasource: ReceiptRemoteDatasourceImpl(),
    storageDatasource: FirebaseStorageDatasourceImpl(),
  );
});

/// OCR service provider
final ocrServiceProvider = Provider<OcrService>((ref) {
  return OcrService();
});

/// Image processor provider
final imageProcessorProvider = Provider<ImageProcessor>((ref) {
  return ImageProcessor();
});

/// Scanner state provider
final scannerProvider =
    StateNotifierProvider<ScannerNotifier, ScannerState>((ref) {
  return ScannerNotifier(ref);
});

/// Scanner notifier
class ScannerNotifier extends StateNotifier<ScannerState> {
  final Ref _ref;
  final Uuid _uuid = const Uuid();

  ScannerNotifier(this._ref) : super(const ScannerState());

  ReceiptRepository get _repository => _ref.read(receiptRepositoryProvider);
  OcrService get _ocrService => _ref.read(ocrServiceProvider);
  ImageProcessor get _imageProcessor => _ref.read(imageProcessorProvider);
  String? get _userId => _ref.read(authProvider).user?.id;

  /// Reset scanner to initial state
  void reset() {
    state = const ScannerState();
  }

  /// Start capturing mode
  void startCapturing() {
    state = state.copyWith(status: ScannerStatus.capturing);
  }

  /// Whether to use mock mode (for testing without cloud services)
  static const bool _useMockMode = true; // Set to false when cloud functions are deployed

  /// Capture image and start processing
  Future<void> captureImage(Uint8List imageBytes) async {
    if (_userId == null) {
      state = state.copyWith(
        status: ScannerStatus.error,
        errorMessage: 'User not authenticated',
      );
      return;
    }

    state = state.copyWith(
      status: ScannerStatus.processing,
      capturedImage: imageBytes,
      processingProgress: 0.1,
    );

    try {
      // Process image for OCR
      state = state.copyWith(processingProgress: 0.2);
      final processedImage = await _imageProcessor.processForOcr(imageBytes);

      final receiptId = _uuid.v4();

      if (_useMockMode) {
        // Mock mode for testing - skip cloud services
        await _processMockReceipt(receiptId, processedImage);
        return;
      }

      // Upload image to storage
      state = state.copyWith(processingProgress: 0.4);
      final uploadResult = await _repository.uploadReceiptImage(
        receiptId: receiptId,
        userId: _userId!,
        imageBytes: processedImage,
      );

      if (uploadResult.isFailure) {
        throw Exception(uploadResult.failureOrNull?.displayMessage);
      }

      final imageUrl = uploadResult.dataOrThrow;

      // Process with OCR
      state = state.copyWith(processingProgress: 0.6);
      final ocrResult = await _ocrService.processReceipt(
        imageUrl: imageUrl,
        userId: _userId!,
      );

      state = state.copyWith(processingProgress: 0.8);

      // Create receipt from OCR result
      final receipt = _createReceiptFromOcr(
        receiptId: receiptId,
        userId: _userId!,
        imageUrl: imageUrl,
        ocrResult: ocrResult,
      );

      state = state.copyWith(
        status: ScannerStatus.reviewing,
        scannedReceipt: receipt,
        ocrResult: ocrResult,
        processingProgress: 1.0,
      );
    } catch (e) {
      state = state.copyWith(
        status: ScannerStatus.error,
        errorMessage: 'Failed to process receipt: $e',
      );
    }
  }

  /// Process receipt in mock mode (for testing without cloud services)
  Future<void> _processMockReceipt(String receiptId, Uint8List imageBytes) async {
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(processingProgress: 0.4);

    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(processingProgress: 0.6);

    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(processingProgress: 0.8);

    final now = DateTime.now();

    // Create mock receipt with sample data
    final mockReceipt = Receipt(
      id: receiptId,
      userId: _userId!,
      storeName: 'Spinneys',
      storeId: 'spinneys',
      date: now,
      items: [
        ReceiptItem(
          id: _uuid.v4(),
          receiptId: receiptId,
          name: 'Milk 1L',
          quantity: 2,
          unitPrice: 85000,
          totalPrice: 170000,
          currency: 'LBP',
          sortOrder: 0,
          createdAt: now,
        ),
        ReceiptItem(
          id: _uuid.v4(),
          receiptId: receiptId,
          name: 'Bread',
          quantity: 1,
          unitPrice: 45000,
          totalPrice: 45000,
          currency: 'LBP',
          sortOrder: 1,
          createdAt: now,
        ),
        ReceiptItem(
          id: _uuid.v4(),
          receiptId: receiptId,
          name: 'Eggs (12)',
          quantity: 1,
          unitPrice: 180000,
          totalPrice: 180000,
          currency: 'LBP',
          sortOrder: 2,
          createdAt: now,
        ),
      ],
      totalAmountLbp: 395000,
      totalAmountUsd: 0,
      originalCurrency: 'LBP',
      category: ExpenseCategory.groceries,
      status: ReceiptStatus.pending,
      ocrConfidence: 0.85,
      rawOcrText: 'Mock OCR text for testing',
      imageUrls: [], // No image URL in mock mode
      createdAt: now,
      updatedAt: now,
      needsSync: true,
    );

    // Create mock OCR result
    final mockOcrResult = OcrResult(
      rawText: 'Mock OCR text for testing',
      confidence: 0.85,
      storeName: 'Spinneys',
      storeId: 'spinneys',
      date: now,
      items: [
        OcrLineItem(
          name: 'Milk 1L',
          quantity: 2,
          unitPrice: 85000,
          totalPrice: 170000,
          currency: 'LBP',
          confidence: 0.9,
        ),
        OcrLineItem(
          name: 'Bread',
          quantity: 1,
          unitPrice: 45000,
          totalPrice: 45000,
          currency: 'LBP',
          confidence: 0.88,
        ),
        OcrLineItem(
          name: 'Eggs (12)',
          quantity: 1,
          unitPrice: 180000,
          totalPrice: 180000,
          currency: 'LBP',
          confidence: 0.92,
        ),
      ],
      totalAmount: 395000,
      currency: 'LBP',
    );

    state = state.copyWith(
      status: ScannerStatus.reviewing,
      scannedReceipt: mockReceipt,
      ocrResult: mockOcrResult,
      processingProgress: 1.0,
    );
  }

  /// Create receipt entity from OCR result
  Receipt _createReceiptFromOcr({
    required String receiptId,
    required String userId,
    required String imageUrl,
    required OcrResult ocrResult,
  }) {
    final now = DateTime.now();

    // Convert OCR items to receipt items
    final items = <ReceiptItem>[];
    for (int i = 0; i < ocrResult.items.length; i++) {
      final ocrItem = ocrResult.items[i];
      items.add(ReceiptItem(
        id: _uuid.v4(),
        receiptId: receiptId,
        name: ocrItem.name,
        quantity: ocrItem.quantity,
        unitPrice: ocrItem.unitPrice,
        totalPrice: ocrItem.totalPrice,
        currency: ocrItem.currency,
        sortOrder: i,
        createdAt: now,
      ));
    }

    // Determine category from store
    ExpenseCategory category = ExpenseCategory.other;
    if (ocrResult.storeId != null) {
      final storeInfo = LebanonStores.getById(ocrResult.storeId!);
      if (storeInfo != null) {
        final defaultCategory =
            Store.fromStoreInfo(storeInfo).defaultCategoryId;
        if (defaultCategory != null) {
          category = ExpenseCategory.values.firstWhere(
            (c) => c.name == defaultCategory,
            orElse: () => ExpenseCategory.other,
          );
        }
      }
    }

    return Receipt(
      id: receiptId,
      userId: userId,
      storeName: ocrResult.storeName ?? 'Unknown Store',
      storeId: ocrResult.storeId,
      date: ocrResult.date ?? now,
      items: items,
      totalAmountLbp:
          ocrResult.currency == 'LBP' ? (ocrResult.totalAmount ?? 0) : 0,
      totalAmountUsd:
          ocrResult.currency == 'USD' ? (ocrResult.totalAmount ?? 0) : 0,
      originalCurrency: ocrResult.currency,
      category: category,
      status: ocrResult.confidence >= AppConstants.minOcrConfidence
          ? ReceiptStatus.processed
          : ReceiptStatus.pending,
      ocrConfidence: ocrResult.confidence,
      rawOcrText: ocrResult.rawText,
      imageUrls: [imageUrl],
      createdAt: now,
      updatedAt: now,
      needsSync: true,
    );
  }

  /// Update scanned receipt (during review)
  void updateReceipt(Receipt receipt) {
    state = state.copyWith(scannedReceipt: receipt);
  }

  /// Update store name
  void updateStoreName(String storeName, String? storeId) {
    if (state.scannedReceipt == null) return;

    state = state.copyWith(
      scannedReceipt: state.scannedReceipt!.copyWith(
        storeName: storeName,
        storeId: storeId,
        updatedAt: DateTime.now(),
      ),
    );
  }

  /// Update receipt date
  void updateDate(DateTime date) {
    if (state.scannedReceipt == null) return;

    state = state.copyWith(
      scannedReceipt: state.scannedReceipt!.copyWith(
        date: date,
        updatedAt: DateTime.now(),
      ),
    );
  }

  /// Update total amount
  void updateTotal(double amount, String currency) {
    if (state.scannedReceipt == null) return;

    state = state.copyWith(
      scannedReceipt: state.scannedReceipt!.copyWith(
        totalAmountLbp:
            currency == 'LBP' ? amount : state.scannedReceipt!.totalAmountLbp,
        totalAmountUsd:
            currency == 'USD' ? amount : state.scannedReceipt!.totalAmountUsd,
        originalCurrency: currency,
        updatedAt: DateTime.now(),
      ),
    );
  }

  /// Update category
  void updateCategory(ExpenseCategory category) {
    if (state.scannedReceipt == null) return;

    state = state.copyWith(
      scannedReceipt: state.scannedReceipt!.copyWith(
        category: category,
        updatedAt: DateTime.now(),
      ),
    );
  }

  /// Save receipt
  Future<bool> saveReceipt() async {
    if (state.scannedReceipt == null) return false;

    state = state.copyWith(status: ScannerStatus.saving);
    Log.i(LogTags.receipt, 'Starting save...');

    try {
      final result = await _repository.createReceipt(state.scannedReceipt!);

      if (result.isSuccess) {
        Log.i(LogTags.receipt, 'Save successful!');
        state = state.copyWith(status: ScannerStatus.success);
        return true;
      } else {
        final errorMsg = result.failureOrNull?.displayMessage ?? 'Unknown error';
        Log.e(LogTags.receipt, 'Save failed: $errorMsg');
        state = state.copyWith(
          status: ScannerStatus.error,
          errorMessage: errorMsg,
        );
        return false;
      }
    } catch (e, stackTrace) {
      Log.e(LogTags.receipt, 'Save exception', e, stackTrace);
      state = state.copyWith(
        status: ScannerStatus.error,
        errorMessage: 'Failed to save receipt: $e',
      );
      return false;
    }
  }

  /// Discard current scan
  void discardScan() {
    // TODO: Delete uploaded image if exists
    reset();
  }
}
