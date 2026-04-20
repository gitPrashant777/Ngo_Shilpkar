import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../../data/models/user_job_application_model.dart';

class UserJobListScreen extends StatefulWidget {
  const UserJobListScreen({super.key});

  @override
  State<UserJobListScreen> createState() => _UserJobListScreenState();
}

class _UserJobListScreenState extends State<UserJobListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobProvider>(context, listen: false).fetchMyApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<JobProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.myApplications.isEmpty) {
            return const Center(
              child: Text("You haven't applied to any jobs yet."),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.myApplications.length,
            itemBuilder: (context, index) {
              final app = provider.myApplications[index];
              return _buildApplicationCard(app);
            },
          );
        },
      ),
    );
  }

  Widget _buildApplicationCard(UserJobApplicationModel app) {
    Color statusColor;
    switch (app.status) {
      case 'ACCEPTED': statusColor = Colors.green; break;
      case 'REJECTED': statusColor = Colors.red; break;
      default: statusColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.jobTitle.isNotEmpty ? app.jobTitle : "Unknown Job",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2C3E50)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        app.organization.isNotEmpty ? app.organization : "Unknown Org",
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    app.status,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            if (app.jobCity.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                   Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(app.jobCity, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}
