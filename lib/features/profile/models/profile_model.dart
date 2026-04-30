class ProfileModel {
  final String id;
  final String role;
  final String fullName;
  final String email;
  final String? phone;
  final String? cnic;
  final String? dateOfBirth;
  final String? avatarUrl;
  final String? region;
  final String? city;
  final double? latitude;
  final double? longitude;
  final String? createdAt;
  final String? updatedAt;

  const ProfileModel({
    required this.id,
    required this.role,
    required this.fullName,
    required this.email,
    this.phone,
    this.cnic,
    this.dateOfBirth,
    this.avatarUrl,
    this.region,
    this.city,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    id: json['id'] as String,
    role: json['role'] as String? ?? 'aid_worker',
    fullName: json['full_name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    phone: json['phone'] as String?,
    cnic: json['cnic'] as String?,
    dateOfBirth: json['date_of_birth'] as String?,
    avatarUrl: json['avatar_url'] as String?,
    region: json['region'] as String?,
    city: json['city'] as String?,
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    createdAt: json['created_at'] as String?,
    updatedAt: json['updated_at'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role,
    'full_name': fullName,
    'email': email,
    'phone': phone,
    'cnic': cnic,
    'date_of_birth': dateOfBirth,
    'avatar_url': avatarUrl,
    'region': region,
    'city': city,
    'latitude': latitude,
    'longitude': longitude,
  };

  ProfileModel copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? cnic,
    String? dateOfBirth,
    String? avatarUrl,
    String? region,
    String? city,
    double? latitude,
    double? longitude,
  }) => ProfileModel(
    id: id,
    role: role,
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    cnic: cnic ?? this.cnic,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    region: region ?? this.region,
    city: city ?? this.city,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

class AidWorkerProfileModel {
  final String id;
  final String? organizationId;
  final String designation;
  final String? department;
  final bool isTeamLead;
  // 'available' | 'busy' | 'off_duty' — see availability_status enum
  // added in step5 migration. Soft signal: gov dispatch sorts teams by
  // available-member ratio but never gates dispatch on this flag.
  final String availabilityStatus;
  final String? createdAt;
  final String? updatedAt;

  const AidWorkerProfileModel({
    required this.id,
    required this.designation,
    this.organizationId,
    this.department,
    this.isTeamLead = false,
    this.availabilityStatus = 'available',
    this.createdAt,
    this.updatedAt,
  });

  factory AidWorkerProfileModel.fromJson(Map<String, dynamic> json) =>
      AidWorkerProfileModel(
        id: json['id'] as String,
        organizationId: json['organization_id'] as String?,
        designation: json['designation'] as String? ?? '',
        department: json['department'] as String?,
        isTeamLead: json['is_team_lead'] as bool? ?? false,
        availabilityStatus:
            json['availability_status'] as String? ?? 'available',
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'organization_id': organizationId,
    'designation': designation,
    'department': department,
    'is_team_lead': isTeamLead,
    'availability_status': availabilityStatus,
  };

  AidWorkerProfileModel copyWith({
    String? designation,
    String? department,
    bool? isTeamLead,
    String? availabilityStatus,
  }) => AidWorkerProfileModel(
    id: id,
    organizationId: organizationId,
    designation: designation ?? this.designation,
    department: department ?? this.department,
    isTeamLead: isTeamLead ?? this.isTeamLead,
    availabilityStatus: availabilityStatus ?? this.availabilityStatus,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
