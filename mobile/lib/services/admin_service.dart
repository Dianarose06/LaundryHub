import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminService {
  // For Android emulator use 10.0.2.2 to reach host machine.
  // Change to your machine's IP if testing on a physical device.
  static const String _baseUrl = 'http://localhost:8000/api';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Fetches today's stats: total_bookings, pending_count, revenue_today, customer_count.
  static Future<Map<String, dynamic>> fetchStats() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/admin/stats'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {'success': true, 'data': data};
      }

      return {'success': false, 'message': 'Failed to fetch stats (${response.statusCode})'};
    } catch (_) {
      return {'success': false, 'message': 'Connection error'};
    }
  }

  /// Fetches all recent orders with id, customer, status, amount fields.
  static Future<Map<String, dynamic>> fetchRecentOrders() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/admin/orders/recent'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return {'success': true, 'data': body['data'] as List<dynamic>};
      }

      return {'success': false, 'message': 'Failed to fetch orders (${response.statusCode})'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  /// Fetches all orders for admin. Optionally filter by [status] ('pending','ongoing','ready', etc.)
  static Future<Map<String, dynamic>> fetchAllOrders({String? status}) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Not authenticated'};

      final uri = Uri.parse('$_baseUrl/admin/orders').replace(
        queryParameters: (status != null && status != 'all') ? {'status': status} : null,
      );

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return {'success': true, 'data': body['data'] as List<dynamic>};
      }

      return {'success': false, 'message': 'Failed to fetch bookings (${response.statusCode})'};
    } catch (_) {
      return {'success': false, 'message': 'Connection error'};
    }
  }

  /// Updates a single order's status. [newStatus] must be one of:
  /// pending | ongoing | ready | completed | cancelled
  static Future<Map<String, dynamic>> updateOrderStatus(int orderId, String newStatus) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Not authenticated'};

      final response = await http.patch(
        Uri.parse('$_baseUrl/admin/orders/$orderId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': newStatus}),
      );

      if (response.statusCode == 200) return {'success': true};
      return {'success': false, 'message': 'Failed to update status (${response.statusCode})'};
    } catch (_) {
      return {'success': false, 'message': 'Connection error'};
    }
  }

  /// Fetches top 5 customers by total spend.
  static Future<Map<String, dynamic>> fetchTopCustomers() async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Not authenticated'};

      final response = await http.get(
        Uri.parse('$_baseUrl/admin/top-customers'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return {'success': true, 'data': body['data'] as List<dynamic>};
      }

      return {'success': false, 'message': 'Failed to fetch customers (${response.statusCode})'};
    } catch (_) {
      return {'success': false, 'message': 'Connection error'};
    }
  }

  /// Fetches analytics data:
  /// - weekly_revenue: List<double> [Mon–Sun]
  /// - service_breakdown: List of {name, count, pct}
  /// - monthly_revenue: double
  /// - month_label: String (e.g. "March 2026")
  static Future<Map<String, dynamic>> fetchAnalytics() async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Not authenticated'};

      final response = await http.get(
        Uri.parse('$_baseUrl/admin/analytics'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {'success': true, 'data': data};
      }

      return {'success': false, 'message': 'Failed to fetch analytics (${response.statusCode})'};
    } catch (_) {
      return {'success': false, 'message': 'Connection error'};
    }
  }

  /// Fetches all services (admin view — includes inactive).
  static Future<Map<String, dynamic>> fetchServices() async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Not authenticated'};

      final response = await http.get(
        Uri.parse('$_baseUrl/admin/services'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return {'success': true, 'data': body['data'] as List<dynamic>};
      }

      return {'success': false, 'message': 'Failed to fetch services (${response.statusCode})'};
    } catch (_) {
      return {'success': false, 'message': 'Connection error'};
    }
  }

  /// Creates a new service.
  static Future<Map<String, dynamic>> createService({
    required String name,
    required String description,
    required double pricePerKg,
    String? category,
    String? imageUrl,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Not authenticated'};

      final response = await http.post(
        Uri.parse('$_baseUrl/admin/services'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'description': description,
          'price_per_kg': pricePerKg,
          'category': category,
          'image_url': imageUrl,
          'is_active': true,
        }),
      );

      if (response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)['data']};
      }

      return {'success': false, 'message': 'Failed to create service (${response.statusCode})'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  /// Updates an existing service.
  static Future<Map<String, dynamic>> updateService({
    required int serviceId,
    required String name,
    required String description,
    required double pricePerKg,
    String? category,
    String? imageUrl,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Not authenticated'};

      final response = await http.put(
        Uri.parse('$_baseUrl/admin/services/$serviceId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'description': description,
          'price_per_kg': pricePerKg,
          'category': category,
          'image_url': imageUrl,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)['data']};
      }

      return {'success': false, 'message': 'Failed to update service (${response.statusCode})'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  /// Deletes a service.
  static Future<Map<String, dynamic>> deleteService(int serviceId) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Not authenticated'};

      final response = await http.delete(
        Uri.parse('$_baseUrl/admin/services/$serviceId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {'success': true};
      }

      return {'success': false, 'message': 'Failed to delete service (${response.statusCode})'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}
