import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haramain_os/app/data/models/bus_model.dart';
import 'package:haramain_os/app/data/models/group_assignment_model.dart';
import 'package:haramain_os/app/data/models/group_model.dart';
import 'package:haramain_os/app/data/models/hotel_model.dart';
import 'package:haramain_os/app/data/models/mutawwif_model.dart';

import 'group_controller.dart';

class GroupView extends GetView<GroupController> {
  const GroupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Group Manager'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.groups.isEmpty) {
          return _EmptyGroupState(controller: controller);
        }

        return RefreshIndicator(
          onRefresh: controller.loadData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _HeaderSection(controller: controller),
              const SizedBox(height: 16),
              ...controller.dashboards.map((dashboard) {
                return _GroupDashboardCard(
                  group: dashboard.group,
                  totalMembers: dashboard.totalMembers,
                  totalAssignments: dashboard.totalAssignments,
                  totalBusAssignments: dashboard.totalBusAssignments,
                  totalHotelAssignments: dashboard.totalHotelAssignments,
                  totalMutawwifAssignments: dashboard.totalMutawwifAssignments,
                  controller: controller,
                );
              }),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.createSampleGroup,
        icon: const Icon(Icons.group_add),
        label: const Text('Tambah Rombongan'),
      ),
    );
  }
}

class _EmptyGroupState extends StatelessWidget {
  final GroupController controller;

