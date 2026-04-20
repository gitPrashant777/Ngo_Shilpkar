import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../providers/status_provider.dart';
import '../../data/models/status_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// Story-ring widget shown on dashboards
class StatusRingRow extends StatelessWidget {
  const StatusRingRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StatusProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.statuses.isEmpty) {
          return const SizedBox(
            height: 90,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        if (provider.statuses.isEmpty) return const SizedBox.shrink();

        // Show ONE ring that represents all statuses. Tapping opens viewer at index 0.
        // Use the pinned status (if any) or the latest one as the thumbnail.
        final statuses = provider.statuses;
        final featured = statuses.firstWhere(
          (s) => s.pinned,
          orElse: () => statuses.first,
        );
          return SizedBox(
            height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _StatusRingTile(
                status: featured,
                count: statuses.length,
                onTap: () => _openViewer(context, statuses, 0),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openViewer(
      BuildContext context, List<StatusModel> statuses, int startIndex) {
    // Record impression (fire-and-forget, works for guests too)
    context.read<StatusProvider>().recordView(statuses[startIndex].id);

    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) =>
            StatusViewerScreen(statuses: statuses, initialIndex: startIndex),
      ),
    );
  }
}

// ─── Ring Tile ────────────────────────────────────────────────────────────────
class _StatusRingTile extends StatelessWidget {
  final StatusModel status;
  final VoidCallback onTap;
  final int count;

