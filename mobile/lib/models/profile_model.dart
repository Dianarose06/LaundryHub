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
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String?,
        profilePictureUrl: json['profile_picture_url'] as String?,
        bio: json['bio'] as String?,
        address: json['address'] as String?,
        city: json['city'] as String?,
        zipCode: json['zip_code'] as String?,
        country: json['country'] as String?,
        dateOfBirth: json['date_of_birth'] as String?,
        gender: json['gender'] as String?,
        preferredLanguage: json['preferred_language'] as String? ?? 'en',
        notificationsEnabled: json['notifications_enabled'] == true || json['notifications_enabled'] == 1,
        loyaltyPoints: json['loyalty_points'] as int? ?? 0,
        emailVerifiedAt: json['email_verified_at'] as String?,
        profileCompletedAt: json['profile_completed_at'] as String?,
        createdAt: (json['created_at'] as String?) ?? DateTime.now().toIso8601String(),
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
      completedPercentage: json['completed_percentage'] as int,
      totalFields: json['total_fields'] as int,
      completedFields: json['completed_fields'] as int,
      fields: Map<String, bool>.from(json['fields'] as Map),
      isProfileComplete: json['is_profile_complete'] as bool,
    );
  }
}
