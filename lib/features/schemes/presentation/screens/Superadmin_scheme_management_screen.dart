import 'package:flutter/material.dart';
import '../../../../core/utils/storage_service.dart';
import '../../data/models/scheme_model.dart';
import '../../data/repository/scheme_repository.dart';

class SuperAdminSchemeManagementScreen extends StatefulWidget {
  const SuperAdminSchemeManagementScreen({super.key});

  @override
  State<SuperAdminSchemeManagementScreen> createState() =>
      _SuperAdminSchemeManagementScreenState();
}

class _SuperAdminSchemeManagementScreenState extends State<SuperAdminSchemeManagementScreen> {
  final SchemeRepository _repository = SchemeRepository();
  final Color primaryBlue = const Color(0xFF4A78B0);

  List<SchemeModel> _schemes = [];
  bool _isLoading = true;
  String? _selectedStatus;
  String? _editingSchemeId;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _benefitsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSchemes();
  }

  // Logic remains identical as requested
  Future<void> _fetchSchemes() async {
    setState(() => _isLoading = true);
    try {
      final data = await _repository.getAdminSchemes(status: _selectedStatus, page: 1, limit: 20);
      setState(() { _schemes = data; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }
  Future<void> _createOrUpdateScheme() async {
    if (!_formKey.currentState!.validate()) return;

    final benefits = _benefitsController.text
        .split(",")
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final body = {
      "name": _nameController.text.trim(),
      "description": _descController.text.trim(),
      "benefits": benefits,
      "price": double.tryParse(_priceController.text) ?? 0,
    };

    try {
      print(await StorageService().getRole());

      if (_editingSchemeId == null) {
        // 🔥 CREATE + AUTO PUBLISH
        final schemeId = await _repository.createScheme(body);

        await _repository.updateSchemeStatus(
          schemeId,
          "PUBLISHED",
        );
      } else {
        await _repository.updateScheme(_editingSchemeId!, body);
      }

      _clearForm();
      _fetchSchemes();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Scheme saved successfully")),
      );

    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _updateStatus(String id, String status) async {
    try { await _repository.updateSchemeStatus(id, status); _fetchSchemes(); }
    catch (e) { _showError(e.toString()); }
  }

  void _editScheme(SchemeModel scheme) {
    setState(() {
      _editingSchemeId = scheme.id;
      _nameController.text = scheme.name;
      _descController.text = scheme.description;
      _priceController.text = scheme.price.toString();
      _benefitsController.text = scheme.benefits.join(", ");
    });
  }

  void _clearForm() {
    setState(() {
      _editingSchemeId = null;
      _nameController.clear();
      _descController.clear();
      _priceController.clear();
      _benefitsController.clear();
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageHeader(),
              _buildFormCard(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Divider(),
              ),
              _buildFilterSection(),
              _buildSchemeList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Shilpkar Foundation",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryBlue),
          ),
          const SizedBox(height: 10),
          const Text(
            "Schemes",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildCustomField("Scheme Name", _nameController, false),
            _buildCustomField("Description Of Scheme", _descController, true),
            _buildCustomField("Benefits of Scheme (comma separated)", _benefitsController, true),
            _buildCustomField("Price", _priceController, false, isNumeric: true),
            const SizedBox(height: 20),
            SizedBox(
              width: 160,
              height: 40,
              child: ElevatedButton(
                onPressed: _createOrUpdateScheme,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  _editingSchemeId == null ? "Create Scheme" : "Update Scheme",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (_editingSchemeId != null)
              TextButton(onPressed: _clearForm, child: const Text("Cancel Editing", style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomField(String label, TextEditingController controller, bool isLarge, {bool isNumeric = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          maxLines: isLarge ? 4 : 1,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryBlue.withOpacity(0.5)), borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryBlue), borderRadius: BorderRadius.circular(8)),
            errorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(8)),
            focusedErrorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(8)),
          ),
          validator: (v) => v!.isEmpty ? "Required" : null,
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Text("Filter: ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: DropdownButton<String>(
              value: _selectedStatus,
              hint: const Text("All Status"),
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: null, child: Text("All")),
                DropdownMenuItem(value: "DRAFT", child: Text("Draft")),
                DropdownMenuItem(value: "PUBLISHED", child: Text("Published")),
                DropdownMenuItem(value: "ARCHIVED", child: Text("Archived")),
              ],
              onChanged: (val) {
                setState(() => _selectedStatus = val);
                _fetchSchemes();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeList() {
    if (_isLoading) return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
    if (_schemes.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No Schemes Found")));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _schemes.length,
      itemBuilder: (context, index) {
        final scheme = _schemes[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: ListTile(
            title: Text(scheme.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Status: ${scheme.status}"),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => value == "edit" ? _editScheme(scheme) : _updateStatus(scheme.id, value),
              itemBuilder: (context) => [
                const PopupMenuItem(value: "edit", child: Text("Edit")),
                const PopupMenuItem(value: "PUBLISHED", child: Text("Publish")),
                const PopupMenuItem(value: "ARCHIVED", child: Text("Archive")),
              ],
            ),
          ),
        );
      },
    );
  }
}