import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/main_navigation.dart';
import '../../../../shared/widgets/dashboard_info_card.dart';
import '../../../attendance/presentation/screens/attendance_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/screens/chat_list_screen.dart'; // Maybe used for navigation
// import '../../../chat/presentation/screens/broadcast_list_screen.dart' as shilpkar;
import '../../../chat/presentation/screens/chat_request_screen.dart'; // Adjust path as needed
import '../../../ecommerce/presentation/screens/public/product_list_screen.dart';
import '../../../home/presentation/providers/homepage_provider.dart';
import '../../../chat/presentation/screens/public_broadcast_screen.dart';
import 'package:shilpkar/features/notifications/presentation/widgets/notification_bell.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  @override
  void initState() {
    super.initState();
     WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomepageProvider>().fetchHomepage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAppBar(context),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeroSection(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildAttendanceAction(
                        "Attendance",
                        "Punch in and Punch Out time of coordinators",
                        const Color(0xFFD9A05B),
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AttendanceScreen()),
                              );
                            },
                      ),
                      const SizedBox(height: 16),
    
                      DashboardInfoCard(
                        icon: Icons.forum_rounded,
                        iconColor: AppColors.primaryBlue,
                        title: "Connect with Admin",
                        subtitle: "Resolve queries",
                        buttonLabel: "Chat Now",
                        buttonColor: AppColors.primaryBlue,
                        bgColor: AppColors.joinUsBg,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatRequestScreen())),
                      ),
                      const SizedBox(height: 16),
                      
                      DashboardInfoCard(
                        icon: Icons.campaign_rounded,
                        iconColor: const Color(0xFF6B8E23),
                        title: "Announcements",
                        subtitle: "View important system messages",
                        buttonLabel: "View All",
                        buttonColor: const Color(0xFF6B8E23),
                        bgColor: const Color(0xFFF1F8E9),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PublicBroadcastScreen())),
                      ),
                      const SizedBox(height: 24),
    
                      _buildInfoGrid(),
                       const SizedBox(height: 40), 
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF55789A),
      elevation: 0,
      title: Row(
        children: [
          // Matches the logo placement in design
          Image.asset('assets/Images/logoSk.png', height: 40),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              "Shilpkar Employee",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        _buildLanguageToggle(),
        const NotificationBell(iconColor: Colors.white),
        const SizedBox(width: 2),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () async {
            try {
              // Call provider logout to clear state (if needed in your AuthProvider)
              debugPrint("EmployeeDashboard: Calling logout...");
              await context.read<AuthProvider>().logout();
            } catch (e) {
              debugPrint("EmployeeDashboard: Logout error: $e");
            }
            // Navigate away
            if (context.mounted) {
               Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const MainNavigationScreen(initialIndex: 1),
                ),
                    (route) => false,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Consumer<HomepageProvider>(
      builder: (context, provider, _) {
          String? bannerUrl;
          if (provider.homepage != null && provider.homepage!.coverImages.isNotEmpty) {
            bannerUrl = provider.homepage!.coverImages.first.url;
          }
        return Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: bannerUrl != null 
                  ? NetworkImage(bannerUrl) 
                  : const AssetImage('assets/Images/Frame2.png') as ImageProvider,
              fit: BoxFit.cover,
              colorFilter: const ColorFilter.mode(Colors.black45, BlendMode.darken),
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
}