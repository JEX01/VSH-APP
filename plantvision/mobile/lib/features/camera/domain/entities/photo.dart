class Photo {
  final String id;
  final String localPath;
  final String? thumbnailPath;
  final String equipmentId;
  final String? equipmentName;
  final String? areaId;
  final String? areaName;
  final String? plantId;
  final String? plantName;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final DateTime capturedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? severity;
  final String? notes;
  final List<String>? tags;
  final bool isUploaded;
  final DateTime? uploadedAt;
  final String? serverUrl;
  final int retryCount;
  final DateTime? lastRetryAt;
  final String? errorMessage;
  final int? fileSize;
  final String? mimeType;

  const Photo({
    required this.id,
    required this.localPath,
    this.thumbnailPath,
    required this.equipmentId,
    this.equipmentName,
    this.areaId,
    this.areaName,
    this.plantId,
    this.plantName,
    this.latitude,
    this.longitude,
    this.locationName,
    required this.capturedAt,
    required this.createdAt,
    required this.updatedAt,
    this.severity,
    this.notes,
    this.tags,
    this.isUploaded = false,
    this.uploadedAt,
    this.serverUrl,
    this.retryCount = 0,
    this.lastRetryAt,
    this.errorMessage,
    this.fileSize,
    this.mimeType,
  });

  Photo copyWith({
    String? id,
    String? localPath,
    String? thumbnailPath,
    String? equipmentId,
    String? equipmentName,
    String? areaId,
    String? areaName,
    String? plantId,
    String? plantName,
    double? latitude,
    double? longitude,
    String? locationName,
    DateTime? capturedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? severity,
    String? notes,
    List<String>? tags,
    bool? isUploaded,
    DateTime? uploadedAt,
    String? serverUrl,
    int? retryCount,
    DateTime? lastRetryAt,
    String? errorMessage,
    int? fileSize,
    String? mimeType,
  }) {
    return Photo(
      id: id ?? this.id,
      localPath: localPath ?? this.localPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      equipmentId: equipmentId ?? this.equipmentId,
      equipmentName: equipmentName ?? this.equipmentName,
      areaId: areaId ?? this.areaId,
      areaName: areaName ?? this.areaName,
      plantId: plantId ?? this.plantId,
      plantName: plantName ?? this.plantName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      capturedAt: capturedAt ?? this.capturedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      severity: severity ?? this.severity,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      isUploaded: isUploaded ?? this.isUploaded,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      serverUrl: serverUrl ?? this.serverUrl,
      retryCount: retryCount ?? this.retryCount,
      lastRetryAt: lastRetryAt ?? this.lastRetryAt,
      errorMessage: errorMessage ?? this.errorMessage,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'local_path': localPath,
      'thumbnail_path': thumbnailPath,
      'equipment_id': equipmentId,
      'equipment_name': equipmentName,
      'area_id': areaId,
      'area_name': areaName,
      'plant_id': plantId,
      'plant_name': plantName,
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locationName,
      'captured_at': capturedAt.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'severity': severity,
      'notes': notes,
      'tags': tags?.join(','),
      'is_uploaded': isUploaded ? 1 : 0,
      'uploaded_at': uploadedAt?.millisecondsSinceEpoch,
      'server_url': serverUrl,
      'retry_count': retryCount,
      'last_retry_at': lastRetryAt?.millisecondsSinceEpoch,
      'error_message': errorMessage,
      'file_size': fileSize,
      'mime_type': mimeType,
    };
  }

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] as String,
      localPath: json['local_path'] as String,
      thumbnailPath: json['thumbnail_path'] as String?,
      equipmentId: json['equipment_id'] as String,
      equipmentName: json['equipment_name'] as String?,
      areaId: json['area_id'] as String?,
      areaName: json['area_name'] as String?,
      plantId: json['plant_id'] as String?,
      plantName: json['plant_name'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      locationName: json['location_name'] as String?,
      capturedAt: DateTime.fromMillisecondsSinceEpoch(json['captured_at'] as int),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updated_at'] as int),
      severity: json['severity'] as String?,
      notes: json['notes'] as String?,
      tags: json['tags'] != null ? (json['tags'] as String).split(',') : null,
      isUploaded: (json['is_uploaded'] as int) == 1,
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['uploaded_at'] as int)
          : null,
      serverUrl: json['server_url'] as String?,
      retryCount: json['retry_count'] as int? ?? 0,
      lastRetryAt: json['last_retry_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['last_retry_at'] as int)
          : null,
      errorMessage: json['error_message'] as String?,
      fileSize: json['file_size'] as int?,
      mimeType: json['mime_type'] as String?,
    );
  }
}
