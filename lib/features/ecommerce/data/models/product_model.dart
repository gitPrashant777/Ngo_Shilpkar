class ProductModel {
  final String id;
  final String name;
  final double price;
  final List<String> images;
  final String categoryId;
  final String? categoryName; // Added to store category name
  final bool isFeatured;
  final bool isActive;
  final String? description;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.images,
    required this.categoryId,
    this.categoryName,
    this.isFeatured = false,
    this.isActive = true,
    this.description,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    String catId = '';
    String? catName;

    // 1. Check 'category' field
    if (json['category'] != null) {
      if (json['category'] is Map) {
        catId = json['category']['_id'] ?? json['category']['id'] ?? '';
        catName = json['category']['name'];
      } else if (json['category'] is String) {
        catId = json['category'];
      }
    }

    // 2. Fallback to 'categoryId' field if catId is still empty
    if (catId.isEmpty && json['categoryId'] != null) {
      if (json['categoryId'] is String) {
        catId = json['categoryId'];
      } else if (json['categoryId'] is Map) {
         catId = json['categoryId']['_id'] ?? json['categoryId']['id'] ?? '';
         // Just in case categoryId field contains the object
      }
    }

    return ProductModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      categoryId: catId,
      categoryName: catName,
      isFeatured: json['isFeatured'] ?? false,
      isActive: json['isActive'] ?? true,
      description: json['description'] ?? json['desc'] ?? json['details'] ?? json['productDescription'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'price': price,
      'images': images,
      'category': categoryId, // Sending back as ID when updating/creating usually
      'isFeatured': isFeatured,
      'isActive': isActive,
      if (description != null) 'description': description,
    };
  }
}
