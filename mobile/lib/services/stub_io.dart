// stub_io.dart — used on Flutter Web (dart:io is unavailable)

class PlatformIO {
  static Future<String?> getCachedProfileImage(int userId) async => null;
  static Future<void> cacheProfileImage(int userId, String sourceUrl) async {}
  static Future<void> clearCache(int userId) async {}
  static Future<void> clearAllCache() async {}
}