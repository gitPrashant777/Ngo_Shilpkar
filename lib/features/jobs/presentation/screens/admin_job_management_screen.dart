import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import 'create_job_screen.dart';
import 'job_applications_screen.dart';
import '../../../../l10n/app_localizations.dart';

class AdminJobManagementScreen extends StatefulWidget {
  const AdminJobManagementScreen({super.key});

  @override
  State<AdminJobManagementScreen> createState() => _AdminJobManagementScreenState();
}

class _AdminJobManagementScreenState extends State<AdminJobManagementScreen> {
  final Color primaryBlue = const Color(0xFF55789A);
  final Color successGreen = const Color(0xFF7A9E6F);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobProvider>(context, listen: false).fetchJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.jobManagement, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => Provider.of<JobProvider>(context, listen: false).fetchJobs(),
          ),
        ],
      ),
      body: Consumer<JobProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.jobs.isEmpty) {
            return _buildEmptyState(provider);
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchJobs(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              itemCount: provider.jobs.length,
              itemBuilder: (context, index) {
                final job = provider.jobs[index];
                return _buildJobCard(context, job, provider);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryBlue,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateJobScreen())),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(AppLocalizations.of(context)!.postNewJob, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, dynamic job, JobProvider provider) {
    bool isOpen = job.status == 'OPEN';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 10, 12, 4),

            // ✅ Logo Added Here
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                'assets/Images/logoSk.png',
                height: 34,
                fit: BoxFit.contain,
              ),
            ),

            title: Text(
              job.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                children: [
                  Icon(Icons.business, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      job.organization,
                      style: TextStyle(color: Colors.grey.shade600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _buildStatusBadge(job.status),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: Icons.people_outline_rounded,
                  label: AppLocalizations.of(context)!.applications,
                  color: primaryBlue,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JobApplicationsScreen(
                        jobId: job.id,
                        jobTitle: job.title,
                      ),
                    ),
                  ),
                ),
                _buildActionButton(
                  icon: isOpen
                      ? Icons.lock_outline_rounded
                      : Icons.public_rounded,
                   label: isOpen ? AppLocalizations.of(context)!.closeListing : AppLocalizations.of(context)!.openListing,
                  color: isOpen ? Colors.orange : successGreen,
                  onTap: () {
                    String nextStatus = isOpen ? 'CLOSED' : 'OPEN';
                    provider.updateJobStatus(job.id, nextStatus);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'OPEN': color = successGreen; break;
      case 'CLOSED': color = Colors.redAccent; break;
      default: color = Colors.blueGrey; // For DRAFT
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(status, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildEmptyState(JobProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_off_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.noActiveJobPostings, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          TextButton.icon(onPressed: () => provider.fetchJobs(), icon: const Icon(Icons.refresh), label: Text(AppLocalizations.of(context)!.refreshList)),
        ],
      ),
    );
  }
}
