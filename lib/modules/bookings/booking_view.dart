import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/booking_model.dart';
import 'booking_controller.dart';

class BookingView extends GetView<BookingController> {
  const BookingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HaramainOS Smart Seat Booking'),
        centerTitle: true,
      ),
      body: Obx(() {
        final package = controller.selectedPackage.value;

        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (package == null) {
          return const Center(child: Text('Paket belum tersedia'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _PackageHeader(controller: controller),
            const SizedBox(height: 16),
            _SeatLegend(),
            const SizedBox(height: 16),
            _SeatGrid(controller: controller),
            const SizedBox(height: 24),
            _PendingApprovalList(controller: controller),
          ],
        );
      }),
    );
  }
}

class _PackageHeader extends StatelessWidget {
  final BookingController controller;

  const _PackageHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    final package = controller.selectedPackage.value!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                package.packageName ?? '-',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('Keberangkatan: ${_date(package.departureDate)}'),
              Text('Hotel Makkah: ${package.makkahHotel ?? '-'}'),
              Text('Hotel Madinah: ${package.madinahHotel ?? '-'}'),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _StatBox(
                      title: 'Kapasitas',
                      value: '${package.capacity ?? 0}',
                    ),
                  ),
                  Expanded(
                    child: _StatBox(
                      title: 'Approved',
                      value: '${controller.approvedCount}',
                    ),
                  ),
                  Expanded(
                    child: _StatBox(
                      title: 'Pending',
                      value: '${controller.pendingCount}',
                    ),
                  ),
                  Expanded(
                    child: _StatBox(
                      title: 'Sisa',
                      value: '${controller.availableCount}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _date(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatBox extends StatelessWidget {
  final String title;
  final String value;

  const _StatBox({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(title),
      ],
    );
  }
}

class _SeatLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _LegendItem(color: Colors.white, border: true, label: 'Tersedia'),
        _LegendItem(color: Colors.amber, label: 'Pending'),
        _LegendItem(color: Colors.green, label: 'Approved'),
        _LegendItem(color: Colors.redAccent, label: 'Rejected'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool border;

  const _LegendItem({
    required this.color,
    required this.label,
    this.border = false,
  });

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
            border: border ? Border.all(color: Colors.black45) : null,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}

class _SeatGrid extends StatelessWidget {
  final BookingController controller;

  const _SeatGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    final capacity = controller.selectedPackage.value?.capacity ?? 0;

    return Obx(
      () => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: capacity,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          final seatNumber = index + 1;
          final booking = controller.getBookingBySeat(seatNumber);

          return _SeatBox(
            seatNumber: seatNumber,
            booking: booking,
            onTap: () {
              if (booking == null) {
                controller.bookSeat(seatNumber);
              }
            },
          );
        },
      ),
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
      onTap: status == BookingStatus.available ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: _color(status),
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(10),
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

  Color _color(BookingStatus status) {
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

class _PendingApprovalList extends StatelessWidget {
  final BookingController controller;

  const _PendingApprovalList({required this.controller});

  @override
  Widget build(BuildContext context) {
    final pendingBookings = controller.bookings
        .where((item) => item.status == BookingStatus.pending)
        .toList();

    if (pendingBookings.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Belum ada booking yang menunggu approval.'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Approval Travel',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...pendingBookings.map((booking) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Seat #${booking.seatNumber}'),
                subtitle: const Text('Status: Pending Approval'),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => controller.rejectBooking(booking),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () => controller.approveBooking(booking),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
