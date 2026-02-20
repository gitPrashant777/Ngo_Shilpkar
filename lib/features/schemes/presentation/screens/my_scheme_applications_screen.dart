import 'package:flutter/material.dart';
import '../../../schemes/data/repository/scheme_repository.dart';
import '../../../schemes/data/models/scheme_application_model.dart';

class MySchemeApplicationsScreen extends StatefulWidget {
  const MySchemeApplicationsScreen({super.key});

  @override
  State<MySchemeApplicationsScreen> createState() =>
      _MySchemeApplicationsScreenState();
}

class _MySchemeApplicationsScreenState
    extends State<MySchemeApplicationsScreen> {
  final SchemeRepository _repository = SchemeRepository();

  bool _isLoading = true;
  List<SchemeApplicationModel> _applications = [];

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    try {
      final data = await _repository.getMyApplications();
      setState(() {
        _applications = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _withdraw(String applicationId) async {
    try {
      await _repository.withdrawApplication(applicationId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Application withdrawn")),
      );
      _fetchApplications();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case "APPROVED":
        return Colors.green;
      case "REJECTED":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _applications.isEmpty
          ? const Center(child: Text("No applications found"))
          : ListView.builder(
        itemCount: _applications.length,
        itemBuilder: (context, index) {
          final app = _applications[index];

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
                              app.schemeName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2C3E50)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _statusColor(app.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _statusColor(app.status).withOpacity(0.5)),
                        ),
                        child: Text(
                          app.status,
                          style: TextStyle(
                            color: _statusColor(app.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (app.status == "UNDER_REVIEW") ...[
                    const SizedBox(height: 12),
                    Align(
                       alignment: Alignment.centerRight,
                       child: TextButton.icon(
                         icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.red),
                         label: const Text("Withdraw", style: TextStyle(color: Colors.red, fontSize: 13)),
                         style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                         ),
                         onPressed: () => _withdraw(app.id),
                       ),
                    ),
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
