import 'package:flutter/material.dart';
import 'package:shilpkar/features/employee/presentation/screens/MakeCoordinatorScreen.dart';

class EmployeeDashboard extends StatelessWidget {
  const EmployeeDashboard({super.key});

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
                  // Feature Card Row (Make Coordinators / Details)
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeatureCard(
                          "Make Coordinators",
                          "Add people in this good cause",
                          "Make Coordinator",
                          Icons.person_add_alt_1_outlined,
                          const Color(0xFF55789A),
                              ()  {
                                // Navigates to the specialized Admin creation screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const MakeCoordinatorScreen()),
                                );
                              },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFeatureCard(
                          "Coordinator Details",
                          "Add people in this good cause",
                          "See Details",
                          Icons.person_search_outlined,
                          const Color(0xFF7A9E6F),
                              () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Attendance Action Bar (Full Width)
                  _buildAttendanceAction(
                    "Attendance",
                    "Punch in and Punch Out time of coordinators",
                    const Color(0xFFD9A05B),
                        () {},
                  ),
                  const SizedBox(height: 24),

                  // Info Grid (Vision, Work, Impact)
                  _buildInfoGrid(),
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
          // Matches the logo placement in design
          Image.asset('assets/Images/logoSk.png', height: 35),
          const SizedBox(width: 8),
          const Text("Shilpkar Foundation",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
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
            Text("Welcome to Shilpkar Foundtion",
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

  Widget _buildFeatureCard(String title, String sub, String btnText, IconData icon, Color color, VoidCallback onTap) {
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(sub, style: const TextStyle(fontSize: 9, color: Colors.grey), maxLines: 2),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: Text(btnText, style: const TextStyle(fontSize: 10, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAttendanceAction(String title, String sub, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
            Text(sub, style: const TextStyle(fontSize: 11, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Row(
      children: [
        _buildMiniCard("Our Vision", "Why we Exist", Icons.track_changes_rounded, Colors.orange),
        const SizedBox(width: 8),
        _buildMiniCard("Our Work", "what we do", Icons.auto_graph_rounded, Colors.blue),
        const SizedBox(width: 8),
        _buildMiniCard("Our Impact", "village reached", Icons.public_rounded, Colors.green),
      ],
    );
  }

  Widget _buildMiniCard(String title, String sub, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            Text(sub, style: const TextStyle(fontSize: 8, color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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