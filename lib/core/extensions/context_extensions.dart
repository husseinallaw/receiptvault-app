import 'package:flutter/material.dart';

/// BuildContext extensions for easy access to common properties
extension ContextExtensions on BuildContext {
  // ==================== Theme ====================

  /// Get current theme data
  ThemeData get theme => Theme.of(this);

  /// Get color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Get text theme
  TextTheme get textTheme => theme.textTheme;

  /// Check if dark mode
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// Get primary color
  Color get primaryColor => colorScheme.primary;

  /// Get background color
  Color get backgroundColor => colorScheme.surface;

  /// Get error color
  Color get errorColor => colorScheme.error;

  // ==================== Media Query ====================

  /// Get media query data
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Get screen size
  Size get screenSize => mediaQuery.size;

  /// Get screen width
  double get screenWidth => screenSize.width;

  /// Get screen height
  double get screenHeight => screenSize.height;

  /// Get safe area padding
  EdgeInsets get safeAreaPadding => mediaQuery.padding;

  /// Get view insets (keyboard, etc.)
  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  /// Check if keyboard is visible
  bool get isKeyboardVisible => viewInsets.bottom > 0;

  /// Get device pixel ratio
  double get devicePixelRatio => mediaQuery.devicePixelRatio;

  /// Check if small screen (phone)
  bool get isSmallScreen => screenWidth < 600;

  /// Check if medium screen (tablet)
  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 1200;

  /// Check if large screen (desktop)
  bool get isLargeScreen => screenWidth >= 1200;

  /// Get responsive value based on screen size
  T responsive<T>({
    required T small,
    T? medium,
    T? large,
  }) {
    if (isLargeScreen) return large ?? medium ?? small;
    if (isMediumScreen) return medium ?? small;
    return small;
  }

  // ==================== Orientation ====================

  /// Get current orientation
  Orientation get orientation => mediaQuery.orientation;

  /// Check if portrait
  bool get isPortrait => orientation == Orientation.portrait;

  /// Check if landscape
  bool get isLandscape => orientation == Orientation.landscape;

  // ==================== Navigation ====================

  /// Get navigator state
  NavigatorState get navigator => Navigator.of(this);

  /// Pop current route
  void pop<T>([T? result]) => navigator.pop(result);

  /// Check if can pop
  bool get canPop => navigator.canPop();

  /// Pop until predicate is true
  void popUntil(bool Function(Route<dynamic>) predicate) =>
      navigator.popUntil(predicate);

  // ==================== Focus ====================

  /// Unfocus current focus (dismiss keyboard)
  void unfocus() => FocusScope.of(this).unfocus();

  /// Request focus on a specific node
  void requestFocus(FocusNode node) => FocusScope.of(this).requestFocus(node);

  // ==================== Snackbar ====================

  /// Show a snackbar
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    Color? backgroundColor,
  }) {
    return ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Show error snackbar
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showErrorSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    return showSnackBar(
      message,
      duration: duration,
      backgroundColor: errorColor,
    );
  }

  /// Show success snackbar
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSuccessSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    return showSnackBar(
      message,
      duration: duration,
      backgroundColor: Colors.green,
    );
  }

  /// Hide current snackbar
  void hideSnackBar() => ScaffoldMessenger.of(this).hideCurrentSnackBar();

  // ==================== Scaffold ====================

  /// Open drawer
  void openDrawer() => Scaffold.of(this).openDrawer();

  /// Open end drawer
  void openEndDrawer() => Scaffold.of(this).openEndDrawer();

  /// Close drawer
  void closeDrawer() => Navigator.of(this).pop();

  // ==================== Directionality ====================

  /// Get text direction
  TextDirection get textDirection => Directionality.of(this);

  /// Check if RTL
  bool get isRTL => textDirection == TextDirection.rtl;

  /// Check if LTR
  bool get isLTR => textDirection == TextDirection.ltr;
}
