import 'package:flutter/material.dart';
import '../../data/repository/scheme_repository.dart';
import '../../data/models/scheme_application_model.dart';

class SuperAdminSchemeApplicationsScreen extends StatefulWidget {
  final String schemeId;
  final String schemeName;

  const SuperAdminSchemeApplicationsScreen({
    super.key,
    required this.schemeId,
    required this.schemeName,
  });

  @override
  State<SuperAdminSchemeApplicationsScreen> createState() =>
      _SuperAdminSchemeApplicationsScreenState();
}

class _SuperAdminSchemeApplicationsScreenState
    extends State<SuperAdminSchemeApplicationsScreen> {
  final SchemeRepository _repository = SchemeRepository();

  List<SchemeApplicationModel> _applications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    try {
      final response = await _repository.getApplications(widget.schemeId);

      if (mounted) {
        setState(() {
          _applications = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError(e.toString());
      }
    }
  }

  Future<void> _updateStatus(
      String applicationId, String status) async {
    try {
      await _repository.updateApplicationStatus(
        applicationId,
        status,
        "Reviewed by admin",
      );

      if (mounted) {
        setState(() {
          _applications = _applications.map((app) {
            if (app.id == applicationId) {
              return app.copyWith(status: status);
            }
            return app;
          }).toList();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Application $status")),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case "APPROVED":
        return Colors.green;
      case "REJECTED":
        return Colors.red;
      case "UNDER_REVIEW":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Applications - ${widget.schemeName}"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _applications.isEmpty
          ? const Center(child: Text("No Applications"))
          : ListView.builder(
        itemCount: _applications.length,
        itemBuilder: (context, index) {
          final app = _applications[index];

          return Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    app.beneficiaryName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text("Category: ${app.category}"),
                  const SizedBox(height: 6),
                  Text(
                    "Status: ${app.status}",
                    style: TextStyle(
                      color:
                      _statusColor(app.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (app.status == "UNDER_REVIEW")
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                _updateStatus(
                                    app.id,
                                    "APPROVED"),
                            style:
                            ElevatedButton
                                .styleFrom(
                              backgroundColor:
                              Colors.green,
                            ),
                            child:
                            const Text("Approve"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                _updateStatus(
                                    app.id,
                                    "REJECTED"),
                            style:
                            ElevatedButton
                                .styleFrom(
                              backgroundColor:
                              Colors.red,
                            ),
                            child:
                            const Text("Reject"),
                          ),
                        ),
                      ],
                    )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
