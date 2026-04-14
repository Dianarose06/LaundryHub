import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import 'stub_io.dart' if (dart.library.io) 'real_io.dart';

Uint8List _compressImageInBackground(Map<String, dynamic> input) {
  final bytes = input['bytes'] as Uint8List;
  final maxWidth = input['maxWidth'] as int;
  final maxHeight = input['maxHeight'] as int;

  var image = img.decodeImage(bytes);
  if (image == null) {
    throw 'Could not decode image. Please choose a JPG, JPEG, PNG, or GIF file.';
  }

  if (image.width > maxWidth || image.height > maxHeight) {
    image = img.copyResize(
      image,
      width: image.width > image.height ? maxWidth : null,
      height: image.height > image.width ? maxHeight : null,
      interpolation: img.Interpolation.average,
    );
  }

  return Uint8List.fromList(img.encodeJpg(image, quality: 85));
}

class ImageUploadService {
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const int maxWidth = 1200;
  static const int maxHeight = 1200;

  static Future<String?> validateImage(XFile image) async {
    try {
      final fileSize = await image.length();
      if (fileSize > maxFileSize) {
        return 'Image is too large. Maximum size is 5MB. '
            'Current: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB';
      }

      final lower =
          (image.name.isNotEmpty ? image.name : image.path).toLowerCase();
      if (!(lower.endsWith('.jpg') ||
          lower.endsWith('.jpeg') ||
          lower.endsWith('.png') ||
          lower.endsWith('.gif'))) {
        return 'Unsupported image format. Please use JPG, JPEG, PNG, or GIF.';
      }

      return null;
    } catch (e) {
      return 'Error validating image: $e';
    }
  }

  static Future<Uint8List> compressImage(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      if (bytes.length <= 400 * 1024) {
        return bytes;
      }

      return compute(
        _compressImageInBackground,
        {
          'bytes': bytes,
          'maxWidth': maxWidth,
          'maxHeight': maxHeight,
        },
      );
    } catch (e) {
      throw 'Failed to compress image: $e';
    }
  }

  static Future<String?> getCachedProfileImage(int userId) async {
    if (kIsWeb) return null;
    return PlatformIO.getCachedProfileImage(userId);
  }

  static Future<void> cacheProfileImage(int userId, String sourceUrl) async {
    if (kIsWeb) return;
    await PlatformIO.cacheProfileImage(userId, sourceUrl);
  }

  static Future<void> clearCache(int userId) async {
    if (kIsWeb) return;
    await PlatformIO.clearCache(userId);
  }

  static Future<void> clearAllCache() async {
    if (kIsWeb) return;
    await PlatformIO.clearAllCache();
  }

  static String getFileSizeString(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    }
    return '${(bytes / 1024 / 1024).toStringAsFixed(2)} MB';
  }
}