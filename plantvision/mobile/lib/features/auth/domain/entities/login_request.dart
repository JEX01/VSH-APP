class LoginRequest {
  final String username;
  final String password;
  final String? fcmToken;

  const LoginRequest({
    required this.username,
    required this.password,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }
}