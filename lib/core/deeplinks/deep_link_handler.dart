class DeepLinkHandler {
  static Map<String, String>? parse(Uri uri) {
    final segments = uri.pathSegments;

    // https://ngo-project.com/share/:type/:id
    if ((uri.scheme == 'http' || uri.scheme == 'https') &&
        segments.length >= 3 &&
        segments[0] == 'share') {
      return {
        'type': segments[1],
        'id': segments[2],
      };
    }

    // Custom scheme: ngoapp://job/123
    if (uri.scheme.isNotEmpty) {
      final type = uri.host.isNotEmpty
          ? uri.host
          : (segments.isNotEmpty ? segments[0] : '');
      final id = uri.host.isNotEmpty
          ? (segments.isNotEmpty ? segments[0] : '')
          : (segments.length > 1 ? segments[1] : '');

      if (type.isNotEmpty && id.isNotEmpty) {
        return {'type': type, 'id': id};
      }
    }

    return null;
  }
}
