import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shilpkar/core/api/api_client.dart';
import 'package:shilpkar/core/api/api_endpoints.dart';
import 'package:shilpkar/core/constants/app_colors.dart';
import 'package:shilpkar/core/services/location_service.dart';

/// Coordinator / Admin / Super Admin — submit a parcel for tracking.
class ParcelScreen extends StatefulWidget {
  const ParcelScreen({super.key});

  @override
  State<ParcelScreen> createState() => _ParcelScreenState();
}

class _ParcelScreenState extends State<ParcelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  bool _loading = false;
  bool _isLocating = false;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _nameCtrl.dispose(); _addrCtrl.dispose();
    _pinCtrl.dispose(); _phoneCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _result = null; });
    try {
      final client = ApiClient();
      final res = await client.dio.post(
        ApiEndpoints.parcels,
        data: {
          'recipientName': _nameCtrl.text.trim(),
          'address': _addrCtrl.text.trim(),
          'pincode': _pinCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'productDetails': _detailsCtrl.text.trim(),
        },
      );
      setState(() => _result = res.data['data']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('📦 Parcel submitted successfully!'),
          backgroundColor: Colors.green,
        ));
        _formKey.currentState!.reset();
        _nameCtrl.clear(); _addrCtrl.clear();
        _pinCtrl.clear(); _phoneCtrl.clear(); _detailsCtrl.clear();
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Request failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('❌ $msg'), backgroundColor: Colors.red,
      ));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _detectLocation() async {
    setState(() => _isLocating = true);
    try {
      final locData = await LocationService().detectAndResolveLocation();
      setState(() {
        _pinCtrl.text = locData['postalCode']?.toString() ?? _pinCtrl.text;
        
        List<String> streetParts = [];
        if (locData['village'] != null) streetParts.add(locData['village']);
        if (locData['taluka'] != null) streetParts.add(locData['taluka']);
        if (locData['district'] != null) streetParts.add(locData['district']);
        if (locData['state'] != null) streetParts.add(locData['state']);
        
        if (streetParts.isNotEmpty && _addrCtrl.text.isEmpty) {
          _addrCtrl.text = streetParts.join(", ");
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delivery address fetched!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to detect location: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  InputDecoration _deco(String label, String hint, IconData icon) => InputDecoration(
    labelText: label, hintText: hint,
    prefixIcon: Icon(icon, size: 20),
    filled: true, fillColor: Colors.grey.shade50,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.profileBlue)),
  );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFF2980B9),
          foregroundColor: Colors.white,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Parcels', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              Text('Manage logistics & shipments', style: TextStyle(fontSize: 11, color: Colors.white70)),
            ],
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Create Parcel'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Create Parcel
            _buildCreateTab(),
            // Tab 2: History
            _buildHistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateTab() {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Recipient Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameCtrl,
                      validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                      decoration: _deco('Recipient Name', 'Full name', Icons.person_outline),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v!.trim().isEmpty) return 'Required';
                        if (v.trim().length < 10) return 'Enter valid phone';
                        return null;
                      },
                      decoration: _deco('Phone', '10-digit mobile number', Icons.phone_outlined),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        _isLocating
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : TextButton.icon(
                                onPressed: _detectLocation,
                                icon: const Icon(Icons.my_location, size: 16),
                                label: const Text("Auto Detect", style: TextStyle(fontSize: 13)),
                              ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addrCtrl,
                      maxLines: 2,
                      validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                      decoration: _deco('Full Address', 'Street, Area, City', Icons.location_on_outlined),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pinCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v!.trim().isEmpty) return 'Required';
                        if (v.trim().length != 6) return 'Enter 6-digit pincode';
                        return null;
                      },
                      decoration: _deco('Pincode', '6-digit pincode', Icons.pin_drop_outlined),
                    ),
                    const SizedBox(height: 16),
                    const Text('Parcel Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _detailsCtrl,
                      maxLines: 3,
                      validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                      decoration: _deco('Product / Contents', 'e.g. Uniform and ID 2x, Books 3x', Icons.inventory_outlined),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _submit,
                        icon: _loading
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.local_shipping_outlined),
                        label: Text(_loading ? 'Submitting...' : 'Submit Parcel'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2980B9),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Tracking ID card
              if (_result != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2980B9), Color(0xFF27AE60)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.local_shipping, color: Colors.white, size: 36),
                      const SizedBox(height: 10),
                      const Text('Parcel Created!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 6),
                      Text(
                        _result!['trackingId'] ?? '-',
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2),
                      ),
                      const SizedBox(height: 4),
                      Text('Status: ${_result!['status'] ?? 'CREATED'}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
  }

  Widget _buildHistoryTab() {
    return FutureBuilder<Response>(
      future: ApiClient().dio.get(ApiEndpoints.parcels),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Failed to load history', style: TextStyle(color: Colors.red.shade400)),
          );
        }
        
        final data = snapshot.data?.data['data'];
        final parcels = (data is List) ? data.cast<Map<String, dynamic>>() : [];
        if (parcels.isEmpty) {
          return const Center(child: Text('No parcels created yet', style: TextStyle(color: Colors.grey)));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: parcels.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (ctx, i) {
            final p = parcels[i];
            final trkId = p['trackingId'] ?? '-';
            final status = p['status'] ?? 'CREATED';
            final name = p['recipientName'] ?? 'Unknown';
            final phone = p['phone'] ?? '';
            final pin = p['pincode'] ?? '';
            final details = p['productDetails'] ?? '-';

            Color statusColor;
            switch(status) {
              case 'CREATED': statusColor = Colors.blue; break;
              case 'SHIPPED': statusColor = Colors.orange; break;
              case 'DELIVERED': statusColor = Colors.green; break;
              default: statusColor = Colors.grey;
            }

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(trkId, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.2)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: statusColor.withOpacity(0.5)),
                        ),
                        child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                      ),
                    ],
                  ),
                  const Divider(),
                  _row('Recipient', name),
                  _row('Phone', phone),
                  _row('Pincode', pin),
                  _row('Details', details),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 70, child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12))),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
      ],
    ),
  );
}
