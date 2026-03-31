import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laundryhub/models/profile_model.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class ProfileService {
  final Dio _dio;
  final String baseUrl = ApiConfig.apiPath;

  /// Returns the base host (e.g. 'http://localhost:8000') derived from baseUrl.
  String get _baseHost => ApiConfig.baseUrl;

  /// Builds a correct, fully-qualified image URL.
  /// Handles:
  ///   - Relative paths: 'storage/profile-pictures/xxx.jpg' → prepends baseHost
  ///   - Old absolute URLs with wrong host/port → replaces host with baseHost
  String? _buildImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;

    // Already a relative path (new format from updated controller)
    if (!url.startsWith('http')) {
      return '$_baseHost/$url';
    }

    // Old absolute URL — strip the scheme+host and rebuild with correct host
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    final correctUri = Uri.parse(
      _baseHost,
    ).replace(path: uri.path, query: uri.query.isNotEmpty ? uri.query : null);
    return correctUri.toString();
  }

  ProfileService(this._dio);

  /// Get current user's profile
  Future<CustomerProfile> getProfile() async {
    try {
      final token = await AuthService.getToken();
      final response = await _dio.get(
        '$baseUrl/profile',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        // Fix image URL port in case server-generated URL doesn't match API port
        if (data['profile_picture_url'] != null) {
          data['profile_picture_url'] = _buildImageUrl(
            data['profile_picture_url'] as String?,
          );
        }
        return CustomerProfile.fromJson(data);
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } on Exception catch (e) {
      throw Exception('Error loading profile: ${e.toString()}');
    } catch (e) {
      throw Exception('Unexpected error loading profile: ${e.toString()}');
    }
  }

  /// Update user's profile
  Future<CustomerProfile> updateProfile({
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

      final response = await _dio.put(
        '$baseUrl/profile',
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
        return CustomerProfile.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update profile');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw Exception(e.response?.data['message'] ?? 'Validation failed');
      }
      rethrow;
    }
  }

  /// Change current user's password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final token = await AuthService.getToken();

      final response = await _dio.post(
        '$baseUrl/profile/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception(
          response.data['message'] ?? 'Failed to change password',
        );
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message']?.toString();
      final errors = e.response?.data?['errors'];

      if (message != null && message.isNotEmpty) {
        throw Exception(message);
      }

      if (errors is Map && errors.isNotEmpty) {
        final firstKey = errors.keys.first;
        final firstError = errors[firstKey];
        if (firstError is List && firstError.isNotEmpty) {
          throw Exception(firstError.first.toString());
        }
      }

      throw Exception('Failed to change password');
    }
  }

  /// Get profile completion status
  Future<ProfileCompletionStatus> getCompletionStatus() async {
    try {
      final token = await AuthService.getToken();

      final response = await _dio.get(
        '$baseUrl/profile/completion-status',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return ProfileCompletionStatus.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load completion status');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Upload profile picture
  Future<String> uploadProfilePicture(
    XFile image, {
    List<int>? uploadBytes,
    String? fileName,
  }) async {
    try {
      final token = await AuthService.getToken();
      final parts = image.path.split(RegExp(r'[\\/]'));
      final resolvedFileName =
          fileName ??
          (image.name.isNotEmpty
              ? image.name
              : (parts.isNotEmpty ? parts.last : 'profile.jpg'));
      final bytes = uploadBytes ?? await image.readAsBytes();

      final formData = FormData.fromMap({
        'profile_picture': MultipartFile.fromBytes(
          bytes,
          filename: resolvedFileName,
        ),
      });

      final response = await _dio.post(
        '$baseUrl/profile/upload-picture',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final rawUrl = response.data['data']['profile_picture_url'] as String?;
        return _buildImageUrl(rawUrl) ?? rawUrl ?? '';
      } else {
        throw Exception(response.data['message'] ?? 'Failed to upload picture');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final data = e.response?.data;
        final message = data is Map<String, dynamic>
            ? (data['message']?.toString() ?? 'Invalid image file')
            : 'Invalid image file';
        final errors = data is Map<String, dynamic> ? data['errors'] : null;
        if (errors is Map && errors.isNotEmpty) {
          final firstKey = errors.keys.first;
          final firstError = errors[firstKey];
          if (firstError is List && firstError.isNotEmpty) {
            throw Exception(firstError.first.toString());
          }
        }
        throw Exception(message);
      }
      rethrow;
    }
  }

  /// Get public profile (for other users)
  Future<Map<String, dynamic>> getPublicProfile(int userId) async {
    try {
      final response = await _dio.get(
        '$baseUrl/profile/$userId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception('Profile not found');
      }
    } catch (e) {
      rethrow;
    }
  }
}
