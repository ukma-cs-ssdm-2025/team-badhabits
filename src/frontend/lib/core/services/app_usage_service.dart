import 'package:shared_preferences/shared_preferences.dart';

/// Service for tracking app usage days
///
/// Stores unique dates when the user opens the app to track milestones
class AppUsageService {
  AppUsageService._();

  static const String _usageDatesKey = 'app_usage_dates';
  static const String _lastUsageDateKey = 'app_last_usage_date';

  static SharedPreferences? _prefs;

  /// Initialize the service
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Record today's usage and return total unique days
  static Future<int> recordUsage() async {
    if (_prefs == null) {
      await init();
    }

    final today = _formatDate(DateTime.now());
    final lastDate = _prefs!.getString(_lastUsageDateKey);

    // If already recorded today, just return current count
    if (lastDate == today) {
      return getTotalDaysUsed();
    }

    // Get existing dates
    final dates = _prefs!.getStringList(_usageDatesKey) ?? [];

    // Add today if not already present
    if (!dates.contains(today)) {
      dates.add(today);
      await _prefs!.setStringList(_usageDatesKey, dates);
    }

    // Update last usage date
    await _prefs!.setString(_lastUsageDateKey, today);

    return dates.length;
  }

  /// Get total unique days the app was used
  static int getTotalDaysUsed() {
    if (_prefs == null) {
      return 0;
    }
    final dates = _prefs!.getStringList(_usageDatesKey) ?? [];
    return dates.length;
  }

  /// Check if this is first usage today
  static bool isFirstUsageToday() {
    if (_prefs == null) {
      return true;
    }
    final today = _formatDate(DateTime.now());
    final lastDate = _prefs!.getString(_lastUsageDateKey);
    return lastDate != today;
  }

  /// Format date as YYYY-MM-DD
  static String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