  const _StatusRingTile({required this.status, required this.onTap, this.count = 1});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: status.pinned
                        ? [AppColors.goldYellow, AppColors.darkOrange]
                        : [AppColors.profileBlue, AppColors.lightBlueScheme],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    color: Colors.grey.shade200,
                  ),
                  child: ClipOval(
                    child: status.isVideo
                        // Video URLs are .mp4 and can't render as images — show placeholder
                        ? Container(
                            color: const Color(0xFF1A1A2E),
                            child: const Center(
                              child: Icon(
                                Icons.play_circle_fill,
                                color: Colors.deepPurpleAccent,
                                size: 28,
                              ),
                            ),
                          )
                        : status.mediaUrl != null
                            ? Image.network(
                                status.mediaUrl!,
                                fit: BoxFit.cover,
                                loadingBuilder: (_, child, progress) =>
                                    progress == null
                                        ? child
                                        : const Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2),
                                            ),
                                          ),
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.image_not_supported,
                                      color: Colors.grey, size: 22),
                                ),
                              )
                            : const Icon(Icons.circle_notifications_outlined,
                                color: AppColors.profileBlue, size: 28),
                  ),
                ),
              ),
              // Count badge — shown when there are multiple statuses
              if (count > 1)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E5799),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        count > 9 ? '9+' : '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              // Video badge
              if (status.isVideo)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Colors.deepPurple,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.videocam,
                        size: 11, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
            SizedBox(
              width: 65,
            child: Text(
              status.caption ??
                  (status.isVideo ? l10n.video : l10n.updateStatus),
              style: const TextStyle(fontSize: 10, color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Full-screen Story Viewer ──────────────────────────────────────────────────
class StatusViewerScreen extends StatefulWidget {
  final List<StatusModel> statuses;
  final int initialIndex;

  const StatusViewerScreen({
    super.key,
    required this.statuses,
    required this.initialIndex,
  });

  @override
  State<StatusViewerScreen> createState() => _StatusViewerScreenState();
}

class _StatusViewerScreenState extends State<StatusViewerScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  int _currentIndex = 0;
  bool _isMuted = false;

  // Video
  VideoPlayerController? _videoCtrl;
  bool _videoReady = false;

  static const _imageDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _progressController =
        AnimationController(vsync: this, duration: _imageDuration)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) _nextStory();
          });
    _initPage(_currentIndex);
  }

  StatusModel get _current => widget.statuses[_currentIndex];

  Future<void> _initPage(int index) async {
    final s = widget.statuses[index];
    _progressController.reset();

    if (s.isVideo && s.mediaUrl != null) {
      await _disposeVideo();
      final ctrl =
          VideoPlayerController.networkUrl(Uri.parse(s.mediaUrl!));
      await ctrl.initialize();
      if (!mounted) return;
      ctrl.setVolume(_isMuted ? 0 : 1);
      ctrl.addListener(_onVideoUpdate);
      setState(() {
        _videoCtrl = ctrl;
        _videoReady = true;
      });
      // Set progress bar duration to video length
      _progressController.duration =
          ctrl.value.duration > Duration.zero
              ? ctrl.value.duration
              : _imageDuration;
      ctrl.play();
      _progressController.forward();
    } else {
      await _disposeVideo();
      setState(() => _videoReady = false);
      _progressController.duration = _imageDuration;
      _progressController.forward();
    }
  }

  void _onVideoUpdate() {
    if (!mounted) return;
    final ctrl = _videoCtrl;
    if (ctrl == null) return;
    if (ctrl.value.position >= ctrl.value.duration &&
        ctrl.value.duration > Duration.zero) {
      _nextStory();
    }
  }

  Future<void> _disposeVideo() async {
    _videoCtrl?.removeListener(_onVideoUpdate);
    await _videoCtrl?.dispose();
    _videoCtrl = null;
    _videoReady = false;
  }

  void _nextStory() {
    if (_currentIndex < widget.statuses.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 250), curve: Curves.easeIn);
    } else {
      Navigator.pop(context);
    }
  }

  void _prevStory() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 250), curve: Curves.easeIn);
    }
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    _videoCtrl?.setVolume(_isMuted ? 0 : 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _videoCtrl?.removeListener(_onVideoUpdate);
    _videoCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: (details) {
          final half = size.width / 2;
          if (details.localPosition.dx < half) {
            _prevStory();
          } else {
            _nextStory();
          }
        },
        child: Stack(
          children: [
            // ── Page view ────────────────────────────────────────────────────
            PageView.builder(
              controller: _pageController,
              itemCount: widget.statuses.length,
              onPageChanged: (idx) {
                setState(() => _currentIndex = idx);
                _initPage(idx);
              },
              itemBuilder: (_, index) {
                final s = widget.statuses[index];
                return _buildStoryContent(s);
              },
            ),

            // ── Top: progress bars ────────────────────────────────────────────
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: Row(
                      children: List.generate(widget.statuses.length, (i) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            height: 3,
                            child: i < _currentIndex
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  )
                                : i == _currentIndex
                                    ? AnimatedBuilder(
                                        animation: _progressController,
                                        builder: (_, __) =>
                                            LinearProgressIndicator(
                                          value: _progressController.value,
                                          backgroundColor: Colors.white30,
                                          valueColor:
                                              const AlwaysStoppedAnimation(
                                                  Colors.white),
                                          minHeight: 3,
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white30,
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // ── Header: avatar + title + date + close + mute ──────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: Row(
                      children: [
                        // Circular avatar
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white60, width: 1.5),
                            color: Colors.white24,
                          ),
                          child: ClipOval(
                            child: _current.mediaUrl != null
                                ? Image.network(
                                    _current.mediaUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                        Icons.person,
                                        color: Colors.white60,
                                        size: 20),
                                  )
                                : const Icon(Icons.campaign_rounded,
                                    color: Colors.white60, size: 20),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Title + date
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _current.caption?.isNotEmpty == true
                                    ? _current.caption!
                                    : 'Our Work',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  shadows: [
                                    Shadow(
                                        blurRadius: 4,
                                        color: Colors.black87)
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 1),
                              Text(
                                _formatHeaderDate(_current.createdAt),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  shadows: [
                                    Shadow(
                                        blurRadius: 4,
                                        color: Colors.black87)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Mute (video only)
                        if (_current.isVideo && _videoReady)
                          GestureDetector(
                            onTap: _toggleMute,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.black38,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isMuted
                                    ? Icons.volume_off
                                    : Icons.volume_up,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        // Close
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.black38,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom: thumbnail strip ───────────────────────────────────────
            if (widget.statuses.length > 1)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.statuses.length > 5
                            ? 5
                            : widget.statuses.length,
                        (i) {
                          // Centre the strip around the current index
                          final total = widget.statuses.length;
                          final half = (total > 5 ? 5 : total) ~/ 2;
                          int si = (_currentIndex - half + i).clamp(0, total - 1);
                          final s = widget.statuses[si];
                          final isCurrent = si == _currentIndex;
                          return GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(si,
                                  duration:
                                      const Duration(milliseconds: 250),
                                  curve: Curves.easeIn);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              width: isCurrent ? 52 : 44,
                              height: isCurrent ? 52 : 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isCurrent
                                      ? Colors.white
                                      : Colors.white38,
                                  width: isCurrent ? 2.5 : 1.5,
                                ),
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: s.isVideo
                                        // Videos: dark bg + play icon (video URL can't be used as image)
                                        ? Container(
                                            color: const Color(0xFF1A1A2E),
                                            child: const Center(
                                              child: Icon(
                                                Icons.play_circle_fill,
                                                color: Colors.deepPurpleAccent,
                                                size: 20,
                                              ),
                                            ),
                                          )
                                        : s.mediaUrl != null
                                            ? Image.network(
                                                s.mediaUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Container(
                                                      color: Colors.grey.shade800,
                                                      child: const Icon(
                                                          Icons.image_not_supported,
                                                          color: Colors.grey,
                                                          size: 16),
                                                    ),
                                              )
                                            : Container(
                                                color: Colors.grey.shade800,
                                                child: const Icon(
                                                    Icons.campaign_rounded,
                                                    color: Colors.grey,
                                                    size: 18),
                                              ),
                                  ),
                                  // Show play overlay only for non-video (video already has icon in thumbnail)
                                  if (!s.isVideo && s.mediaUrl == null)
                                    const Center(
                                      child: Icon(Icons.play_circle_fill,
                                          color: Colors.white60, size: 18),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryContent(StatusModel s) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Media ─────────────────────────────────────────────────────────────
        if (s.isVideo)
          _buildVideoContent(s)
        else if (s.mediaUrl != null)
          Image.network(
            s.mediaUrl!,
            fit: BoxFit.contain,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : const Center(
                    child: CircularProgressIndicator(color: Colors.white)),
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image, color: Colors.white54, size: 60),
            ),
          )
        else
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.profileBlue, AppColors.lightBlueScheme],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Icon(Icons.campaign_rounded,
                  color: Colors.white60, size: 80),
            ),
          ),

        // ── Caption (bottom gradient overlay) ─────────────────────────────────
        if (s.caption != null && s.caption!.isNotEmpty)
          Positioned(
            bottom: widget.statuses.length > 1 ? 100 : 24,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.85),
                    Colors.transparent
                  ],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (s.pinned)
                    const Padding(
                      padding: EdgeInsets.only(right: 8, bottom: 2),
                      child: Icon(Icons.push_pin,
                          color: AppColors.goldYellow, size: 16),
                    ),
                  Expanded(
                    child: Text(
                      s.caption!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        shadows: [
                          Shadow(
                              blurRadius: 4.0,
                              color: Colors.black87,
                              offset: Offset(1.0, 1.0)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoContent(StatusModel s) {
    if (!_videoReady || _videoCtrl == null || s.id != _current.id) {
      // Loading / not yet initialized
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }
    return Container(
      color: Colors.black,
      child: Center(
        child: AspectRatio(
          aspectRatio: _videoCtrl!.value.aspectRatio,
          child: VideoPlayer(_videoCtrl!),
        ),
      ),
    );
  }

  String _formatHeaderDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
