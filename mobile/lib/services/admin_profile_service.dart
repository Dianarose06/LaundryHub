import 'package:dio/dio.dart';
import 'auth_service.dart';
import '../config/api_config.dart';

class AdminProfileService {
  final Dio _dio;
  final String baseUrl = ApiConfig.apiPath;

  AdminProfileService(this._dio);

  /// Get all customers
  Future<Map<String, dynamic>> getCustomers({
    int perPage = 20,
    int page = 1,
    String? search,
  }) async {
    try {
      final token = await AuthService.getToken();

      final queryParams = {
        'per_page': perPage,
        'page': page,
        '_t': DateTime.now().millisecondsSinceEpoch, // ✅ bust cache
        if (search != null) 'search': search,
      };

      final response = await _dio.get(
        '$baseUrl/admin/customers',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load customers');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get customer profile details
  Future<Map<String, dynamic>> getCustomerProfile(int userId) async {
    try {
      final token = await AuthService.getToken();

      final response = await _dio.get(
        '$baseUrl/admin/customers/$userId',
        queryParameters: {
          '_t': DateTime.now().millisecondsSinceEpoch, // ✅ bust cache
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception('Failed to load customer profile');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Update customer profile
  Future<Map<String, dynamic>> updateCustomerProfile(
    int userId, {
    String? name,
    String? firstName,
    String? lastName,
    String? middleInitial,
    String? phone,
    String? bio,
    String? address,
    String? city,
    String? zipCode,
    String? country,
    String? dateOfBirth,
    String? gender,
    String? preferredLanguage,
    bool? notificationsEnabled,
    String? emailVerifiedAt,
  }) async {
    try {
      final token = await AuthService.getToken();

      final Map<String, dynamic> data = {};

      if (name != null) data['name'] = name;
      if (firstName != null) data['first_name'] = firstName;
      if (lastName != null) data['last_name'] = lastName;
      if (middleInitial != null) data['middle_initial'] = middleInitial;
      if (phone != null) data['phone'] = phone;
      if (bio != null) data['bio'] = bio;
      if (address != null) data['address'] = address;
      if (city != null) data['city'] = city;
      if (zipCode != null) data['zip_code'] = zipCode;
      if (country != null) data['country'] = country;
      if (dateOfBirth != null) data['date_of_birth'] = dateOfBirth;
      if (gender != null) data['gender'] = gender;
      if (preferredLanguage != null)
        data['preferred_language'] = preferredLanguage;
      if (notificationsEnabled != null)
        data['notifications_enabled'] = notificationsEnabled;
      if (emailVerifiedAt != null) data['email_verified_at'] = emailVerifiedAt;

      final response = await _dio.put(
        '$baseUrl/admin/customers/$userId',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to update customer',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw Exception(e.response?.data['message'] ?? 'Validation failed');
      }
      rethrow;
    }
  }

  /// Get customer orders — always fetches fresh, no cache
  Future<Map<String, dynamic>> getCustomerOrders(
    int userId, {
    int perPage = 20,
    int page = 1,
  }) async {
    try {
      final token = await AuthService.getToken();

      final queryParams = {
        'per_page': perPage,
        'page': page,
        '_t': DateTime.now().millisecondsSinceEpoch, // ✅ bust cache every call
      };

      final response = await _dio.get(
        '$baseUrl/admin/customers/$userId/orders',
        queryParameters: queryParams,
        options: Options(
          receiveTimeout: const Duration(seconds: 15), // ✅ timeout
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Cache-Control': 'no-cache', // ✅ tell server no cache
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load customer orders');
      }
    } catch (e) {
      rethrow;
    }
  }
}
