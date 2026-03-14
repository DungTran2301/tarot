import 'dart:html' as html;

class StorageService {
  static const String _userIdKey = 'user_id';
  static const String _lastAiDateKey = 'last_ai_date';
  static const String _aiDailyCountKey = 'ai_daily_count';

  static Future<void> write(String key, String value) async {
    try {
      html.window.localStorage[key] = value;
    } catch (e) {
      print('Storage Error (write): $e');
    }
  }

  static Future<String?> read(String key) async {
    try {
      return html.window.localStorage[key];
    } catch (e) {
      print('Storage Error (read): $e');
      return null;
    }
  }

  // Convenience methods
  static Future<String?> getUserId() => read(_userIdKey);
  static Future<void> setUserId(String id) => write(_userIdKey, id);

  static Future<String?> getLastAiDate() => read(_lastAiDateKey);
  static Future<void> setLastAiDate(String date) => write(_lastAiDateKey, date);

  static Future<int> getAiCount() async {
    final val = await read(_aiDailyCountKey);
    return int.tryParse(val ?? '0') ?? 0;
  }

  static Future<void> setAiCount(int count) =>
      write(_aiDailyCountKey, count.toString());
}
