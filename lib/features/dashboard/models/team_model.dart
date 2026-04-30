class TeamModel {
  final String id;
  final String name;
  final String? description;
  final String? teamLeadId;
  final String? organizationId;
  final String status;
  final List<String> specialization;
  final String? region;
  final double? latitude;
  final double? longitude;
  final int capacity;
  final String createdBy;
  final String? createdAt;
  final String? updatedAt;
  final int memberCount;
  final bool isApproved;
  final String? teamCode;

  const TeamModel({
    required this.id,
    required this.name,
    required this.createdBy,
    this.description,
    this.teamLeadId,
    this.organizationId,
    this.status = 'available',
    this.specialization = const [],
    this.region,
    this.latitude,
    this.longitude,
    this.capacity = 10,
    this.createdAt,
    this.updatedAt,
    this.memberCount = 0,
    this.isApproved = false,
    this.teamCode,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    final rawSpec = json['specialization'];
    return TeamModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      teamLeadId: json['team_lead_id'] as String?,
      organizationId: json['organization_id'] as String?,
      status: json['status'] as String? ?? 'available',
      specialization: rawSpec is List
          ? rawSpec.map((e) => e.toString()).toList()
          : const [],
      region: json['region'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      capacity: (json['capacity'] as num?)?.toInt() ?? 10,
      createdBy: json['created_by'] as String? ?? '',
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      memberCount: (json['member_count'] as num?)?.toInt() ?? 0,
      isApproved: json['is_approved'] as bool? ?? false,
      teamCode: json['team_code'] as String?,
    );
  }

  TeamModel copyWith({
    String? name,
    String? description,
    String? teamLeadId,
    String? status,
    List<String>? specialization,
    String? region,
    double? latitude,
    double? longitude,
    int? capacity,
    int? memberCount,
    bool? isApproved,
    String? teamCode,
  }) =>
      TeamModel(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        teamLeadId: teamLeadId ?? this.teamLeadId,
        organizationId: organizationId,
        status: status ?? this.status,
        specialization: specialization ?? this.specialization,
        region: region ?? this.region,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        capacity: capacity ?? this.capacity,
        createdBy: createdBy,
        createdAt: createdAt,
        updatedAt: updatedAt,
        memberCount: memberCount ?? this.memberCount,
        isApproved: isApproved ?? this.isApproved,
        teamCode: teamCode ?? this.teamCode,
      );

  String get statusDisplay {
    switch (status) {
      case 'available':
        return 'Available';
      case 'deployed':
        return 'Deployed';
      case 'off_duty':
        return 'Off Duty';
      default:
        return status;
    }
  }
}
