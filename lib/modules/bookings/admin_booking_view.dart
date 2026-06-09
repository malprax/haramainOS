import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haramain_os/app/data/models/booking_model.dart';

import 'booking_controller.dart';

class AdminBookingView extends GetView<BookingController> {
  const AdminBookingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Booking Seat'),
        centerTitle: true,
      ),
      body: Obx(() {
        final package = controller.selectedPackage.value;

        if (package == null) {
          return const Center(child: Text('Paket belum dipilih.'));
        }

        final capacity = package.capacity ?? 0;
        final packageId = package.id?.toString().trim();
        final bookingSnapshot = controller.bookings.toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              package.packageName ?? '-',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text('Kapasitas: $capacity jamaah'),

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

                final booking = bookingSnapshot.firstWhereOrNull(
                  (item) =>
                      item.packageId?.toString().trim() == packageId &&
                      item.seatNumber == seatNumber,
                );

                final status = booking?.status ?? BookingStatus.available;

                return _SeatBox(
                  key: ValueKey(
                    'admin-seat-$seatNumber-${status.name}-${booking?.id ?? 'empty'}',
                  ),
                  seatNumber: seatNumber,
                  booking: booking,
                  onTap: () {
                    _showAdminActionDialog(context, seatNumber, booking);
                  },
                );
              },
            ),
          ],
        );
      }),
    );
  }

  void _showAdminActionDialog(
    BuildContext context,
    int seatNumber,
    BookingModel? booking,
  ) {
    final status = booking?.status ?? BookingStatus.available;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Seat #$seatNumber'),
          content: Text(
            status == BookingStatus.available
                ? 'Seat ini masih kosong. Menunggu jamaah melakukan booking.'
                : 'Status booking: ${_statusLabel(status)}',
          ),
          actions: [
            if (status == BookingStatus.available)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),

            if (status == BookingStatus.pending) ...[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  controller.resetBooking(booking!);
                },
                child: const Text('Reset ke Kosong'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  controller.cancelBooking(booking!);
                },
                child: const Text('Batalkan'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  controller.approveBooking(booking!);
                },
                child: const Text('Approve'),
              ),
            ],

            if (status == BookingStatus.approved) ...[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  controller.cancelBooking(booking!);
                },
                child: const Text('Batalkan'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  controller.resetBooking(booking!);
                },
                child: const Text('Reset ke Kosong'),
              ),
            ],

            if (status == BookingStatus.rejected)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  controller.resetBooking(booking!);
                },
                child: const Text('Reset ke Kosong'),
              ),
          ],
        );
      },
    );
  }

  String _statusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.available:
        return 'Kosong';
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.approved:
        return 'Approved';
      case BookingStatus.rejected:
        return 'Dibatalkan';
    }
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
    super.key,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
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
