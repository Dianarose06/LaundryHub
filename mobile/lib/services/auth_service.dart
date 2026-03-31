import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  static String get _baseUrl => ApiConfig.apiPath;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        await _saveSession(data['token'] as String, data['user']);
        return {'success': true, 'data': data};
      }

      if (response.statusCode == 404) {
        return {
          'success': false,
          'user_not_found': true,
          'message':
              data['message'] ?? 'Account not found. Please register first.',
        };
      }

      if (response.statusCode == 403) {
        return {
          'success': false,
          'email_not_verified': true,
          'message': data['message'] ?? 'Please verify your email first.',
        };
      }

      return {'success': false, 'message': _extractError(data)};
    } catch (_) {
      return {
        'success': false,
        'message': 'Connection error. Please check your network.',
      };
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

      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

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
    } catch (_) {
      return {
        'success': false,
        'message': 'Connection error. Please check your network.',
      };
    }
  }

  static Future<void> _saveSession(String token, dynamic user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user));
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_userKey);
    if (json == null) return null;
    return jsonDecode(json) as Map<String, dynamic>;
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<String> getRole() async {
    final user = await getUser();
    return user?['role']?.toString() ?? 'customer';
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
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
      final response = await http.post(
        Uri.parse('$_baseUrl/resend-verification'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      }

      return {'success': false, 'message': _extractError(data)};
    } catch (_) {
      return {
        'success': false,
        'message': 'Connection error. Please check your network.',
      };
    }
  }

  static Future<Map<String, dynamic>> verifyCode(
    String email,
    String code,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/verify-code'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'code': code}),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        // Don't save the session - user will login manually after verification
        return {'success': true, 'message': data['message']};
      }

      return {'success': false, 'message': _extractError(data)};
    } catch (_) {
      return {
        'success': false,
        'message': 'Connection error. Please check your network.',
      };
    }
  }

  static Future<Map<String, dynamic>> sendVerificationCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/send-verification-code'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      }

      return {'success': false, 'message': _extractError(data)};
    } catch (_) {
      return {
        'success': false,
        'message': 'Connection error. Please check your network.',
      };
    }
  }

  static Future<Map<String, dynamic>> checkVerificationCode(
    String email,
    String code,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/check-verification-code'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'code': code}),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      }

      return {'success': false, 'message': _extractError(data)};
    } catch (_) {
      return {
        'success': false,
        'message': 'Connection error. Please check your network.',
      };
    }
  }

  static Future<Map<String, dynamic>> sendPasswordResetCode(
    String email,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/send-password-reset-code'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      }

      return {'success': false, 'message': _extractError(data)};
    } catch (_) {
      return {
        'success': false,
        'message': 'Connection error. Please check your network.',
      };
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/reset-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'code': code,
          'password': password,
          'password_confirmation': password,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      }

      return {'success': false, 'message': _extractError(data)};
    } catch (_) {
      return {
        'success': false,
        'message': 'Connection error. Please check your network.',
      };
    }
  }
}
