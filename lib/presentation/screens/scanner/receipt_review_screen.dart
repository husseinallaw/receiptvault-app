import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/receipts_provider.dart';
import '../../providers/scanner_provider.dart';

/// Screen for reviewing and editing scanned receipt data
class ReceiptReviewScreen extends ConsumerStatefulWidget {
  const ReceiptReviewScreen({super.key});

  @override
  ConsumerState<ReceiptReviewScreen> createState() =>
      _ReceiptReviewScreenState();
}

class _ReceiptReviewScreenState extends ConsumerState<ReceiptReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _storeController;
  late TextEditingController _totalController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final receipt = ref.read(scannerProvider).scannedReceipt;
    _storeController = TextEditingController(text: receipt?.storeName ?? '');
    _totalController = TextEditingController(
      text: receipt?.total.amount.toStringAsFixed(2) ?? '0.00',
    );
    _notesController = TextEditingController(text: receipt?.notes ?? '');
  }

  @override
  void dispose() {
    _storeController.dispose();
    _totalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scannerState = ref.watch(scannerProvider);
    final receipt = scannerState.scannedReceipt;

    if (receipt == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.scannerReview)),
        body: Center(child: Text(l10n.noReceiptData)),
      );
    }

    // Listen for save success
    ref.listen<ScannerState>(scannerProvider, (previous, next) {
      if (next.isSuccess) {
        // Refresh receipts list
        ref.read(receiptsProvider.notifier).refresh();
        // Navigate back
        context.go('/receipts');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scannerReview),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            ref.read(scannerProvider.notifier).discardScan();
            context.pop();
          },
        ),
        actions: [
          if (scannerState.isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveReceipt,
              child: Text(l10n.save),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Receipt image preview
            if (receipt.primaryImageUrl != null)
              _ImagePreview(imageUrl: receipt.primaryImageUrl!),

            const SizedBox(height: 24),

            // Confidence indicator
            _ConfidenceIndicator(confidence: receipt.ocrConfidence ?? 0),

            const SizedBox(height: 24),

            // Store name
            TextFormField(
              controller: _storeController,
              decoration: InputDecoration(
                labelText: l10n.receiptStore,
                prefixIcon: const Icon(Icons.store),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.storeNameRequired;
                }
                return null;
              },
              onChanged: (value) {
                ref.read(scannerProvider.notifier).updateStoreName(value, null);
              },
            ),

            const SizedBox(height: 16),

            // Date picker
            _DatePickerField(
              initialDate: receipt.date,
              onDateChanged: (date) {
                ref.read(scannerProvider.notifier).updateDate(date);
              },
            ),

            const SizedBox(height: 16),

            // Total amount
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _totalController,
                    decoration: InputDecoration(
                      labelText: l10n.receiptTotal,
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.totalRequired;
                      }
                      if (double.tryParse(value) == null) {
                        return l10n.invalidAmount;
                      }
                      return null;
                    },
                    onChanged: (value) {
                      final amount = double.tryParse(value);
                      if (amount != null) {
                        ref.read(scannerProvider.notifier).updateTotal(
                              amount,
                              receipt.originalCurrency,
                            );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CurrencyDropdown(
                    value: receipt.originalCurrency,
                    onChanged: (currency) {
                      if (currency != null) {
                        final amount =
                            double.tryParse(_totalController.text) ?? 0;
                        ref.read(scannerProvider.notifier).updateTotal(
                              amount,
                              currency,
                            );
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Category
            _CategoryDropdown(
              value: receipt.category,
              onChanged: (category) {
                if (category != null) {
                  ref.read(scannerProvider.notifier).updateCategory(category);
                }
              },
            ),

            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: l10n.receiptNotes,
                prefixIcon: const Icon(Icons.note),
              ),
              maxLines: 3,
              onChanged: (value) {
                // Notes will be saved with the receipt
              },
            ),

            const SizedBox(height: 24),

            // Items section
            _ItemsSection(items: receipt.items),

            const SizedBox(height: 24),

            // Error message
            if (scannerState.hasError)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        scannerState.errorMessage ?? l10n.unknownError,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(scannerProvider.notifier).discardScan();
                    context.pop();
                  },
                  child: Text(l10n.discard),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: scannerState.isSaving ? null : _saveReceipt,
                  child: scannerState.isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.saveReceipt),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveReceipt() async {
    if (!_formKey.currentState!.validate()) return;

    // Update notes before saving
    final currentReceipt = ref.read(scannerProvider).scannedReceipt;
    if (currentReceipt != null) {
      ref.read(scannerProvider.notifier).updateReceipt(
            currentReceipt.copyWith(notes: _notesController.text),
          );
    }

    await ref.read(scannerProvider.notifier).saveReceipt();
  }
}

class _ImagePreview extends StatelessWidget {
  final String imageUrl;

  const _ImagePreview({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey.shade200,
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ConfidenceIndicator extends StatelessWidget {
  final double confidence;

  const _ConfidenceIndicator({required this.confidence});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final percentage = (confidence * 100).toInt();
    final isHigh = confidence >= AppConstants.highOcrConfidence;
    final isAcceptable = confidence >= AppConstants.minOcrConfidence;

    Color color;
    IconData icon;
    String message;

    if (isHigh) {
      color = Colors.green;
      icon = Icons.check_circle;
      message = l10n.highConfidence;
    } else if (isAcceptable) {
      color = Colors.orange;
      icon = Icons.info;
      message = l10n.moderateConfidence;
    } else {
      color = Colors.red;
      icon = Icons.warning;
      message = l10n.lowConfidence;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$message ($percentage%)',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!isAcceptable)
                  Text(
                    l10n.pleaseReviewData,
                    style: TextStyle(
                      color: color.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateChanged;

  const _DatePickerField({
    required this.initialDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMMMd();

    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          onDateChanged(date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.receiptDate,
          prefixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(dateFormat.format(initialDate)),
      ),
    );
  }
}

class _CurrencyDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _CurrencyDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12),
      ),
      items: const [
        DropdownMenuItem(value: 'LBP', child: Text('LBP')),
        DropdownMenuItem(value: 'USD', child: Text('USD')),
      ],
      onChanged: onChanged,
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final ExpenseCategory value;
  final ValueChanged<ExpenseCategory?> onChanged;

  const _CategoryDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DropdownButtonFormField<ExpenseCategory>(
      value: value,
      decoration: InputDecoration(
        labelText: l10n.receiptCategory,
        prefixIcon: const Icon(Icons.category),
      ),
      items: ExpenseCategory.values.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Row(
            children: [
              Text(category.icon),
              const SizedBox(width: 8),
              Text(category.displayName),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class _ItemsSection extends StatelessWidget {
  final List items;

  const _ItemsSection({required this.items});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            l10n.noItemsDetected,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.receiptItems,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '${items.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.asMap().entries.map((entry) {
          final item = entry.value;
          return ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(item.name),
            subtitle: Text('${item.quantity} × ${item.unitPrice}'),
            trailing: Text(
              item.total.format(),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          );
        }),
      ],
    );
  }
}
