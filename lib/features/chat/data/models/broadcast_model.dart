class BroadcastModel {
  final String id;
  final String message;
  final String? category;
  final bool isEmergency;
  final Sender? sender;
  final DateTime createdAt;

  BroadcastModel({
    required this.id,
    required this.message,
    this.category,
    this.isEmergency = false,
    this.sender,
    required this.createdAt,
  });

  factory BroadcastModel.fromJson(Map<String, dynamic> json) {
    var senderData = json['sender'];
    Sender? parsedSender;

    if (senderData is Map<String, dynamic>) {
      parsedSender = Sender.fromJson(senderData);
    } else if (senderData is String) {
      parsedSender = Sender(id: senderData, name: 'Unknown');
    }

    return BroadcastModel(
      id: json['_id'] ?? '',
      message: json['message'] ?? '',
      category: json['category']?.toString(),
      isEmergency: json['isEmergency'] == true,
      sender: parsedSender,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }
}

class Sender {
  final String id;
  final String name;

  Sender({required this.id, required this.name});

  factory Sender.fromJson(Map<String, dynamic> json) {
    return Sender(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown',
    );
  }
}
