import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/constants/app_colors.dart';

class AboutUsManagementScreen extends StatefulWidget {
  const AboutUsManagementScreen({super.key});

  @override
  State<AboutUsManagementScreen> createState() => _AboutUsManagementScreenState();
}

class _AboutUsManagementScreenState extends State<AboutUsManagementScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final client = ApiClient();
      final response = await client.dio.get(ApiEndpoints.cmsPage('about'));
      final raw = response.data;
      if (raw is Map && raw['data'] is Map) {
        final data = Map<String, dynamic>.from(raw['data']);
        _titleController.text = data['title']?.toString() ?? '';
        _contentController.text = data['content']?.toString() ?? '';

        final contact = data['contact'] is Map
            ? Map<String, dynamic>.from(data['contact'])
            : (data['contactUs'] is Map
                ? Map<String, dynamic>.from(data['contactUs'])
                : null);
        _addressController.text = contact?['address']?.toString() ?? '';
        _emailController.text = contact?['email']?.toString() ?? '';
        _websiteController.text = contact?['website']?.toString() ?? '';
        _phoneController.text = contact?['phone']?.toString() ?? '';
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final payload = <String, dynamic>{
        if (_titleController.text.trim().isNotEmpty)
          'title': _titleController.text.trim(),
        if (_contentController.text.trim().isNotEmpty)
          'content': _contentController.text.trim(),
        'contact': {
          if (_addressController.text.trim().isNotEmpty)
            'address': _addressController.text.trim(),
          if (_emailController.text.trim().isNotEmpty)
            'email': _emailController.text.trim(),
          if (_websiteController.text.trim().isNotEmpty)
            'website': _websiteController.text.trim(),
          if (_phoneController.text.trim().isNotEmpty)
            'phone': _phoneController.text.trim(),
        },
      };

      final client = ApiClient();
      await client.dio.patch(ApiEndpoints.adminAboutPage, data: payload);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('About Us updated successfully')),
      );
      Navigator.pop(context);
    } on DioException catch (e) {
      _showError(e.response?.data?['message']?.toString() ?? e.message);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String? msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg ?? 'Failed to update'), backgroundColor: AppColors.errorRed),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.refundBackground,
      appBar: AppBar(
        title: const Text('Edit About Us'),
        backgroundColor: AppColors.refundBackground,
        foregroundColor: AppColors.refundPrimaryText,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: Text(
              _isSaving ? 'Saving...' : 'Save',
              style: const TextStyle(color: AppColors.refundPrimaryButton),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _field('Title', _titleController, maxLines: 1),
                const SizedBox(height: 12),
                _field('Content', _contentController, maxLines: 8),
                const SizedBox(height: 16),
                const Text(
                  'Contact',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.refundPrimaryText),
                ),
                const SizedBox(height: 8),
                _field('Address', _addressController, maxLines: 3),
                const SizedBox(height: 10),
                _field('Email', _emailController, maxLines: 1),
                const SizedBox(height: 10),
                _field('Website', _websiteController, maxLines: 1),
                const SizedBox(height: 10),
                _field('Phone', _phoneController, maxLines: 1),
              ],
            ),
    );
  }

  Widget _field(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.refundSearchBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
