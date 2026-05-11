/// API Configuration
///
/// This file centralizes API base URL configuration to support different environments:
/// - Development: localhost:8000
/// - Production: your domain
///
/// For Android emulator: use 10.0.2.2 instead of localhost to reach the host machine
/// For physical device testing: use your machine's actual IP address
class ApiConfig {
  // Configuration: Change this to match your environment
  // For development: 'http://10.0.2.2:8000' (Android emulator)
  // For production: 'https://yourdomain.com'
  static const String baseUrl = 'http://localhost:8000';
  static const String apiPath = '$baseUrl/api';
  static const String _adminRedirectUrlFromEnv = String.fromEnvironment(
    'ADMIN_REDIRECT_URL',
    defaultValue: '',
  );

  // Browser-only Laravel admin panel URL.
  // Example dev URL: 'http://localhost:8000/admin'
  // Example prod URL: 'https://yourdomain.com/admin'
  static String get adminRedirectUrl {
    if (_adminRedirectUrlFromEnv.isNotEmpty) {
      return _adminRedirectUrlFromEnv;
    }

    return '$baseUrl/admin';
  }

  /// Update this method to switch between environments dynamically
  static void updateBaseUrl(String url) {
    // Placeholder for future runtime switching.
    // Current implementation uses compile-time constants.
    if (url.isEmpty) {
      return;
    }
  }
}
