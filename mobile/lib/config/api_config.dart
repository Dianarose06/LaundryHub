import 'package:flutter/foundation.dart';

/// API Configuration
///
/// This file centralizes API base URL configuration to support different environments:
/// - Development: localhost:8000 / 10.0.2.2:8000
/// - Production: your domain
class ApiConfig {
  // Optional compile-time override:
  // flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String? _runtimeOverrideBaseUrl;

  static const String _defaultLocalBaseUrl = 'http://127.0.0.1:8000';
  static const String _androidEmulatorBaseUrl = 'http://10.0.2.2:8000';

  static String get baseUrl {
    if (_runtimeOverrideBaseUrl != null && _runtimeOverrideBaseUrl!.isNotEmpty) {
      return _runtimeOverrideBaseUrl!;
    }

    if (_envBaseUrl.isNotEmpty) {
      return _normalizeBaseUrl(_envBaseUrl);
    }

    if (kIsWeb) {
      return _webBaseUrl;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _androidEmulatorBaseUrl;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return _defaultLocalBaseUrl;
    }
  }

  static String get apiPath => '$baseUrl/api';
  static String get adminWebUrl => '$baseUrl/admin';

  static String get _webBaseUrl {
    final scheme = Uri.base.scheme.isNotEmpty ? Uri.base.scheme : 'http';
    final rawHost = Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost';
    final host = rawHost == 'localhost' ? '127.0.0.1' : rawHost;
    return '$scheme://$host:8000';
  }

  /// Update this method to switch between environments dynamically
  static void updateBaseUrl(String url) {
    final trimmed = url.trim();
    _runtimeOverrideBaseUrl = trimmed.isEmpty ? null : _normalizeBaseUrl(trimmed);
  }

  static String _normalizeBaseUrl(String url) {
    final normalized = url.replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.tryParse(normalized);

    if (uri == null || uri.host != 'localhost') {
      return normalized;
    }

    return uri.replace(host: '127.0.0.1').toString();
  }
}
