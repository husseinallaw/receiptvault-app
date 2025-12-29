import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Initialize Firebase
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(
    const ProviderScope(
      child: ReceiptVaultApp(),
    ),
  );
}

/// Main application widget for ReceiptVault
class ReceiptVaultApp extends ConsumerWidget {
  const ReceiptVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Watch theme provider for dynamic theme switching
    // final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'ReceiptVault',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
      // TODO: Add GoRouter for navigation
      // routerConfig: ref.watch(routerProvider),
    );
  }
}

/// Temporary home screen placeholder
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ReceiptVault'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'ReceiptVault',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Smart Receipt Scanning for Lebanon',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  _FeatureRow(
                    icon: Icons.camera_alt,
                    title: 'Scan Receipts',
                    subtitle: 'OCR-powered receipt scanning',
                  ),
                  const SizedBox(height: 16),
                  _FeatureRow(
                    icon: Icons.account_balance_wallet,
                    title: 'Track Spending',
                    subtitle: 'LBP & USD dual currency',
                  ),
                  const SizedBox(height: 16),
                  _FeatureRow(
                    icon: Icons.compare_arrows,
                    title: 'Compare Prices',
                    subtitle: 'Find the best deals',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            FilledButton.icon(
              onPressed: () {
                // TODO: Navigate to onboarding or auth
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium,
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
