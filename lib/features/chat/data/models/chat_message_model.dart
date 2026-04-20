class ChatMessageModel {
  final String id;
  final String chatSessionId;
  final Sender sender;
  final String text;
  final String? fileUrl;
  final String? fileType;
  final DateTime? createdAt;

  ChatMessageModel({
    required this.id,
    required this.chatSessionId,
    required this.sender,
    required this.text,
    this.fileUrl,
    this.fileType,
    this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['_id'] ?? '',
      chatSessionId: json['chatSessionId'] ?? '',
      sender: Sender.fromJson(json['sender'] is Map<String, dynamic> ? json['sender'] : {'_id': json['sender']}),
      text: json['text'] ?? '',
      fileUrl: json['fileUrl'],
      fileType: json['fileType'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}

class Sender {
  final String id;
  final String name;
  final String role;

  Sender({
    required this.id,
    required this.name,
    required this.role,
  });

  factory Sender.fromJson(Map<String, dynamic> json) {
    return Sender(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'User',
      role: json['role']?.toString() ?? '',
    );
  }
}
