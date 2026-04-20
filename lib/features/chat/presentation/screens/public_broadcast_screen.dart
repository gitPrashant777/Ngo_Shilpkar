import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/broadcast_provider.dart';
import 'package:intl/intl.dart';

class PublicBroadcastScreen extends StatefulWidget {
  const PublicBroadcastScreen({super.key});

  @override
  State<PublicBroadcastScreen> createState() => _PublicBroadcastScreenState();
}

class _PublicBroadcastScreenState extends State<PublicBroadcastScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BroadcastProvider>().fetchPublicBroadcasts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: const Text("Announcements"),
        backgroundColor: AppColors.appBarBlue,
        foregroundColor: Colors.white,
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
                  "Error: ${provider.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (provider.publicBroadcasts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.campaign_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No announcements at this time",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.fetchPublicBroadcasts,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.publicBroadcasts.length,
              itemBuilder: (context, index) {
                final broadcast = provider.publicBroadcasts[index];
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
                          children: [
                            const Icon(
                              Icons.campaign_rounded,
                              color: AppColors.primaryBlue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "System Announcement",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.appBarBlue,
                              ),
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
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            DateFormat(
                              'MMM d, yyyy - h:mm a',
                            ).format(broadcast.createdAt.toLocal()),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
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
    );
  }
}