  const _EmptyGroupState({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.groups_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada rombongan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Mulai buat rombongan untuk mengelola jamaah, mutawwif, bus, dan hotel secara dinamis.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: controller.createSampleGroup,
              icon: const Icon(Icons.add),
              label: const Text('Buat Rombongan Contoh'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final GroupController controller;

  const _HeaderSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final totalGroups = controller.groups.length;
    final totalAssignments = controller.assignments
        .where((item) => item.isActive)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HaramainOS',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const Text('Dynamic Assignment Dashboard for Umrah Travel'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _SummaryBox(
                title: 'Rombongan',
                value: totalGroups.toString(),
                icon: Icons.groups,
              ),
            ),
            const SizedBox(width: 12),
            Obx(
              () => Expanded(
                child: _SummaryBox(
                  title: 'Jamaah',
                  value: controller.jamaahCount.value.toString(),
                  icon: Icons.people,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryBox(
                title: 'Aktif',
                value: totalAssignments.toString(),
                icon: Icons.assignment_turned_in,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryBox({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }
}

class _GroupDashboardCard extends StatelessWidget {
  final GroupModel group;
  final int totalMembers;
  final int totalAssignments;
  final int totalBusAssignments;
  final int totalHotelAssignments;
  final int totalMutawwifAssignments;
  final GroupController controller;

  const _GroupDashboardCard({
    required this.group,
    required this.totalMembers,
    required this.totalAssignments,
    required this.totalBusAssignments,
    required this.totalHotelAssignments,
    required this.totalMutawwifAssignments,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final activeAssignments = controller.assignments.where((assignment) {
      return assignment.groupId == group.id && assignment.isActive;
    }).toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GroupTitleRow(group: group, controller: controller),
            Text(group.description ?? '-'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(label: '$totalMembers Jamaah', icon: Icons.people),
                _InfoChip(
                  label: '$totalBusAssignments Bus',
                  icon: Icons.directions_bus,
                ),
                _InfoChip(
                  label: '$totalHotelAssignments Hotel',
                  icon: Icons.hotel,
                ),
                _InfoChip(
                  label: '$totalMutawwifAssignments Mutawwif',
                  icon: Icons.person_pin,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _JamaahCounter(controller: controller),
            const Divider(height: 28),
            const Text(
              'Assignment Aktif',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (activeAssignments.isEmpty)
              const Text('Belum ada assignment aktif')
            else
              ...activeAssignments.map(
                (assignment) => _AssignmentTile(assignment: assignment),
              ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showBusPicker(context, group),
                  icon: const Icon(Icons.directions_bus),
                  label: const Text('Pilih Bus'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showHotelPicker(context, group),
                  icon: const Icon(Icons.hotel),
                  label: const Text('Pilih Hotel'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showMutawwifPicker(context, group),
                  icon: const Icon(Icons.person_pin),
                  label: const Text('Pilih Mutawwif'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showBusPicker(BuildContext context, GroupModel group) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return _BusPickerSheet(
          buses: controller.readyBuses,
          onSelected: (bus) {
            Navigator.pop(context);
            controller.assignSelectedBus(group, bus);
          },
        );
      },
    );
  }

  void _showHotelPicker(BuildContext context, GroupModel group) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return _HotelPickerSheet(
          hotels: controller.readyHotels,
          onSelected: (hotel) {
            Navigator.pop(context);
            controller.assignSelectedHotel(group, hotel);
          },
        );
      },
    );
  }

  void _showMutawwifPicker(BuildContext context, GroupModel group) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return _MutawwifPickerSheet(
          mutawwifs: controller.readyMutawwifs,
          onSelected: (mutawwif) {
            Navigator.pop(context);
            controller.assignSelectedMutawwif(group, mutawwif);
          },
        );
      },
    );
  }
}

class _GroupTitleRow extends StatelessWidget {
  final GroupModel group;
  final GroupController controller;

  const _GroupTitleRow({required this.group, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            group.groupName ?? 'Tanpa Nama Rombongan',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showDeleteDialog(context),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Hapus Rombongan'),
          content: Text(
            'Apakah Anda yakin ingin menghapus ${group.groupName ?? 'rombongan ini'}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tidak'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                controller.deleteGroup(group);
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
  }
}

class _JamaahCounter extends StatelessWidget {
  final GroupController controller;

  const _JamaahCounter({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Jamaah:', style: TextStyle(fontWeight: FontWeight.bold)),
        IconButton(
          onPressed: controller.decreaseJamaah,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Obx(
          () => Text(
            controller.jamaahCount.value.toString(),
            style: const TextStyle(fontSize: 18),
          ),
        ),
        IconButton(
          onPressed: controller.increaseJamaah,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _InfoChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(label));
  }
}

class _AssignmentTile extends StatelessWidget {
  final GroupAssignmentModel assignment;

  const _AssignmentTile({required this.assignment});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(_getIcon(assignment.assignmentType)),
      title: Text(assignment.resourceName),
      subtitle: Text(
        '${assignment.city.isEmpty ? assignment.route : assignment.city} • ${assignment.route}\n'
        'Mulai: ${_formatDateTime(assignment.startDate)}'
        '${assignment.endDate == null ? '' : ' • Selesai: ${_formatDateTime(assignment.endDate!)}'}',
      ),
      trailing: const Icon(Icons.check_circle, color: Colors.green),
    );
  }

  IconData _getIcon(AssignmentType type) {
    switch (type) {
      case AssignmentType.bus:
        return Icons.directions_bus;
      case AssignmentType.hotel:
        return Icons.hotel;
      case AssignmentType.mutawwif:
        return Icons.person_pin;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }
}

class _BusPickerSheet extends StatelessWidget {
  final List<BusModel> buses;
  final void Function(BusModel bus) onSelected;

  const _BusPickerSheet({required this.buses, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Pilih Bus Ready',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...buses.map((bus) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.directions_bus),
              title: Text(bus.busNumber),
              subtitle: Text(
                '${bus.city}\n${bus.route}\nBerangkat: ${_formatDateTime(bus.departureTime)}',
              ),
              trailing: const Text('Ready'),
              onTap: () => onSelected(bus),
            ),
          );
        }),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _HotelPickerSheet extends StatelessWidget {
  final List<HotelModel> hotels;
  final void Function(HotelModel hotel) onSelected;

  const _HotelPickerSheet({required this.hotels, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Pilih Hotel Ready',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...hotels.map((hotel) {
          final stayDays = hotel.checkOut.difference(hotel.checkIn).inDays;

          return Card(
            child: ListTile(
              leading: const Icon(Icons.hotel),
              title: Text(hotel.hotelName),
              subtitle: Text(
                '${hotel.city} • $stayDays hari\n'
                'Check-in: ${_formatDateTime(hotel.checkIn)}\n'
                'Check-out: ${_formatDateTime(hotel.checkOut)}',
              ),
              trailing: const Text('Ready'),
              onTap: () => onSelected(hotel),
            ),
          );
        }),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _MutawwifPickerSheet extends StatelessWidget {
  final List<MutawwifModel> mutawwifs;
  final void Function(MutawwifModel mutawwif) onSelected;

  const _MutawwifPickerSheet({
    required this.mutawwifs,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Pilih Mutawwif Ready',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...mutawwifs.map((mutawwif) {
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(
                  (mutawwif.fullName ?? 'M').isNotEmpty
                      ? (mutawwif.fullName ?? 'M')[0]
                      : 'M',
                ),
              ),
              title: Text(mutawwif.fullName ?? '-'),
              subtitle: Text(
                '${mutawwif.phoneNumber ?? '-'}\n${mutawwif.notes ?? '-'}',
              ),
              trailing: const Text('Ready'),
              onTap: () => onSelected(mutawwif),
            ),
          );
        }),
      ],
    );
  }
}
