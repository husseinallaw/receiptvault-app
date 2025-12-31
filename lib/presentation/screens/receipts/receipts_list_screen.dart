import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/receipt.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/receipts_provider.dart';
import 'widgets/receipt_card.dart';

/// Screen displaying list of receipts with filtering and search
class ReceiptsListScreen extends ConsumerStatefulWidget {
  const ReceiptsListScreen({super.key});

  @override
  ConsumerState<ReceiptsListScreen> createState() => _ReceiptsListScreenState();
}

class _ReceiptsListScreenState extends ConsumerState<ReceiptsListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load receipts on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(receiptsProvider.notifier).loadReceipts();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(receiptsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(receiptsProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.receiptsSearch,
                  border: InputBorder.none,
                ),
                onSubmitted: (value) {
                  ref.read(receiptsProvider.notifier).search(value);
                },
              )
            : Text(l10n.receiptsTitle),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  ref.read(receiptsProvider.notifier).clearSearch();
                }
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => _handleFilterSelection(value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'all',
                child: Text(l10n.allReceipts),
              ),
              PopupMenuItem(
                value: 'this_month',
                child: Text(l10n.thisMonth),
              ),
              PopupMenuItem(
                value: 'last_month',
                child: Text(l10n.lastMonth),
              ),
              const PopupMenuDivider(),
              ...ExpenseCategory.values.map((category) {
                return PopupMenuItem(
                  value: 'category_${category.name}',
                  child: Row(
                    children: [
                      Text(category.icon),
                      const SizedBox(width: 8),
                      Text(category.displayName),
                    ],
                  ),
                );
              }),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(receiptsProvider.notifier).refresh(),
        child: _buildBody(state, l10n),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/scanner'),
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget _buildBody(ReceiptsState state, AppLocalizations l10n) {
    if (state.isLoading && state.receipts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasReceipts) {
      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: state.receipts.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.receipts.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final receipt = state.receipts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ReceiptCard(
              receipt: receipt,
              onTap: () => context.push('/receipts/${receipt.id}'),
              onDelete: () => _confirmDelete(receipt),
            ),
          );
        },
      );
    }

    return _EmptyState(
      message: state.filter.searchQuery != null
          ? l10n.noSearchResults
          : l10n.receiptsEmpty,
      actionLabel: l10n.scanFirstReceipt,
      onAction: () => context.push('/scanner'),
    );
  }

  void _handleFilterSelection(String value) {
    final notifier = ref.read(receiptsProvider.notifier);

    if (value == 'all') {
      notifier.clearFilters();
    } else if (value == 'this_month') {
      final now = DateTime.now();
      notifier.filterByDateRange(
        DateTime(now.year, now.month, 1),
        DateTime(now.year, now.month + 1, 0, 23, 59, 59),
      );
    } else if (value == 'last_month') {
      final now = DateTime.now();
      notifier.filterByDateRange(
        DateTime(now.year, now.month - 1, 1),
        DateTime(now.year, now.month, 0, 23, 59, 59),
      );
    } else if (value.startsWith('category_')) {
      final categoryName = value.substring(9);
      final category = ExpenseCategory.values.firstWhere(
        (c) => c.name == categoryName,
        orElse: () => ExpenseCategory.other,
      );
      notifier.filterByCategory(category);
    }
  }

  void _confirmDelete(Receipt receipt) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteReceipt),
        content: Text(l10n.deleteReceiptConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(receiptsProvider.notifier).deleteReceipt(receipt.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add_a_photo),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
