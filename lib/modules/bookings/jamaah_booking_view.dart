import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haramain_os/app/data/models/booking_model.dart';

import 'booking_controller.dart';

class JamaahBookingView extends GetView<BookingController> {
  const JamaahBookingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Seat Booking'),
        centerTitle: true,
      ),
      body: Obx(() {
        final package = controller.selectedPackage.value;

        if (package == null) {
          return const Center(child: Text('Paket belum dipilih.'));
        }

        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final capacity = package.capacity ?? 0;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              package.packageName ?? '-',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text('Silakan pilih seat kosong. Kapasitas: $capacity jamaah'),
            const SizedBox(height: 16),
            const _SeatLegend(),
            const SizedBox(height: 20),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: capacity,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final seatNumber = index + 1;
                final booking = controller.getBookingBySeat(seatNumber);

                return _SeatBox(
                  seatNumber: seatNumber,
                  booking: booking,
                  onTap: () {
                    if (booking == null) {
                      _showJamaahBookingDialog(context, seatNumber);
                    } else {
                      _showUnavailableDialog(context, booking);
                    }
                  },
                );
              },
            ),
          ],
        );
      }),
    );
  }

  void _showJamaahBookingDialog(BuildContext context, int seatNumber) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Booking Seat #$seatNumber'),
          content: const Text(
            'Apakah Anda ingin memilih seat ini? Status awal akan menjadi pending sampai disetujui admin travel.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tidak'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                controller.bookSeatByJamaah(seatNumber);
              },
              child: const Text('Ya, Booking'),
            ),
          ],
        );
      },
    );
  }

  void _showUnavailableDialog(BuildContext context, BookingModel booking) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Seat tidak tersedia'),
          content: Text(
            'Seat ini sudah memiliki status: ${booking.status?.name ?? '-'}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }
}

class _SeatLegend extends StatelessWidget {
  const _SeatLegend();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _LegendBox(color: Colors.white, label: 'Kosong'),
        _LegendBox(color: Colors.amber, label: 'Pending'),
        _LegendBox(color: Colors.green, label: 'Approved'),
        _LegendBox(color: Colors.redAccent, label: 'Dibatalkan'),
      ],
    );
  }
}

class _SeatBox extends StatelessWidget {
  final int seatNumber;
  final BookingModel? booking;
  final VoidCallback onTap;

  const _SeatBox({
    required this.seatNumber,
    required this.booking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = booking?.status ?? BookingStatus.available;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: _getColor(status),
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          seatNumber.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: status == BookingStatus.available
                ? Colors.black
                : Colors.white,
          ),
        ),
      ),
    );
  }

  Color _getColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.available:
        return Colors.white;
      case BookingStatus.pending:
        return Colors.amber;
      case BookingStatus.approved:
        return Colors.green;
      case BookingStatus.rejected:
        return Colors.redAccent;
    }
  }
}

class _LegendBox extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendBox({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
