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
