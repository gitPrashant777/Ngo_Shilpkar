class ChatRequestModel {
  final String id;
  final String requesterId;
  final String topic;
  final String role;
  final String status;
  final String? chatSessionId;
  final DateTime? createdAt;
  
  // Added to support nested objects in Admin GET /requests API
  final String? requesterName;
  final String? requesterRole;

  ChatRequestModel({
    required this.id,
    required this.requesterId,
    required this.topic,
    required this.role,
    required this.status,
    this.chatSessionId,
    this.createdAt,
    this.requesterName,
    this.requesterRole,
  });

  factory ChatRequestModel.fromJson(Map<String, dynamic> json) {
    String reqId = '';
    String? reqName;
    String? reqRole;
    
    if (json['requester'] is String) {
      reqId = json['requester'];
    } else if (json['requester'] is Map) {
      reqId = json['requester']['_id'] ?? '';
      reqName = json['requester']['name'];
      reqRole = json['requester']['role'];
    }

    return ChatRequestModel(
      id: json['_id'] ?? '',
      requesterId: reqId,
      topic: json['topic'] ?? '',
      role: json['role'] ?? '',
      status: json['status'] ?? 'PENDING',
      chatSessionId: json['chatSessionId'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      requesterName: reqName,
      requesterRole: reqRole,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "requester": requesterId,
      "topic": topic,
      "role": role,
      "status": status,
      "chatSessionId": chatSessionId,
      "createdAt": createdAt?.toIso8601String(),
    };
  }
}

class PaginatedChatRequestsModel {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final List<ChatRequestModel> data;

  PaginatedChatRequestsModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.data,
  });

  factory PaginatedChatRequestsModel.fromJson(Map<String, dynamic> json) {
    return PaginatedChatRequestsModel(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => ChatRequestModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
