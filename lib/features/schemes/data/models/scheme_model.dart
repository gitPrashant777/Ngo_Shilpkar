// lib/features/schemes/data/models/scheme_model.dart

class SchemeModel {
  final String id;
  final String name;
  final String description;
  final List<String> benefits;
  final String status;
  final double price;
  final bool isActive;

  SchemeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.benefits,
    required this.status,
    required this.price,
    required this.isActive,
  });

  factory SchemeModel.fromJson(Map<String, dynamic> json) {
    return SchemeModel(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      benefits: List<String>.from(json["benefits"] ?? []),
      status: json["status"] ?? "",
      price: (json["price"] ?? 0).toDouble(),
      isActive: json["isActive"] ?? true,
    );
  }
}
