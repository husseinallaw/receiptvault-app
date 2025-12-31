import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/auth/auth_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/receipts/receipt_detail_screen.dart';
import '../../presentation/screens/receipts/receipts_list_screen.dart';
import '../../presentation/screens/scanner/receipt_review_screen.dart';
import '../../presentation/screens/scanner/scanner_screen.dart';
import '../../presentation/screens/shell/shell_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import 'routes.dart';

// Placeholder screens - will be replaced with actual implementations
class _PlaceholderScreen extends ConsumerWidget {
  final String title;
  const _PlaceholderScreen(this.title);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (title == 'Home')
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await ref.read(authProvider.notifier).signOut();
              },
              tooltip: 'Sign Out',
            ),
        ],
      ),
      body: Center(child: Text('$title - Coming Soon')),
    );
  }
}

/// Provider for app initialization state
final appInitializedProvider = StateProvider<bool>((ref) => true);

/// Provider for authentication state (derived from authProvider)
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isAuthenticated;
});

/// GoRouter configuration provider
final routerProvider = Provider<GoRouter>((ref) {
  // Create refresh notifier to listen for state changes
  final refreshNotifier = _RouterRefreshNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      // Use ref.read inside redirect to get current state without creating dependencies
      final isAuthenticated = ref.read(isAuthenticatedProvider);
      final appInitialized = ref.read(appInitializedProvider);
      final currentPath = state.matchedLocation;

      // If app not initialized, stay on splash
      if (!appInitialized && currentPath != AppRoutes.splash) {
        return AppRoutes.splash;
      }

      // Auth routes
      final isAuthRoute = currentPath == AppRoutes.auth ||
          currentPath == AppRoutes.onboarding ||
          currentPath == AppRoutes.splash;

      // If not authenticated and not on auth route, redirect to auth
      if (!isAuthenticated && !isAuthRoute) {
        return AppRoutes.auth;
      }

      // If authenticated and on auth route, redirect to home
      if (isAuthenticated && isAuthRoute && currentPath != AppRoutes.splash) {
        return AppRoutes.home;
      }

      // No redirect needed
      return null;
    },
    routes: [
      // ==================== Auth Routes ====================
      GoRoute(
        path: AppRoutes.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.auth,
        name: RouteNames.auth,
        builder: (context, state) => const AuthScreen(),
      ),

      // ==================== Main App (Shell Route) ====================
      ShellRoute(
        builder: (context, state, child) => ShellScreen(child: child),
        routes: [
          // Home
          GoRoute(
            path: AppRoutes.home,
            name: RouteNames.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: _PlaceholderScreen('Home'),
            ),
          ),

          // Receipts
          GoRoute(
            path: AppRoutes.receipts,
            name: RouteNames.receipts,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReceiptsListScreen(),
            ),
            routes: [
              GoRoute(
                path: ':id',
                name: RouteNames.receiptDetail,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ReceiptDetailScreen(receiptId: id);
                },
              ),
            ],
          ),

          // Scanner
          GoRoute(
            path: AppRoutes.scanner,
            name: RouteNames.scanner,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ScannerScreen(),
            ),
            routes: [
              GoRoute(
                path: 'review',
                name: RouteNames.receiptReview,
                builder: (context, state) => const ReceiptReviewScreen(),
              ),
            ],
          ),

          // Budget
          GoRoute(
            path: AppRoutes.budget,
            name: RouteNames.budget,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: _PlaceholderScreen('Budget'),
            ),
            routes: [
              GoRoute(
                path: 'create',
                name: RouteNames.createBudget,
                builder: (context, state) =>
                    const _PlaceholderScreen('Create Budget'),
              ),
              GoRoute(
                path: ':id',
                name: RouteNames.budgetDetail,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return _PlaceholderScreen('Budget $id');
                },
              ),
            ],
          ),

          // Settings
          GoRoute(
            path: AppRoutes.settings,
            name: RouteNames.settings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: _PlaceholderScreen('Settings'),
            ),
            routes: [
              GoRoute(
                path: 'profile',
                name: RouteNames.profile,
                builder: (context, state) =>
                    const _PlaceholderScreen('Profile'),
              ),
              GoRoute(
                path: 'appearance',
                name: RouteNames.appearance,
                builder: (context, state) =>
                    const _PlaceholderScreen('Appearance'),
              ),
              GoRoute(
                path: 'notifications',
                name: RouteNames.notifications,
                builder: (context, state) =>
                    const _PlaceholderScreen('Notifications'),
              ),
              GoRoute(
                path: 'data',
                name: RouteNames.dataManagement,
                builder: (context, state) =>
                    const _PlaceholderScreen('Data Management'),
              ),
              GoRoute(
                path: 'about',
                name: RouteNames.about,
                builder: (context, state) => const _PlaceholderScreen('About'),
              ),
            ],
          ),
        ],
      ),

      // ==================== Standalone Routes ====================
      GoRoute(
        path: AppRoutes.analytics,
        name: RouteNames.analytics,
        builder: (context, state) => const _PlaceholderScreen('Analytics'),
      ),
      GoRoute(
        path: AppRoutes.priceComparison,
        name: RouteNames.priceComparison,
        builder: (context, state) =>
            const _PlaceholderScreen('Price Comparison'),
      ),
      GoRoute(
        path: AppRoutes.subscription,
        name: RouteNames.subscription,
        builder: (context, state) => const _PlaceholderScreen('Subscription'),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.matchedLocation}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Notifier to refresh router when auth state changes
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(this._ref) {
    _ref.listen(isAuthenticatedProvider, (_, __) => notifyListeners());
    _ref.listen(appInitializedProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}
