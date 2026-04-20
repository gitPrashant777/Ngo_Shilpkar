import 'package:flutter/material.dart';
import '../../../auth/data/models/beneficiary_model.dart';
import '../../../../core/constants/app_colors.dart';

class BeneficiaryDetailScreen extends StatelessWidget {
  final BeneficiaryModel beneficiary;

  const BeneficiaryDetailScreen({super.key, required this.beneficiary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: Text("${beneficiary.firstName}'s Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Personal Information"),
            _buildInfoCard([
              _buildInfoRow("Name", "${beneficiary.firstName} ${beneficiary.lastName}"),
              _buildInfoRow("Mobile", beneficiary.mobile),
              _buildInfoRow("Email", beneficiary.email),
              _buildInfoRow("Category", beneficiary.category),
              _buildInfoRow("Address", beneficiary.address),
            ]),

            const SizedBox(height: 20),
            _buildSectionHeader("Location"),
            _buildInfoCard([
              _buildInfoRow("Village", beneficiary.village),
              _buildInfoRow("Taluka", beneficiary.taluka),
              _buildInfoRow("District", beneficiary.district),
              _buildInfoRow("State", beneficiary.state),
            ]),

            const SizedBox(height: 20),
            _buildSectionHeader("Bank Details"),
            _buildInfoCard([
              _buildInfoRow("Account Holder", beneficiary.accountHolderName),
              _buildInfoRow("Account Number", beneficiary.accountNumber),
              _buildInfoRow("IFSC Code", beneficiary.ifsc),
              _buildInfoRow("Account Type", beneficiary.accountType),
              _buildInfoRow("Payment Status", beneficiary.paymentStatus, isStatus: true),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF55789A)),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : "N/A",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isStatus
                    ? (value == "PAID" ? Colors.green : Colors.orange)
                    : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
