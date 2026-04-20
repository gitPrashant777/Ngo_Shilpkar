import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../data/models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddEditProductScreen extends StatefulWidget {
  final ProductModel? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  
  // Changed from single controller to list of URLs
  List<String> _uploadedImages = [];
  
  String? _selectedCategoryId;
  bool _isFeatured = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    
    // Initialize images list
    if (widget.product != null) {
      _uploadedImages = List.from(widget.product!.images);
    }
    
    _selectedCategoryId = widget.product?.categoryId;
    _isFeatured = widget.product?.isFeatured ?? false;
    _isActive = widget.product?.isActive ?? true;

    // Fetch categories if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseSelectCategory)),
      );
      return;
    }
    if (_uploadedImages.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseUploadImage)),
      );
      return;
    }

    final productProvider = context.read<ProductProvider>();
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0;
    final description = _descriptionController.text.trim();

    final productData = {
      'name': name,
      'price': price,
      'description': description,
      'categoryId': _selectedCategoryId,
      'images': _uploadedImages, // Send list of images
      'isFeatured': _isFeatured,
      'isActive': _isActive,
    };

    try {
      if (widget.product != null) {
        await productProvider.updateProduct(widget.product!.id, productData);
      } else {
        await productProvider.createProduct(productData);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.product != null ? AppLocalizations.of(context)!.productUpdated : AppLocalizations.of(context)!.productCreated)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: Text(isEditing ? AppLocalizations.of(context)!.editProduct : AppLocalizations.of(context)!.addProduct),
        backgroundColor: AppColors.appBarBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CATEGORY DROPDOWN
              Consumer<CategoryProvider>(
                builder: (context, provider, _) {
                  return DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    items: provider.categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.category,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) => value == null ? AppLocalizations.of(context)!.selectCategory : null,
                  );
                },
              ),
              const SizedBox(height: 16),

              // NAME
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.productName,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? AppLocalizations.of(context)!.enterProductName : null,
              ),
              const SizedBox(height: 16),

              // PRICE
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.price,
                  border: const OutlineInputBorder(),
                  prefixText: "₹ ",
                ),
                validator: (value) {
                  if (value!.isEmpty) return AppLocalizations.of(context)!.enterPrice;
                  if (double.tryParse(value) == null) return AppLocalizations.of(context)!.enterValidNumber;
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // DESCRIPTION
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.description,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // IMAGE PICKER
              _buildImagePicker(),
              const SizedBox(height: 16),

              // SWITCHES
              SwitchListTile(
                title: Text(AppLocalizations.of(context)!.isFeatured),
                value: _isFeatured,
                onChanged: (val) => setState(() => _isFeatured = val),
              ),
              SwitchListTile(
                title: Text(AppLocalizations.of(context)!.isActive),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),
              
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: context.watch<ProductProvider>().isLoading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appBarBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: context.watch<ProductProvider>().isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isEditing ? AppLocalizations.of(context)!.updateProduct : AppLocalizations.of(context)!.createProduct,
                          style: const TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() => _isUploading = true);
        
        List<String> newUrls = [];
        final provider = context.read<ProductProvider>();
        
        for (var file in pickedFiles) {
           final url = await provider.uploadImage(file.path);
           newUrls.add(url);
        }
        
        setState(() {
          _uploadedImages.addAll(newUrls);
          _isUploading = false;
        });
        
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.imagesUploaded(newUrls.length))),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${AppLocalizations.of(context)!.uploadFailed}: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppLocalizations.of(context)!.productImages, style: const TextStyle(fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: _isUploading ? null : _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: Text(AppLocalizations.of(context)!.addImages),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        if (_isUploading)
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_uploadedImages.isEmpty)
           Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[100],
            ),
            child: Center(child: Text(AppLocalizations.of(context)!.noImagesSelected, style: const TextStyle(color: Colors.grey))),
           )
        else
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _uploadedImages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final imageUrl = _uploadedImages[index];
                return Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _uploadedImages.removeAt(index);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}


