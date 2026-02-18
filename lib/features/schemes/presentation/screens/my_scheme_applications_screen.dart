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
      appBar: AppBar(title: const Text("My Scheme Applications")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _applications.isEmpty
          ? const Center(child: Text("No applications found"))
          : ListView.builder(
        itemCount: _applications.length,
        itemBuilder: (context, index) {
          final app = _applications[index];

          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              title: Text(app.schemeName),
              subtitle: Text(
                app.status,
                style: TextStyle(
                  color: _statusColor(app.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: app.status == "UNDER_REVIEW"
                  ? IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _withdraw(app.id),
              )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
