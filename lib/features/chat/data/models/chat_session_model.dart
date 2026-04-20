class ChatSessionModel {
  final String id;
  final String requesterId;
  final String responderId;
  final String topic;
  final String status;
  final DateTime? createdAt;
  final int unreadCount;

  // Added to support nested objects in Admin GET /sessions API
  final String? requesterName;
  final String? responderName;

  ChatSessionModel({
    required this.id,
    required this.requesterId,
    required this.responderId,
    required this.topic,
    required this.status,
    this.createdAt,
    this.requesterName,
    this.responderName,
    this.unreadCount = 0,
  });

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    String reqId = '';
    String? reqName;
    if (json['requester'] is String) {
      reqId = json['requester'];
    } else if (json['requester'] is Map) {
      reqId = json['requester']['_id'] ?? '';
      reqName = json['requester']['name'];
    }

    String resId = '';
    String? resName;
    if (json['responder'] is String) {
      resId = json['responder'];
    } else if (json['responder'] is Map) {
      resId = json['responder']['_id'] ?? '';
      resName = json['responder']['name'];
    }

    return ChatSessionModel(
      id: json['_id'] ?? '',
      requesterId: reqId,
      responderId: resId,
      topic: json['topic'] ?? '',
      status: json['status'] ?? 'ACTIVE',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      requesterName: reqName,
      responderName: resName,
      unreadCount: json['unreadCount'] is int
          ? json['unreadCount']
          : int.tryParse(json['unreadCount']?.toString() ?? '') ?? 0,
    );
  }
}

class PaginatedChatSessionsModel {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final List<ChatSessionModel> data;

  PaginatedChatSessionsModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.data,
  });

  factory PaginatedChatSessionsModel.fromJson(Map<String, dynamic> json) {
    return PaginatedChatSessionsModel(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => ChatSessionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
