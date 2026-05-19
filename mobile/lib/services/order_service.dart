import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class OrderService {
  static Future<String> _apiPath() => ApiConfig.resolveApiPath();

  static Future<String?> _getToken() async {
    return AuthService.getToken();
  }

  static Future<Map<String, dynamic>> createOrder({
    required int serviceId,
    String orderType = 'pickup',
    double? deliveryFee,
    required String pickupAddress,
    int? pickupBarangayId,
    String? pickupCity,
    DateTime? pickupDate,
    TimeOfDay? pickupTime,
    DateTime? deliveryDate,
    TimeOfDay? deliveryTime,
    String? notes,
    String? deliveryType,
    XFile? laundryPhoto,
    List<int>? addOnIds,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required. Please login again.',
        };
      }

      final body = <String, dynamic>{
        'service_id': serviceId,
        'type': orderType,
        'delivery_type': orderType,
        'delivery_fee': deliveryFee ?? 0,
        'pickup_address': pickupAddress,
        'payment_method': 'cod',
      };

      if (pickupBarangayId != null) {
        body['pickup_barangay_id'] = pickupBarangayId;
      }

      if (pickupCity != null && pickupCity.isNotEmpty) {
        body['pickup_city'] = pickupCity;
      }

      if (pickupDate != null) {
        body['pickup_date'] =
            '${pickupDate.year}-${pickupDate.month.toString().padLeft(2, '0')}-${pickupDate.day.toString().padLeft(2, '0')}';
      }

      if (pickupTime != null) {
        body['pickup_time'] =
            '${pickupTime.hour.toString().padLeft(2, '0')}:${pickupTime.minute.toString().padLeft(2, '0')}';
      }

      if (deliveryDate != null) {
        body['delivery_date'] =
            '${deliveryDate.year}-${deliveryDate.month.toString().padLeft(2, '0')}-${deliveryDate.day.toString().padLeft(2, '0')}';
      }

      if (deliveryTime != null) {
        body['delivery_time'] =
            '${deliveryTime.hour.toString().padLeft(2, '0')}:${deliveryTime.minute.toString().padLeft(2, '0')}';
      }

      if (notes != null && notes.isNotEmpty) {
        body['notes'] = notes;
      }

      if (addOnIds != null && addOnIds.isNotEmpty) {
        body['add_ons'] = addOnIds;
      }

      final uri = Uri.parse('${await _apiPath()}/orders');
      late final http.Response response;

      if (laundryPhoto != null) {
        final request = http.MultipartRequest('POST', uri)
          ..headers.addAll({
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          });

        body.forEach((key, value) {
          if (value is List) {
            for (var i = 0; i < value.length; i++) {
              request.fields['$key[$i]'] = value[i].toString();
            }
          } else if (value != null) {
            request.fields[key] = value.toString();
          }
        });

        request.files.add(
          http.MultipartFile.fromBytes(
            'laundry_photo',
            await laundryPhoto.readAsBytes(),
            filename: laundryPhoto.name,
          ),
        );

        final streamed = await request.send();
        response = await http.Response.fromStream(streamed);
      } else {
        response = await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        );
      }

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
        Uri.parse('${await _apiPath()}/orders'),
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
          'meta': data['meta'] ?? <String, dynamic>{},
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
        Uri.parse('${await _apiPath()}/orders/$orderId'),
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
          'meta': data['meta'] ?? <String, dynamic>{},
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

      final response = await http.patch(
        Uri.parse('${await _apiPath()}/orders/$orderId/cancel'),
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
