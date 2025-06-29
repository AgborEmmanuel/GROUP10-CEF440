
class User {
  final String userId;
  final String email;
  final String role;
  final String accountStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLogin;
  final bool emailVerified;

  User({
    required this.userId,
    required this.email,
    required this.role,
    required this.accountStatus,
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
    required this.emailVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      email: json['email'],
      role: json['role'],
      accountStatus: json['account_status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      lastLogin: json['last_login'] != null ? DateTime.parse(json['last_login']) : null,
      emailVerified: json['email_verified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'role': role,
      'account_status': accountStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'email_verified': emailVerified,
    };
  }
} 