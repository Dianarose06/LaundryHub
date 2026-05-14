class CustomerProfile {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? profilePictureUrl;
  final String? bio;
  final String? address;
  final String? city;
  final String? zipCode;
  final String? country;
  final String? dateOfBirth;
  final String? gender;
  final String preferredLanguage;
  final bool notificationsEnabled;
  final int loyaltyPoints;
  final String? emailVerifiedAt;
  final String? profileCompletedAt;
  final String createdAt;

  CustomerProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profilePictureUrl,
    this.bio,
    this.address,
    this.city,
    this.zipCode,
    this.country,
    this.dateOfBirth,
    this.gender,
    required this.preferredLanguage,
    required this.notificationsEnabled,
    required this.loyaltyPoints,
    this.emailVerifiedAt,
    this.profileCompletedAt,
    required this.createdAt,
  });

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    try {
      return CustomerProfile(
        id: _asInt(json['id']),
        name: _asString(json['name']) ?? '',
        email: _asString(json['email']) ?? '',
        phone: _asString(json['phone']),
        profilePictureUrl: _asString(json['profile_picture_url']),
        bio: _asString(json['bio']),
        address: _asString(json['address']),
        city: _asString(json['city']),
        zipCode: _asString(json['zip_code']),
        country: _asString(json['country']),
        dateOfBirth: _asString(json['date_of_birth']),
        gender: _asString(json['gender']),
        preferredLanguage: _asString(json['preferred_language']) ?? 'en',
        notificationsEnabled: _asBool(json['notifications_enabled']),
        loyaltyPoints: _asInt(json['loyalty_points']),
        emailVerifiedAt: _asString(json['email_verified_at']),
        profileCompletedAt: _asString(json['profile_completed_at']),
        createdAt:
            _asString(json['created_at']) ?? DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw Exception('Error parsing profile: $e. Data: $json');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_picture_url': profilePictureUrl,
      'bio': bio,
      'address': address,
      'city': city,
      'zip_code': zipCode,
      'country': country,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'preferred_language': preferredLanguage,
      'notifications_enabled': notificationsEnabled,
      'loyalty_points': loyaltyPoints,
      'email_verified_at': emailVerifiedAt,
      'profile_completed_at': profileCompletedAt,
      'created_at': createdAt,
    };
  }

  CustomerProfile copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? profilePictureUrl,
    String? bio,
    String? address,
    String? city,
    String? zipCode,
    String? country,
    String? dateOfBirth,
    String? gender,
    String? preferredLanguage,
    bool? notificationsEnabled,
    int? loyaltyPoints,
    String? emailVerifiedAt,
    String? profileCompletedAt,
    String? createdAt,
  }) {
    return CustomerProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      bio: bio ?? this.bio,
      address: address ?? this.address,
      city: city ?? this.city,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      profileCompletedAt: profileCompletedAt ?? this.profileCompletedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool isProfileComplete() {
    return profileCompletedAt != null;
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    final normalized = value?.toString().toLowerCase().trim();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }

  static String? _asString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }
}

class ProfileCompletionStatus {
  final int completedPercentage;
  final int totalFields;
  final int completedFields;
  final Map<String, bool> fields;
  final bool isProfileComplete;

  ProfileCompletionStatus({
    required this.completedPercentage,
    required this.totalFields,
    required this.completedFields,
    required this.fields,
    required this.isProfileComplete,
  });

  factory ProfileCompletionStatus.fromJson(Map<String, dynamic> json) {
    return ProfileCompletionStatus(
      completedPercentage: CustomerProfile._asInt(json['completed_percentage']),
      totalFields: CustomerProfile._asInt(json['total_fields']),
      completedFields: CustomerProfile._asInt(json['completed_fields']),
      fields: _asBoolMap(json['fields']),
      isProfileComplete: CustomerProfile._asBool(json['is_profile_complete']),
    );
  }

  static Map<String, bool> _asBoolMap(dynamic value) {
    if (value is! Map) return {};

    return value.map(
      (key, mapValue) => MapEntry(
        key.toString(),
        CustomerProfile._asBool(mapValue),
      ),
    );
  }
}
