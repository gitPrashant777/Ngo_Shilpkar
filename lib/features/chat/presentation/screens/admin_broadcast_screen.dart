import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/user_roles.dart';
import '../../../auth/data/repository/user_repository.dart';
import '../providers/broadcast_provider.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';

class AdminBroadcastScreen extends StatefulWidget {
  const AdminBroadcastScreen({super.key});

  @override
  State<AdminBroadcastScreen> createState() => _AdminBroadcastScreenState();
}

class _AdminBroadcastScreenState extends State<AdminBroadcastScreen> {
  final UserRepository _userRepository = UserRepository();
  List<Map<String, dynamic>> _categories = [];

  static const List<String> _announcementCategories = [
    'General',
    'Health Alert',
    'Emergency',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BroadcastProvider>().fetchAllBroadcasts();
      _fetchCategories();
    });
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await _userRepository.getUserCategories();
      if (mounted) {
        setState(() => _categories = categories);
      }
    } catch (_) {}
  }

  void _showCreateBroadcastDialog() {
    final TextEditingController textController = TextEditingController();
    String? selectedCategory;
    final List<String> selectedRoles = [];
    final List<String> selectedCategoryIds = [];
    bool isEmergency = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.newBroadcastMessage),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.enterMessageHere,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Announcement Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _announcementCategories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setDialogState(() => selectedCategory = val),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Target Roles',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    UserRole.field,
                    UserRole.coordinator,
                    UserRole.districtCoordinator,
                    UserRole.talukaCoordinator,
                    UserRole.villageCoordinator,
                    UserRole.beneficiary,
                  ].map((role) {
                    final selected = selectedRoles.contains(role);
                    return FilterChip(
                      label: Text(UserRole.displayName(role)),
                      selected: selected,
                      onSelected: (val) {
                        setDialogState(() {
                          if (val) {
                            selectedRoles.add(role);
                          } else {
                            selectedRoles.remove(role);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Recipient Categories',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                if (_categories.isEmpty)
                  const Text('No categories available')
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: _categories.map((cat) {
                      final id = cat['_id']?.toString() ?? '';
                      final name = cat['name']?.toString() ?? 'Category';
                      final selected = selectedCategoryIds.contains(id);
                      return FilterChip(
                        label: Text(name),
                        selected: selected,
                        onSelected: (val) {
                          setDialogState(() {
                            if (val) {
                              selectedCategoryIds.add(id);
                            } else {
                              selectedCategoryIds.remove(id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: isEmergency,
                  title: const Text('Emergency Alert'),
                  onChanged: (val) => setDialogState(() => isEmergency = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancelBtn),
            ),
            ElevatedButton(
              onPressed: () async {
                if (textController.text.trim().isEmpty) return;

                final message = textController.text.trim();
                final provider = context.read<BroadcastProvider>();
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                Navigator.pop(context);

                await provider.createBroadcast(
                  message: message,
                  category: selectedCategory,
                  targetRoles: selectedRoles,
                  targetCategories: selectedCategoryIds,
                  isEmergency: isEmergency,
                );

                if (provider.error != null) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        "${AppLocalizations.of(context)!.errorOccurred}: ${provider.error}",
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.broadcastSentSuccess,
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
              child: Text(
                AppLocalizations.of(context)!.sendBtn,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.manageBroadcasts),
        backgroundColor: AppColors.appBarBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Upload Emergency Siren',
            icon: const Icon(Icons.alarm),
            onPressed: _uploadSiren,
          ),
        ],
      ),
      body: Consumer<BroadcastProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "${AppLocalizations.of(context)!.errorOccurred}: ${provider.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (provider.broadcasts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.campaign_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noBroadcastsFound,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.fetchAllBroadcasts,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.broadcasts.length,
              itemBuilder: (context, index) {
                final broadcast = provider.broadcasts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.campaign_rounded,
                                  color: AppColors.primaryBlue,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.sentBy(broadcast.sender?.name ?? 'Admin'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.appBarBlue,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.grey,
                              ),
                              onPressed: () =>
                                  _showEditDeleteMenu(context, broadcast),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (broadcast.category != null && broadcast.category!.isNotEmpty) ...[
                          Wrap(
                            spacing: 8,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: broadcast.isEmergency
                                      ? Colors.red.shade50
                                      : Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  broadcast.category!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: broadcast.isEmergency ? Colors.red : Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        Text(
                          broadcast.message,
                          style: const TextStyle(fontSize: 16, height: 1.4),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "ID: ${broadcast.id.substring(0, 6)}...",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            Text(
                              DateFormat(
                                'MMM d, yyyy - h:mm a',
                              ).format(broadcast.createdAt.toLocal()),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateBroadcastDialog,
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          AppLocalizations.of(context)!.newBroadcastMessage,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showEditDeleteMenu(BuildContext context, broadcast) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: Text(AppLocalizations.of(context)!.editBroadcast),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(broadcast);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(
                AppLocalizations.of(context)!.deleteBroadcast,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _promptDelete(broadcast.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(broadcast) {
    final TextEditingController textController = TextEditingController(
      text: broadcast.message,
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.editBroadcast),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (textController.text.trim().isEmpty) return;
              final newMessage = textController.text.trim();

              // Capture instances before popping
              final provider = context.read<BroadcastProvider>();
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              Navigator.pop(dialogContext); // Close dialog

              await provider.updateBroadcast(broadcast.id, newMessage);

              if (provider.error != null && mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      "${AppLocalizations.of(context)!.errorOccurred}: ${provider.error!}",
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.broadcastUpdated,
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(AppLocalizations.of(context)!.saveBtn),
          ),
        ],
      ),
    );
  }

  void _promptDelete(String id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteBroadcastPrompt),
        content: Text(AppLocalizations.of(context)!.cannotBeUndone),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context)!.cancelBtn),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              // Capture instances
              final provider = context.read<BroadcastProvider>();
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              Navigator.pop(dialogContext); // Close dialog

              await provider.deleteBroadcast(id);

              if (provider.error != null && mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      "${AppLocalizations.of(context)!.errorOccurred}: ${provider.error!}",
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.broadcastDeleted,
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(
              AppLocalizations.of(context)!.deleteBtn,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadSiren() async {
    final provider = context.read<BroadcastProvider>();
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'aac', 'ogg'],
    );

    if (result == null || result.files.single.path == null) return;
    final path = result.files.single.path!;

    try {
      final url = await provider.uploadEmergencySiren(path);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(url == null || url.isEmpty
              ? 'Emergency siren uploaded.'
              : 'Emergency siren uploaded: $url'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload siren: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
