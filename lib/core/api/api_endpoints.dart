class ApiEndpoints {
  static const String baseUrl = "https://ngo-project-r7cc.onrender.com/api";
      // "https://8hddfh1m-3000.inc1.devtunnels.ms/api";
  //

  // http://13.222.160.206:5002/
  //
  // https://ngo-project-r7cc.onrender.com/api

  // Auth
  static const String login = "/auth/login";
  static const String profileMe = "/profile/me";
  static const String forgotPassword = "/auth/superadmin-forgot-password";

  // Super Admin
  static const String createUser = "/onboarding/create-user";
}