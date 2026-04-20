class MediaModel {
  final String url;
  final String key;

  MediaModel({required this.url, required this.key});

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      url: json['url'] ?? '',
      key: json['key'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'url': url, 'key': key};
}

class HomepageModel {
  final List<MediaModel> coverImages;
  final List<MediaModel> coverVideos;
  final String welcomeTitle;
  final String welcomeSubtitle;
  final bool welcomeVisible;
  final DateTime? updatedAt;

  HomepageModel({
    required this.coverImages,
    required this.coverVideos,
    required this.welcomeTitle,
    required this.welcomeSubtitle,
    required this.welcomeVisible,
    this.updatedAt,
  });

  factory HomepageModel.fromJson(Map<String, dynamic> json) {
    // Helper to handle mixed string/object lists
    List<MediaModel> parseMedia(dynamic raw) {
      if (raw is! List) return [];
      return raw.map((e) {
        if (e is Map<String, dynamic>) {
          return MediaModel.fromJson(e);
        } else if (e is String) {
          final uri = Uri.tryParse(e);
          // Extract the full path and remove the leading slash to get the S3 key
          String key = uri?.path ?? e;
          if (key.startsWith('/')) {
            key = key.substring(1);
          }
          return MediaModel(url: e, key: key);
        }
        return MediaModel(url: '', key: '');
      }).toList();
    }

    final welcome = json['welcomeSection'] as Map<String, dynamic>? ?? {};
    final isVisibleRaw = welcome['isVisible'];
    final bool isVisible = isVisibleRaw is bool
        ? isVisibleRaw
        : isVisibleRaw is String
            ? isVisibleRaw.toLowerCase() == 'true'
            : true;

    return HomepageModel(
      coverImages: parseMedia(json['coverImages']),
      coverVideos: parseMedia(json['coverVideos']),
      welcomeTitle: welcome['title'] ?? 'Welcome to Shilpkar Foundation',
      welcomeSubtitle:
          welcome['subtitle'] ?? 'Empowering communities with purpose driven actions',
      welcomeVisible: isVisible,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }
}
