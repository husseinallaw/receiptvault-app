import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography configuration for ReceiptVault
/// Uses Inter for English and Tajawal for Arabic
class AppTypography {
  static const String fontFamilyEnglish = 'Inter';
  static const String fontFamilyArabic = 'Tajawal';

  static TextTheme get textTheme => const TextTheme(
        // Display styles
        displayLarge: TextStyle(
          fontFamily: fontFamilyEnglish,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          height: 1.2,
          color: AppColors.textPrimaryLight,
        ),
        displayMedium: TextStyle(
          fontFamily: fontFamilyEnglish,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          height: 1.2,
          color: AppColors.textPrimaryLight,
        ),
        displaySmall: TextStyle(
          fontFamily: fontFamilyEnglish,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          height: 1.2,
          color: AppColors.textPrimaryLight,
        ),

        // Headline styles
        headlineLarge: TextStyle(
          fontFamily: fontFamilyEnglish,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: AppColors.textPrimaryLight,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontFamilyEnglish,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: AppColors.textPrimaryLight,
        ),
        headlineSmall: TextStyle(
          fontFamily: fontFamilyEnglish,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: AppColors.textPrimaryLight,
        ),

        // Title styles
        titleLarge: TextStyle(
          fontFamily: fontFamilyEnglish,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: AppColors.textPrimaryLight,
        ),
        titleMedium: TextStyle(
          fontFamily: fontFamilyEnglish,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: AppColors.textPrimaryLight,
        ),
        titleSmall: TextStyle(
          fontFamily: fontFamilyEnglish,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: AppColors.textPrimaryLight,
        ),

        // Body styles
        bodyLarge: TextStyle(
          fontFamily: fontFamilyEnglish,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: 1.5,
          color: AppColors.textPrimaryLight,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamilyEnglish,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          height: 1.5,
          color: AppColors.textPrimaryLight,
        ),
        bodySmall: TextStyle(
          fontFamily: fontFamilyEnglish,
          fontSize: 12,
          fontWeight: FontWeight.normal,
          height: 1.5,
          color: AppColors.textSecondaryLight,
        ),

        // Label styles
        labelLarge: TextStyle(
          fontFamily: fontFamilyEnglish,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: AppColors.textPrimaryLight,
        ),
        labelMedium: TextStyle(
          fontFamily: fontFamilyEnglish,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: AppColors.textSecondaryLight,
        ),
        labelSmall: TextStyle(
          fontFamily: fontFamilyEnglish,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          height: 1.4,
          letterSpacing: 0.5,
          color: AppColors.textSecondaryLight,
        ),
      );

  static TextTheme get textThemeDark => textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        displayMedium: textTheme.displayMedium?.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        displaySmall: textTheme.displaySmall?.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        headlineLarge: textTheme.headlineLarge?.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        titleSmall: textTheme.titleSmall?.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        bodyLarge:
            textTheme.bodyLarge?.copyWith(color: AppColors.textPrimaryDark),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        labelLarge: textTheme.labelLarge?.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        labelMedium: textTheme.labelMedium?.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        labelSmall: textTheme.labelSmall?.copyWith(
          color: AppColors.textSecondaryDark,
        ),
      );
}
