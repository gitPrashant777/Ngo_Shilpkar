import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/public_home_screen.dart';
import '../../data/models/job_model.dart';
import 'apply_job_screen.dart';
import 'job_list_screen.dart';
import 'job_applications_screen.dart';
import '../../../auth/presentation/screens/beneficiary_login_screen.dart' as shilpkar_auth;
import '../../../auth/presentation/screens/employee_login_screen.dart' as shilpkar_auth;
import '../../../../core/navigation/main_navigation.dart';

class JobDetailScreen extends StatelessWidget {
  final JobModel job;

  const JobDetailScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4373AD)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Shilpkar Foundation",
          style: TextStyle(
            color: Color(0xFF4373AD),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 150), // Extra bottom padding for button/nav
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row with Title and Logo Box
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            job.organization,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildInfoRow(Icons.location_on_outlined, job.city),
                const SizedBox(height: 12),

                const SizedBox(height: 30),

                // Job Description Section
                const Text(
                  "Job Description",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  job.description,
                  style: const TextStyle(color: Colors.black54, height: 1.5),
                ),
                const SizedBox(height: 30),

                // Required Skills Section
                const Text(
                  "Required Skills",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: job.requiredSkills.map((skill) {
                    return Chip(
                      label: Text(skill),
                      backgroundColor: const Color(0xFFE3F2FD),
                      labelStyle: const TextStyle(color: Color(0xFF1565C0)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                
                 Row(
                  children: [
                    _buildInfoRow(Icons.category, job.category.isNotEmpty ? job.category : "General"),
                    const SizedBox(width: 40),
                    _buildInfoRow(Icons.timer, job.duration.isNotEmpty ? job.duration : "N/A"),
                  ],
                ),
                const SizedBox(height: 12),
                 _buildInfoRow(Icons.payments_outlined, job.stipend.isNotEmpty ? "₹${job.stipend}" : "Unpaid"),
                const SizedBox(height: 30),
      ]
            ),

          ),

          // Fixed Bottom Section
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.white, // Ensure background covers safe area if needed, mostly handled by parent
              child: SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Adjusted padding
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: _buildActionButton(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



// ... (imports)

  Widget _buildActionButton(BuildContext context) {
    final userRole = Provider.of<AuthProvider>(context).role; 
    
    bool isJobClosed = job.status == 'CLOSED';

    if (isJobClosed) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
        child: const Text("Job Closed", style: TextStyle(color: Colors.white)),
      );
    }

    // Admin / Super Admin -> View Applications
    if (userRole == 'ADMIN' || userRole == 'SUPER_ADMIN') {
      return ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => JobApplicationsScreen(jobId: job.id, jobTitle: job.title)),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: const Text(
          "View Applications",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }

    if (userRole == 'FIELD' || userRole == 'COORDINATOR') {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
        child: const Text("Not Eligible to Apply", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      );
    }

    // Guest / Beneficiary -> Apply Now
    return ElevatedButton(
      onPressed: () {
        if (userRole == null || userRole.isEmpty) {
          _showLoginSheet(context);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ApplyJobScreen(jobId: job.id)),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3B76D1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      child: const Text(
        "Apply Now",
        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.appBarBlue,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const JobListScreen()),
            );
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PublicHomeScreen()),
            );
            break;
          case 2:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Schemes coming soon")),
            );
            break;
          case 3:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Profile coming soon")),
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: "Jobs"),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: "Schemes"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
      ],
    );
  }
  void _showLoginSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Login Required",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("Please login to apply for this job."),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.group_add_rounded, color: Color(0xFF7A9E6F)),
              title: const Text("Login as Beneficiary"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const shilpkar_auth.BeneficiaryLoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
