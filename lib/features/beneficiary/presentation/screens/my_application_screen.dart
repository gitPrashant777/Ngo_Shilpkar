import 'package:flutter/material.dart';

import '../../../schemes/presentation/screens/my_scheme_applications_screen.dart';
import '../../../../features/jobs/presentation/screens/user_job_list_screen.dart';


class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Applications", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4373AD),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
          tabs: const [
            Tab(text: "Jobs"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          UserJobListScreen(),
        ],
      ),
    );
  }
}
