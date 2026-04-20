class UserJobApplicationModel {
  final String id;
  final String status;
  final String jobId;
  final String jobTitle;
  final String jobCity;
  final String organization;

  UserJobApplicationModel({
    required this.id,
    required this.status,
    required this.jobId,
    required this.jobTitle,
    required this.jobCity,
    required this.organization,
  });

  factory UserJobApplicationModel.fromJson(Map<String, dynamic> json) {
    final job = json["jobId"]; // Based on contract: jobId: { _id, title, city }
    
    return UserJobApplicationModel(
      id: json["_id"] ?? "",
      status: json["status"] ?? "PENDING",
      jobId: (job is Map) ? (job["_id"] ?? "") : "",
      jobTitle: (job is Map) ? (job["title"] ?? "") : "",
      jobCity: (job is Map) ? (job["city"] ?? "") : "",
      organization: (job is Map) ? (job["organization"] ?? "") : "",
    );
  }
}
