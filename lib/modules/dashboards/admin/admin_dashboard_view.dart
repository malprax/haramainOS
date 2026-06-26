import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import 'admin_dashboard_controller.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildStatsGrid(),
            const SizedBox(height: 22),
            const Text(
              'Menu Utama',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildMenuGrid(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      centerTitle: false,
      titleSpacing: 16,
      title: const Text(
        'Dashboard Admin',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        Obx(() {
          final count = controller.unreadNotificationCount.value;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () => Get.toNamed(AppRoutes.adminNotifications),
              ),
              if (count > 0)
                Positioned(
                  right: 7,
                  top: 7,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      count > 99 ? '99+' : count.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: controller.logout,
        ),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(
          () => Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.green.shade700,
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assalamualaikum, ${controller.adminName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kelola paket, booking, dokumen, dan layanan jamaah.',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.85,
      children: const [
        _StatCard(title: 'Total Jamaah', value: '120', icon: Icons.groups),
        _StatCard(title: 'Paket Aktif', value: '8', icon: Icons.card_travel),
        _StatCard(
          title: 'Booking Pending',
          value: '15',
          icon: Icons.event_seat,
        ),
        _StatCard(
          title: 'Dokumen Pending',
          value: '5',
          icon: Icons.folder_copy,
        ),
      ],
    );
  }

  Widget _buildMenuGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        _MenuCard(
          title: 'Paket',
          icon: Icons.card_travel,
          onTap: () => Get.toNamed(AppRoutes.adminPackages),
        ),
        _MenuCard(
          title: 'Booking',
          icon: Icons.event_seat,
          onTap: () => Get.toNamed(AppRoutes.adminBooking),
        ),
        _MenuCard(
          title: 'Dokumen',
          icon: Icons.folder_copy,
          onTap: () => Get.toNamed(AppRoutes.adminDocuments),
        ),
        _MenuCard(
          title: 'Group',
          icon: Icons.groups,
          onTap: () => Get.toNamed(AppRoutes.adminGroups),
        ),
        _MenuCard(
          title: 'Family',
          icon: Icons.family_restroom,
          onTap: () => Get.toNamed(AppRoutes.adminFamilies),
        ),
        _MenuCard(title: 'Jamaah', icon: Icons.people, onTap: () {}),
        _MenuCard(title: 'Mutawwif', icon: Icons.location_pin, onTap: () {}),
        _MenuCard(title: 'Broadcast', icon: Icons.campaign, onTap: () {}),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const _MenuCard({required this.title, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
