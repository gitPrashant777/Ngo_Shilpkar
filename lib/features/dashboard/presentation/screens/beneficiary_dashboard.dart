import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/action_card.dart';
import '../../../jobs/presentation/screens/user_job_list_screen.dart';
import '../../../schemes/presentation/screens/user_scheme_list_screen.dart';
import 'my_applications_screen.dart';

class BeneficiaryDashboard extends StatelessWidget {
  const BeneficiaryDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Primary Action: Apply for a Job (Matches Public Home style)
                  _buildFullWidthAction(
                    "Apply for a Job",
                    "View open positions and apply with your qualifications",
                    Icons.edit_document,
                    const Color(0xFFD9A05B),
                        () {
                      // Navigate to Job List
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const UserJobListScreen()));
                    },
                  ),
                  const SizedBox(height: 16),

                  // Secondary Actions Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildCategoryBox(
                          "My Schemes",
                          "Track your applied benefits",
                          "View Schemes",
                          Icons.assignment_turned_in_rounded,
                          const Color(0xFF55789A),
                              () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const UserSchemeListScreen()));
                              },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildCategoryBox(
                          "Products",
                          "Explore purpose driven products",
                          "Explore",
                          Icons.shopping_bag_rounded,
                          const Color(0xFF7A9E6F),
                              () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Info Grid (Our Vision, Work, Impact)
                  _buildInfoGrid(),
                  const SizedBox(height: 16),

                  // Connect with Admin / Support
                  _buildSupportCard(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF55789A),
      elevation: 0,
      title: Row(
        children: [
          Image.asset('assets/Images/logoSk.png', height: 40),
          const SizedBox(width: 8),
          const Text("Shilpkar Foundation",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text("Empowering communities with purpose driven actions",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBox(String title, String sub, String btnText, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(sub, style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 2),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(btnText, style: const TextStyle(fontSize: 11, color: Colors.white)),
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
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                  Text(sub, style: const TextStyle(fontSize: 11, color: Colors.white70)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Row(
      children: [
        _buildMiniCard("Our Vision", Icons.track_changes_rounded, Colors.orange),
        const SizedBox(width: 8),
        _buildMiniCard("Our Work", Icons.auto_graph_rounded, Colors.blue),
        const SizedBox(width: 8),
        _buildMiniCard("Our Impact", Icons.public_rounded, Colors.green),
      ],
    );
  }

  Widget _buildMiniCard(String title, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          const Icon(Icons.forum_outlined, color: Color(0xFF55789A), size: 30),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Connect with Admin", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("Connect to resolve queries", style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF55789A), shape: StadiumBorder()),
            child: const Text("Chat", style: TextStyle(color: Colors.white)),
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
        child: const Text("English | मराठी", style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF55789A),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      currentIndex: 1,
      onTap: (index) {
        if (index == 0) { // Jobs
           Navigator.push(context, MaterialPageRoute(builder: (_) => const UserJobListScreen()));
        } else if (index == 2) { // Schemes/Applications ? 
           // Let's make "Schemes" icon go to Scheme List or My Applications
           // Label is "Schemes". Maybe Scheme List?
           // But we also have "Bottom Nav -> Profile" which usually shows profile.
           // And "Schemes" usually means "View Schemes".
           Navigator.push(context, MaterialPageRoute(builder: (_) => const UserSchemeListScreen()));
        } else if (index == 3) { // Profile or "My Apps"
           // Let's simplify and make index 3 go to MyApplicationsScreen for now or Profile.
           // Since "Profile" label is there, it should go to Profile. 
           // But I don't have Profile screen in the plan yet, but I created MyApplicationsScreen.
           // I'll leave Profile as placeholder or route to MyApplicationsScreen temporarily or just a placeholder.
           Navigator.push(context, MaterialPageRoute(builder: (_) => const MyApplicationsScreen()));
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: "Jobs"),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: "Schemes"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Applications"),
      ],
    );
  }
}
