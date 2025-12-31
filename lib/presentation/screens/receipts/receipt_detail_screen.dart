import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/receipt.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/receipts_provider.dart';

/// Screen displaying receipt details
class ReceiptDetailScreen extends ConsumerWidget {
  final String receiptId;

  const ReceiptDetailScreen({
    super.key,
    required this.receiptId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final receiptAsync = ref.watch(receiptProvider(receiptId));

    return receiptAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(l10n.errorLoadingReceipt),
        ),
      ),
      data: (receipt) {
        if (receipt == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text(l10n.receiptNotFound),
            ),
          );
        }

        return _ReceiptDetailContent(receipt: receipt);
      },
    );
  }
}

class _ReceiptDetailContent extends ConsumerWidget {
  final Receipt receipt;

  const _ReceiptDetailContent({required this.receipt});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd();

    return Scaffold(
      appBar: AppBar(
        title: Text(receipt.storeName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Receipt image
          if (receipt.primaryImageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: Image.network(
                  receipt.primaryImageUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Store and date
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.store,
                    label: l10n.receiptStore,
                    value: receipt.storeName,
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    icon: Icons.calendar_today,
                    label: l10n.receiptDate,
                    value: dateFormat.format(receipt.date),
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    icon: Icons.category,
                    label: l10n.receiptCategory,
                    value:
                        '${receipt.category.icon} ${receipt.category.displayName}',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Amount
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.receiptTotal,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    receipt.total.format(),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  if (receipt.originalCurrency == 'LBP' &&
                      receipt.totalAmountUsd > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      '≈ ${receipt.totalUsd.format()}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Items
          if (receipt.items.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.receiptItems,
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          '${receipt.itemCount}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...receipt.items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    Text(
                                      '${item.formattedQuantity} × ${item.pricePerUnit.format()}',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.outline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                item.total.format(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Notes
          if (receipt.notes != null && receipt.notes!.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.receiptNotes,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(receipt.notes!),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Metadata
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.analytics,
                    label: l10n.ocrConfidence,
                    value: receipt.confidencePercentage,
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    icon: receipt.isSynced ? Icons.cloud_done : Icons.cloud_off,
                    label: l10n.syncStatus,
                    value: receipt.isSynced ? l10n.synced : l10n.pendingSync,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
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
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(receiptsProvider.notifier)
                  .deleteReceipt(receipt.id);
              if (context.mounted) {
                context.pop();
              }
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.outline),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
