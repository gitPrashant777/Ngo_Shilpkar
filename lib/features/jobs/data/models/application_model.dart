import 'package:flutter/foundation.dart';

class ApplicationModel {
  final String id;
  final String jobId;
  final String fullName;
  final String email;
  final String mobile;
  final String resumeUrl;
  final String photoUrl;
  final String status;
  final String applicantType;
  final DateTime? createdAt;

  ApplicationModel({
    required this.id,
    required this.jobId,
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.resumeUrl,
    required this.photoUrl,
    required this.status,
    required this.applicantType,
    this.createdAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    debugPrint('📋 RAW APPLICATION JSON: $json');

    // Handle jobId that could be a string or a nested object
    String jobId = '';
    if (json["jobId"] is Map) {
      jobId = json["jobId"]["_id"]?.toString() ?? '';
    } else {
      jobId = json["jobId"]?.toString() ?? '';
    }

    // The API might nest applicant details inside "applicantId" or "userId"
    Map<String, dynamic> applicantData = {};
    if (json["applicantId"] is Map) {
      applicantData = json["applicantId"] as Map<String, dynamic>;
    } else if (json["userId"] is Map) {
      applicantData = json["userId"] as Map<String, dynamic>;
    }

    // Handle fullName: check top-level, then nested applicant, then firstName/lastName
    String fullName = json["fullName"]?.toString() ?? '';
    if (fullName.isEmpty) {
      fullName = applicantData["fullName"]?.toString() ?? '';
    }
    if (fullName.isEmpty) {
      final first = json["firstName"]?.toString() ?? applicantData["firstName"]?.toString() ?? '';
      final last = json["lastName"]?.toString() ?? applicantData["lastName"]?.toString() ?? '';
      fullName = '$first $last'.trim();
    }
    if (fullName.isEmpty) {
      // Try "name" field
      fullName = json["name"]?.toString() ?? applicantData["name"]?.toString() ?? '';
    }

    // Email: check top-level, then nested
    String email = json["email"]?.toString() ?? '';
    if (email.isEmpty) {
      email = applicantData["email"]?.toString() ?? '';
    }

    // Mobile: check top-level, then nested
    String mobile = json["mobile"]?.toString() ?? '';
    if (mobile.isEmpty) {
      mobile = applicantData["mobile"]?.toString() ?? 
               json["phone"]?.toString() ?? 
               applicantData["phone"]?.toString() ?? '';
    }

    // ID: check _id, then id
    String appId = json["_id"]?.toString() ?? json["id"]?.toString() ?? '';

    debugPrint('📋 PARSED: id=$appId, name=$fullName, email=$email, mobile=$mobile, status=${json["status"]}');

    return ApplicationModel(
      id: appId,
      jobId: jobId,
      fullName: fullName.isNotEmpty ? fullName : (json["applicantType"]?.toString() ?? "Applicant"),
      email: email,
      mobile: mobile,
      resumeUrl: json["resumeUrl"]?.toString() ?? "",
      photoUrl: json["photoUrl"]?.toString() ?? "",
      status: json["status"]?.toString() ?? "PENDING",
      applicantType: json["applicantType"]?.toString() ?? "GUEST",
      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"].toString())
          : null,
    );
  }
}

