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

  /// Update this method to switch between environments dynamically
  static void updateBaseUrl(String url) {
    // This could be extended to support runtime configuration
    // Currently using const for compile-time optimization
    print('To change API URL, edit ApiConfig.baseUrl');
  }
}
