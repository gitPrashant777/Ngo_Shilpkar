// lib/features/schemes/presentation/screens/scheme_detail_screen.dart

import 'package:flutter/material.dart';
import '../../data/models/scheme_model.dart';
import '../../data/repository/scheme_repository.dart';

class SchemeDetailScreen extends StatefulWidget {
  final SchemeModel scheme;

  const SchemeDetailScreen({super.key, required this.scheme});

  @override
  State<SchemeDetailScreen> createState() => _SchemeDetailScreenState();
}

class _SchemeDetailScreenState extends State<SchemeDetailScreen> {
  final SchemeRepository _repository = SchemeRepository();
  final Color primaryBlue = const Color(0xFF4A78B0); // Matches your Foundation theme

  bool _isApplying = false;
  bool _isWithdrawLoading = false;
  bool _hasApplied = false;
  String? _applicationId;

  @override
  void initState() {
    super.initState();
    _checkIfApplied();
  }

  Future<void> _checkIfApplied() async {
    try {
      final apps = await _repository.getMyApplications();
      for (var app in apps) {
        if (app.schemeId == widget.scheme.id && app.isActive) {
          if (mounted) {
            setState(() {
              _hasApplied = true;
              _applicationId = app.id;
            });
          }
          break;
        }
      }
    } catch (_) {}
  }

  Future<void> _apply() async {
    setState(() => _isApplying = true);
    try {
      await _repository.applyForScheme(widget.scheme.id);
      if (mounted) setState(() => _hasApplied = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Application submitted successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  Future<void> _withdraw() async {
    if (_applicationId == null) return;
    setState(() => _isWithdrawLoading = true);
    try {
      await _repository.withdrawApplication(_applicationId!);
      if (mounted) {
        setState(() {
          _hasApplied = false;
          _applicationId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Application withdrawn successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isWithdrawLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = widget.scheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        title: const Text("Scheme Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header Section ---
                  Text(
                    scheme.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 15),

                  // --- Description Section ---
                  const Text(
                    "Description",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    scheme.description,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.5),
                  ),

                  const SizedBox(height: 25),

                  // --- Benefits Section ---
                  const Text(
                    "Key Benefits",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...scheme.benefits.map((b) => _buildBenefitCard(b)),
                ],
              ),
            ),
          ),

          // --- Sticky Bottom Button Bar ---
          _buildBottomActionArea(),
        ],
      ),
    );
  }

  Widget _buildBenefitCard(String benefit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              benefit,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: _hasApplied
              ? OutlinedButton(
            onPressed: _isWithdrawLoading ? null : _withdraw,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: _isWithdrawLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
                : const Text("WITHDRAW APPLICATION", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          )
              : ElevatedButton(
            onPressed: _isApplying ? null : _apply,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: _isApplying
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text("APPLY NOW", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        ),
      ),
    );
  }
}