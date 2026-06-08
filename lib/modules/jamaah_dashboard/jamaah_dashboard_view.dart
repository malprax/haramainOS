import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../auth/auth_controller.dart';

class JamaahDashboardView extends StatelessWidget {
  JamaahDashboardView({super.key});

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Jamaah'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Obx(() {
              final userName =
                  authController.currentUser.value?.fullName ?? 'Jamaah';

              return Column(
                children: [
                  Text(
                    'Assalamualaikum',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }),
          ),

          const SizedBox(height: 24),

          Card(
            elevation: 3,
            color: Colors.green.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(18),
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.card_travel,
                  color: Colors.green.shade700,
                  size: 30,
                ),
              ),
              title: const Text(
                'Beli Paket Umrah',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Lihat daftar paket aktif yang tersedia dari travel',
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => Get.toNamed(AppRoutes.jamaahPackages),
            ),
          ),

          const SizedBox(height: 20),

          const _MenuTile(title: 'Checklist Umrah', icon: Icons.checklist),
          const _MenuTile(title: 'Manasik', icon: Icons.school),
          const _MenuTile(title: 'Bahasa Arab Praktis', icon: Icons.translate),
          const _MenuTile(title: 'Peta Makkah', icon: Icons.map),
          const _MenuTile(title: 'Peta Madinah', icon: Icons.map_outlined),
          const _MenuTile(title: 'Tracking Jamaah', icon: Icons.location_on),
          const _MenuTile(title: 'Broadcast Travel', icon: Icons.campaign),
          const _MenuTile(title: 'E-Book', icon: Icons.menu_book),
          const _MenuTile(title: 'Al-Quran', icon: Icons.book),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String title;
  final IconData icon;

  const _MenuTile({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
