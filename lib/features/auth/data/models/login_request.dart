class LoginRequest {
  final String? email;
  final String? username;
  final String password;
  final String loginAsRole;

  LoginRequest({
    this.email,
    this.username,
    required this.password,
    required this.loginAsRole,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "password": password,
      "loginAsRole": loginAsRole,
    };

    if (email != null) {
      data["email"] = email;
    }

    if (username != null) {
      data["username"] = username;
    }

    return data;
  }
}
