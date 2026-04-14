// real_io.dart — used on native platforms (Android, iOS, Desktop)
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PlatformIO {
  static Future<String?> getCachedProfileImage(int userId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${appDir.path}/profile_images');
      final cachedFile = File('${cacheDir.path}/profile_$userId.jpg');

      if (await cachedFile.exists()) {
        return cachedFile.path;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> cacheProfileImage(int userId, String sourceUrl) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${appDir.path}/profile_images');

      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      final cachedFile = File('${cacheDir.path}/profile_$userId.jpg');
      await cachedFile.writeAsString(sourceUrl);
    } catch (e) {
      // Silently fail for caching
    }
  }

  static Future<void> clearCache(int userId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final cachedFile =
          File('${appDir.path}/profile_images/profile_$userId.jpg');
      if (await cachedFile.exists()) {
        await cachedFile.delete();
      }
    } catch (e) {
      // Silently fail
    }
  }

  static Future<void> clearAllCache() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${appDir.path}/profile_images');
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    } catch (e) {
      // Silently fail
    }
  }
}