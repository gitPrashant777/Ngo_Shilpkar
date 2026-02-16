class UserModel {
  final String id;
  final String username;
  final String role;
  final String? email;
  final bool isActive;

  UserModel({
    required this.id,
    required this.username,
    required this.role,
    this.email,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'],
      username: json['username'],
      role: json['role'],
      email: json['email'],
      isActive: json['isActive'] ?? true,
    );
  }
}