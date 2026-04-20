import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  // We need a valid job ID first. Let's get one from the published jobs list.
  print("Fetching jobs...");
  var jobsResponse = await http.get(
    Uri.parse("https://ngo-project-r7cc.onrender.com/api/jobs/public?page=1&limit=10"),
  );
  var jobsData = jsonDecode(jobsResponse.body);
  var jobsList = jobsData['data'] ?? jobsData['jobs'] ?? [];
  if (jobsList.isEmpty) {
    jobsResponse = await http.get(
      Uri.parse("https://ngo-project-r7cc.onrender.com/api/jobs?page=1&limit=10"),
    );
     jobsData = jsonDecode(jobsResponse.body);
     jobsList = jobsData['data'] ?? jobsData['jobs'] ?? [];
     if (jobsList.isEmpty) {
       print("Still no jobs. Response: \${jobsResponse.body}");
       return;
     }
  }
  
  var jobId = jobsList[0]['_id'];
  print("Testing job application on Job ID: \$jobId");
  
  var payloadWithoutUserId = {
    'firstName': 'Guest',
    'lastName': 'User',
    'dob': '1990-01-01',
    'mobile': '9999999999',
    'email': 'guest@test.com',
    'location': {
      'state': 'Test State',
      'district': 'Test District',
      'taluka': 'Test Taluka',
      'village': 'Test Village',
      'address': 'Test Address',
    },
    'highestQualification': 'B.Tech',
    'experienceLevel': 'Fresher',
    'jobType': 'Full-time',
    'availability': ['field'],
    'isGuest': true,
  };
  
  print("Sending payload without userId...");
  var resNoUser = await http.post(
    Uri.parse("https://ngo-project-r7cc.onrender.com/api/applications/\$jobId/apply"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(payloadWithoutUserId),
  );
  print("Status: \${resNoUser.statusCode}");
  print("Body: \${resNoUser.body}");
}
