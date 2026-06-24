import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:haramain_os/app/data/models/booking_model.dart';

import 'admin_booking_request_controller.dart';

class AdminBookingRequestView extends GetView<AdminBookingRequestController> {
  const AdminBookingRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Persetujuan Booking'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final bookings = controller.filteredBookings;

        return RefreshIndicator(
          onRefresh: controller.loadData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SummaryCard(controller: controller),
              const SizedBox(height: 14),
              _FilterRow(controller: controller),
              const SizedBox(height: 14),
              if (bookings.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text('Belum ada booking sesuai filter.'),
                  ),
                )
              else
                ...bookings.map(
                  (booking) => _BookingRequestCard(
                    booking: booking,
                    controller: controller,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final AdminBookingRequestController controller;

  const _SummaryCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _InfoItem(
              label: 'Pending',
              value: controller.pendingCount.toString(),
              color: Colors.orange,
            ),
            _InfoItem(
              label: 'Approved',
              value: controller.approvedCount.toString(),
              color: Colors.green,
            ),
            _InfoItem(
              label: 'Rejected',
              value: controller.rejectedCount.toString(),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final AdminBookingRequestController controller;

  const _FilterRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedFilter.value;

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'Semua',
              selected: selected,
              controller: controller,
            ),
            _FilterChip(
              label: 'Pending',
              selected: selected,
              controller: controller,
            ),
            _FilterChip(
              label: 'Approved',
              selected: selected,
              controller: controller,
            ),
            _FilterChip(
              label: 'Rejected',
              selected: selected,
              controller: controller,
            ),
          ],
        ),
      );
    });
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String selected;
  final AdminBookingRequestController controller;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected == label,
        onSelected: (_) => controller.changeFilter(label),
      ),
    );
  }
}

class _BookingRequestCard extends StatelessWidget {
  final BookingModel booking;
  final AdminBookingRequestController controller;

  const _BookingRequestCard({required this.booking, required this.controller});

  @override
  Widget build(BuildContext context) {
    final status = booking.status ?? BookingStatus.available;
    final packageName = controller.getPackageName(booking.packageId);
    final seatNumber = booking.seatNumber?.toString() ?? '-';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatusIcon(status: status),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    packageName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                _StatusChip(status: status),
              ],
            ),
            const SizedBox(height: 12),
            Text('Seat: $seatNumber'),
            const SizedBox(height: 4),
            Text('Jamaah ID: ${booking.jamaahId ?? '-'}'),
            const SizedBox(height: 4),
            Text('Tanggal Booking: ${_formatDate(booking.bookingDate)}'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => controller.openSeatMap(booking),
                    icon: const Icon(Icons.event_seat),
                    label: const Text('Seat Map'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: status == BookingStatus.rejected
                        ? null
                        : () => controller.rejectBooking(booking),
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: status == BookingStatus.approved
                        ? null
                        : () => controller.approveBooking(booking),
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
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

class _StatusIcon extends StatelessWidget {
  final BookingStatus status;

  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case BookingStatus.pending:
        return const CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(Icons.hourglass_top, color: Colors.white),
        );
      case BookingStatus.approved:
        return const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.check, color: Colors.white),
        );
      case BookingStatus.rejected:
        return const CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(Icons.close, color: Colors.white),
        );
      case BookingStatus.available:
        return const CircleAvatar(
          backgroundColor: Colors.grey,
          child: Icon(Icons.event_seat, color: Colors.white),
        );
    }
  }
}

class _StatusChip extends StatelessWidget {
  final BookingStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _statusText(status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _statusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.approved:
        return 'Approved';
      case BookingStatus.rejected:
        return 'Rejected';
      case BookingStatus.available:
        return 'Empty';
    }
  }

  Color _statusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.approved:
        return Colors.green;
      case BookingStatus.rejected:
        return Colors.red;
      case BookingStatus.available:
        return Colors.grey;
    }
  }
}
