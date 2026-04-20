import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/GradientActionCard.dart';
import '../providers/auth_provider.dart';
import 'beneficiary_login_screen.dart';
import 'employee_login_screen.dart';
import 'package:shilpkar/features/dashboard/presentation/screens/admin_login_screen.dart';
import 'package:shilpkar/features/dashboard/presentation/screens/my_payments_screen.dart';
import 'edit_profile_screen.dart';
import '../../../../features/ecommerce/presentation/providers/customer_auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isAuthenticated && auth.userProfile == null) {
        auth.fetchUserProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final customerAuth = Provider.of<CustomerAuthProvider>(context);

    final isBeneficiaryAdminNode = auth.isAuthenticated;
    final isCustomerNode = customerAuth.isAuthenticated;
    final isCompletelyGuest = !isBeneficiaryAdminNode && !isCustomerNode;

    final bottomInset = MediaQuery.of(context).padding.bottom;
    // 65 = nav bar height, give a small extra buffer so content clears the floating button
    final navBarClearance = 65.0 + bottomInset + 12.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false, // we handle bottom manually
        child: isCompletelyGuest
            ? _buildGuestViewWithPadding(context, navBarClearance)
            : (isBeneficiaryAdminNode
                ? _buildUserViewWithPadding(context, auth, navBarClearance)
                : _buildCustomerViewWithPadding(context, customerAuth, navBarClearance)),
      ),
    );
  }

  Widget _buildCustomerViewWithPadding(
    BuildContext context,
    CustomerAuthProvider customerAuth,
    double bottomPadding,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final customer = customerAuth.currentCustomer;

    if (customer == null) {
      return const Center(child: CircularProgressIndicator());
    }

    String joinDate = l10n.notAvailable;
    if (customer.createdAt != null) {
      final date = customer.createdAt!.toLocal();
      joinDate =
          "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  customer.fullName ?? "Guest User",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E5799),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.black,
                    size: 28,
                  ),
                  onSelected: (value) {
                    if (value == 'logout') {
                      customerAuth.logout();
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.logout,
                              size: 20,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(l10n.logout),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
          ),

          // Profile Overview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFFE0E0E0),
                  child: Icon(Icons.person, size: 40, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Text(
                  customer.fullName ?? 'Guest User',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(thickness: 1, height: 1, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 20),

          // Basic Details
          _buildSectionHeader(l10n.basicDetails),
          _buildDetailRow('Customer ID', customer.id),
          _buildDetailRow(
            l10n.phoneNumberField,
            customer.mobile ?? l10n.notAvailable,
          ),
          _buildDetailRow(l10n.emailField, customer.email.isNotEmpty ? customer.email : l10n.notAvailable),
          _buildDetailRow('Profile Created', joinDate),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildGuestViewWithPadding(
    BuildContext context,
    double bottomPadding,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            l10n.shilpkarFoundation,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E5799),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            l10n.welcomeGuest,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.pleaseLoginManageProfile,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          GradientActionCard(
            title: l10n.loginAsBeneficiary,
            subtitle: l10n.loginAsBeneficiarySubtitle,
            icon: Icons.group_add_rounded,
            gradientColors: AppColors.beneficiaryGradient,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BeneficiaryLoginScreen()),
            ),
          ),
          const SizedBox(height: 16),
          GradientActionCard(
            title: l10n.loginAsEmployee,
            subtitle: l10n.loginAsEmployeeSubtitle,
            icon: Icons.person_pin_rounded,
            gradientColors: AppColors.employeeGradient,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EmployeeLoginScreen()),
            ),
          ),
          const SizedBox(height: 16),
          GradientActionCard(
            title: l10n.loginAsAdmin,
            subtitle: l10n.loginAsAdminSubtitle,
            icon: Icons.admin_panel_settings_rounded,
            gradientColors: AppColors.adminGradient,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserViewWithPadding(
    BuildContext context,
    AuthProvider auth,
    double bottomPadding,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final user = auth.userProfile?.user;
    final profile = auth.userProfile?.profile;

    if (auth.isLoading && user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Role display: "Beneficiary, Student"
    String roleText = user?.role ?? l10n.userRole;
    // Convert to Title Case if needed, or keep as is. Usually roles are uppercase in DB.
    // Let's make it Title Case for display if it matches "BENEFICIARY"
    if (roleText == "BENEFICIARY") roleText = l10n.beneficiaryRole;

    if (profile?.category != null && profile!.category!.isNotEmpty) {
      roleText += ", ${profile.category}";
    }

    String foundationJoinDate = l10n.notAvailable;
    if (user?.createdAt != null) {
      try {
        final date = DateTime.parse(user!.createdAt!).toLocal();
        foundationJoinDate =
            "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
      } catch (_) {}
    }

    String profileJoinDate = l10n.notAvailable;
    if (profile?.createdAt != null) {
      try {
        final date = DateTime.parse(profile!.createdAt!).toLocal();
        profileJoinDate =
            "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
      } catch (_) {}
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.shilpkarFoundation,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E5799),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.black,
                    size: 28,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    } else if (value == 'logout') {
                      auth.logout();
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(l10n.editProfile),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.logout,
                              size: 20,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(l10n.logout),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
          ),

          // ── Profile Overview ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty
                      ? NetworkImage(profile.avatarUrl!)
                      : null,
                  child: (profile?.avatarUrl == null || profile!.avatarUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 40, color: Colors.grey)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  "${profile?.firstName ?? user?.username ?? l10n.userRole} ${profile?.lastName ?? ''}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  roleText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey, // 600
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(thickness: 1, height: 1, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 20),

          // ── Basic Details ────────────────────────────────────────────────────
          _buildSectionHeader(l10n.basicDetails),
          _buildDetailRow(
            'Customer ID',
            user?.id.toUpperCase() ?? l10n.notAvailable,
          ),
          _buildDetailRow(
            l10n.usernameField,
            user?.username ?? l10n.notAvailable,
          ),
          _buildDetailRow(
            l10n.phoneNumberField,
            user?.mobile ?? l10n.notAvailable,
          ),
          _buildDetailRow(l10n.emailField, user?.email ?? l10n.notAvailable),
          _buildDetailRow(
            l10n.dateOfBirthField,
            profile?.dob ?? l10n.notAvailable,
          ),

          // User Progress Tracking / Membership Dates
          _buildDetailRow('Foundation Joined', foundationJoinDate),
          _buildDetailRow('Profile Created', profileJoinDate),

          // ── Location Details ─────────────────────────────────────────────────
          const SizedBox(height: 10),
          _buildSectionHeader(l10n.locationDetails),
          _buildDetailRow(
            l10n.stateField,
            profile?.location.state ?? l10n.notAvailable,
          ),
          _buildDetailRow(
            l10n.districtField,
            profile?.location.district ?? l10n.notAvailable,
          ),
          _buildDetailRow(
            l10n.talukaField,
            profile?.location.taluka ?? l10n.notAvailable,
          ),
          _buildDetailRow(
            l10n.villageField,
            profile?.location.village ?? l10n.notAvailable,
          ),
          _buildDetailRow(
            l10n.addressField,
            profile?.location.address ?? l10n.notAvailable,
          ),

          // ── Banking Details ──────────────────────────────────────────────────
          const SizedBox(height: 10),
          _buildSectionHeader(l10n.bankingDetails),
          _buildDetailRow(
            l10n.accountNumberField,
            profile?.bankDetails.accountNumber ?? l10n.notAvailable,
          ),
          _buildDetailRow(
            l10n.accountHolderNameField,
            profile?.bankDetails.accountHolderName ?? l10n.notAvailable,
          ),
          _buildDetailRow(
            l10n.ifscCodeField,
            profile?.bankDetails.ifsc ?? l10n.notAvailable,
          ),
          _buildDetailRow(
            l10n.accountTypeField,
            profile?.bankDetails.accountType ?? l10n.notAvailable,
          ),
          _buildDetailRow(
            l10n.upiIdField,
            profile?.bankDetails.upiId ?? l10n.notAvailable,
          ),

          // ── My Payments ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyPaymentsScreen()),
                  );
                },
                icon: const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 20,
                ),
                label: const Text('My Payments / Transaction History'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),

          // ── Delete Account ───────────────────────────────────────────────────
          Center(
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(l10n.deleteAccount),
                    content: Text(l10n.deleteAccountConfirm),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          try {
                            await ApiClient().dio.post(
                              ApiEndpoints.userDeletionRequest,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n.accountDeletionSubmitted,
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to submit deletion request: $e',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: Text(
                          l10n.delete,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                l10n.deleteAccount,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      color: const Color(
        0xFFB0C4DE,
      ).withValues(alpha: 0.5), // Light Blue-Grey similar to image
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      margin: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          SizedBox(
            width: 140, // Fixed width for alignment
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF757575), // Grey
              ),
            ),
          ),
        ],
      ),
    );
  }
}
