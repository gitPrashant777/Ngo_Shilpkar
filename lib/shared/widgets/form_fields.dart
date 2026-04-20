import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

// ─────────────────────────────────────────────────────────
// LABELED TEXT FIELD
// Label floats above input (not inside), white box, rounded border
// ─────────────────────────────────────────────────────────
class LabeledTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool obscureText;
  final String? hint;
  final bool readOnly;
  final int maxLines;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;

  const LabeledTextField({
    super.key,
    required this.label,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.obscureText = false,
    this.hint,
    this.readOnly = false,
    this.maxLines = 1,
    this.suffixIcon,
    this.onTap,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A4A4A),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            onChanged: onChanged,
            obscureText: obscureText,
            readOnly: readOnly,
            maxLines: maxLines,
            onTap: onTap,
            inputFormatters: inputFormatters,
            cursorColor: AppColors.appBarBlue,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: hint, // Let hint be null if not provided, allowing label as placeholder if desired
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              isDense: true,
              suffixIcon: suffixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColors.appBarBlue),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColors.appBarBlue),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColors.appBarBlue, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// LABELED DROPDOWN
// Label floats above dropdown (not inside), white box, rounded border
// ─────────────────────────────────────────────────────────
class LabeledDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;

  const LabeledDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A4A4A),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            validator: validator,
            isExpanded: true,
            iconEnabledColor: AppColors.appBarBlue,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
            decoration: InputDecoration(
               contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
               isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColors.appBarBlue),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColors.appBarBlue),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColors.appBarBlue, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Colors.red),
              ),
               focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// SECTION HEADER (bold title above a group of fields)
// ─────────────────────────────────────────────────────────
class FormSectionHeader extends StatelessWidget {
  final String title;
  const FormSectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.appBarBlue,
            ),
          ),
          const SizedBox(height: 6),
          Container(height: 2, width: 40, color: AppColors.appBarBlue),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// PRIMARY FORM BUTTON
// ─────────────────────────────────────────────────────────
class PrimaryFormButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryFormButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.appBarBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// PAGINATION FOOTER (shown at bottom of scrollable list)
// ─────────────────────────────────────────────────────────
class PaginationLoader extends StatelessWidget {
  const PaginationLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class NoPaginationEnd extends StatelessWidget {
  final String? message;
  const NoPaginationEnd({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          message ?? 'No more items',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
      ),
    );
  }
}
