class ReviewModel {
  final String id;
  final String productId;
  final int rating;
  final String comment;
  final String? userId; // Optional context ID string
  final String? userName; // User's full name extracted from userId object
  final String? createdAt; 

  ReviewModel({
    required this.id,
    required this.productId,
    required this.rating,
    required this.comment,
    this.userId,
    this.userName,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    String? finalUserName;
    String? finalUserId;

    if (json['userId'] is Map<String, dynamic>) {
      finalUserName = json['userId']['fullName'];
      finalUserId = json['userId']['_id'];
    } else if (json['userId'] is String) {
      finalUserId = json['userId'];
    }

    return ReviewModel(
      id: json['_id'] ?? '',
      productId: json['productId'] ?? '',
      rating: json['rating'] ?? json['stars'] ?? 0, 
      comment: json['comment'] ?? '',
      userId: finalUserId,
      userName: finalUserName,
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'productId': productId,
      'rating': rating,
      'comment': comment,
      if (userId != null) 'userId': userId,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}
