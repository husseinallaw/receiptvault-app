import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'core/di/injection.dart';
import 'l10n/generated/app_localizations.dart';
// import 'firebase_options.dart'; // TODO: Generate with FlutterFire CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // TODO: Initialize Firebase when firebase_options.dart is generated
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(
    ProviderScope(
      overrides: [
        // Override SharedPreferences with initialized instance
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const ReceiptVaultApp(),
    ),
  );
}

/// Main application widget for ReceiptVault
class ReceiptVaultApp extends ConsumerStatefulWidget {
  const ReceiptVaultApp({super.key});

  @override
  ConsumerState<ReceiptVaultApp> createState() => _ReceiptVaultAppState();
}

class _ReceiptVaultAppState extends ConsumerState<ReceiptVaultApp> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Simulate app initialization (loading user preferences, etc.)
    await Future.delayed(const Duration(milliseconds: 500));

    // Mark app as initialized
    ref.read(appInitializedProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'ReceiptVault',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _convertThemeMode(themeMode),

      // Router
      routerConfig: router,

      // Localization
      locale: Locale(locale.code),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }

  ThemeMode _convertThemeMode(ThemeModePreference preference) {
    return switch (preference) {
      ThemeModePreference.light => ThemeMode.light,
      ThemeModePreference.dark => ThemeMode.dark,
      ThemeModePreference.system => ThemeMode.system,
    };
  }
}
