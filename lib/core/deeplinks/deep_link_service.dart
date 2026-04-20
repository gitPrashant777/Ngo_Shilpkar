import 'dart:async';
import 'package:app_links/app_links.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;

  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  void Function(Uri uri)? onDeepLinkReceived;

  Future<void> init() async {
    // Handle cold start
    final uri = await _appLinks.getInitialAppLink();
    if (uri != null) {
      onDeepLinkReceived?.call(uri);
    }

    // Handle runtime links
    _sub = _appLinks.uriLinkStream.listen((uri) {
      onDeepLinkReceived?.call(uri);
    });
  }

  void dispose() {
    _sub?.cancel();
  }
}
