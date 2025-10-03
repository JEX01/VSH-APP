class AuthUser {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final String? employeeId;
  final String? department;
  final String? plantArea;
  final String? phone;
  final DateTime? lastLoginAt;

  const AuthUser({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.employeeId,
    this.department,
    this.plantArea,
    this.phone,
    this.lastLoginAt,
  });

  String get fullName => '$firstName $lastName';
  
  bool get isWorker => role == UserRole.worker;
  bool get isManager => role == UserRole.manager;
  bool get isAdmin => role == UserRole.admin;

  AuthUser copyWith({
    String? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    UserRole? role,
    String? employeeId,
    String? department,
    String? plantArea,
    String? phone,
    DateTime? lastLoginAt,
  }) {
    return AuthUser(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      employeeId: employeeId ?? this.employeeId,
      department: department ?? this.department,
      plantArea: plantArea ?? this.plantArea,
      phone: phone ?? this.phone,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.name,
      'employeeId': employeeId,
      'department': department,
      'plantArea': plantArea,
      'phone': phone,
      'lastLoginAt': lastLoginAt?.millisecondsSinceEpoch,
    };
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      role: UserRole.fromString(json['role'] as String),
      employeeId: json['employeeId'] as String?,
      department: json['department'] as String?,
      plantArea: json['plantArea'] as String?,
      phone: json['phone'] as String?,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastLoginAt'] as int)
          : null,
    );
  }
}

enum UserRole {
  worker,
  manager,
  admin;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'worker':
        return UserRole.worker;
      case 'manager':
        return UserRole.manager;
      case 'admin':
        return UserRole.admin;
      default:
        throw ArgumentError('Invalid user role: $role');
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.worker:
        return 'Worker';
      case UserRole.manager:
        return 'Manager';
      case UserRole.admin:
        return 'Administrator';
    }
  }
}