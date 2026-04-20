import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/job_provider.dart';
import '../../data/models/application_model.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';

class JobApplicationsScreen extends StatefulWidget {
  final String jobId;
  final String jobTitle;

  const JobApplicationsScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  @override
  State<JobApplicationsScreen> createState() => _JobApplicationsScreenState();
}

class _JobApplicationsScreenState extends State<JobApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobProvider>(context, listen: false).fetchApplications(widget.jobId);
    });
  }

  Future<void> _updateStatus(String applicationId, String status) async {
    final l10n = AppLocalizations.of(context)!;
    debugPrint("📤 UPDATE STATUS: applicationId=$applicationId, status=$status");

    if (applicationId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.applicationIdMissing), backgroundColor: AppColors.errorRed),
      );
      return;
    }

    // Confirm action
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(status.toUpperCase() == "ACCEPTED" ? l10n.acceptApplication : l10n.rejectApplication),
        content: Text(status.toUpperCase() == "ACCEPTED" ? l10n.confirmAccept : l10n.confirmReject),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: status.toUpperCase() == "ACCEPTED" ? AppColors.statusGreen : AppColors.errorRed,
            ),
            child: Text(status.toUpperCase() == "ACCEPTED" ? l10n.accept : l10n.reject),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await Provider.of<JobProvider>(context, listen: false)
          .updateApplicationStatus(applicationId, status);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.applicationStatusUpdated(status)),
            backgroundColor: status.toUpperCase() == "ACCEPTED" ? AppColors.statusGreen : AppColors.statusOrange,
          ),
        );
      }
    } catch (e) {
      debugPrint("❌ UPDATE STATUS ERROR: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ ${e.toString().replaceAll('Exception: ', '')}"),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.couldNotOpenLink)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.applicationsFor(widget.jobTitle)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => Provider.of<JobProvider>(context, listen: false)
                .fetchApplications(widget.jobId),
          ),
        ],
      ),
      body: Consumer<JobProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.applications.isEmpty) {
            return Center(child: Text(l10n.noApplicationsFound));
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            itemCount: provider.applications.length,
            itemBuilder: (context, index) {
              final app = provider.applications[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Name + Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  app.fullName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    app.applicantType,
                                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildStatusChip(app.status),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Contact details
                      if (app.email.isNotEmpty) ...[
                        Row(children: [
                          const Icon(Icons.email_outlined, size: 13, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(app.email, style: const TextStyle(fontSize: 12)),
                        ]),
                        const SizedBox(height: 2),
                      ],
                      if (app.mobile.isNotEmpty) ...[
                        Row(children: [
                          const Icon(Icons.phone_outlined, size: 13, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(app.mobile, style: const TextStyle(fontSize: 12)),
                        ]),
                      ],
                      const SizedBox(height: 6),

                      // Resume & Photo links
                      Row(
                        children: [
                          if (app.resumeUrl.isNotEmpty)
                            TextButton.icon(
                              onPressed: () => _openUrl(app.resumeUrl),
                              icon: const Icon(Icons.description_outlined, size: 14),
                              label: Text(l10n.resume, style: const TextStyle(fontSize: 11)),
                            ),
                          if (app.photoUrl.isNotEmpty)
                            TextButton.icon(
                              onPressed: () => _openUrl(app.photoUrl),
                              icon: const Icon(Icons.photo_outlined, size: 14),
                              label: Text(l10n.photo, style: const TextStyle(fontSize: 11)),
                            ),
                        ],
                      ),

                      // Action buttons (only for PENDING)
                      if (app.status.toUpperCase() == "PENDING") ...[
                        const Divider(),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _updateStatus(app.id, "ACCEPTED"),
                                icon: const Icon(Icons.check, size: 16, color: Colors.white),
                                label: Text(l10n.accept, style: const TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.statusGreen,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _updateStatus(app.id, "REJECTED"),
                                icon: const Icon(Icons.close, size: 16, color: Colors.white),
                                label: Text(l10n.reject, style: const TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.errorRed,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case "ACCEPTED":
        color = AppColors.statusGreen;
        break;
      case "REJECTED":
        color = AppColors.errorRed;
        break;
      case "REVIEWED":
        color = AppColors.statusActiveBlue;
        break;
      default:
        color = AppColors.statusOrange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
