class ApplicationModel {
  final String id;
  final String jobId;
  final String fullName;
  final String email;
  final String mobile;
  final String resumeUrl;
  final String status;
  final DateTime? createdAt;

  ApplicationModel({
    required this.id,
    required this.jobId,
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.resumeUrl,
    required this.status,
    this.createdAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json["_id"]?.toString() ?? "",
      jobId: json["jobId"]?.toString() ?? "",
      fullName: json["fullName"] ?? "",
      email: json["email"] ?? "",
      mobile: json["mobile"] ?? "",
      resumeUrl: json["resumeUrl"] ?? "",
      status: json["status"] ?? "PENDING",
      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"])
          : null,
    );
  }
}
