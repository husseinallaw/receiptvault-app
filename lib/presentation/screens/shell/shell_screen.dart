import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import 'widgets/bottom_nav_bar.dart';

/// Shell screen with bottom navigation
class ShellScreen extends StatelessWidget {
  final Widget child;

  const ShellScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const AppBottomNavBar(),
      floatingActionButton: _buildScannerFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildScannerFab(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    final isOnScanner = currentPath.startsWith(AppRoutes.scanner);

    return FloatingActionButton.large(
      onPressed: () {
        if (!isOnScanner) {
          context.go(AppRoutes.scanner);
        }
      },
      backgroundColor: isOnScanner
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.primaryContainer,
      foregroundColor: isOnScanner
          ? Theme.of(context).colorScheme.onPrimary
          : Theme.of(context).colorScheme.onPrimaryContainer,
      elevation: isOnScanner ? 8 : 4,
      child: const Icon(Icons.document_scanner_outlined, size: 32),
    );
  }
}
