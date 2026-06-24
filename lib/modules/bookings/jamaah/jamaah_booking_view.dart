import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:haramain_os/app/data/models/booking_model.dart';

import 'jamaah_booking_controller.dart';

class JamaahBookingView extends GetView<JamaahBookingController> {
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
          return const Center(child: Text('Paket belum dipilih'));
        }

        final capacity = package.capacity ?? 0;
        final packageId = package.id?.trim() ?? '';

        return RefreshIndicator(
          onRefresh: controller.loadData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _PackageHeaderCard(
                packageName: package.packageName ?? '-',
                capacity: capacity,
              ),
              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _BookingStat(
                        title: 'Kosong',
                        value: controller
                            .availableCountBySelectedPackage()
                            .toString(),
                        color: Colors.grey,
                      ),
                      _BookingStat(
                        title: 'Pending',
                        value: controller
                            .pendingCountBySelectedPackage()
                            .toString(),
                        color: Colors.amber,
                      ),
                      _BookingStat(
                        title: 'Approved',
                        value: controller
                            .approvedCountBySelectedPackage()
                            .toString(),
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
              ),

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

                  final booking = controller.bookings.firstWhereOrNull(
                    (item) =>
                        item.packageId?.trim() == packageId &&
                        item.seatNumber == seatNumber &&
                        item.status != BookingStatus.rejected,
                  );

                  final status = booking?.status ?? BookingStatus.available;

                  return _SeatBox(
                    key: ValueKey(
                      'jamaah-seat-$seatNumber-${status.name}-${booking?.id ?? 'empty'}',
                    ),
                    seatNumber: seatNumber,
                    booking: booking,
                    onTap: () {
                      if (booking == null) {
                        _showBookingDialog(context, seatNumber);
                        return;
                      }

                      if (controller.isMyBooking(booking) &&
                          booking.status == BookingStatus.pending) {
                        _showCancelDialog(context, booking);
                        return;
                      }

                      _showSeatInformation(context, booking);
                    },
                  );
                },
              ),

              const SizedBox(height: 20),

              _InfoCard(),
            ],
          ),
        );
      }),
    );
  }

  void _showBookingDialog(BuildContext context, int seatNumber) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Booking Seat #$seatNumber'),
          content: const Text(
            'Seat akan berstatus Pending sampai disetujui Admin Travel.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                controller.bookSeat(seatNumber);
              },
              icon: const Icon(Icons.event_seat),
              label: const Text('Booking'),
            ),
          ],
        );
      },
    );
  }

  void _showCancelDialog(BuildContext context, BookingModel booking) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Batalkan Seat #${booking.seatNumber}?'),
          content: const Text(
            'Booking masih pending dan dapat dibatalkan sebelum disetujui admin.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tidak'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                controller.cancelMyBooking(booking);
              },
              icon: const Icon(Icons.close),
              label: const Text('Batalkan'),
            ),
          ],
        );
      },
    );
  }

  void _showSeatInformation(BuildContext context, BookingModel booking) {
    final status = _statusLabel(booking.status ?? BookingStatus.available);
    final isMine = controller.isMyBooking(booking);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Informasi Seat'),
          content: Text(
            isMine
                ? 'Seat ini milik Anda dengan status $status.'
                : 'Seat ini sudah digunakan jamaah lain dengan status $status.',
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

  String _statusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.available:
        return 'Kosong';
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.approved:
        return 'Approved';
      case BookingStatus.rejected:
        return 'Rejected';
    }
  }
}

class _PackageHeaderCard extends StatelessWidget {
  final String packageName;
  final int capacity;

  const _PackageHeaderCard({required this.packageName, required this.capacity});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.green.shade700,
              child: const Icon(Icons.card_travel, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    packageName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kapasitas $capacity jamaah',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingStat extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _BookingStat({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(title),
      ],
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
    final isAvailable = status == BookingStatus.available;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: _getColor(status),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isAvailable ? Colors.black26 : Colors.transparent,
          ),
          boxShadow: [
            if (!isAvailable)
              BoxShadow(
                color: _getColor(status).withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          seatNumber.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isAvailable ? Colors.black : Colors.white,
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
        return Colors.white;
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

class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: Colors.blueGrey.shade700),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Seat pending masih menunggu persetujuan admin. Jika booking ditolak, seat akan tersedia kembali untuk jamaah lain.',
                style: TextStyle(color: Colors.blueGrey.shade800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
