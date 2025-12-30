import 'package:intl/intl.dart';

/// Date and DateTime utility extensions
extension DateTimeExtensions on DateTime {
  /// Format as Lebanese date (dd/MM/yyyy)
  String get formatLebanese => DateFormat('dd/MM/yyyy').format(this);

  /// Format as Lebanese date with time
  String get formatLebaneseFull => DateFormat('dd/MM/yyyy HH:mm').format(this);

  /// Format as ISO date (yyyy-MM-dd)
  String get formatIso => DateFormat('yyyy-MM-dd').format(this);

  /// Format as relative time (e.g., "2 hours ago", "Yesterday")
  String get formatRelative {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(this);
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      return formatLebanese;
    }
  }

  /// Format as relative time in Arabic
  String get formatRelativeArabic {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      if (minutes == 1) return 'منذ دقيقة';
      if (minutes == 2) return 'منذ دقيقتين';
      if (minutes <= 10) return 'منذ $minutes دقائق';
      return 'منذ $minutes دقيقة';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      if (hours == 1) return 'منذ ساعة';
      if (hours == 2) return 'منذ ساعتين';
      if (hours <= 10) return 'منذ $hours ساعات';
      return 'منذ $hours ساعة';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE', 'ar').format(this);
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      if (weeks == 1) return 'منذ أسبوع';
      if (weeks == 2) return 'منذ أسبوعين';
      return 'منذ $weeks أسابيع';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      if (months == 1) return 'منذ شهر';
      if (months == 2) return 'منذ شهرين';
      if (months <= 10) return 'منذ $months أشهر';
      return 'منذ $months شهر';
    } else {
      return formatLebanese;
    }
  }

  /// Format based on locale
  String formatRelativeLocalized(String locale) {
    return locale == 'ar' ? formatRelativeArabic : formatRelative;
  }

  /// Get start of day
  DateTime get startOfDay => DateTime(year, month, day);

  /// Get end of day
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Get start of week (Monday)
  DateTime get startOfWeek {
    final daysToSubtract = weekday - DateTime.monday;
    return subtract(Duration(days: daysToSubtract)).startOfDay;
  }

  /// Get end of week (Sunday)
  DateTime get endOfWeek {
    final daysToAdd = DateTime.sunday - weekday;
    return add(Duration(days: daysToAdd)).endOfDay;
  }

  /// Get start of month
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// Get end of month
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59, 999);

  /// Get start of year
  DateTime get startOfYear => DateTime(year, 1, 1);

  /// Get end of year
  DateTime get endOfYear => DateTime(year, 12, 31, 23, 59, 59, 999);

  /// Check if same day as another date
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Check if same month as another date
  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }

  /// Check if same year as another date
  bool isSameYear(DateTime other) {
    return year == other.year;
  }

  /// Check if today
  bool get isToday => isSameDay(DateTime.now());

  /// Check if yesterday
  bool get isYesterday =>
      isSameDay(DateTime.now().subtract(const Duration(days: 1)));

  /// Check if this week
  bool get isThisWeek {
    final now = DateTime.now();
    return isAfter(now.startOfWeek.subtract(const Duration(seconds: 1))) &&
        isBefore(now.endOfWeek.add(const Duration(seconds: 1)));
  }

  /// Check if this month
  bool get isThisMonth => isSameMonth(DateTime.now());

  /// Check if this year
  bool get isThisYear => isSameYear(DateTime.now());

  /// Get month name
  String get monthName => DateFormat('MMMM').format(this);

  /// Get month name in Arabic
  String get monthNameArabic => DateFormat('MMMM', 'ar').format(this);

  /// Get short month name
  String get monthNameShort => DateFormat('MMM').format(this);

  /// Get day name
  String get dayName => DateFormat('EEEE').format(this);

  /// Get day name in Arabic
  String get dayNameArabic => DateFormat('EEEE', 'ar').format(this);
}

/// Extension for Duration
extension DurationExtensions on Duration {
  /// Format as human readable string
  String get formatHumanReadable {
    if (inSeconds < 60) {
      return '$inSeconds seconds';
    } else if (inMinutes < 60) {
      return '$inMinutes minutes';
    } else if (inHours < 24) {
      return '$inHours hours';
    } else {
      return '$inDays days';
    }
  }
}
