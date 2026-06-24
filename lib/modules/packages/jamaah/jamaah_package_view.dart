import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haramain_os/app/data/models/package_model.dart';

import 'jamaah_package_controller.dart';

class JamaahPackageView extends GetView<JamaahPackageController> {
  const JamaahPackageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Paket Umrah'), centerTitle: true),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final packages = controller.activePackages;

        if (packages.isEmpty) {
          return const Center(
            child: Text('Belum ada paket aktif yang tersedia.'),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Paket Tersedia',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text('Silakan pilih paket umrah yang ingin Anda booking.'),
            const SizedBox(height: 18),
            ...packages.map(
              (package) =>
                  _JamaahPackageCard(package: package, controller: controller),
            ),
          ],
        );
      }),
    );
  }
}

class _JamaahPackageCard extends StatelessWidget {
  final PackageModel package;
  final JamaahPackageController controller;

  const _JamaahPackageCard({required this.package, required this.controller});

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
        onTap: () => controller.openJamaahBooking(package),
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
                  _StatusBadge(isActive: package.isActive == true),
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

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => controller.openJamaahBooking(package),
                  icon: const Icon(Icons.event_seat),
                  label: const Text(
                    'Pilih Paket dan Booking Seat',
                    style: TextStyle(fontWeight: FontWeight.bold),
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
