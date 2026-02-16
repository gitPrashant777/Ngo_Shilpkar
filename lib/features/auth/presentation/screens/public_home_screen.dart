import 'package:flutter/material.dart';
import 'package:shilpkar/features/dashboard/presentation/screens/admin_login_screen.dart';
import 'package:shilpkar/features/admin/presentation/screens/admin_dashboard.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/GradientActionCard.dart';
import 'beneficiary_login_screen.dart';
import 'employee_login_screen.dart';

class PublicHomeScreen extends StatelessWidget {
  const PublicHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeroSection(),
            const SizedBox(height: 24),

            GradientActionCard(
              title: "Login as Employee",
              subtitle: "for field staff, coordinators and office team",
              icon: Icons.person_pin_rounded,
              gradientColors: AppColors.employeeGradient,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployeeLoginScreen())),            ),
            GradientActionCard(
              title: "Login as Beneficiary",
              subtitle: "for farmers, women, workers, students & citizens",
              icon: Icons.group_add_rounded,
              gradientColors: AppColors.beneficiaryGradient,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>  BeneficiaryLoginScreen())),            ),
            GradientActionCard(
              title: "Login as Admin",
              subtitle: "for admins and super-admin",
              icon: Icons.admin_panel_settings_rounded,
              gradientColors: AppColors.adminGradient,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>  AdminLoginScreen())),
            ),
            GradientActionCard(
              title: "Apply for a Job",
              subtitle: "View open positions and apply with your qualifications",
              icon: Icons.edit_document,
              gradientColors: AppColors.jobGradient,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>  AdminDashboard())),
            ),

            _buildSecondaryActions(),
            const SizedBox(height: 16),
            _buildInfoGrid(),
            const SizedBox(height: 16),
            _buildDonateCard(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildSecondaryActions() {
    return Row(
      children: [
        Expanded(
          child: _buildSquareBox(
            "Join Us on our social mission",
            "Be a part of beautiful change",
            "Join Now",
            Icons.groups_rounded,
            const Color(0xFFF1F4F7),
            const Color(0xFF55789A),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSquareBox(
            "Purpose Driven Products",
            "Every product you support creates impact",
            "Explore Products",
            Icons.shopping_bag_rounded,
            const Color(0xFFF1F4F7),
            const Color(0xFF7A9E6F),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGrid() {
    return Row(
      children: [
        Expanded(child: _buildMiniCard("Our Vision", "Why we Exist", Icons.track_changes_rounded, Colors.orange)),
        const SizedBox(width: 8),
        Expanded(child: _buildMiniCard("Our Work", "what we do on the ground", Icons.auto_graph_rounded, Colors.blue)),
        const SizedBox(width: 8),
        Expanded(child: _buildMiniCard("Our Impact", "Lives touched & villages reached", Icons.public_rounded, Colors.green)),
      ],
    );
  }
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.appBarBlue,
      elevation: 0,
      title: Row(
        children: [
          Image.asset('assets/Images/logoSk.png', height: 35), // Updated to your logo path
          const SizedBox(width: 8),
          const Text("Shilpkar Foundation", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
      actions: [
        _buildLanguageToggle(),
      ],
    );
  }
  Widget _buildHeroSection() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: const DecorationImage(
          // Updated to use your local asset image
          image: AssetImage('assets/Images/Frame2.png'),
          fit: BoxFit.cover,
          // Darken filter to make the white text readable
          colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
              "Welcome to Shilpkar Foundation",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Empowering communities with purpose driven actions",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: const Text("English  |  मराठी", style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }



  // Updated Square Box with proper Join Now / Explore buttons
  Widget _buildSquareBox(String title, String subtitle, String btnText, IconData icon, Color bg, Color accent) {
    return Container(
      padding: const EdgeInsets.all(12),
      height: 155, // Fixed height to match Figma aspect ratio
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F7), // Light greyish background from image
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2D3134)),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                elevation: 0,
              ),
              child: Text(btnText, style: const TextStyle(fontSize: 11, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  // Updated Mini Cards for the Info Grid
  Widget _buildMiniCard(String title, String subtitle, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      height: 75,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 4),
              Text(
                title,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2D3134)),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 8, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Updated Donate Card with the rounded pink button
  Widget _buildDonateCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite, color: Color(0xFFE93452), size: 30),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Donate",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2D3134)),
                ),
                Text(
                  "Your support help us reach more communities",
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE93452),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              elevation: 0,
            ),
            child: const Text("Donate", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.appBarBlue,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      currentIndex: 1,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: "Jobs"),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: "Schemes"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
      ],
    );
  }
}

