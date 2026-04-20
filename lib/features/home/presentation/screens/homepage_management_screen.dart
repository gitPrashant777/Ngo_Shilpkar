import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../data/models/homepage_model.dart';
import '../providers/homepage_provider.dart';

class HomepageManagementScreen extends StatefulWidget {
  const HomepageManagementScreen({super.key});

  @override
  State<HomepageManagementScreen> createState() =>
      _HomepageManagementScreenState();
}

class _HomepageManagementScreenState extends State<HomepageManagementScreen> {
  final _titleCtrl = TextEditingController();
  final _subtitleCtrl = TextEditingController();
  bool _welcomeVisible = true;
  bool _isUploading = false;
  double _uploadProgress = 0;
  bool _uploadSheetShown = false;
  final ValueNotifier<double> _uploadProgressNotifier = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<HomepageProvider>();
      provider.fetchHomepage().then((_) {
        if (provider.homepage != null) {
          _titleCtrl.text = provider.homepage!.welcomeTitle;
          _subtitleCtrl.text = provider.homepage!.welcomeSubtitle;
          _welcomeVisible = provider.homepage!.welcomeVisible;
          if (mounted) setState(() {});
        }
      });
    });
  }

  @override

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _uploadProgressNotifier.dispose();
    super.dispose();
  }

  // ── Upload cover image ─────────────────────────────────────
  Future<void> _pickAndUpload() async {
    final provider = context.read<HomepageProvider>();
    final currentCount = provider.homepage?.coverImages.length ?? 0;

    if (currentCount >= 5) {
      _showSnack('Maximum 5 cover images allowed', Colors.orange);
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });
    _uploadProgressNotifier.value = 0;
    _showUploadSheet('Uploading image...');

    try {
      await provider.uploadCoverImage(
        picked.path,
        onProgress: (sent, total) {
          if (total <= 0) return;
          final percent = (sent / total) * 100;
          _uploadProgressNotifier.value = percent;
          if (mounted) setState(() => _uploadProgress = percent);
        },
      );
      _showSnack('✅ Cover image uploaded successfully', Colors.green);
    } catch (e) {
      _showSnack('❌ ${e.toString().replaceAll("Exception: ", "")}', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
        if (_uploadSheetShown) {
          Navigator.pop(context);
          _uploadSheetShown = false;
        }
      }
    }
  }

  // ── Replace cover image ─────────────────────────────────────
  Future<void> _replaceCoverImage(MediaModel oldImage) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null) return;

    setState(() => _isUploading = true);

    try {
      final provider = context.read<HomepageProvider>();
      await provider.uploadCoverImage(picked.path);
      await provider.deleteCoverImage(oldImage.key);
      _showSnack('✅ Image replaced successfully', Colors.green);
    } catch (e) {
      _showSnack('❌ Failed to replace: ${e.toString().replaceAll("Exception: ", "")}', Colors.red);
    } finally {
      setState(() => _isUploading = false);
    }
  }

  // ── Delete cover image ─────────────────────────────────────
  Future<void> _deleteCoverImage(MediaModel image) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Image?'),
        content: const Text('This will permanently remove this cover image.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await context.read<HomepageProvider>().deleteCoverImage(image.key);
      _showSnack('✅ Image deleted', Colors.green);
    } catch (e) {
      _showSnack('❌ ${e.toString().replaceAll("Exception: ", "")}', Colors.red);
    }
  }

  // ── Video Management ───────────────────────────────────────
  Future<void> _pickAndUploadVideo() async {
    final provider = context.read<HomepageProvider>();
    final currentCount = provider.homepage?.coverVideos.length ?? 0;

    if (currentCount >= 5) {
      _showSnack('Maximum 5 cover videos allowed', Colors.orange);
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickVideo(source: ImageSource.gallery);

    if (picked == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });
    _uploadProgressNotifier.value = 0;
    _showUploadSheet('Uploading video...');

    try {
      await provider.uploadCoverVideo(
        picked.path,
        onProgress: (sent, total) {
          if (total <= 0) return;
          final percent = (sent / total) * 100;
          _uploadProgressNotifier.value = percent;
          if (mounted) setState(() => _uploadProgress = percent);
        },
      );
      _showSnack('✅ Cover video uploaded successfully', Colors.green);
    } catch (e) {
      _showSnack('❌ ${e.toString().replaceAll("Exception: ", "")}', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
        if (_uploadSheetShown) {
          Navigator.pop(context);
          _uploadSheetShown = false;
        }
      }
    }
  }

  Future<void> _deleteCoverVideo(MediaModel video) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Video?'),
        content: const Text('This will permanently remove this cover video.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await context.read<HomepageProvider>().deleteCoverVideo(video.key);
      _showSnack('✅ Video deleted', Colors.green);
    } catch (e) {
      _showSnack('❌ ${e.toString().replaceAll("Exception: ", "")}', Colors.red);
    }
  }

  // ── Save welcome section ───────────────────────────────────
  Future<void> _saveWelcome() async {
    final title = _titleCtrl.text.trim();
    final subtitle = _subtitleCtrl.text.trim();

    if (title.isEmpty && subtitle.isEmpty) {
      _showSnack('Please enter title or subtitle', Colors.orange);
      return;
    }

    try {
      await context.read<HomepageProvider>().updateWelcomeSection(
            title: title.isNotEmpty ? title : null,
            subtitle: subtitle.isNotEmpty ? subtitle : null,
            isVisible: _welcomeVisible,
          );
      _showSnack('✅ Welcome section updated', Colors.green);
    } catch (e) {
      _showSnack('❌ ${e.toString().replaceAll("Exception: ", "")}', Colors.red);
    }
  }

  void _showSnack(String msg, Color bg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: bg),
    );
  }

  void _showUploadSheet(String title) {
    _uploadSheetShown = true;
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ValueListenableBuilder<double>(
                valueListenable: _uploadProgressNotifier,
                builder: (context, value, _) {
                  final pct = value.clamp(0, 100);
                  return Column(
                    children: [
                      LinearProgressIndicator(
                        value: pct / 100,
                        minHeight: 4,
                      ),
                      const SizedBox(height: 8),
                      Text('${pct.toStringAsFixed(0)}%'),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Manage Homepage'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<HomepageProvider>().fetchHomepage(),
          ),
        ],
      ),
      body: Consumer<HomepageProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.homepage == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.homepage == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: ${provider.error}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => provider.fetchHomepage(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  'Cover Images',
                  subtitle: '${provider.homepage?.coverImages.length ?? 0}/5 images',
                ),
                const SizedBox(height: 8),
                _buildCoverImagesGrid(provider),
                const SizedBox(height: 12),

                _buildSectionHeader(
                  'Cover Videos',
                  subtitle: '${provider.homepage?.coverVideos.length ?? 0}/5 videos',
                ),
                const SizedBox(height: 8),
                _buildCoverVideosGrid(provider),
                const SizedBox(height: 12),

                _buildSectionHeader('Welcome Section'),
                const SizedBox(height: 8),
                _buildWelcomeEditor(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? subtitle}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF3498DB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF3498DB),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCoverImagesGrid(HomepageProvider provider) {
    final images = provider.homepage?.coverImages ?? [];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (images.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Icon(Icons.image_not_supported_outlined,
                      size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'No cover images yet',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final img = images[index];
                return _buildImageTile(img);
              },
            ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickAndUpload,
              icon: _isUploading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.add_photo_alternate_outlined,
                      color: Colors.white),
              label: Text(
                _isUploading ? 'Uploading...' : 'Add Cover Image',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498DB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverVideosGrid(HomepageProvider provider) {
    final videos = provider.homepage?.coverVideos ?? [];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (videos.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Icon(Icons.video_collection_outlined,
                      size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'No cover videos yet',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final vid = videos[index];
                return _buildVideoTile(vid);
              },
            ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickAndUploadVideo,
              icon: _isUploading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.video_call_outlined,
                      color: Colors.white),
              label: Text(
                _isUploading ? 'Uploading...' : 'Add Cover Video',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A085),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageTile(MediaModel image) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            image.url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _isUploading ? null : () => _replaceCoverImage(image),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.85),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, size: 16, color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _isUploading ? null : () => _deleteCoverImage(image),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.85),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVideoTile(MediaModel video) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_outline, color: Colors.white, size: 32),
              SizedBox(height: 4),
              Text(
                'Video',
                style: TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: _isUploading ? null : () => _deleteCoverVideo(video),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.85),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeEditor() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Show Welcome Section',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF555555),
              ),
            ),
            value: _welcomeVisible,
            onChanged: (value) => setState(() => _welcomeVisible = value),
          ),
          const SizedBox(height: 6),
          const Text(
            'Title',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF555555)),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _titleCtrl,
            decoration: InputDecoration(
              hintText: 'Enter welcome title',
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Subtitle',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF555555)),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _subtitleCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Enter welcome subtitle',
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: _saveWelcome,
              icon: const Icon(Icons.save_outlined, color: Colors.white),
              label: const Text(
                'Save Welcome Section',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
