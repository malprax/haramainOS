import 'package:flutter/material.dart';
import 'package:haramain_os/app/data/models/package_model.dart';

class PackageInfo extends StatelessWidget {
  final PackageModel package;

  const PackageInfo({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_month, size: 16),
            const SizedBox(width: 6),
            Text(_formatDate(package.departureDate)),
            const SizedBox(width: 16),
            const Icon(Icons.timelapse, size: 16),
            const SizedBox(width: 6),
            Text('${package.durationDays ?? 0} Hari'),
          ],
        ),
        const SizedBox(height: 14),
        _HotelRow(
          city: 'Makkah',
          hotel: package.makkahHotel ?? '-',
          stars: '★★★★★',
        ),
        const SizedBox(height: 6),
        _HotelRow(
          city: 'Madinah',
          hotel: package.madinahHotel ?? '-',
          stars: '★★★★',
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class StatusBadge extends StatelessWidget {
  final bool isActive;

  const StatusBadge({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        isActive ? 'Aktif' : 'Tidak Aktif',
        style: TextStyle(
          color: isActive ? Colors.green.shade800 : Colors.grey.shade800,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _HotelRow extends StatelessWidget {
  final String city;
  final String hotel;
  final String stars;

  const _HotelRow({
    required this.city,
    required this.hotel,
    required this.stars,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            '$city:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(hotel)),
        Text(stars, style: const TextStyle(color: Colors.orange)),
      ],
    );
  }
}
