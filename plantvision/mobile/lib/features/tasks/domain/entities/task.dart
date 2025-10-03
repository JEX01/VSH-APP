class Task {
  final String id;
  final String assignedTo;
  final String assignedBy;
  final String equipmentId;
  final String title;
  final String? description;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime? dueDate;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? completionNotes;
  final String? completionPhotoId;
  final Map<String, dynamic> metadata;
  final String? assignedUsername;
  final String? assignedFirstName;
  final String? assignedLastName;
  final String? assignerUsername;
  final String? assignerFirstName;
  final String? assignerLastName;
  final String? equipmentCode;
  final String? equipmentName;
  final String? equipmentType;
  final String? plantCode;
  final String? plantName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.assignedTo,
    required this.assignedBy,
    required this.equipmentId,
    required this.title,
    this.description,
    required this.priority,
    required this.status,
    this.dueDate,
    this.startedAt,
    this.completedAt,
    this.completionNotes,
    this.completionPhotoId,
    this.metadata = const {},
    this.assignedUsername,
    this.assignedFirstName,
    this.assignedLastName,
    this.assignerUsername,
    this.assignerFirstName,
    this.assignerLastName,
    this.equipmentCode,
    this.equipmentName,
    this.equipmentType,
    this.plantCode,
    this.plantName,
    required this.createdAt,
    required this.updatedAt,
  });

  String get assignedUserFullName => 
      assignedFirstName != null && assignedLastName != null 
          ? '$assignedFirstName $assignedLastName'
          : assignedUsername ?? 'Unknown User';
          
  String get assignerFullName => 
      assignerFirstName != null && assignerLastName != null 
          ? '$assignerFirstName $assignerLastName'
          : assignerUsername ?? 'Unknown Manager';
          
  String get equipmentDisplayName => 
      equipmentCode != null && equipmentName != null
          ? '$equipmentCode - $equipmentName'
          : 'Unknown Equipment';

  bool get isPending => status == TaskStatus.pending;
  bool get isInProgress => status == TaskStatus.inProgress;
  bool get isCompleted => status == TaskStatus.completed;
  bool get isCancelled => status == TaskStatus.cancelled;
  
  bool get isOverdue => dueDate != null && 
      dueDate!.isBefore(DateTime.now()) && 
      !isCompleted && !isCancelled;
      
  Duration? get timeRemaining {
    if (dueDate == null || isCompleted || isCancelled) return null;
    final now = DateTime.now();
    if (dueDate!.isBefore(now)) return Duration.zero;
    return dueDate!.difference(now);
  }

  String get timeRemainingFormatted {
    final remaining = timeRemaining;
    if (remaining == null) return '';
    if (remaining == Duration.zero) return 'Overdue';
    
    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    final minutes = remaining.inMinutes % 60;
    
    if (days > 0) return '${days}d ${hours}h';
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  Task copyWith({
    String? id,
    String? assignedTo,
    String? assignedBy,
    String? equipmentId,
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
    DateTime? startedAt,
    DateTime? completedAt,
    String? completionNotes,
    String? completionPhotoId,
    Map<String, dynamic>? metadata,
    String? assignedUsername,
    String? assignedFirstName,
    String? assignedLastName,
    String? assignerUsername,
    String? assignerFirstName,
    String? assignerLastName,
    String? equipmentCode,
    String? equipmentName,
    String? equipmentType,
    String? plantCode,
    String? plantName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedBy: assignedBy ?? this.assignedBy,
      equipmentId: equipmentId ?? this.equipmentId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      completionNotes: completionNotes ?? this.completionNotes,
      completionPhotoId: completionPhotoId ?? this.completionPhotoId,
      metadata: metadata ?? this.metadata,
      assignedUsername: assignedUsername ?? this.assignedUsername,
      assignedFirstName: assignedFirstName ?? this.assignedFirstName,
      assignedLastName: assignedLastName ?? this.assignedLastName,
      assignerUsername: assignerUsername ?? this.assignerUsername,
      assignerFirstName: assignerFirstName ?? this.assignerFirstName,
      assignerLastName: assignerLastName ?? this.assignerLastName,
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
      'assignedTo': assignedTo,
      'assignedBy': assignedBy,
      'equipmentId': equipmentId,
      'title': title,
      'description': description,
      'priority': priority.name,
      'status': status.name,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'startedAt': startedAt?.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'completionNotes': completionNotes,
      'completionPhotoId': completionPhotoId,
      'metadata': metadata,
      'assignedUsername': assignedUsername,
      'assignedFirstName': assignedFirstName,
      'assignedLastName': assignedLastName,
      'assignerUsername': assignerUsername,
      'assignerFirstName': assignerFirstName,
      'assignerLastName': assignerLastName,
      'equipmentCode': equipmentCode,
      'equipmentName': equipmentName,
      'equipmentType': equipmentType,
      'plantCode': plantCode,
      'plantName': plantName,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      assignedTo: json['assigned_to'] ?? json['assignedTo'] as String,
      assignedBy: json['assigned_by'] ?? json['assignedBy'] as String,
      equipmentId: json['equipment_id'] ?? json['equipmentId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      priority: TaskPriority.fromString(json['priority'] as String),
      status: TaskStatus.fromString(json['status'] as String),
      dueDate: json['due_date'] != null || json['dueDate'] != null
          ? DateTime.parse((json['due_date'] ?? json['dueDate']) as String)
          : null,
      startedAt: json['started_at'] != null || json['startedAt'] != null
          ? DateTime.parse((json['started_at'] ?? json['startedAt']) as String)
          : null,
      completedAt: json['completed_at'] != null || json['completedAt'] != null
          ? DateTime.parse((json['completed_at'] ?? json['completedAt']) as String)
          : null,
      completionNotes: json['completion_notes'] ?? json['completionNotes'] as String?,
      completionPhotoId: json['completion_photo_id'] ?? json['completionPhotoId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      assignedUsername: json['assigned_username'] ?? json['assignedUsername'] as String?,
      assignedFirstName: json['assigned_first_name'] ?? json['assignedFirstName'] as String?,
      assignedLastName: json['assigned_last_name'] ?? json['assignedLastName'] as String?,
      assignerUsername: json['assigner_username'] ?? json['assignerUsername'] as String?,
      assignerFirstName: json['assigner_first_name'] ?? json['assignerFirstName'] as String?,
      assignerLastName: json['assigner_last_name'] ?? json['assignerLastName'] as String?,
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

enum TaskPriority {
  low,
  medium,
  high,
  urgent;

  static TaskPriority fromString(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return TaskPriority.low;
      case 'medium':
        return TaskPriority.medium;
      case 'high':
        return TaskPriority.high;
      case 'urgent':
        return TaskPriority.urgent;
      default:
        throw ArgumentError('Invalid task priority: $priority');
    }
  }

  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }
}

enum TaskStatus {
  pending,
  inProgress,
  completed,
  cancelled;

  static TaskStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return TaskStatus.pending;
      case 'in_progress':
      case 'inprogress':
        return TaskStatus.inProgress;
      case 'completed':
        return TaskStatus.completed;
      case 'cancelled':
        return TaskStatus.cancelled;
      default:
        throw ArgumentError('Invalid task status: $status');
    }
  }

  String get displayName {
    switch (this) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get apiValue {
    switch (this) {
      case TaskStatus.pending:
        return 'pending';
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.completed:
        return 'completed';
      case TaskStatus.cancelled:
        return 'cancelled';
    }
  }
}