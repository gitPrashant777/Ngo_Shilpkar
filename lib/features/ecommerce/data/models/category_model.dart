class CategoryModel {
  final String id;
  final String name;
  final String? createdBy;

  CategoryModel({
    required this.id,
    required this.name,
    this.createdBy,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      createdBy: json['createdBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      if (createdBy != null) 'createdBy': createdBy,
    };
  }
}
