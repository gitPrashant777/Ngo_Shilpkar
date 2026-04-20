import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/broadcast_provider.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';

class BroadcastListScreen extends StatefulWidget {
  const BroadcastListScreen({super.key});

  @override
  State<BroadcastListScreen> createState() => _BroadcastListScreenState();
}

class _BroadcastListScreenState extends State<BroadcastListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBroadcasts();
    });
  }

  void _fetchBroadcasts() {
    final role = context.read<AuthProvider>().role;
    final isSuperAdmin = role == 'SUPER_ADMIN' || role == 'ADMIN';

    if (isSuperAdmin) {
      context.read<BroadcastProvider>().fetchAllBroadcasts();
    } else {
      context.read<BroadcastProvider>().fetchPublicBroadcasts();
    }
  }

  void _showSendBroadcastDialog() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.sendBroadcast),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.enterMessageAllUsers,
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancelBtn),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                try {
                  await context.read<BroadcastProvider>().createBroadcast(
                    message: controller.text.trim(),
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)!.broadcastSentSuccess,
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "${AppLocalizations.of(context)!.errorOccurred}: $e",
                        ),
                      ),
                    );
                  }
                }
              }
            },
            child: Text(AppLocalizations.of(context)!.sendBtn),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().role;
    final isSuperAdmin = role == 'SUPER_ADMIN' || role == 'ADMIN';

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.manageBroadcasts),
        backgroundColor: AppColors.appBarBlue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: isSuperAdmin
          ? FloatingActionButton(
              onPressed: _showSendBroadcastDialog,
              backgroundColor: AppColors.appBarBlue,
              child: const Icon(Icons.send, color: Colors.white),
            )
          : null,
      body: Consumer<BroadcastProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.broadcasts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.campaign_outlined,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noBroadcastsYet,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _fetchBroadcasts(),
            child: ListView.separated(
              itemCount: provider.broadcasts.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final broadcast = provider.broadcasts[index];
                final time = DateFormat(
                  'MMM d, h:mm a',
                ).format(broadcast.createdAt);

                return ListTile(
                  tileColor: Colors.white,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.secondaryGreen.withValues(
                      alpha: 0.2,
                    ),
                    child: const Icon(
                      Icons.campaign_rounded,
                      color: AppColors.secondaryGreen,
                    ),
                  ),
                  title: Text(
                    broadcast.message,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (broadcast.sender != null) ...[
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.byName(broadcast.sender!.name),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              const Text(
                                " • ",
                                style: TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                            Text(
                              time,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        if (broadcast.category != null && broadcast.category!.isNotEmpty) ...[
                          const SizedBox(height: 6),
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
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: broadcast.isEmergency ? Colors.red : Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
