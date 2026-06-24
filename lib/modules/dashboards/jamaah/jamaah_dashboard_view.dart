import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import 'jamaah_dashboard_controller.dart';

class JamaahDashboardView extends GetView<JamaahDashboardController> {
  const JamaahDashboardView({super.key});

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Tidak')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.authController.currentUser.value = null;
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
      appBar: _buildAppBar(),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildInformationCard(),
            const SizedBox(height: 16),
            _buildPackageProgressCard(),
            const SizedBox(height: 16),
            _buildBuyPackageCard(),
            const SizedBox(height: 20),
            const Text(
              'Layanan Jamaah',
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
      title: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard | ${controller.userName}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            const Text(
              'Semoga perjalanan ibadah Anda selalu dimudahkan.',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      actions: [
        Obx(() {
          final count = controller.unreadNotificationCount.value;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () => Get.toNamed(
                  AppRoutes.jamaahNotifications,
                  parameters: {'jamaahId': controller.jamaahId},
                ),
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
          onPressed: _showLogoutDialog,
        ),
      ],
    );
  }

  Widget _buildInformationCard() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.green.shade700,
              child: const Icon(Icons.info_outline, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Pastikan semua langkah selesai agar perjalanan Anda lancar.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageProgressCard() {
    final approvedBookings = controller.myApprovedBookings;

    return Card(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'Paket',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Text(
                    'Progress',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (approvedBookings.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Belum ada paket yang disetujui.'),
              ),
            ),
          ...approvedBookings.map((booking) {
            final package = controller.getPackageById(booking.packageId);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 4,
                        child: _buildPackageInfo(
                          packageName: package?.packageName ?? 'Paket',
                          seatNumber: booking.seatNumber,
                          departureDate: package?.departureDate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(flex: 6, child: _buildHorizontalProgress()),
                    ],
                  ),
                ),
                if (booking != approvedBookings.last) const Divider(height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPackageInfo({
    required String packageName,
    required int? seatNumber,
    required DateTime? departureDate,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.green.shade50,
              child: Icon(Icons.card_travel, color: Colors.green.shade700),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                packageName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Seat #${seatNumber ?? '-'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          departureDate == null
              ? 'Berangkat: -'
              : 'Berangkat: ${_formatDate(departureDate)}',
          style: TextStyle(color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildHorizontalProgress() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 620,
        child: Row(
          children: [
            _ProgressStep(
              number: '1',
              title: 'Booking',
              subtitle: 'Seat dibooking',
              isDone: true,
              isLast: false,
            ),
            _ProgressStep(
              number: '2',
              title: 'Dokumen',
              subtitle: 'Dokumen lengkap',
              isDone: true,
              isLast: false,
            ),
            _ProgressStep(
              number: '3',
              title: 'Pembayaran',
              subtitle: 'Menunggu pembayaran',
              isDone: false,
              isLast: false,
            ),
            _ProgressStep(
              number: '4',
              title: 'Manasik',
              subtitle: 'Belum dimulai',
              isDone: false,
              isLast: false,
            ),
            _ProgressStep(
              number: '5',
              title: 'Berangkat',
              subtitle: 'Belum berangkat',
              isDone: false,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuyPackageCard() {
    return Card(
      color: Colors.green.shade50,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(Icons.card_travel, color: Colors.green.shade700),
        ),
        title: const Text(
          'Pilih paket terbaik untuk perjalanan ibadah Anda',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Dapatkan pengalaman terbaik bersama travel.'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => Get.toNamed(AppRoutes.jamaahPackages),
      ),
    );
  }

  Widget _buildMenuGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.5,
      children: [
        _GridMenu(
          title: 'Dokumen',
          icon: Icons.folder_copy,
          onTap: () => Get.toNamed(AppRoutes.jamaahDocuments),
        ),
        const _GridMenu(title: 'Manasik', icon: Icons.school),
        const _GridMenu(title: 'Tracking', icon: Icons.location_on),
        const _GridMenu(title: 'Broadcast', icon: Icons.campaign),
        const _GridMenu(title: 'Al-Quran', icon: Icons.menu_book),
        const _GridMenu(title: 'E-Book', icon: Icons.book),
        const _GridMenu(title: 'Peta', icon: Icons.map),
        const _GridMenu(title: 'Bahasa Arab', icon: Icons.translate),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }
}

class _ProgressStep extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final bool isDone;
  final bool isLast;

  const _ProgressStep({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.isDone,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDone ? Colors.green.shade700 : Colors.grey;

    return SizedBox(
      width: isLast ? 96 : 130,
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: isDone ? Colors.green.shade700 : Colors.white,
                child: isDone
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : Text(
                        number,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              if (!isLast)
                Expanded(
                  child: Divider(
                    thickness: 2,
                    color: isDone ? Colors.green.shade700 : Colors.grey,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$number. $title',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _GridMenu extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const _GridMenu({required this.title, required this.icon, this.onTap});

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
            const SizedBox(width: 8),
            Flexible(
              child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
