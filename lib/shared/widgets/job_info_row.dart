import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// A reusable icon + label row used across Job list cards and Job detail screen.
class JobInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final double iconSize;
  final double fontSize;

  const JobInfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.iconSize = 15,
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: AppColors.textSecondary),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            style: TextStyle(color: AppColors.textSecondary, fontSize: fontSize),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Logo placeholder box — shown top-right on cards and detail screen.
class JobLogoPlaceholder extends StatelessWidget {
  final double size;
  const JobLogoPlaceholder({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.dividerGrey,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

/// Full-width primary CTA button used in Job detail and list cards.
class JobPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  const JobPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.lightBlueScheme,
          disabledBackgroundColor: AppColors.textSecondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
