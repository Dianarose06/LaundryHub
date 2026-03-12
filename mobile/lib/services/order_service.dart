import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  // For Android emulator use 10.0.2.2 to reach host machine.
  // Change to your machine's IP if testing on a physical device.
  static const String _baseUrl = 'http://localhost:8000/api';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, dynamic>> createOrder({
    required int serviceId,
    required double weightKg,
    required String pickupAddress,
    DateTime? pickupDate,
    TimeOfDay? pickupTime,
    DateTime? deliveryDate,
    TimeOfDay? deliveryTime,
    String? notes,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required. Please login again.',
        };
      }

      final body = {
        'service_id': serviceId,
        'weight_kg': weightKg,
        'pickup_address': pickupAddress,
        if (pickupDate != null) 
          'pickup_date': '${pickupDate.year}-${pickupDate.month.toString().padLeft(2, '0')}-${pickupDate.day.toString().padLeft(2, '0')}',
        if (pickupTime != null) 
          'pickup_time': '${pickupTime.hour.toString().padLeft(2, '0')}:${pickupTime.minute.toString().padLeft(2, '0')}',
        if (deliveryDate != null) 
          'delivery_date': '${deliveryDate.year}-${deliveryDate.month.toString().padLeft(2, '0')}-${deliveryDate.day.toString().padLeft(2, '0')}',
        if (deliveryTime != null) 
          'delivery_time': '${deliveryTime.hour.toString().padLeft(2, '0')}:${deliveryTime.minute.toString().padLeft(2, '0')}',
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Order placed successfully!',
          'data': data['order'] ?? data['data'],
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

  static Future<Map<String, dynamic>> getOrders() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required. Please login again.',
        };
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/orders'),
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
          'data': data['orders'] ?? data['data'] ?? [],
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

  static Future<Map<String, dynamic>> getOrderDetails(int orderId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required. Please login again.',
        };
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/orders/$orderId'),
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
          'data': data['order'] ?? data['data'],
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

  static Future<Map<String, dynamic>> cancelOrder(int orderId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required. Please login again.',
        };
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/orders/$orderId'),
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
          'message': data['message'] ?? 'Order cancelled successfully.',
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
    if (data['message'] != null) return data['message'] as String;
    if (data['error'] != null) return data['error'] as String;
    if (data['errors'] != null) {
      final errors = data['errors'] as Map<String, dynamic>;
      final firstError = errors.values.first;
      if (firstError is List && firstError.isNotEmpty) {
        return firstError.first as String;
      }
      return firstError.toString();
    }
    return 'An error occurred. Please try again.';
  }
}
