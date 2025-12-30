import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:receipt_vault/app/theme/app_colors.dart';
import 'package:receipt_vault/app/theme/app_spacing.dart';
import 'package:receipt_vault/app/theme/app_typography.dart';
import 'package:receipt_vault/l10n/generated/app_localizations.dart';
import 'package:receipt_vault/presentation/providers/auth_provider.dart';
import 'package:receipt_vault/presentation/screens/auth/widgets/email_sign_in_form.dart';
import 'package:receipt_vault/presentation/screens/auth/widgets/social_sign_in_button.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isSignUp = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);

    // Listen for auth state changes
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.hasError && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }

      if (next.isAuthenticated) {
        if (next.needsOnboarding) {
          context.go('/onboarding');
        } else {
          context.go('/home');
        }
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xxl),

              // Logo and Title
              _buildHeader(l10n),

              const SizedBox(height: AppSpacing.xxl),

              // Social Sign In Buttons
              _buildSocialButtons(l10n, authState.isLoading),

              const SizedBox(height: AppSpacing.lg),

              // Divider
              _buildDivider(l10n),

              const SizedBox(height: AppSpacing.lg),

              // Email Form
              EmailSignInForm(
                isSignUp: _isSignUp,
                isLoading: authState.isLoading,
                onSubmit: _handleEmailAuth,
                onForgotPassword: _handleForgotPassword,
              ),

              const SizedBox(height: AppSpacing.lg),

              // Toggle Sign Up / Sign In
              _buildToggleButton(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      children: [
        // Logo placeholder - replace with actual logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.receipt_long,
            size: 50,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.appTitle,
          style: AppTypography.headlineLarge,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          _isSignUp ? l10n.createAccount : l10n.welcomeBack,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButtons(AppLocalizations l10n, bool isLoading) {
    return Column(
      children: [
        // Apple Sign In (iOS first!)
        SocialSignInButton(
          provider: SocialProvider.apple,
          onPressed: isLoading ? null : _handleAppleSignIn,
          isLoading: isLoading,
        ),
        const SizedBox(height: AppSpacing.sm),

        // Google Sign In
        SocialSignInButton(
          provider: SocialProvider.google,
          onPressed: isLoading ? null : _handleGoogleSignIn,
          isLoading: isLoading,
        ),
      ],
    );
  }

  Widget _buildDivider(AppLocalizations l10n) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            l10n.or,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildToggleButton(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isSignUp ? l10n.alreadyHaveAccount : l10n.dontHaveAccount,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _isSignUp = !_isSignUp;
            });
          },
          child: Text(
            _isSignUp ? l10n.signIn : l10n.signUp,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleEmailAuth({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final authNotifier = ref.read(authProvider.notifier);

    if (_isSignUp) {
      await authNotifier.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
    } else {
      await authNotifier.signInWithEmail(
        email: email,
        password: password,
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    await ref.read(authProvider.notifier).signInWithGoogle();
  }

  Future<void> _handleAppleSignIn() async {
    await ref.read(authProvider.notifier).signInWithApple();
  }

  Future<void> _handleForgotPassword(String email) async {
    final l10n = AppLocalizations.of(context)!;
    final success =
        await ref.read(authProvider.notifier).sendPasswordResetEmail(email);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.passwordResetEmailSent),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
