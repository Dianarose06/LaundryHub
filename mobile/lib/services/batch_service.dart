import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class BatchService {
  static String get _baseUrl => ApiConfig.apiPath;

  static Future<Map<String, dynamic>> getHomeBatch({
    int ordersLimit = 20,
    int notificationsLimit = 5,
    bool includeServices = true,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required. Please login again.',
        };
      }

      final uri = Uri.parse('$_baseUrl/batch/home').replace(
        queryParameters: {
          'orders_limit': ordersLimit.toString(),
          'notifications_limit': notificationsLimit.toString(),
          'include_services': includeServices ? 'true' : 'false',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'] as Map<String, dynamic>? ?? {},
        };
      }

      if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      }

      return {'success': false, 'message': _extractError(data)};
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error. Please check your network.',
      };
    }
  }

  static Future<Map<String, dynamic>> getProfileBatch({
    int recentOrdersLimit = 5,
    int notificationsLimit = 5,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required. Please login again.',
        };
      }

      final uri = Uri.parse('$_baseUrl/batch/profile').replace(
        queryParameters: {
          'recent_orders_limit': recentOrdersLimit.toString(),
          'notifications_limit': notificationsLimit.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'] as Map<String, dynamic>? ?? {},
        };
      }

      if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      }

      return {'success': false, 'message': _extractError(data)};
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error. Please check your network.',
      };
    }
  }

  static String _extractError(Map<String, dynamic> data) {
    if (data['message'] != null) return data['message'].toString();
    if (data['error'] != null) return data['error'].toString();
    if (data['errors'] != null) {
      final errors = data['errors'] as Map<String, dynamic>;
      if (errors.isNotEmpty) {
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
        return firstError.toString();
      }
    }
    return 'An error occurred. Please try again.';
  }
}
