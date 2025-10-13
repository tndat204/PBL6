import 'package:flutter/material.dart';



class AdminDashboard extends StatelessWidget {
 

  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.red, // Mock color for admin
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings, size: 100, color: Colors.red),
            SizedBox(height: 20),
            Text(
              'Welcome to Admin Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Manage users, skills, reports, etc.'),
          ],
        ),
      ),
    );
  }
}