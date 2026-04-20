import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/status_provider.dart';
import '../../data/models/status_model.dart';
import '../../../../core/constants/app_colors.dart';

class StatusManagementScreen extends StatefulWidget {
  const StatusManagementScreen({super.key});

  @override
  State<StatusManagementScreen> createState() => _StatusManagementScreenState();
}

class _StatusManagementScreenState extends State<StatusManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatusProvider>().fetchStatuses(refresh: true);
    });
  }

  // ─── CREATE ──────────────────────────────────────────────────────────────────
  void _showCreateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _CreateStatusSheet(parentContext: context),
    );
  }

  // ─── EDIT CAPTION ─────────────────────────────────────────────────────────────
  void _showEditCaption(StatusModel status) {
    final ctrl = TextEditingController(text: status.caption ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Caption'),
        content: TextField(
          controller: ctrl,
          maxLength: 500,
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await context
                  .read<StatusProvider>()
                  .editCaption(status.id, ctrl.text.trim());
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok
                      ? '✅ Caption updated!'
                      : '❌ ${context.read<StatusProvider>().error}'),
                  backgroundColor: ok ? Colors.green : Colors.red,
                ));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.profileBlue),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── DELETE ───────────────────────────────────────────────────────────────────
  void _confirmDelete(StatusModel status) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Status?'),
        content: const Text('This will permanently remove the status and its media.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<StatusProvider>().deleteStatus(status.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('🗑️ Status deleted'),
                        backgroundColor: Colors.red));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── VIEW VIEWERS ─────────────────────────────────────────────────────────────
  void _showViewersSheet(StatusModel status, StatusProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, scrollCtrl) => Column(
          children: [
            // Handle bar
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text('Viewed By', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: provider.getStatusViewsDetails(status.id),
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final views = snap.data ?? [];
                  if (views.isEmpty) {
                    return Center(
                      child: Text('No views yet', style: TextStyle(color: Colors.grey.shade500)),
                    );
                  }
                  return ListView.separated(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: views.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx2, i) {
                      final view = views[i];
                      final isAnonymous = view['userId'] == null;
                      final user = view['user'] is Map ? view['user'] : null;
                      final name = (user?['name'] ?? user?['fullName'])?.toString() ?? 'Guest User';
                      final username = (user?['username'])?.toString() ?? '';
                      final phone = (user?['phone'] ?? user?['mobileNumber'])?.toString() ?? '';
                      final role = (user?['role'])?.toString() ?? 'Guest';
                      
                      return Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: isAnonymous ? Colors.grey.shade200 : AppColors.profileBlue.withOpacity(0.15),
                            child: Icon(
                              isAnonymous ? Icons.person_outline : Icons.person,
                              color: isAnonymous ? Colors.grey.shade600 : AppColors.profileBlue,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                if (username.isNotEmpty && !isAnonymous)
                                  Text('@$username', style: TextStyle(fontSize: 12, color: Colors.blue.shade600, fontWeight: FontWeight.w500)),
                                if (phone.isNotEmpty && !isAnonymous && phone != username)
                                  Text(phone, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isAnonymous ? Colors.grey.shade100 : AppColors.goldYellow.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(role.toString().toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isAnonymous ? Colors.grey.shade700 : AppColors.darkOrange)),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uploadActive = context.watch<StatusProvider>().isUploading;
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.profileBlue,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Shilpkar Foundation',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400)),
            Text('Status Management',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<StatusProvider>().fetchStatuses(refresh: true),
          ),
        ],
        bottom: uploadActive
            ? const PreferredSize(
                preferredSize: Size.fromHeight(3),
                child: LinearProgressIndicator(minHeight: 3),
              )
            : null,
      ),
      body: Consumer<StatusProvider>(
        builder: (context, provider, _) {
          Widget content;
          if (provider.isLoading && provider.statuses.isEmpty) {
            content = const Center(child: CircularProgressIndicator());
          } else if (provider.statuses.isEmpty) {
            content = Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stream, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No statuses yet',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showCreateSheet,
                    icon: const Icon(Icons.add),
                    label: const Text('Create First Status'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.profileBlue,
                        foregroundColor: Colors.white),
                  ),
                ],
              ),
            );
          } else {
            content = RefreshIndicator(
              onRefresh: () => provider.fetchStatuses(refresh: true),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: provider.statuses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final status = provider.statuses[index];
                  return _buildStatusCard(status, provider);
                },
              ),
            );
          }

          return Column(
            children: [
              if (provider.isUploading)
                LinearProgressIndicator(
                  value: provider.uploadProgress,
                  minHeight: 3,
                ),
              Expanded(child: content),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateSheet,
        backgroundColor: AppColors.profileBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label:
            const Text('New Status', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStatusCard(StatusModel status, StatusProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)
        ],
        border: status.pinned
            ? Border.all(color: AppColors.goldYellow, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Media thumbnail
          if (status.mediaUrl != null)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      status.mediaUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade100,
                        child: Center(
                          child: Icon(
                            status.isVideo
                                ? Icons.videocam_outlined
                                : Icons.broken_image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    // Type badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              status.isVideo
                                  ? Icons.videocam
                                  : Icons.image_outlined,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              status.isVideo ? 'Video' : 'Image',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (status.isVideo)
                      const Center(
                        child: Icon(Icons.play_circle_fill,
                            color: Colors.white70, size: 52),
                      ),
                  ],
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pin badge + date
                Row(
                  children: [
                    if (status.pinned)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.goldYellow),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.push_pin,
                                size: 12, color: AppColors.darkOrange),
                            SizedBox(width: 4),
                            Text('Pinned',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.darkOrange,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    const Spacer(),
                    Text(
                      _formatDate(status.createdAt),
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
                if (status.caption != null && status.caption!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(status.caption!,
                      style: const TextStyle(fontSize: 14, height: 1.4)),
                ],
                if (status.expiresAt != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined,
                          size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        'Expires ${_formatDate(status.expiresAt!)}',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                // Actions + View Count
                Row(
                  children: [
                    // Live view count badge (Clickable to see who viewed)
                    FutureBuilder<int>(
                      future: provider.getViewCount(status.id),
                      builder: (ctx, snap) {
                        final count = snap.data ?? 0;
                        return GestureDetector(
                          onTap: () => _showViewersSheet(status, provider),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.visibility_outlined, size: 13, color: Colors.blue.shade700),
                                const SizedBox(width: 4),
                                Text(
                                  '$count Views',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.blue.shade700),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _ActionChip(
                      icon: status.pinned
                          ? Icons.push_pin
                          : Icons.push_pin_outlined,
                      label: status.pinned ? 'Unpin' : 'Pin',
                      color: status.pinned
                          ? AppColors.darkOrange
                          : Colors.grey.shade600,
                      onTap: () async {
                        final ok = await provider.togglePin(status.id);
                        if (!ok && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(provider.error ?? 'Pin failed'),
                            backgroundColor: Colors.red,
                          ));
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    _ActionChip(
                      icon: Icons.edit_outlined,
                      label: 'Edit',
                      color: Colors.blue.shade700,
                      onTap: () => _showEditCaption(status),
                    ),
                    const SizedBox(width: 8),
                    _ActionChip(
                      icon: Icons.delete_outline,
                      label: 'Delete',
                      color: Colors.red.shade700,
                      onTap: () => _confirmDelete(status),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ─── Create Status Bottom Sheet (stateful for video preview) ──────────────────
class _CreateStatusSheet extends StatefulWidget {
  final BuildContext parentContext;
  const _CreateStatusSheet({required this.parentContext});

  @override
  State<_CreateStatusSheet> createState() => _CreateStatusSheetState();
}

class _CreateStatusSheetState extends State<_CreateStatusSheet> {
  final TextEditingController _captionCtrl = TextEditingController();
  final List<_PickedMedia> _pickedMedia = [];

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_pickedMedia.length >= 10) {
      _showLimitSnack();
      return;
    }
    final results = await ImagePicker().pickMultiImage(
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (results.isEmpty) return;
    setState(() {
      for (final result in results) {
        if (_pickedMedia.length >= 10) break;
        _pickedMedia.add(
          _PickedMedia(
            file: File(result.path),
            isVideo: false,
            name: result.name,
            mimeType: _mimeFromPath(result.path) ?? 'image/jpeg',
          ),
        );
      }
    });
    if (_pickedMedia.length >= 10 && results.length > 1) {
      _showLimitSnack();
    }
  }

  Future<void> _pickVideo() async {
    if (_pickedMedia.length >= 10) return;
    final result = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (result != null) {
      setState(() {
        _pickedMedia.add(
          _PickedMedia(
            file: File(result.path),
            isVideo: true,
            name: result.name,
            mimeType: _mimeFromPath(result.path) ?? 'video/mp4',
          ),
        );
      });
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _pickedMedia.removeAt(index);
    });
  }

  void _showLimitSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You can upload up to 10 highlights.')),
    );
  }

  String? _mimeFromPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.mp4')) return 'video/mp4';
    if (lower.endsWith('.mov')) return 'video/quicktime';
    if (lower.endsWith('.webm')) return 'video/webm';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.heic')) return 'image/heic';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Create New Status',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _captionCtrl,
            maxLength: 500,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Caption (optional)',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 12),
          // Media type buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Images'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.profileBlue,
                    side: const BorderSide(color: AppColors.profileBlue),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickVideo,
                  icon: const Icon(Icons.videocam_outlined),
                  label: const Text('Video'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    side: const BorderSide(color: Colors.deepPurple),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),

          // Preview grid
          if (_pickedMedia.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.photo_library_outlined,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  'Selected ${_pickedMedia.length}/10',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: _pickedMedia.length,
              itemBuilder: (context, index) {
                final item = _pickedMedia[index];
                return Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: item.isVideo
                            ? Container(
                                color: const Color(0xFF1A1A2E),
                                child: const Center(
                                  child: Icon(
                                    Icons.play_circle_fill,
                                    color: Colors.white70,
                                    size: 28,
                                  ),
                                ),
                              )
                            : Image.file(item.file, fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () => _removeMedia(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],

          Consumer<StatusProvider>(
            builder: (context, provider, _) {
              if (!provider.isUploading) return const SizedBox.shrink();
              final percent = (provider.uploadProgress * 100).round();
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: provider.uploadProgress,
                      minHeight: 3,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Uploading... $percent%',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                if (context.read<StatusProvider>().isUploading) return;
                if (_pickedMedia.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Select at least one file.')),
                  );
                  return;
                }
                final filePaths =
                    _pickedMedia.map((item) => item.file.path).toList();
                final mimeTypes =
                    _pickedMedia.map((item) => item.mimeType).toList();
                final ok = await widget.parentContext
                    .read<StatusProvider>()
                    .createStatuses(
                      caption: _captionCtrl.text.trim().isEmpty
                          ? null
                          : _captionCtrl.text.trim(),
                      filePaths: filePaths,
                      mimeTypes: mimeTypes,
                    );
                if (ok && mounted) {
                  Navigator.pop(context);
                }
                if (widget.parentContext.mounted) {
                  ScaffoldMessenger.of(widget.parentContext)
                      .showSnackBar(SnackBar(
                    content: Text(ok
                        ? '✅ Status created successfully!'
                        : '❌ ${widget.parentContext.read<StatusProvider>().error}'),
                    backgroundColor: ok ? Colors.green : Colors.red,
                  ));
                }
              },
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              label: const Text('Post Status',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.profileBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Inline video preview widget ──────────────────────────────────────────────
// ─── Action Chip ──────────────────────────────────────────────────────────────
class _PickedMedia {
  final File file;
  final bool isVideo;
  final String name;
  final String? mimeType;

  const _PickedMedia({
    required this.file,
    required this.isVideo,
    required this.name,
    this.mimeType,
  });
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
