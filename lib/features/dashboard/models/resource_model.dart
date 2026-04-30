class ResourceModel {
  final String id;
  final String name;
  final String resourceType;
  final String? description;
  final int quantityAvailable;
  final int quantityTotal;
  final String unit;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? managedByOrgId;
  final String? managedByUserId;
  final String? createdAt;
  final String? updatedAt;

  const ResourceModel({
    required this.id,
    required this.name,
    required this.resourceType,
    this.description,
    this.quantityAvailable = 0,
    this.quantityTotal = 0,
    this.unit = 'units',
    this.location,
    this.latitude,
    this.longitude,
    this.managedByOrgId,
    this.managedByUserId,
    this.createdAt,
    this.updatedAt,
  });

  factory ResourceModel.fromJson(Map<String, dynamic> json) => ResourceModel(
    id: json['id'] as String,
    name: json['name'] as String,
    resourceType: json['resource_type'] as String? ?? 'other',
    description: json['description'] as String?,
    quantityAvailable: (json['quantity_available'] as num?)?.toInt() ?? 0,
    quantityTotal: (json['quantity_total'] as num?)?.toInt() ?? 0,
    unit: json['unit'] as String? ?? 'units',
    location: json['location'] as String?,
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    managedByOrgId: json['managed_by_org_id'] as String?,
    managedByUserId: json['managed_by_user_id'] as String?,
    createdAt: json['created_at'] as String?,
    updatedAt: json['updated_at'] as String?,
  );

  Map<String, dynamic> toInsertJson() => {
    'name': name,
    'resource_type': resourceType,
    'description': description,
    'quantity_available': quantityAvailable,
    'quantity_total': quantityTotal,
    'unit': unit,
    'location': location,
    'latitude': latitude,
    'longitude': longitude,
    'managed_by_org_id': managedByOrgId,
    'managed_by_user_id': managedByUserId,
  };

  double get utilizationRate {
    if (quantityTotal == 0) return 0;
    final used = quantityTotal - quantityAvailable;
    return (used / quantityTotal).clamp(0.0, 1.0);
  }

  bool get isLowStock => quantityTotal > 0 && utilizationRate > 0.8;

  String get resourceTypeDisplay {
    switch (resourceType) {
      case 'food':
        return 'Food';
      case 'water':
        return 'Water';
      case 'medical_kits':
        return 'Medical Kits';
      case 'other':
        return 'Other';
      default:
        return resourceType;
    }
  }

  ResourceModel copyWith({
    String? name,
    String? resourceType,
    String? description,
    int? quantityAvailable,
    int? quantityTotal,
    String? unit,
    String? location,
    double? latitude,
    double? longitude,
  }) =>
      ResourceModel(
        id: id,
        name: name ?? this.name,
        resourceType: resourceType ?? this.resourceType,
        description: description ?? this.description,
        quantityAvailable: quantityAvailable ?? this.quantityAvailable,
        quantityTotal: quantityTotal ?? this.quantityTotal,
        unit: unit ?? this.unit,
        location: location ?? this.location,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        managedByOrgId: managedByOrgId,
        managedByUserId: managedByUserId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
