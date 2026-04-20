import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/app_colors.dart';
import '../../../data/models/order_model.dart';
import '../../providers/order_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ReplaceItemScreen extends StatefulWidget {
  final OrderModel order;

  const ReplaceItemScreen({super.key, required this.order});

  @override
  State<ReplaceItemScreen> createState() => _ReplaceItemScreenState();
}

class _ReplaceItemScreenState extends State<ReplaceItemScreen> {
  static const _primaryIssues = [
    'Wrong item was sent',
    'Item is defective or does not work',
    'Missing parts or accessories',
    'Damaged or used product',
  ];

  static const _secondaryIssues = [
    'Inaccurate website description',
    'Wrong style recieved',
    'Wrong brand recieved',
    'Product entirely different',
  ];

  String? _primarySelected;
  String? _secondarySelected;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_primarySelected == null || _secondarySelected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select all issues')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final reason =
          '$_primarySelected / $_secondarySelected. ${_commentController.text}';
      await Provider.of<OrderProvider>(context, listen: false)
          .createReturnRequest(widget.order.id, 'REPLACEMENT', reason);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Replacement request submitted!'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ECommerceColors.scaffold,
      body: Stack(
        children: [
          // Background Gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 350,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ECommerceColors.gradientStart,
                    ECommerceColors.gradientEnd,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Shilpkar Foundation',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          'Replace Item',
                          style: GoogleFonts.poppins(
                            color: const Color(0xff121212),
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Product Card
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: widget.order.productImage != null && widget.order.productImage!.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: widget.order.productImage!,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => const Icon(Icons.image_outlined, color: Colors.grey),
                                          errorWidget: (context, url, err) => const Icon(Icons.image_outlined, color: Colors.grey),
                                        )
                                      : const Icon(Icons.image_outlined, color: Colors.grey),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  widget.order.productName ?? 'Product',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: ECommerceColors.productName,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        Text(
                          'What is the Issue with the item?',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xff121212),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Primary Options Card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: _primaryIssues.map((opt) {
                              return RadioListTile<String>(
                                value: opt,
                                groupValue: _primarySelected,
                                onChanged: (val) => setState(() => _primarySelected = val),
                                activeColor: Colors.black,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                dense: true,
                                title: Text(opt, style: GoogleFonts.poppins(fontSize: 14)),
                              );
                            }).toList(),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        Text(
                          'Please tell us more',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xff121212),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Secondary Options Card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: _secondaryIssues.map((opt) {
                              return RadioListTile<String>(
                                value: opt,
                                groupValue: _secondarySelected,
                                onChanged: (val) => setState(() => _secondarySelected = val),
                                activeColor: Colors.black,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                dense: true,
                                title: Text(opt, style: GoogleFonts.poppins(fontSize: 14)),
                              );
                            }).toList(),
                          ),
                        ),


                        // Comment Section
                        const SizedBox(height: 24),
                        Text(
                          'Add a Comment',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xff121212),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _commentController,
                          maxLines: 4,
                          style: GoogleFonts.poppins(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Write something about the product',
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.grey[400],
                              fontSize: 13,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: ECommerceColors.gradientStart),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: 54,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: ECommerceColors.buyNowBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(color: ECommerceColors.buyNowText, strokeWidth: 2))
                  : Text('Submit Replace Request',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ECommerceColors.buyNowText,
                      )),
            ),
          ),
        ),
      ),
    );
  }
}
