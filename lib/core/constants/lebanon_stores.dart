import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Lebanese store directory with patterns for receipt recognition
class LebanonStores {
  static const Map<String, StoreInfo> stores = {
    'spinneys': StoreInfo(
      id: 'spinneys',
      name: 'Spinneys',
      nameArabic: 'سبينيز',
      type: StoreType.supermarket,
      logoAsset: 'assets/icons/stores/spinneys.svg',
      color: AppColors.spinneys,
      receiptPatterns: ['spinneys', 'سبينيز', 'spinneys.com.lb'],
    ),
    'happy': StoreInfo(
      id: 'happy',
      name: 'Happy',
      nameArabic: 'هابي',
      type: StoreType.supermarket,
      logoAsset: 'assets/icons/stores/happy.svg',
      color: AppColors.happy,
      receiptPatterns: ['happy', 'هابي', 'happy discount'],
    ),
    'al_makhazen': StoreInfo(
      id: 'al_makhazen',
      name: 'Al Makhazen',
      nameArabic: 'المخازن',
      type: StoreType.supermarket,
      logoAsset: 'assets/icons/stores/al_makhazen.svg',
      color: AppColors.alMakhazen,
      receiptPatterns: ['al makhazen', 'almakhazen', 'المخازن'],
    ),
    'charcutier_aoun': StoreInfo(
      id: 'charcutier_aoun',
      name: 'Charcutier Aoun',
      nameArabic: 'شاركوتييه عون',
      type: StoreType.supermarket,
      logoAsset: 'assets/icons/stores/charcutier_aoun.svg',
      color: AppColors.charcutierAoun,
      receiptPatterns: ['charcutier aoun', 'charcutier', 'aoun', 'عون'],
    ),
    'total': StoreInfo(
      id: 'total',
      name: 'Total',
      nameArabic: 'توتال',
      type: StoreType.gasStation,
      logoAsset: 'assets/icons/stores/total.svg',
      color: AppColors.total,
      receiptPatterns: ['total', 'total liban', 'توتال'],
    ),
    'medco': StoreInfo(
      id: 'medco',
      name: 'Medco',
      nameArabic: 'ميدكو',
      type: StoreType.gasStation,
      logoAsset: 'assets/icons/stores/medco.svg',
      color: AppColors.medco,
      receiptPatterns: ['medco', 'ميدكو'],
    ),
  };

  /// Get all receipt patterns for store detection
  static List<String> get allReceiptPatterns {
    return stores.values.expand((store) => store.receiptPatterns).toList();
  }

  /// Find store by receipt text
  static StoreInfo? findByReceiptText(String text) {
    final lowerText = text.toLowerCase();
    for (final store in stores.values) {
      for (final pattern in store.receiptPatterns) {
        if (lowerText.contains(pattern.toLowerCase())) {
          return store;
        }
      }
    }
    return null;
  }

  /// Get store by ID
  static StoreInfo? getById(String id) => stores[id];
}

/// Store information
class StoreInfo {
  final String id;
  final String name;
  final String nameArabic;
  final StoreType type;
  final String logoAsset;
  final Color color;
  final List<String> receiptPatterns;

  const StoreInfo({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.type,
    required this.logoAsset,
    required this.color,
    required this.receiptPatterns,
  });

  /// Get display name based on locale
  String getDisplayName(String locale) {
    return locale.startsWith('ar') ? nameArabic : name;
  }
}

/// Store types
enum StoreType {
  supermarket,
  gasStation,
  pharmacy,
  restaurant,
  other;

  String get displayName {
    switch (this) {
      case StoreType.supermarket:
        return 'Supermarket';
      case StoreType.gasStation:
        return 'Gas Station';
      case StoreType.pharmacy:
        return 'Pharmacy';
      case StoreType.restaurant:
        return 'Restaurant';
      case StoreType.other:
        return 'Other';
    }
  }

  String get displayNameArabic {
    switch (this) {
      case StoreType.supermarket:
        return 'سوبرماركت';
      case StoreType.gasStation:
        return 'محطة وقود';
      case StoreType.pharmacy:
        return 'صيدلية';
      case StoreType.restaurant:
        return 'مطعم';
      case StoreType.other:
        return 'آخر';
    }
  }
}
