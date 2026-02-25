import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shilpkar/features/auth/presentation/screens/public_home_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/job_model.dart';
import '../../data/repository/job_repository.dart';
import '../providers/job_provider.dart';
import 'job_detail_screen.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  final TextEditingController _cityController = TextEditingController();
  String? _selectedCategory;
  final List<String> _categories = ['TECH', 'HEALTH', 'EDUCATION', 'FIELD_WORK', 'OTHER'];
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchJobs();
    });
  }

  void _fetchJobs() {
    Provider.of<JobProvider>(context, listen: false).fetchJobs(
      city: _cityController.text.isNotEmpty ? _cityController.text : null,
      category: _selectedCategory,
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Filter Jobs", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: "City", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: "Category", border: OutlineInputBorder()),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) {
                  setState(() => _selectedCategory = val);
                }, // Just update local state, apply on button press
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _cityController.clear();
                        setState(() => _selectedCategory = null);
                        Navigator.pop(context);
                        _fetchJobs();
                      },
                      child: const Text("Clear"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _fetchJobs();
                      },
                      child: const Text("Apply"),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Shilpkar Foundation",
          style: TextStyle(color: Color(0xFF4A698C), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF4A698C)),
            onPressed: _showFilterSheet,
          )
        ],
      ),
      body: Consumer<JobProvider>(
        builder: (context, provider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  "Jobs",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.jobs.isEmpty 
                        ? const Center(child: Text("No jobs found"))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: provider.jobs.length,
                            itemBuilder: (context, index) {
                              return _buildJobCard(provider.jobs[index]);
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildJobCard(JobModel job) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        job.organization,
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  child:           Image.asset('assets/Images/logoSk.png', height: 40),

                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
            _iconText(Icons.location_on_outlined, job.city),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _iconText(Icons.calendar_today_outlined, job.duration.isNotEmpty ? job.duration : "N/A")), 
                Expanded(child: _iconText(Icons.payments_outlined, job.stipend.isNotEmpty ? "₹${job.stipend}" : "Unpaid")),
              ],
            ),
             const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B76D1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("View Details", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }
  

}
