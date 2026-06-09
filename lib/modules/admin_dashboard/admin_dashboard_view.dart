import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../auth/auth_controller.dart';

class AdminDashboardView extends StatelessWidget {
  AdminDashboardView({super.key});

  final AuthController authController = Get.find<AuthController>();
  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Tidak')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authController.currentUser.value = null;
              Get.offAllNamed(AppRoutes.auth);
            },
            child: const Text('Ya'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin Travel'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: Column(
              children: [
                Text(
                  'PT Barokah Wisata',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Website + Mobile App Travel Umrah Anda',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              child: Row(
                children: [
                  _StatItem(title: 'Jamaah', value: '120', icon: Icons.groups),
                  _StatItem(title: 'Online', value: '95', icon: Icons.wifi),
                  _StatItem(
                    title: 'Offline',
                    value: '25',
                    icon: Icons.person_off,
                  ),
                  _StatItem(title: 'Panic', value: '1', icon: Icons.warning),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Card(
            elevation: 2,
            color: Colors.green.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(18),
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.assignment,
                  color: Colors.green.shade700,
                  size: 30,
                ),
              ),
              title: const Text(
                'Daftar Paket',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: const Text('Kelola paket umrah aktif dan tidak aktif'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => Get.toNamed(AppRoutes.adminPackages),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.green, size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
