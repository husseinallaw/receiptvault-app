import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';

/// Bottom navigation bar for main app navigation
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    final currentIndex = _getSelectedIndex(currentPath);

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => _onItemTapped(context, index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: 'Receipts',
        ),
        // Empty space for FAB
        NavigationDestination(
          icon: SizedBox(width: 24),
          label: '',
          enabled: false,
        ),
        NavigationDestination(
          icon: Icon(Icons.account_balance_wallet_outlined),
          selectedIcon: Icon(Icons.account_balance_wallet),
          label: 'Budget',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }

  int _getSelectedIndex(String path) {
    if (path.startsWith(AppRoutes.home)) return 0;
    if (path.startsWith(AppRoutes.receipts)) return 1;
    if (path.startsWith(AppRoutes.scanner)) return 2;
    if (path.startsWith(AppRoutes.budget)) return 3;
    if (path.startsWith(AppRoutes.settings)) return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.receipts);
        break;
      case 2:
        // FAB handles scanner navigation
        context.go(AppRoutes.scanner);
        break;
      case 3:
        context.go(AppRoutes.budget);
        break;
      case 4:
        context.go(AppRoutes.settings);
        break;
    }
  }
}

/// Bottom navigation bar for Arabic UI
class AppBottomNavBarArabic extends StatelessWidget {
  const AppBottomNavBarArabic({super.key});

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    final currentIndex = _getSelectedIndex(currentPath);

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => _onItemTapped(context, index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'الرئيسية',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: 'الإيصالات',
        ),
        // Empty space for FAB
        NavigationDestination(
          icon: SizedBox(width: 24),
          label: '',
          enabled: false,
        ),
        NavigationDestination(
          icon: Icon(Icons.account_balance_wallet_outlined),
          selectedIcon: Icon(Icons.account_balance_wallet),
          label: 'الميزانية',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'الإعدادات',
        ),
      ],
    );
  }

  int _getSelectedIndex(String path) {
    if (path.startsWith(AppRoutes.home)) return 0;
    if (path.startsWith(AppRoutes.receipts)) return 1;
    if (path.startsWith(AppRoutes.scanner)) return 2;
    if (path.startsWith(AppRoutes.budget)) return 3;
    if (path.startsWith(AppRoutes.settings)) return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.receipts);
        break;
      case 2:
        context.go(AppRoutes.scanner);
        break;
      case 3:
        context.go(AppRoutes.budget);
        break;
      case 4:
        context.go(AppRoutes.settings);
        break;
    }
  }
}
