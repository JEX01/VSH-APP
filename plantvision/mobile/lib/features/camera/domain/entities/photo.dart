class Photo {
  final String id;
  final String userId;
  final String equipmentId;
  final String filename;
  final String? originalFilename;
  final String? s3Key;
  final String? thumbnailS3Key;
  final String mimeType;
  final int fileSize;
  final int? width;
  final int? height;
  final double? latitude;
  final double? longitude;
  final double? gpsAccuracy;
  final DateTime capturedAt;
  final String? deviceInfo;
  final String? notes;
  final PhotoStatus status;
  final String? rejectionReason;
  final String? approvedBy;
  final DateTime? approvedAt;
  final Map<String, dynamic> metadata;
  final String? checksum;
  final String? photoUrl;
  final String? thumbnailUrl;
  final String? username;
  final String? userFirstName;
  final String? userLastName;
  final String? equipmentCode;
  final String? equipmentName;
  final String? equipmentType;
  final String? plantCode;
  final String? plantName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Photo({
    required this.id,
    required this.userId,
    required this.equipmentId,
    required this.filename,
    this.originalFilename,
    this.s3Key,
    this.thumbnailS3Key,
    required this.mimeType,
    required this.fileSize,
    this.width,
    this.height,
    this.latitude,
    this.longitude,
    this.gpsAccuracy,
    required this.capturedAt,
    this.deviceInfo,
    this.notes,
    required this.status,
    this.rejectionReason,
    this.approvedBy,
    this.approvedAt,
    this.metadata = const {},
    this.checksum,
    this.photoUrl,
    this.thumbnailUrl,
    this.username,
    this.userFirstName,
    this.userLastName,
    this.equipmentCode,
    this.equipmentName,
    this.equipmentType,
    this.plantCode,
    this.plantName,
    required this.createdAt,
    required this.updatedAt,
  });

  String get displayName => originalFilename ?? filename;
  String get userFullName => 
      userFirstName != null && userLastName != null 
          ? '$userFirstName $userLastName'
          : username ?? 'Unknown User';
  String get equipmentDisplayName => 
      equipmentCode != null && equipmentName != null
          ? '$equipmentCode - $equipmentName'
          : 'Unknown Equipment';
  
  bool get hasLocation => latitude != null && longitude != null;
  bool get isPending => status == PhotoStatus.pending;
  bool get isApproved => status == PhotoStatus.approved;
  bool get isRejected => status == PhotoStatus.rejected;
  bool get isDeleted => status == PhotoStatus.deleted;
  
  String get fileSizeFormatted {
    if (fileSize < 1024) return '${fileSize}B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  Photo copyWith({
    String? id,
    String? userId,
    String? equipmentId,
    String? filename,
    String? originalFilename,
    String? s3Key,
    String? thumbnailS3Key,
    String? mimeType,
    int? fileSize,
    int? width,
    int? height,
    double? latitude,
    double? longitude,
    double? gpsAccuracy,
    DateTime? capturedAt,
    String? deviceInfo,
    String? notes,
    PhotoStatus? status,
    String? rejectionReason,
    String? approvedBy,
    DateTime? approvedAt,
    Map<String, dynamic>? metadata,
    String? checksum,
    String? photoUrl,
    String? thumbnailUrl,
    String? username,
    String? userFirstName,
    String? userLastName,
    String? equipmentCode,
    String? equipmentName,
    String? equipmentType,
    String? plantCode,
    String? plantName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Photo(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      equipmentId: equipmentId ?? this.equipmentId,
      filename: filename ?? this.filename,
      originalFilename: originalFilename ?? this.originalFilename,
      s3Key: s3Key ?? this.s3Key,
      thumbnailS3Key: thumbnailS3Key ?? this.thumbnailS3Key,
      mimeType: mimeType ?? this.mimeType,
      fileSize: fileSize ?? this.fileSize,
      width: width ?? this.width,
      height: height ?? this.height,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      gpsAccuracy: gpsAccuracy ?? this.gpsAccuracy,
      capturedAt: capturedAt ?? this.capturedAt,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      metadata: metadata ?? this.metadata,
      checksum: checksum ?? this.checksum,
      photoUrl: photoUrl ?? this.photoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      username: username ?? this.username,
      userFirstName: userFirstName ?? this.userFirstName,
      userLastName: userLastName ?? this.userLastName,
      equipmentCode: equipmentCode ?? this.equipmentCode,
      equipmentName: equipmentName ?? this.equipmentName,
      equipmentType: equipmentType ?? this.equipmentType,
      plantCode: plantCode ?? this.plantCode,
      plantName: plantName ?? this.plantName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'equipmentId': equipmentId,
      'filename': filename,
      'originalFilename': originalFilename,
      's3Key': s3Key,
      'thumbnailS3Key': thumbnailS3Key,
      'mimeType': mimeType,
      'fileSize': fileSize,
      'width': width,
      'height': height,
      'latitude': latitude,
      'longitude': longitude,
      'gpsAccuracy': gpsAccuracy,
      'capturedAt': capturedAt.millisecondsSinceEpoch,
      'deviceInfo': deviceInfo,
      'notes': notes,
      'status': status.name,
      'rejectionReason': rejectionReason,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.millisecondsSinceEpoch,
      'metadata': metadata,
      'checksum': checksum,
      'photoUrl': photoUrl,
      'thumbnailUrl': thumbnailUrl,
      'username': username,
      'userFirstName': userFirstName,
      'userLastName': userLastName,
      'equipmentCode': equipmentCode,
      'equipmentName': equipmentName,
      'equipmentType': equipmentType,
      'plantCode': plantCode,
      'plantName': plantName,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] as String,
      userId: json['user_id'] ?? json['userId'] as String,
      equipmentId: json['equipment_id'] ?? json['equipmentId'] as String,
      filename: json['filename'] as String,
      originalFilename: json['original_filename'] ?? json['originalFilename'] as String?,
      s3Key: json['s3_key'] ?? json['s3Key'] as String?,
      thumbnailS3Key: json['thumbnail_s3_key'] ?? json['thumbnailS3Key'] as String?,
      mimeType: json['mime_type'] ?? json['mimeType'] as String,
      fileSize: json['file_size'] ?? json['fileSize'] as int,
      width: json['width'] as int?,
      height: json['height'] as int?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      gpsAccuracy: (json['gps_accuracy'] ?? json['gpsAccuracy'] as num?)?.toDouble(),
      capturedAt: DateTime.parse((json['captured_at'] ?? json['capturedAt']) as String),
      deviceInfo: json['device_info'] ?? json['deviceInfo'] as String?,
      notes: json['notes'] as String?,
      status: PhotoStatus.fromString(json['status'] as String),
      rejectionReason: json['rejection_reason'] ?? json['rejectionReason'] as String?,
      approvedBy: json['approved_by'] ?? json['approvedBy'] as String?,
      approvedAt: json['approved_at'] != null || json['approvedAt'] != null
          ? DateTime.parse((json['approved_at'] ?? json['approvedAt']) as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      checksum: json['checksum'] as String?,
      photoUrl: json['photo_url'] ?? json['photoUrl'] as String?,
      thumbnailUrl: json['thumbnail_url'] ?? json['thumbnailUrl'] as String?,
      username: json['username'] as String?,
      userFirstName: json['first_name'] ?? json['userFirstName'] as String?,
      userLastName: json['last_name'] ?? json['userLastName'] as String?,
      equipmentCode: json['equipment_code'] ?? json['equipmentCode'] as String?,
      equipmentName: json['equipment_name'] ?? json['equipmentName'] as String?,
      equipmentType: json['equipment_type'] ?? json['equipmentType'] as String?,
      plantCode: json['plant_code'] ?? json['plantCode'] as String?,
      plantName: json['plant_name'] ?? json['plantName'] as String?,
      createdAt: DateTime.parse((json['created_at'] ?? json['createdAt']) as String),
      updatedAt: DateTime.parse((json['updated_at'] ?? json['updatedAt']) as String),
    );
  }
}

enum PhotoStatus {
  pending,
  approved,
  rejected,
  deleted;

  static PhotoStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return PhotoStatus.pending;
      case 'approved':
        return PhotoStatus.approved;
      case 'rejected':
        return PhotoStatus.rejected;
      case 'deleted':
        return PhotoStatus.deleted;
      default:
        throw ArgumentError('Invalid photo status: $status');
    }
  }

  String get displayName {
    switch (this) {
      case PhotoStatus.pending:
        return 'Pending Review';
      case PhotoStatus.approved:
        return 'Approved';
      case PhotoStatus.rejected:
        return 'Rejected';
      case PhotoStatus.deleted:
        return 'Deleted';
    }
  }
}