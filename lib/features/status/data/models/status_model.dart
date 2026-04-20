class StatusModel {
  final String id;
  final String? caption;
  final String? mediaUrl;
  final String mediaType; // 'image' | 'video' | 'none'
  final bool pinned;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const StatusModel({
    required this.id,
    this.caption,
    this.mediaUrl,
    this.mediaType = 'none',
    required this.pinned,
    required this.createdAt,
    this.expiresAt,
  });

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
      id: json['id'] ?? json['_id'] ?? '',
      caption: json['caption'],
      mediaUrl: json['mediaUrl'],
      mediaType: json['mediaType'] ?? 'none',
      pinned: json['pinned'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())
          : null,
    );
  }

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  bool get isVideo => mediaType == 'video';
  bool get isImage => mediaType == 'image';
}
