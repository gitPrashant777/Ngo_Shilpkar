import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color appBarBlue = Color(0xFF55789A);
  static const Color backgroundGrey = Color(0xFFF8F9FB);

  // Gradient Card Colors (Start to End)
  static const List<Color> employeeGradient = [Color(0xFF638FB4), Colors.white];
  static const List<Color> beneficiaryGradient = [Color(0xFF7A9E6F), Colors.white];
  static const List<Color> adminGradient = [Color(0xFFD45D5D), Colors.white];
  static const List<Color> jobGradient = [Color(0xFFD9A05B), Colors.white];

  // Info Box Colors
  static const Color joinUsBg = Color(0xFFE8EEF4);
  static const Color productsBg = Color(0xFFE8F1E8);
  static const Color primaryBlue = Color(0xFF4A749B);
  static const Color employeeCard = Color(0xFF638FB4);
  static const Color beneficiaryCard = Color(0xFF7A9E6F);
  static const Color adminCard = Color(0xFFD45D5D);
  static const Color jobCard = Color(0xFFD9A05B);
  static const Color footerBlue = Color(0xFF4A749B);
  static const Color secondaryGreen = Color(0xFF6DAE6B);
  static const Color accentRed = Color(0xFFE93452);

  // Background & Surface
  static const Color background = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF2D3134);
  static const Color textSecondary = Color(0xFF6C757D);

  // Role Specific (from your design)
  static const Color roleSelectedBg = Color(0xFFE3EDF7);

  // ── NEW: Attendance / Teal ──────────────────────────────────────────────────
  static const Color attendanceTeal = Color(0xFF00897B);
  static const Color attendanceTealBg = Color(0xFFE0F2F1);

  // ── NEW: Announcements / Olive ─────────────────────────────────────────────
  static const Color announcementOlive = Color(0xFF6B8E23);
  static const Color announcementOliveBg = Color(0xFFF1F8E9);

  // ── NEW: Pillar Card Backgrounds ───────────────────────────────────────────
  static const Color visionBg = Color(0xFFE8F5E9);
  static const Color workBg = Color(0xFFE3F2FD);
  static const Color impactBg = Color(0xFFFCE4EC);

  // ── NEW: Scheme Container Colors ───────────────────────────────────────────
  static const Color schemeGreen = Color(0xFF388E3C);
  static const Color schemeGreenLight = Color(0xFFE8F5E9);
  static const Color schemeBorder = Color(0xFFA5D6A7);
  static const Color schemeGradientEnd = Color(0xFF1E5799);

  // ── NEW: Misc ──────────────────────────────────────────────────────────────
  static const Color broadcastOrange = Color(0xFFFF9800);
  static const Color donateIconRed = Color(0xFFFF5252);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color sectionHeaderBg = Color(0xFFB0C4DE);
  static const Color profileBlue = Color(0xFF1E5799);
  static const Color dividerGrey = Color(0xFFE0E0E0);
  static const Color textGrey = Color(0xFF757575);
  static const Color debugRedBg = Color(0x0DFF0000);
  static const Color debugRedBorder = Color(0x4DFF0000);

  // ── Attendance Status Colors ───────────────────────────────────────────────
  static const Color statusGreen = Color(0xFF43A047);      // PRESENT / punch-in
  static const Color statusActiveBlue = Color(0xFF1E88E5); // ACTIVE / timer
  static const Color statusRed = Color(0xFFE53935);        // ABSENT / punch-out
  static const Color statusOrange = Color(0xFFFF9800);     // HALF_DAY (same as broadcastOrange)

  // ── Scheme / Job Screens ───────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF5F7F9);  // scaffold bg for many screens
  static const Color lightBlueScheme = Color(0xFF4A78B0);  // scheme primary blue accent
  static const Color darkNavyBlue = Color(0xFF3A5A7E);     // gradient end for attendance banner
  static const Color schemeGreenDark = Color(0xFF1B5E20);  // dark green in public scheme gate

  // ── Status / Pinned Indicators ────────────────────────────────────────────
  static const Color goldYellow = Color(0xFFFFD700);       // pinned border/icon
  static const Color darkOrange = Color(0xFFFF8C00);       // pinned push-pin icon
  static const Color pinnedBg = Color(0xFFFFF8E1);         // pinned card background

  // ── E-Commerce Colors ─────────────────────────────────────────────────────
  static const Color shopAccentOrange = Color(0xFFFFA000);  // Buy Now / CTA button
  static const Color shopPricePrimary  = Color(0xFF2E7D32); // Price text (dark green)
  static const Color shopSelectedBorder= Color(0xFF1565C0); // Selected order card border (blue)
  static const Color shopStarGold     = Color(0xFFFFB300);  // Star rating gold
  static const Color shopDeliveredGreen= Color(0xFF43A047); // Delivered status
  static const Color shopOrderCardBg  = Color(0xFFFFFFFF);  // Order card white
  static const Color shopOrderBuyAgainBg = Color(0xFFF5F5F5); // Buy Again section bg
  static const Color shopSectionTitle = Color(0xFF1A1A1A);  // Section bold titles
  static const Color shopBodyGrey     = Color(0xFFF0F2F5);  // Overall scaffold background
  static const Color shopBlueCta      = Color(0xFF1565C0);  // Blue CTA buttons (Replace/Refund)
  static const Color shopRefundPurple = Color(0xFF7B1FA2);  // Refund status purple
  static const Color shopDivider      = Color(0xFFE0E0E0);  // Divider lines
}