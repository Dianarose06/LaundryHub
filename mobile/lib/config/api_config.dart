import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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
  static String? _resolvedReachableBaseUrl;
  static Future<String>? _resolvingReachableBaseUrl;

  static const String _defaultLocalBaseUrl = 'http://127.0.0.1:8000';
  static const String _androidEmulatorBaseUrl = 'http://10.0.2.2:8000';
  static const String _knownWifiBaseUrl = 'http://10.124.64.160:8000';

  static String get baseUrl {
    if (_runtimeOverrideBaseUrl != null &&
        _runtimeOverrideBaseUrl!.isNotEmpty) {
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

  static List<String> get candidateBaseUrls {
    final candidates = <String>[
      if (_runtimeOverrideBaseUrl != null &&
          _runtimeOverrideBaseUrl!.isNotEmpty)
        _runtimeOverrideBaseUrl!,
      if (_envBaseUrl.isNotEmpty) _normalizeBaseUrl(_envBaseUrl),
      baseUrl,
      if (defaultTargetPlatform == TargetPlatform.android)
        _androidEmulatorBaseUrl,
      _defaultLocalBaseUrl,
      _knownWifiBaseUrl,
    ];

    final seen = <String>{};
    return candidates
        .map(_normalizeBaseUrl)
        .where((url) => seen.add(url))
        .toList(growable: false);
  }

  static String get adminRedirectUrl {
    const fromEnv = String.fromEnvironment('ADMIN_REDIRECT_URL');
    if (fromEnv.isNotEmpty) {
      return fromEnv;
    }
    return adminWebUrl;
  }

  static String get _webBaseUrl {
    final scheme = Uri.base.scheme.isNotEmpty ? Uri.base.scheme : 'http';
    final host = Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost';
    return '$scheme://$host:8000';
  }

  /// Update this method to switch between environments dynamically
  static void updateBaseUrl(String url) {
    final trimmed = url.trim();
    _runtimeOverrideBaseUrl = trimmed.isEmpty
        ? null
        : _normalizeBaseUrl(trimmed);
    _resolvedReachableBaseUrl = _runtimeOverrideBaseUrl;
    _resolvingReachableBaseUrl = null;
  }

  static String _normalizeBaseUrl(String url) {
    final normalized = url.replaceAll(RegExp(r'/+$'), '');
    return normalized;
  }

  static Future<String> resolveReachableBaseUrl({
    bool forceRefresh = false,
  }) async {
    if (forceRefresh) {
      _resolvedReachableBaseUrl = null;
      _resolvingReachableBaseUrl = null;
    }

    if (_resolvedReachableBaseUrl != null &&
        _resolvedReachableBaseUrl!.isNotEmpty) {
      return _resolvedReachableBaseUrl!;
    }

    final activeResolve = _resolvingReachableBaseUrl;
    if (activeResolve != null) return activeResolve;

    final completer = Completer<String>();
    _resolvingReachableBaseUrl = completer.future;

    final candidates = candidateBaseUrls;
    var pending = candidates.length;

    for (final candidate in candidates) {
      http
          .get(
            Uri.parse('$candidate/api/health'),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 3))
          .then((response) {
            if (!completer.isCompleted && response.statusCode < 500) {
              _resolvedReachableBaseUrl = candidate;
              _runtimeOverrideBaseUrl = candidate;
              completer.complete(candidate);
            }
          })
          .catchError((_) {})
          .whenComplete(() {
            pending -= 1;
            if (pending == 0 && !completer.isCompleted) {
              final fallback =
                  _runtimeOverrideBaseUrl ??
                  (_envBaseUrl.isNotEmpty
                      ? _normalizeBaseUrl(_envBaseUrl)
                      : baseUrl);
              _resolvedReachableBaseUrl = fallback;
              completer.complete(fallback);
            }
          });
    }

    try {
      return await completer.future;
    } finally {
      _resolvingReachableBaseUrl = null;
    }
  }

  static Future<String> resolveApiPath({bool forceRefresh = false}) async {
    final resolvedBase = await resolveReachableBaseUrl(
      forceRefresh: forceRefresh,
    );
    return '$resolvedBase/api';
  }
}
