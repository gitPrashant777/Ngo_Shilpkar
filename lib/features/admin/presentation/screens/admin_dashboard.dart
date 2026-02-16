import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/action_card.dart';
import 'MakeAdminScreen.dart';
import 'MakeEmployeeScreen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Row for User Management
                  // lib/features/admin/presentation/screens/admin_dashboard.dart

                  Row(
                    children: [
                      Expanded(
                        child: _buildAdminFeatureBox(
                          "Make Others Admin",
                          "Add people in this good cause",
                          "Make Admin",
                          Icons.admin_panel_settings,
                          const Color(0xFF638FB4),
                              () {
                            // Navigates to the specialized Admin creation screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const MakeAdminScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildAdminFeatureBox(
                          "Make Employee",
                          "Add people in this good cause",
                          "Make Employee",
                          Icons.person_add,
                          const Color(0xFF7A9E6F),
                              () {
                            // Navigates to the multi-step Employee creation screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const MakeEmployeeScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Payment Fixture Bar
                  _buildFullWidthAction(
                    "Payment Fixture",
                    "Fix payments for beneficiaries",
                    Icons.currency_rupee,
                    const Color(0xFFD9A05B),
                        () {},
                  ),
                  const SizedBox(height: 16),

                  // Management Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildAdminFeatureBox(
                          "Beneficiary Details",
                          "check details of people connected with you",
                          "See Details",
                          Icons.group,
                          const Color(0xFF638FB4),
                              () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildAdminFeatureBox(
                          "Job Requests",
                          "Check details of people who applied for jobs",
                          "Make Employee",
                          Icons.work_history,
                          const Color(0xFF638FB4),
                              () {}, // Logic to review applications
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Payment History Bar
                  _buildFullWidthAction(
                    "Payment History",
                    "Check payment history",
                    Icons.history,
                    const Color(0xFFB4C8B4),
                        () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF55789A),
      elevation: 0,
      title: Row(
        children: [
          Image.asset('assets/Images/logoSk.png', height: 40),
          const SizedBox(width: 8),
          const Text("Shilpkar Foundation", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
      actions: [
        _buildLanguageToggle(),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/Images/Frame2.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome to Shilpkar Foundation",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Empowering communities with purpose driven actions",
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminFeatureBox(String title, String sub, String btn, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(sub, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(backgroundColor: color, elevation: 0),
              child: Text(btn, style: const TextStyle(fontSize: 11, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFullWidthAction(String title, String sub, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(sub, style: const TextStyle(fontSize: 12, color: Colors.black45)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: const Text("English | मराठी", style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF55789A),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.work), label: "Jobs"),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.description), label: "Schemes"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}