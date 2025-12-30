import 'package:flutter/material.dart';

/// App color palette for ReceiptVault
/// Designed for Lebanese market with LBP/USD dual currency support
abstract class AppColors {
  // Primary Colors
  static const primary = Color(0xFF2563EB);
  static const primaryLight = Color(0xFF3B82F6);
  static const primaryDark = Color(0xFF1D4ED8);
  static const primaryContainer = Color(0xFFDBEAFE);

  // Secondary Colors (Green - money/success)
  static const secondary = Color(0xFF10B981);
  static const secondaryLight = Color(0xFF34D399);
  static const secondaryDark = Color(0xFF059669);
  static const secondaryContainer = Color(0xFFD1FAE5);

  // Semantic Colors
  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFCA5A5);
  static const errorContainer = Color(0xFFFEE2E2);

  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFCD34D);
  static const warningContainer = Color(0xFFFEF3C7);

  static const success = Color(0xFF10B981);
  static const successLight = Color(0xFF34D399);
  static const successContainer = Color(0xFFD1FAE5);

  static const info = Color(0xFF3B82F6);
  static const infoLight = Color(0xFF93C5FD);
  static const infoContainer = Color(0xFFDBEAFE);

  // Neutral Colors - Light Theme
  static const backgroundLight = Color(0xFFF9FAFB);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceVariantLight = Color(0xFFF3F4F6);
  static const outlineLight = Color(0xFFE5E7EB);
  static const outlineVariantLight = Color(0xFFD1D5DB);

  // Neutral Colors - Dark Theme
  static const backgroundDark = Color(0xFF111827);
  static const surfaceDark = Color(0xFF1F2937);
  static const surfaceVariantDark = Color(0xFF374151);
  static const outlineDark = Color(0xFF4B5563);
  static const outlineVariantDark = Color(0xFF6B7280);

  // Text Colors - Light Theme
  static const textPrimaryLight = Color(0xFF111827);
  static const textSecondaryLight = Color(0xFF6B7280);
  static const textTertiaryLight = Color(0xFF9CA3AF);
  static const textDisabledLight = Color(0xFFD1D5DB);

  // Text Colors - Dark Theme
  static const textPrimaryDark = Color(0xFFF9FAFB);
  static const textSecondaryDark = Color(0xFF9CA3AF);
  static const textTertiaryDark = Color(0xFF6B7280);
  static const textDisabledDark = Color(0xFF4B5563);

  // Currency Colors
  static const lbpColor = Color(0xFF059669); // Green for LBP
  static const usdColor = Color(0xFF2563EB); // Blue for USD

  // Lebanese Store Brand Colors
  static const spinneys = Color(0xFFE31837);
  static const happy = Color(0xFF00A651);
  static const alMakhazen = Color(0xFF1E3A8A);
  static const charcutierAoun = Color(0xFF8B0000);
  static const total = Color(0xFFFF0000);
  static const medco = Color(0xFF00529B);

  // Category Colors
  static const groceries = Color(0xFF10B981);
  static const fuel = Color(0xFFF59E0B);
  static const dining = Color(0xFFEF4444);
  static const utilities = Color(0xFF8B5CF6);
  static const entertainment = Color(0xFFEC4899);
  static const health = Color(0xFF14B8A6);
  static const transport = Color(0xFF6366F1);
  static const shopping = Color(0xFFF97316);
  static const other = Color(0xFF6B7280);

  // Gradient Colors
  static const gradientStart = Color(0xFF2563EB);
  static const gradientEnd = Color(0xFF7C3AED);

  // Chart Colors
  static const chartColors = [
    Color(0xFF2563EB),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
    Color(0xFF6366F1),
  ];

  // Convenience aliases for common use
  static const textSecondary = textSecondaryLight;
  static const border = outlineLight;
  static const borderDark = outlineDark;
}
