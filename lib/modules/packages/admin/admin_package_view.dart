import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haramain_os/app/data/models/package_model.dart';

import '../admin/admin_package_controller.dart';

class AdminPackageView extends GetView<AdminPackageController> {
  const AdminPackageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Paket'), centerTitle: true),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final packages = controller.filteredPackages;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: controller.searchController,
              onChanged: (_) => controller.refreshSearch(),
              decoration: InputDecoration(
                hintText: 'Cari nama paket...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _FilterChipButton(
                  label: 'Semua',
                  selected: controller.selectedStatusFilter.value == 'All',
                  onTap: () => controller.changeStatusFilter('All'),
                ),
                _FilterChipButton(
                  label: 'Aktif',
                  selected: controller.selectedStatusFilter.value == 'Aktif',
                  onTap: () => controller.changeStatusFilter('Aktif'),
                ),
                _FilterChipButton(
                  label: 'Tidak Aktif',
                  selected:
                      controller.selectedStatusFilter.value == 'Tidak Aktif',
                  onTap: () => controller.changeStatusFilter('Tidak Aktif'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (packages.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: Text('Paket tidak ditemukan.')),
              )
            else
              ...packages.map(
                (package) =>
                    _AdminPackageCard(package: package, controller: controller),
              ),
            const SizedBox(height: 100),
          ],
        );
      }),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: controller.openCreateForm,
              icon: const Icon(Icons.add_box_outlined),
              label: const Text(
                'Buat Paket',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade800,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminPackageCard extends StatelessWidget {
  final PackageModel package;
  final AdminPackageController controller;

  const _AdminPackageCard({required this.package, required this.controller});

  @override
  Widget build(BuildContext context) {
    final capacity = package.capacity ?? 0;
    final bookedSeats = package.bookedSeats ?? 0;
    final occupancy = capacity == 0 ? 0.0 : bookedSeats / capacity;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => controller.openAdminBooking(package),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      package.packageName ?? '-',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => controller.openEditForm(package),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteDialog(context),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.flight_takeoff, color: Colors.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${package.durationDays ?? 0} hari • '
                        '${_formatDate(package.departureDate)} - '
                        '${_formatDate(package.returnDate)} • '
                        '$capacity jamaah',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              LinearProgressIndicator(
                value: occupancy,
                minHeight: 8,
                borderRadius: BorderRadius.circular(10),
              ),

              const SizedBox(height: 6),

              Text(
                '$bookedSeats/$capacity seat terisi',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _HotelInfo(
                      city: 'Makkah',
                      hotel: package.makkahHotel ?? '-',
                      stars: package.makkahHotelStars ?? 0,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _HotelInfo(
                      city: 'Madinah',
                      hotel: package.madinahHotel ?? '-',
                      stars: package.madinahHotelStars ?? 0,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  _StatusBadge(isActive: package.isActive == true),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => controller.openAdminBooking(package),
                    icon: const Icon(Icons.event_seat),
                    label: const Text('Kelola Booking'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';

    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Hapus Paket'),
          content: Text(
            'Apakah Anda yakin ingin menghapus ${package.packageName ?? 'paket ini'}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tidak'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                controller.deletePackage(package);
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
  }
}

class _HotelInfo extends StatelessWidget {
  final String city;
  final String hotel;
  final int stars;

  const _HotelInfo({
    required this.city,
    required this.hotel,
    required this.stars,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(city, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(hotel, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(
            stars <= 0 ? '-' : '★' * stars,
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Aktif' : 'Tidak Aktif',
        style: TextStyle(
          color: isActive ? Colors.green.shade800 : Colors.grey.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: Colors.green.shade700,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
