import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../providers/category_provider.dart';

class AdminCategoryManagementScreen extends StatefulWidget {
  final bool embedded;
  const AdminCategoryManagementScreen({super.key, this.embedded = false});

  @override
  State<AdminCategoryManagementScreen> createState() =>
      _AdminCategoryManagementScreenState();
}

class _AdminCategoryManagementScreenState
    extends State<AdminCategoryManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
    });
  }

  void _showCategoryDialog({String? id, String? currentName}) {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController controller =
        TextEditingController(text: currentName);
    final isEditing = id != null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(isEditing ? l10n.editCategory : l10n.newCategory,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.categoryName,
                  hintText: l10n.categoryNameHint,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.category_outlined),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  Text(l10n.cancel, style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.appBarBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  final provider = context.read<CategoryProvider>();
                  Navigator.pop(context);
                  try {
                    if (isEditing) {
                      await provider.updateCategory(id, name);
                    } else {
                      await provider.createCategory(name);
                    }
                    _showToast(
                        isEditing ? l10n.categoryUpdated : l10n.categoryCreated,
                        Colors.green);
                  } catch (e) {
                    _showToast("Error: $e", Colors.red);
                  }
                }
              },
              child: Text(isEditing ? l10n.update : l10n.create,
                  style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showToast(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  void _confirmDelete(String id, String name) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.warning_amber_rounded,
            color: Colors.red, size: 40),
        content: Text(l10n.deleteCategoryConfirm(name),
            textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.keepIt),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, elevation: 0),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<CategoryProvider>().deleteCategory(id);
                _showToast(l10n.categoryDeleted, Colors.orange);
              } catch (e) {
                _showToast("Error: $e", Colors.red);
              }
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final body = Consumer<CategoryProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (provider.error != null) {
          return _buildErrorState(provider, l10n);
        }

        final categories = provider.categories;

        if (categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.category_outlined,
                    size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                Text(l10n.noCategoriesFound,
                    style: const TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: AppColors.appBarBlue.withOpacity(0.1),
                  child: Text(
                    category.name.isNotEmpty
                        ? category.name[0].toUpperCase()
                        : "?",
                    style: TextStyle(
                        color: AppColors.appBarBlue,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  category.name,
                  style:
                      const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _actionButton(
                      icon: Icons.edit_note_rounded,
                      color: Colors.blue,
                      onTap: () => _showCategoryDialog(
                          id: category.id, currentName: category.name),
                    ),
                    const SizedBox(width: 8),
                    _actionButton(
                      icon: Icons.delete_sweep_rounded,
                      color: Colors.redAccent,
                      onTap: () => _confirmDelete(category.id, category.name),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (widget.embedded) {
      return Container(
        color: const Color(0xFFF4F7FA),
        child: body,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: Text(
          l10n.categoriesTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.appBarBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<CategoryProvider>().fetchCategories(),
          ),
        ],
      ),
      body: body,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(),
        backgroundColor: AppColors.secondaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          l10n.addCategory,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _actionButton(
      {required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  Widget _buildErrorState(CategoryProvider provider, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 60, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text("${provider.error}", textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => provider.fetchCategories(),
              child: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}
