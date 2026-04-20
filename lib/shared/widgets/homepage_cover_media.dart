import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class HomepageCoverMedia extends StatefulWidget {
  final String? imageUrl;
  final String? videoUrl;
  final String fallbackAsset;
  final double height;

  const HomepageCoverMedia({
    super.key,
    required this.fallbackAsset,
    this.imageUrl,
    this.videoUrl,
    this.height = 180,
  });

  @override
  State<HomepageCoverMedia> createState() => _HomepageCoverMediaState();
}

class _HomepageCoverMediaState extends State<HomepageCoverMedia> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  @override
  void didUpdateWidget(covariant HomepageCoverMedia oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeController();
      _initVideo();
    }
  }

  void _initVideo() {
    final url = widget.videoUrl;
    if (url == null || url.isEmpty) return;
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller?.play();
        }
      });
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showVideo = _controller != null && _controller!.value.isInitialized;
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (showVideo)
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.size.width,
                    height: _controller!.value.size.height,
                    child: VideoPlayer(_controller!),
                  ),
                ),
              )
            else if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
              Image.network(
                widget.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, _, __) => Image.asset(
                  widget.fallbackAsset,
                  fit: BoxFit.cover,
                ),
              )
            else
              Image.asset(
                widget.fallbackAsset,
                fit: BoxFit.cover,
              ),
          ],
        ),
      ),
    );
  }
}
