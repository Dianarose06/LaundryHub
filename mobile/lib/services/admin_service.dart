import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AdminService {
  static String get _baseUrl => ApiConfig.apiPath;

  // Client-side caching to avoid redundant API calls
  static final Map<String, _CachedData> _cache = {};

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Load cached data from persistent storage on app startup
  static Future<void> loadPersistentCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheJson = prefs.getString('admin_cache_persistent');
      if (cacheJson != null) {
        final cacheData = jsonDecode(cacheJson) as Map<String, dynamic>;
        for (final entry in cacheData.entries) {
          final data = entry.value as Map<String, dynamic>;
          _cache[entry.key] = _CachedData(
            Map<String, dynamic>.from(data['data'] as Map),
            DateTime.parse(data['timestamp'] as String),
          );
        }
      }
    } catch (_) {
      // Silently fail if persistent cache is corrupted
    }
  }

  /// Save cache to persistent storage
  static Future<void> _savePersistentCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = <String, dynamic>{};
      for (final entry in _cache.entries) {
        cacheData[entry.key] = {
          'data': entry.value.data,
          'timestamp': entry.value.timestamp.toIso8601String(),
        };
      }
      await prefs.setString('admin_cache_persistent', jsonEncode(cacheData));
    } catch (_) {
      // Silently fail cache persistence
    }
  }

  /// Check if cache is still valid (TTL in seconds)
  static bool _isCacheValid(String key, int ttlSeconds) {
    if (!_cache.containsKey(key)) return false;
    final cached = _cache[key]!;
    final now = DateTime.now();
    return now.difference(cached.timestamp).inSeconds < ttlSeconds;
  }

  /// Get or fetch stats with caching (5 minute TTL)
  static Future<Map<String, dynamic>> fetchStats() async {
    const cacheKey = 'admin_stats';
    const ttl = 300; // 5 minutes

    if (_isCacheValid(cacheKey, ttl)) {
      return _cache[cacheKey]!.data;
    }

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
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final data = responseBody is Map<String, dynamic> ? responseBody : {'data': responseBody};
        
        final result = {'success': true, 'data': data};
        _cache[cacheKey] = _CachedData(result);
        await _savePersistentCache();
        return result;
      }

      return {'success': false, 'message': 'Failed to fetch stats (${response.statusCode}): ${response.body}'};
    } catch (e) {
      // Return stale cache if available
      if (_cache.containsKey(cacheKey)) {
        return _cache[cacheKey]!.data;
      }
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  /// Get or fetch recent orders with caching (3 minute TTL)
  static Future<Map<String, dynamic>> fetchRecentOrders() async {
    const cacheKey = 'admin_recent_orders';
    const ttl = 180; // 3 minutes

    if (_isCacheValid(cacheKey, ttl)) {
      return _cache[cacheKey]!.data;
    }

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
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final result = {'success': true, 'data': body['data'] as List<dynamic>};
        _cache[cacheKey] = _CachedData(result);
        await _savePersistentCache();
        return result;
      }

      return {'success': false, 'message': 'Failed to fetch orders (${response.statusCode})'};
    } catch (e) {
      // Return stale cache if available
      if (_cache.containsKey(cacheKey)) {
        return _cache[cacheKey]!.data;
      }
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  /// Fetches all orders for admin. Optionally filter by [status] ('pending','ongoing','ready', etc.)
  static Future<Map<String, dynamic>> fetchAllOrders({String? status, int page = 1, int perPage = 20}) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Not authenticated'};

      final params = {'page': page.toString(), 'per_page': perPage.toString()};
      if (status != null && status != 'all') {
        params['status'] = status;
      }

      final uri = Uri.parse('$_baseUrl/admin/orders').replace(queryParameters: params);

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return {'success': true, 'data': body['data'] as List<dynamic>, 'pagination': body['pagination']};
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

      if (response.statusCode == 200) {
        await clearCache(); // Invalidate admin cache when order status changes
        return {'success': true};
      }
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

  /// Fetches analytics data with caching (10 minute TTL)
  static Future<Map<String, dynamic>> fetchAnalytics() async {
    const cacheKey = 'admin_analytics';
    const ttl = 600; // 10 minutes

    if (_isCacheValid(cacheKey, ttl)) {
      return _cache[cacheKey]!.data;
    }

    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Not authenticated'};

      final response = await http.get(
        Uri.parse('$_baseUrl/admin/analytics'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final result = {'success': true, 'data': data};
        _cache[cacheKey] = _CachedData(result);
        await _savePersistentCache();
        return result;
      }

      return {'success': false, 'message': 'Failed to fetch analytics (${response.statusCode})'};
    } catch (e) {
      // Return stale cache if available
      if (_cache.containsKey(cacheKey)) {
        return _cache[cacheKey]!.data;
      }
      return {'success': false, 'message': 'Connection error'};
    }
  }

  /// Fetches all services (admin view — includes inactive) with caching (15 minute TTL)
  static Future<Map<String, dynamic>> fetchServices() async {
    const cacheKey = 'admin_services';
    const ttl = 900; // 15 minutes

    if (_isCacheValid(cacheKey, ttl)) {
      return _cache[cacheKey]!.data;
    }

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
        final result = {'success': true, 'data': body['data'] as List<dynamic>};
        _cache[cacheKey] = _CachedData(result);
        return result;
      }

      return {'success': false, 'message': 'Failed to fetch services (${response.statusCode})'};
    } catch (_) {
      return {'success': false, 'message': 'Connection error'};
    }
  }

  /// Clear all admin caches (call after mutations)
  static Future<void> clearCache() async {
    _cache.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_cache_persistent');
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
        await clearCache(); // Invalidate admin cache after creating service
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
        await clearCache(); // Invalidate admin cache after updating service
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
        await clearCache(); // Invalidate admin cache after deleting service
        return {'success': true};
      }

      return {'success': false, 'message': 'Failed to delete service (${response.statusCode})'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}

/// Helper class to store cached data with timestamp for TTL validation
class _CachedData {
  final Map<String, dynamic> data;
  final DateTime timestamp;

  _CachedData(this.data, [DateTime? customTimestamp]) 
    : timestamp = customTimestamp ?? DateTime.now();
}
