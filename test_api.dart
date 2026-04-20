import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print("Logging in to get token...");
  var response = await http.post(
    Uri.parse("https://ngo-project-r7cc.onrender.com/api/auth/login"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"username": "BEN0003", "password": "vkLVs6CjWu", "loginAsRole": "BENEFICIARY"}),
  );

  print("Login Output: \${response.body}");
  var loginData = jsonDecode(response.body);
  var token = loginData['token'] ?? loginData['data']?['token'];
  print("Token: \$token");

  var profileResponse = await http.get(
    Uri.parse("https://ngo-project-r7cc.onrender.com/api/profile/me"),
    headers: {"Authorization": "Bearer \$token"},
  );
  print("Profile Output: \${profileResponse.body}");

  var schemesResponse = await http.get(
    Uri.parse("https://ngo-project-r7cc.onrender.com/api/schemes?page=1&limit=20"),
    headers: {"Authorization": "Bearer \$token"},
  );
  print("Schemes Output: \${schemesResponse.body}");
}
