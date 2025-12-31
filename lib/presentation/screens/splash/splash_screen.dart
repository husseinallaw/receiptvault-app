import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:receipt_vault/app/theme/app_colors.dart';
import 'package:receipt_vault/core/utils/logger.dart';
import 'package:receipt_vault/presentation/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
    _navigateWhenReady();
  }

  Future<void> _navigateWhenReady() async {
    Log.d(LogTags.app, 'Splash: Waiting for auth state...');

    // Wait minimum time for animation
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Wait for auth state to be determined (not initial)
    int attempts = 0;
    const maxAttempts = 20; // 4 seconds max wait

    while (mounted && attempts < maxAttempts) {
      final authState = ref.read(authProvider);
      Log.d(LogTags.app, 'Splash: Auth status = ${authState.status}');

      if (authState.status != AuthStatus.initial) {
        // Auth state determined, navigate based on it
        if (authState.isAuthenticated) {
          Log.i(LogTags.app, 'Splash: User authenticated, going to home');
          context.go('/home');
        } else {
          Log.i(LogTags.app, 'Splash: User not authenticated, going to auth');
          context.go('/auth');
        }
        return;
      }

      // Wait a bit and check again
      await Future.delayed(const Duration(milliseconds: 200));
      attempts++;
    }

    // Timeout - default to auth screen
    if (mounted) {
      Log.w(
          LogTags.app, 'Splash: Auth state timeout, defaulting to auth screen');
      context.go('/auth');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    size: 60,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),

                // App Name
                const Text(
                  'ReceiptVault',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),

                // Tagline
                Text(
                  'Smart receipt tracking',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),

                const SizedBox(height: 48),

                // Loading indicator
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
