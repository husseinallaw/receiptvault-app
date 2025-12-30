import 'package:flutter/material.dart';
import 'package:receipt_vault/app/theme/app_colors.dart';
import 'package:receipt_vault/app/theme/app_spacing.dart';
import 'package:receipt_vault/app/theme/app_typography.dart';

enum SocialProvider { google, apple }

class SocialSignInButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SocialSignInButton({
    super.key,
    required this.provider,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: _getBackgroundColor(isDark),
          foregroundColor: _getForegroundColor(isDark),
          side: BorderSide(
            color: _getBorderColor(isDark),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(isDark),
            const SizedBox(width: AppSpacing.sm),
            Text(
              _getButtonText(),
              style: AppTypography.bodyLarge.copyWith(
                color: _getForegroundColor(isDark),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(bool isDark) {
    switch (provider) {
      case SocialProvider.google:
        // Google "G" logo colors
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              'G',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        );
      case SocialProvider.apple:
        return Icon(
          Icons.apple,
          size: 24,
          color: isDark ? Colors.white : Colors.black,
        );
    }
  }

  String _getButtonText() {
    switch (provider) {
      case SocialProvider.google:
        return 'Continue with Google';
      case SocialProvider.apple:
        return 'Continue with Apple';
    }
  }

  Color _getBackgroundColor(bool isDark) {
    switch (provider) {
      case SocialProvider.google:
        return isDark ? AppColors.surfaceDark : Colors.white;
      case SocialProvider.apple:
        return isDark ? Colors.white : Colors.black;
    }
  }

  Color _getForegroundColor(bool isDark) {
    switch (provider) {
      case SocialProvider.google:
        return isDark ? Colors.white : Colors.black87;
      case SocialProvider.apple:
        return isDark ? Colors.black : Colors.white;
    }
  }

  Color _getBorderColor(bool isDark) {
    switch (provider) {
      case SocialProvider.google:
        return isDark ? AppColors.borderDark : AppColors.border;
      case SocialProvider.apple:
        return isDark ? Colors.white : Colors.black;
    }
  }
}
