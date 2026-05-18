import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<http.Response> _postAuth(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final baseUrl = await ApiConfig.resolveReachableBaseUrl();

    return http
        .post(
          Uri.parse('$baseUrl/api$endpoint'),
          headers: _jsonHeaders,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 20));
  }

  static String _networkErrorMessage(Object? error) {
    if (error is TimeoutException) {
      return 'Connection timed out. Please check that the Laravel server is running on port 8000.';
    }

    return 'Unable to reach the Laravel server. Please check that Docker is running and your phone is on the same Wi-Fi.';
  }

  static String _friendlyError(Object error) {
    if (error is TimeoutException) {
      return _networkErrorMessage(error);
    }

    return error.toString().replaceFirst('Exception: ', '');
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _postAuth('/login', {
        'email': email,
        'password': password,
      });

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final role = data['role']?.toString().toLowerCase() ?? 'user';

        if (role == 'admin') {
          return {
            'success': true,
            'role': 'admin',
            'redirect_url': data['redirect_url'],
            'data': data,
          };
        }

        final user = Map<String, dynamic>.from(
          data['user'] as Map<String, dynamic>? ?? const {},
        );
        user['role'] = 'user';

        await _saveSession(data['token'] as String, user);
        return {
          'success': true,
          'role': 'user',
          'data': {...data, 'role': 'user', 'user': user},
        };
      }

      if (response.statusCode == 403) {
        return {
          'success': false,
          'email_not_verified': true,
          'message': data['message'] ?? 'Please verify your email first.',
        };
      }

      if (response.statusCode == 401) {
        return {
          'success': false,
          'message': data['message'] ?? 'Invalid credentials.',
        };
      }

      return {'success': false, 'message': _extractError(data)};
    } catch (e) {
      return {'success': false, 'message': _friendlyError(e)};
    }
  }

  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    String? middleInitial,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final normalizedFirstName = firstName.trim();
      final normalizedLastName = lastName.trim();
      final normalizedMiddleInitial =
          (middleInitial != null && middleInitial.trim().isNotEmpty)
          ? middleInitial.trim().substring(0, 1).toUpperCase()
          : null;

      final formattedName = normalizedMiddleInitial != null
          ? '$normalizedLastName, $normalizedFirstName $normalizedMiddleInitial.'
          : '$normalizedLastName, $normalizedFirstName';

      final body = {
        'name': formattedName,
        'first_name': normalizedFirstName,
        'last_name': normalizedLastName,
        'middle_initial': normalizedMiddleInitial,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'phone': (phone != null && phone.isNotEmpty) ? phone : null,
      };

      final response = await _postAuth('/register', body);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201) {
        // Registration successful
        return {
          'success': true,
          'message': data['message'] ?? 'Registration successful.',
          'email': email,
        };
      }

      return {'success': false, 'message': _extractError(data)};
    } catch (e) {
      return {'success': false, 'message': _friendlyError(e)};
    }
  }

  static String? _cachedToken;
  static Map<String, dynamic>? _cachedUser;

  static Future<void> _saveSession(String token, dynamic user) async {
    final prefs = await SharedPreferences.getInstance();
    await _secureStorage.write(key: _tokenKey, value: token);
    await prefs.setString(_userKey, jsonEncode(user));

    _cachedToken = token;
    _cachedUser = user is Map<String, dynamic>
        ? user
        : jsonDecode(jsonEncode(user)) as Map<String, dynamic>;
  }

  static Future<void> bootstrapSession({
    required String token,
    required String role,
  }) async {
    await _saveSession(token, {'role': role});
  }

  static Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;

    _cachedToken = await _secureStorage.read(key: _tokenKey);
    return _cachedToken;
  }

  static Future<Map<String, dynamic>?> getUser() async {
    if (_cachedUser != null) return _cachedUser;

    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_userKey);
    if (json == null) return null;

    _cachedUser = jsonDecode(json) as Map<String, dynamic>;
    return _cachedUser;
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<String> getRole() async {
    final user = await getUser();
    return user?['role']?.toString() ?? 'user';
  }

  static Future<void> logout() async {
    _cachedToken = null;
    _cachedUser = null;

    final prefs = await SharedPreferences.getInstance();
    await _secureStorage.delete(key: _tokenKey);
    await prefs.remove(_userKey);
  }

  static String _extractError(Map<String, dynamic> data) {
    if (data['errors'] != null) {
      final errors = data['errors'] as Map<String, dynamic>;
      if (errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) {
          return first.first.toString();
        }
      }
    }
    return data['message']?.toString() ??
        'Something went wrong. Please try again.';
  }

  static Future<Map<String, dynamic>> resendVerification({
    required String email,
  }) async {
    try {
      final response = await _postAuth('/resend-verification', {
        'email': email,
      });

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      }

      return {'success': false, 'message': _extractError(data)};
    } catch (e) {
      return {'success': false, 'message': _friendlyError(e)};
    }
  }

  static Future<Map<String, dynamic>> verifyCode(
    String email,
    String code,
  ) async {
    try {
      final response = await _postAuth('/verify-code', {
        'email': email,
        'code': code,
      });

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        // Don't save the session - user will login manually after verification
        return {'success': true, 'message': data['message']};
      }

      return {'success': false, 'message': _extractError(data)};
    } catch (e) {
      return {'success': false, 'message': _friendlyError(e)};
    }
  }

  static Future<Map<String, dynamic>> sendVerificationCode(String email) async {
    try {
      final response = await _postAuth('/send-verification-code', {
        'email': email,
      });

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      }

      return {'success': false, 'message': _extractError(data)};
    } catch (e) {
      return {'success': false, 'message': _friendlyError(e)};
    }
  }

  static Future<Map<String, dynamic>> checkVerificationCode(
    String email,
    String code,
  ) async {
    try {
      final response = await _postAuth('/check-verification-code', {
        'email': email,
        'code': code,
      });

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      }

      return {'success': false, 'message': _extractError(data)};
    } catch (e) {
      return {'success': false, 'message': _friendlyError(e)};
    }
  }

  static Future<Map<String, dynamic>> sendPasswordResetCode(
    String email,
  ) async {
    try {
      final response = await _postAuth('/send-password-reset-code', {
        'email': email,
      });

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      }

      return {'success': false, 'message': _extractError(data)};
    } catch (e) {
      return {'success': false, 'message': _friendlyError(e)};
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    try {
      final response = await _postAuth('/reset-password', {
        'email': email,
        'code': code,
        'password': password,
        'password_confirmation': password,
      });

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      }

      return {'success': false, 'message': _extractError(data)};
    } catch (e) {
      return {'success': false, 'message': _friendlyError(e)};
    }
  }
}
