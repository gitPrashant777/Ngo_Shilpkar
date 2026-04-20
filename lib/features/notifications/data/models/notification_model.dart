class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final String? referenceId;
  final String? referenceModel;
  final String? category;
  final bool isEmergency;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.referenceId,
    this.referenceModel,
    this.category,
    this.isEmergency = false,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? '',
      referenceId: json['referenceId']?.toString(),
      referenceModel: json['referenceModel']?.toString(),
      category: json['category']?.toString(),
      isEmergency: json['isEmergency'] == true,
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'body': body,
      'type': type,
      'referenceId': referenceId,
      'referenceModel': referenceModel,
      'category': category,
      'isEmergency': isEmergency,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
