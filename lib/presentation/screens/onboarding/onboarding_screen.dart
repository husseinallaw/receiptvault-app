import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:receipt_vault/app/constants/currencies.dart';
import 'package:receipt_vault/app/theme/app_colors.dart';
import 'package:receipt_vault/app/theme/app_spacing.dart';
import 'package:receipt_vault/app/theme/app_typography.dart';
import 'package:receipt_vault/domain/entities/user_preferences.dart';
import 'package:receipt_vault/l10n/generated/app_localizations.dart';
import 'package:receipt_vault/presentation/providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // User preferences to collect
  String _selectedLocale = 'en';
  String _selectedPrimaryCurrency = SupportedCurrencies.usd;
  String _selectedSecondaryCurrency = SupportedCurrencies.lbp;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentPage + 1) / 3,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildWelcomePage(l10n),
                  _buildLanguagePage(l10n),
                  _buildCurrencyPage(l10n),
                ],
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: _previousPage,
                      child: Text(l10n.back),
                    )
                  else
                    const SizedBox(width: 80),
                  const Spacer(),
                  FilledButton(
                    onPressed:
                        _currentPage == 2 ? _completeOnboarding : _nextPage,
                    child:
                        Text(_currentPage == 2 ? l10n.getStarted : l10n.next),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.receipt_long,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.welcomeToReceiptVault,
            style: AppTypography.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.onboardingWelcomeDescription,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildFeatureItem(
            Icons.camera_alt,
            l10n.featureScanReceipts,
          ),
          _buildFeatureItem(
            Icons.currency_exchange,
            l10n.featureMultiCurrency,
          ),
          _buildFeatureItem(
            Icons.analytics,
            l10n.featureTrackSpending,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagePage(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.selectLanguage,
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.selectLanguageDescription,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildLanguageOption('en', 'English', '🇺🇸'),
          const SizedBox(height: AppSpacing.md),
          _buildLanguageOption('ar', 'العربية', '🇱🇧'),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String locale, String name, String flag) {
    final isSelected = _selectedLocale == locale;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedLocale = locale;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors.primary.withOpacity(0.05) : null,
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                name,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyPage(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.selectCurrencies,
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.selectCurrenciesDescription,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Primary Currency
          Text(
            l10n.primaryCurrency,
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildCurrencySelector(
            value: _selectedPrimaryCurrency,
            onChanged: (value) {
              setState(() {
                _selectedPrimaryCurrency = value!;
              });
            },
          ),

          const SizedBox(height: AppSpacing.lg),

          // Secondary Currency
          Text(
            l10n.secondaryCurrency,
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildCurrencySelector(
            value: _selectedSecondaryCurrency,
            onChanged: (value) {
              setState(() {
                _selectedSecondaryCurrency = value!;
              });
            },
          ),

          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.info),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.currencyChangeableInSettings,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector({
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      items: [
        DropdownMenuItem(
          value: SupportedCurrencies.usd,
          child: Text('🇺🇸 USD - US Dollar'),
        ),
        DropdownMenuItem(
          value: SupportedCurrencies.lbp,
          child: Text('🇱🇧 LBP - Lebanese Pound'),
        ),
        DropdownMenuItem(
          value: SupportedCurrencies.eur,
          child: Text('🇪🇺 EUR - Euro'),
        ),
      ],
      onChanged: onChanged,
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    final authNotifier = ref.read(authProvider.notifier);
    final currentPrefs = ref.read(authProvider).preferences;

    if (currentPrefs != null) {
      final updatedPrefs = currentPrefs.copyWith(
        locale: _selectedLocale,
        primaryCurrency: _selectedPrimaryCurrency,
        secondaryCurrency: _selectedSecondaryCurrency,
        hasCompletedOnboarding: true,
      );

      await authNotifier.updatePreferences(updatedPrefs);
    }

    await authNotifier.completeOnboarding();

    if (mounted) {
      context.go('/home');
    }
  }
}
