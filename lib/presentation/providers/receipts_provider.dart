import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/entities/store.dart';
import '../../domain/repositories/receipt_repository.dart';
import 'auth_provider.dart';
import 'scanner_provider.dart';

/// Receipts list state
class ReceiptsState {
  final List<Receipt> receipts;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;
  final ReceiptFilter filter;
  final ReceiptStats? stats;

  const ReceiptsState({
    this.receipts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
    this.filter = const ReceiptFilter(),
    this.stats,
  });

  ReceiptsState copyWith({
    List<Receipt>? receipts,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? errorMessage,
    ReceiptFilter? filter,
    ReceiptStats? stats,
  }) {
    return ReceiptsState(
      receipts: receipts ?? this.receipts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
      filter: filter ?? this.filter,
      stats: stats ?? this.stats,
    );
  }

  bool get isEmpty => receipts.isEmpty && !isLoading;
  bool get hasReceipts => receipts.isNotEmpty;
  int get count => receipts.length;
}

/// Receipts list provider
final receiptsProvider =
    StateNotifierProvider<ReceiptsNotifier, ReceiptsState>((ref) {
  return ReceiptsNotifier(ref);
});

/// Receipts notifier
class ReceiptsNotifier extends StateNotifier<ReceiptsState> {
  final Ref _ref;

  ReceiptsNotifier(this._ref) : super(const ReceiptsState());

  ReceiptRepository get _repository => _ref.read(receiptRepositoryProvider);
  String? get _userId => _ref.read(authProvider).user?.id;

  /// Load receipts with current filter
  Future<void> loadReceipts({bool refresh = false}) async {
    if (_userId == null) return;

    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        receipts: [],
        hasMore: true,
      );
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final filter = state.filter.copyWith(
        userId: _userId,
        offset: 0,
      );

      final result = await _repository.getReceipts(filter);

      result.when(
        success: (receipts) {
          state = state.copyWith(
            receipts: receipts,
            isLoading: false,
            hasMore: receipts.length >= filter.limit,
          );
        },
        failure: (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.displayMessage,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load receipts: $e',
      );
    }
  }

  /// Load more receipts (pagination)
  Future<void> loadMore() async {
    if (_userId == null || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final filter = state.filter.copyWith(
        userId: _userId,
        offset: state.receipts.length,
      );

      final result = await _repository.getReceipts(filter);

      result.when(
        success: (receipts) {
          state = state.copyWith(
            receipts: [...state.receipts, ...receipts],
            isLoadingMore: false,
            hasMore: receipts.length >= filter.limit,
          );
        },
        failure: (failure) {
          state = state.copyWith(
            isLoadingMore: false,
            errorMessage: failure.displayMessage,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: 'Failed to load more receipts: $e',
      );
    }
  }

  /// Update filter and reload
  Future<void> setFilter(ReceiptFilter filter) async {
    state = state.copyWith(filter: filter);
    await loadReceipts(refresh: true);
  }

  /// Filter by date range
  Future<void> filterByDateRange(DateTime start, DateTime end) async {
    await setFilter(state.filter.copyWith(
      startDate: start,
      endDate: end,
    ));
  }

  /// Filter by category
  Future<void> filterByCategory(ExpenseCategory? category) async {
    await setFilter(state.filter.copyWith(category: category));
  }

  /// Filter by store
  Future<void> filterByStore(String? storeId) async {
    await setFilter(state.filter.copyWith(storeId: storeId));
  }

  /// Search receipts
  Future<void> search(String query) async {
    await setFilter(state.filter.copyWith(searchQuery: query));
  }

  /// Clear search
  Future<void> clearSearch() async {
    await setFilter(state.filter.copyWith(searchQuery: null));
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    await setFilter(const ReceiptFilter());
  }

  /// Update sort
  Future<void> setSort(ReceiptSortField field, bool descending) async {
    await setFilter(state.filter.copyWith(
      sortBy: field,
      sortDescending: descending,
    ));
  }

  /// Delete receipt
  Future<bool> deleteReceipt(String id) async {
    try {
      final result = await _repository.deleteReceipt(id);

      if (result.isSuccess) {
        state = state.copyWith(
          receipts: state.receipts.where((r) => r.id != id).toList(),
        );
        return true;
      }

      return false;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to delete receipt: $e',
      );
      return false;
    }
  }

  /// Load receipt stats
  Future<void> loadStats({DateTime? startDate, DateTime? endDate}) async {
    if (_userId == null) return;

    final now = DateTime.now();
    final start = startDate ?? DateTime(now.year, now.month, 1);
    final end = endDate ?? DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    try {
      final result = await _repository.getReceiptStats(
        userId: _userId!,
        startDate: start,
        endDate: end,
      );

      result.when(
        success: (stats) {
          state = state.copyWith(stats: stats);
        },
        failure: (_) {
          // Ignore stats errors
        },
      );
    } catch (_) {
      // Ignore stats errors
    }
  }

  /// Refresh receipts
  Future<void> refresh() async {
    await loadReceipts(refresh: true);
    await loadStats();
  }
}

/// Single receipt provider
final receiptProvider =
    FutureProvider.family<Receipt?, String>((ref, receiptId) async {
  final repository = ref.watch(receiptRepositoryProvider);
  final result = await repository.getReceiptById(receiptId);
  return result.dataOrNull;
});

/// Stores provider
final storesProvider = FutureProvider<List<Store>>((ref) async {
  final repository = ref.watch(receiptRepositoryProvider);
  final result = await repository.getStores();
  return result.dataOrNull ?? [];
});

/// Spending by category provider
final spendingByCategoryProvider =
    FutureProvider.family<Map<String, double>, DateRange>((ref, range) async {
  final repository = ref.watch(receiptRepositoryProvider);
  final authState = ref.watch(authProvider);

  if (authState.user == null) return {};

  final result = await repository.getSpendingByCategory(
    userId: authState.user!.id,
    startDate: range.start,
    endDate: range.end,
    currency: 'LBP',
  );

  return result.dataOrNull ?? {};
});

/// Date range for spending queries
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({required this.start, required this.end});

  factory DateRange.thisMonth() {
    final now = DateTime.now();
    return DateRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
    );
  }

  factory DateRange.lastMonth() {
    final now = DateTime.now();
    return DateRange(
      start: DateTime(now.year, now.month - 1, 1),
      end: DateTime(now.year, now.month, 0, 23, 59, 59),
    );
  }

  factory DateRange.thisYear() {
    final now = DateTime.now();
    return DateRange(
      start: DateTime(now.year, 1, 1),
      end: DateTime(now.year, 12, 31, 23, 59, 59),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateRange && other.start == start && other.end == end;
  }

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}
