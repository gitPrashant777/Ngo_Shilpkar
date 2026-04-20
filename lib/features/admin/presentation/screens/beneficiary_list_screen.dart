import 'package:flutter/material.dart';
import '../../../auth/data/models/beneficiary_model.dart';
import '../../../auth/data/repository/user_repository.dart';
import 'beneficiary_detail_screen.dart';

class BeneficiaryListScreen extends StatefulWidget {
  const BeneficiaryListScreen({super.key});

  @override
  State<BeneficiaryListScreen> createState() => _BeneficiaryListScreenState();
}

class _BeneficiaryListScreenState extends State<BeneficiaryListScreen> {
  final UserRepository _repository = UserRepository();
  List<BeneficiaryModel> _beneficiaries = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBeneficiaries();
  }

  Future<void> _fetchBeneficiaries() async {
    try {
      final data = await _repository.getBeneficiaries();
      setState(() {
        _beneficiaries = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text("Beneficiaries"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text("Error: $_errorMessage"))
          : _beneficiaries.isEmpty
          ? const Center(child: Text("No Beneficiaries Found"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _beneficiaries.length,
        itemBuilder: (context, index) {
          final beneficiary = _beneficiaries[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  beneficiary.firstName.isNotEmpty
                      ? beneficiary.firstName[0].toUpperCase()
                      : "?",
                  style: const TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                "${beneficiary.firstName} ${beneficiary.lastName}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(beneficiary.mobile),
                   Text("${beneficiary.village}, ${beneficiary.taluka}"),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BeneficiaryDetailScreen(beneficiary: beneficiary),
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
