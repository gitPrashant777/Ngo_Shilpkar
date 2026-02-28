class JobModel {
  final String id;
  final String title;
  final String description;
  final String organization;
  final String city;
  final String category;
  final String status;
  final List<String> requiredSkills;
  final String duration;
  final String stipend;
  final DateTime? createdAt;

  JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.organization,
    required this.city,
    required this.category,
    required this.status,
    required this.requiredSkills,
    required this.duration,
    required this.stipend,
    this.createdAt,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      organization: json['organization'] ?? '',
      city: json['city'] ?? '',
      category: json['category'] ?? '',
      status: json['status'] ?? 'DRAFT',
      requiredSkills: (json['requiredSkills'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      duration: json['duration'] ?? '',
      stipend: json['stipend']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "description": description,
      "organization": organization,
      "city": city,
      "category": category,
      "status": status,
      "requiredSkills": requiredSkills,
      "duration": duration,
      "stipend": stipend,
    };
  }
}

class PaginatedJobsModel {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final List<JobModel> data;

  PaginatedJobsModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.data,
  });

  factory PaginatedJobsModel.fromJson(Map<String, dynamic> json) {
    return PaginatedJobsModel(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => JobModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
