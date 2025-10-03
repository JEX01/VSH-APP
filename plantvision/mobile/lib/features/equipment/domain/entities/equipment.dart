class Equipment {
  final String id;
  final String plantId;
  final String equipmentCode;
  final String equipmentName;
  final String? equipmentType;
  final String? description;
  final String? manufacturer;
  final String? model;
  final String? serialNumber;
  final DateTime? installationDate;
  final String? locationArea;
  final double? latitude;
  final double? longitude;
  final String? qrCode;
  final Map<String, dynamic> specifications;
  final EquipmentStatus status;
  final String? plantCode;
  final String? plantName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Equipment({
    required this.id,
    required this.plantId,
    required this.equipmentCode,
    required this.equipmentName,
    this.equipmentType,
    this.description,
    this.manufacturer,
    this.model,
    this.serialNumber,
    this.installationDate,
    this.locationArea,
    this.latitude,
    this.longitude,
    this.qrCode,
    this.specifications = const {},
    required this.status,
    this.plantCode,
    this.plantName,
    required this.createdAt,
    required this.updatedAt,
  });

  String get displayName => '$equipmentCode - $equipmentName';
  
  String get fullLocation {
    final parts = <String>[];
    if (plantName != null) parts.add(plantName!);
    if (locationArea != null) parts.add(locationArea!);
    return parts.join(' - ');
  }

  bool get hasLocation => latitude != null && longitude != null;

  Equipment copyWith({
    String? id,
    String? plantId,
    String? equipmentCode,
    String? equipmentName,
    String? equipmentType,
    String? description,
    String? manufacturer,
    String? model,
    String? serialNumber,
    DateTime? installationDate,
    String? locationArea,
    double? latitude,
    double? longitude,
    String? qrCode,
    Map<String, dynamic>? specifications,
    EquipmentStatus? status,
    String? plantCode,
    String? plantName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Equipment(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      equipmentCode: equipmentCode ?? this.equipmentCode,
      equipmentName: equipmentName ?? this.equipmentName,
      equipmentType: equipmentType ?? this.equipmentType,
      description: description ?? this.description,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      installationDate: installationDate ?? this.installationDate,
      locationArea: locationArea ?? this.locationArea,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      qrCode: qrCode ?? this.qrCode,
      specifications: specifications ?? this.specifications,
      status: status ?? this.status,
      plantCode: plantCode ?? this.plantCode,
      plantName: plantName ?? this.plantName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantId': plantId,
      'equipmentCode': equipmentCode,
      'equipmentName': equipmentName,
      'equipmentType': equipmentType,
      'description': description,
      'manufacturer': manufacturer,
      'model': model,
      'serialNumber': serialNumber,
      'installationDate': installationDate?.millisecondsSinceEpoch,
      'locationArea': locationArea,
      'latitude': latitude,
      'longitude': longitude,
      'qrCode': qrCode,
      'specifications': specifications,
      'status': status.name,
      'plantCode': plantCode,
      'plantName': plantName,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'] as String,
      plantId: json['plant_id'] ?? json['plantId'] as String,
      equipmentCode: json['equipment_code'] ?? json['equipmentCode'] as String,
      equipmentName: json['equipment_name'] ?? json['equipmentName'] as String,
      equipmentType: json['equipment_type'] ?? json['equipmentType'] as String?,
      description: json['description'] as String?,
      manufacturer: json['manufacturer'] as String?,
      model: json['model'] as String?,
      serialNumber: json['serial_number'] ?? json['serialNumber'] as String?,
      installationDate: json['installation_date'] != null || json['installationDate'] != null
          ? DateTime.parse((json['installation_date'] ?? json['installationDate']) as String)
          : null,
      locationArea: json['location_area'] ?? json['locationArea'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      qrCode: json['qr_code'] ?? json['qrCode'] as String?,
      specifications: json['specifications'] as Map<String, dynamic>? ?? {},
      status: EquipmentStatus.fromString(json['status'] as String),
      plantCode: json['plant_code'] ?? json['plantCode'] as String?,
      plantName: json['plant_name'] ?? json['plantName'] as String?,
      createdAt: DateTime.parse((json['created_at'] ?? json['createdAt']) as String),
      updatedAt: DateTime.parse((json['updated_at'] ?? json['updatedAt']) as String),
    );
  }
}

enum EquipmentStatus {
  active,
  maintenance,
  inactive;

  static EquipmentStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return EquipmentStatus.active;
      case 'maintenance':
        return EquipmentStatus.maintenance;
      case 'inactive':
        return EquipmentStatus.inactive;
      default:
        throw ArgumentError('Invalid equipment status: $status');
    }
  }

  String get displayName {
    switch (this) {
      case EquipmentStatus.active:
        return 'Active';
      case EquipmentStatus.maintenance:
        return 'Under Maintenance';
      case EquipmentStatus.inactive:
        return 'Inactive';
    }
  }

  bool get isOperational => this == EquipmentStatus.active;
}