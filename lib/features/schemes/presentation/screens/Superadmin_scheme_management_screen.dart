import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/scheme_provider.dart';
import '../../data/models/scheme_model.dart';
import '../../data/repository/scheme_repository.dart';
import 'scheme_applications_admin_screen.dart';
import 'scheme_dashboard_screen.dart';

class SuperAdminSchemeManagementScreen extends StatefulWidget {
  const SuperAdminSchemeManagementScreen({super.key});

  @override
  State<SuperAdminSchemeManagementScreen> createState() =>
      _SuperAdminSchemeManagementScreenState();
}

class _SuperAdminSchemeManagementScreenState extends State<SuperAdminSchemeManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _benefitsController = TextEditingController();
  
  String _schemeType = "PAID";
  String _financialType = "SUBSIDY";
  String _payoutMode = "MONTHLY";
  
  String? _editingSchemeId;
  bool _isSaving = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SchemeProvider>().fetchAdminSchemes(refresh: true);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _benefitsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _clearForm() {
    setState(() {
      _editingSchemeId = null;
      _nameController.clear();
      _descController.clear();
      _priceController.clear();
      _benefitsController.clear();
      _schemeType = "PAID";
      _financialType = "SUBSIDY";
      _payoutMode = "MONTHLY";
      _isSaving = false;
    });
  }

  void _editScheme(SchemeModel scheme) {
    setState(() {
      _editingSchemeId = scheme.id;
      _nameController.text = scheme.name;
      _descController.text = scheme.description;
      _priceController.text = scheme.price.toString();
      _benefitsController.text = scheme.benefits.join(", ");
      
      _schemeType = scheme.schemeType;
      _financialType = scheme.financialType;
      _payoutMode = scheme.payoutMode;
    });
    
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  Future<void> _createOrUpdateScheme() async {
    if (!_formKey.currentState!.validate()) return;

    final benefits = _benefitsController.text
        .split(",")
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final auth = context.read<AuthProvider>();
    final provider = context.read<SchemeProvider>();
    final l10n = AppLocalizations.of(context)!;
    
    if (auth.userProfile == null) await auth.fetchUserProfile();
    final userId = auth.userProfile?.user.id;

    final body = {
      "name": _nameController.text.trim(),
      "description": _descController.text.trim(),
      "benefits": benefits,
      "price": double.tryParse(_priceController.text) ?? 0,
      "schemeType": _schemeType,
      "financialType": _financialType,
      "payoutMode": _payoutMode,
      "status": "DRAFT",
      "startDate": DateTime.now().toIso8601String(),
      "endDate": DateTime.now().add(const Duration(days: 365)).toIso8601String(),
    };

    if (userId != null && userId.isNotEmpty) body["createdBy"] = userId;

    setState(() => _isSaving = true);

    try {
      if (_editingSchemeId == null) {
        final success = await provider.createScheme(body);
        if (success) {
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.schemeCreatedDrafted), backgroundColor: Colors.green),
            );
            _clearForm();
          }
        } else {
           if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.error ?? l10n.failedToCreate, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
        }
      } else {
        await provider.updateSchemeStatus(_editingSchemeId!, "DRAFT");
        final SchemeRepository repo = SchemeRepository();
        await repo.updateScheme(_editingSchemeId!, body);
        await provider.fetchAdminSchemes(refresh: true);
        
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.schemeUpdated)),
          );
          _clearForm();
        }
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteScheme(String id) async {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<SchemeProvider>();
    final conf = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: Text(l10n.deleteScheme),
      content: Text(l10n.deleteSchemeConfirm),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
        ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: Text(l10n.delete)),
      ],
    ));
    if (conf != true || !mounted) return;

    final suc = await provider.deleteScheme(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(suc ? l10n.schemeDeleted : l10n.failedToDelete),
        backgroundColor: suc ? Colors.red : Colors.orange,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(l10n.schemeManagement, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => context.read<SchemeProvider>().fetchAdminSchemes(refresh: true),
          )
        ],
      ),
      body: Consumer<SchemeProvider>(
        builder: (context, provider, child) {
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(child: _buildFormCard(l10n)),
              SliverToBoxAdapter(child: _buildFilterTabs(provider)),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _buildSchemeListItem(provider.adminSchemes[index], provider, l10n);
                  },
                  childCount: provider.adminSchemes.length,
                ),
              ),
              if (!provider.isLoading && provider.adminSchemes.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(child: Text(l10n.noSchemesFound, style: const TextStyle(color: Colors.grey))),
                  ),
                ),
              SliverToBoxAdapter(
                child: _AdminPaginationBar(
                  currentPage: provider.adminSchemesCurrentPage,
                  totalPages: provider.adminSchemesTotalPages,
                  isLoading: provider.isLoading,
                  onPageChanged: (p) => provider.goToAdminSchemesPage(p),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFormCard(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _editingSchemeId == null ? l10n.createNewScheme : l10n.editScheme,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            _buildCustomField(l10n.schemeName, _nameController, false),
            _buildCustomField(l10n.description, _descController, true),
            _buildCustomField(l10n.benefitsCommaSep, _benefitsController, true),
            
            Row(
              children: [
                Expanded(child: _buildDropdown(l10n.schemeType, ["FREE", "PAID"], _schemeType, (v) => setState(() => _schemeType = v!))),
                const SizedBox(width: 12),
                Expanded(child: _buildCustomField(l10n.priceInr, _priceController, false, isNumeric: true)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildDropdown(l10n.financial, ["SUBSIDY", "LOAN", "GRANT"], _financialType, (v) => setState(() => _financialType = v!))),
                const SizedBox(width: 12),
                Expanded(child: _buildDropdown(l10n.payoutMode, ["MONTHLY", "ONE_TIME", "MILESTONE"], _payoutMode, (v) => setState(() => _payoutMode = v!))),
              ],
            ),
            const SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: _isSaving ? null : _createOrUpdateScheme,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      _editingSchemeId == null ? l10n.createScheme : l10n.saveChanges,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
            ),
            if (_editingSchemeId != null)
              TextButton(
                onPressed: _clearForm,
                child: Text(l10n.cancelEditing, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> options, String currentValue, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentValue,
              isExpanded: true,
              items: options.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomField(String label, TextEditingController controller, bool isLarge, {bool isNumeric = false}) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: isLarge ? 3 : 1,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        validator: (v) => v!.isEmpty ? l10n.required : null,
      ),
    );
  }

  Widget _buildFilterTabs(SchemeProvider provider) {
    final filters = ["ALL", "DRAFT", "PUBLISHED", "ARCHIVED"];
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, idx) {
          final f = filters[idx];
          final isSel = provider.adminSchemesFilter == f;
          return GestureDetector(
            onTap: () => provider.fetchAdminSchemes(refresh: true, statusFilter: f),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSel ? AppColors.primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSel ? AppColors.primaryBlue : Colors.grey.shade300),
              ),
              alignment: Alignment.center,
              child: Text(
                f,
                style: TextStyle(
                  color: isSel ? Colors.white : Colors.black87,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSchemeListItem(SchemeModel scheme, SchemeProvider provider, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  scheme.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildStatusBadge(scheme.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(scheme.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 12),
          
          Row(
            children: [
              _buildInfoChip(Icons.currency_rupee, scheme.price > 0 ? scheme.price.toStringAsFixed(0) : "FREE"),
              const SizedBox(width: 8),
              _buildInfoChip(Icons.account_balance_wallet, scheme.financialType),
              const SizedBox(width: 8),
              _buildInfoChip(Icons.calendar_month, scheme.payoutMode),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (scheme.status == "DRAFT")
                    _buildActionButton(l10n.publish, Colors.green, () => provider.updateSchemeStatus(scheme.id, "PUBLISHED")),
                  if (scheme.status == "PUBLISHED")
                    _buildActionButton(l10n.archive, Colors.orange, () => provider.updateSchemeStatus(scheme.id, "ARCHIVED")),
                  if (scheme.status == "ARCHIVED")
                    _buildActionButton(l10n.republish, Colors.green, () => provider.updateSchemeStatus(scheme.id, "PUBLISHED")),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.people_outline, color: Colors.teal, size: 20),
                    tooltip: l10n.viewApplications,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SchemeApplicationsAdminScreen(
                          schemeId: scheme.id,
                          schemeName: scheme.name,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.dashboard_outlined, color: Colors.blueGrey, size: 20),
                    tooltip: l10n.viewDashboard,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SchemeDashboardScreen(
                          schemeId: scheme.id,
                          schemeName: scheme.name,
                        ),
                      ),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 20), onPressed: () => _editScheme(scheme)),
                  IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () => _deleteScheme(scheme.id)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color tc;
    if (status == "PUBLISHED") { bg = Colors.green.shade100; tc = Colors.green.shade800; }
    else if (status == "ARCHIVED") { bg = Colors.orange.shade100; tc = Colors.orange.shade800; }
    else { bg = Colors.grey.shade200; tc = Colors.grey.shade800; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(color: tc, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.blue.shade700),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _AdminPaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final bool isLoading;
  final Function(int) onPageChanged;

  const _AdminPaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.isLoading,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: (currentPage > 1 && !isLoading) ? () => onPageChanged(currentPage - 1) : null,
            icon: Icon(Icons.chevron_left, color: (currentPage > 1) ? AppColors.primaryBlue : Colors.grey),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${AppLocalizations.of(context)!.page} $currentPage ${AppLocalizations.of(context)!.ofText} $totalPages",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          IconButton(
            onPressed: (currentPage < totalPages && !isLoading) ? () => onPageChanged(currentPage + 1) : null,
            icon: Icon(Icons.chevron_right, color: (currentPage < totalPages) ? AppColors.primaryBlue : Colors.grey),
          ),
        ],
      ),
    );
  }
}
