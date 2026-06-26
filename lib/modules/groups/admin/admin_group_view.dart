import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:haramain_os/app/data/models/bus_model.dart';
import 'package:haramain_os/app/data/models/group_assignment_model.dart';
import 'package:haramain_os/app/data/models/group_member_model.dart';
import 'package:haramain_os/app/data/models/group_model.dart';
import 'package:haramain_os/app/data/models/hotel_model.dart';
import 'package:haramain_os/app/data/models/mutawwif_model.dart';
import 'package:haramain_os/app/data/models/user_model.dart';

import 'admin_group_controller.dart';

class AdminGroupView extends GetView<AdminGroupController> {
  const AdminGroupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group Management'), centerTitle: true),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SummarySection(controller: controller),
              const SizedBox(height: 16),
              if (controller.groups.isEmpty)
                const _EmptyGroupView()
              else
                ...controller.dashboards.map((dashboard) {
                  return _GroupCard(
                    group: dashboard.group,
                    totalMembers: dashboard.totalMembers,
                    totalBusAssignments: dashboard.totalBusAssignments,
                    totalHotelAssignments: dashboard.totalHotelAssignments,
                    totalMutawwifAssignments:
                        dashboard.totalMutawwifAssignments,
                    controller: controller,
                  );
                }),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateGroupDialog(context),
        icon: const Icon(Icons.group_add),
        label: const Text('Tambah Group'),
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    controller.groupNameController.clear();
    controller.descriptionController.clear();

    Get.dialog(
      AlertDialog(
        title: const Text('Tambah Rombongan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller.groupNameController,
              decoration: const InputDecoration(
                labelText: 'Nama Rombongan',
                hintText: 'Contoh: Rombongan A',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                hintText: 'Contoh: Jamaah reguler September',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Batal')),
          ElevatedButton.icon(
            onPressed: controller.createGroup,
            icon: const Icon(Icons.save),
            label: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final AdminGroupController controller;

  const _SummarySection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryBox(
            title: 'Group',
            value: controller.groups.length.toString(),
            icon: Icons.groups,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryBox(
            title: 'Member',
            value: controller.totalMembers.toString(),
            icon: Icons.people,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryBox(
            title: 'Leader',
            value: controller.totalLeader.toString(),
            icon: Icons.star,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryBox(
            title: 'Assign',
            value: controller.totalActiveAssignments.toString(),
            icon: Icons.assignment_turned_in,
            color: Colors.purple,
          ),
        ),
      ],
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryBox({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _EmptyGroupView extends StatelessWidget {
  const _EmptyGroupView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.groups_rounded, size: 76, color: Colors.grey.shade400),
            const SizedBox(height: 14),
            const Text(
              'Belum ada rombongan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Buat group untuk mengatur jamaah, bus, hotel, dan mutawwif.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final GroupModel group;
  final int totalMembers;
  final int totalBusAssignments;
  final int totalHotelAssignments;
  final int totalMutawwifAssignments;
  final AdminGroupController controller;

  const _GroupCard({
    required this.group,
    required this.totalMembers,
    required this.totalBusAssignments,
    required this.totalHotelAssignments,
    required this.totalMutawwifAssignments,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final assignments = controller.getActiveAssignmentsByGroup(group.id);
    final groupMembers = controller.getMembersByGroup(group.id);
    final leader = controller.getLeaderByGroup(group.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GroupTitleRow(group: group, controller: controller),
            const SizedBox(height: 4),
            Text(
              group.description ?? '-',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(label: '$totalMembers Jamaah', icon: Icons.people),
                _InfoChip(
                  label: leader == null
                      ? 'Belum ada Leader'
                      : 'Leader: ${controller.getJamaahName(leader.jamaahId)}',
                  icon: Icons.star,
                ),
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

            const Divider(height: 28),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Member Rombongan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showJamaahDialog(context, group),
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Tambah'),
                ),
              ],
            ),

            if (groupMembers.isEmpty)
              Text(
                'Belum ada jamaah dalam group ini',
                style: TextStyle(color: Colors.grey.shade700),
              )
            else
              ...groupMembers.map(
                (member) =>
                    _GroupMemberTile(member: member, controller: controller),
              ),

            const Divider(height: 28),

            const Text(
              'Assignment Aktif',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (assignments.isEmpty)
              Text(
                'Belum ada assignment aktif',
                style: TextStyle(color: Colors.grey.shade700),
              )
            else
              ...assignments.map(
                (assignment) => _AssignmentTile(assignment: assignment),
              ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showJamaahDialog(context, group),
                  icon: const Icon(Icons.people),
                  label: const Text('Kelola Jamaah'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showBusPicker(context),
                  icon: const Icon(Icons.directions_bus),
                  label: const Text('Bus'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showHotelPicker(context),
                  icon: const Icon(Icons.hotel),
                  label: const Text('Hotel'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showMutawwifPicker(context),
                  icon: const Icon(Icons.person_pin),
                  label: const Text('Mutawwif'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showJamaahDialog(BuildContext context, GroupModel group) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.85,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Obx(() {
          final groupMembers = controller.getMembersByGroup(group.id);
          final availableJamaah = controller.getAvailableJamaahForGroup(
            group.id,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Kelola Jamaah - ${group.groupName ?? '-'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),

              const Text(
                'Anggota Saat Ini',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              if (groupMembers.isEmpty)
                Text(
                  'Belum ada jamaah dalam group ini',
                  style: TextStyle(color: Colors.grey.shade700),
                )
              else
                SizedBox(
                  height: 160,
                  child: ListView(
                    children: groupMembers.map((member) {
                      return _GroupMemberTile(
                        member: member,
                        controller: controller,
                      );
                    }).toList(),
                  ),
                ),

              const SizedBox(height: 16),

              const Text(
                'Tambah Jamaah',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: availableJamaah.isEmpty
                    ? const Center(child: Text('Tidak ada jamaah tersedia'))
                    : ListView.builder(
                        itemCount: availableJamaah.length,
                        itemBuilder: (context, index) {
                          final UserModel jamaah = availableJamaah[index];

                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(_initial(jamaah.fullName)),
                              ),
                              title: Text(jamaah.fullName),
                              subtitle: Text(jamaah.email),
                              trailing: ElevatedButton(
                                onPressed: () async {
                                  await controller.addJamaahToGroup(
                                    group: group,
                                    jamaah: jamaah,
                                  );
                                },
                                child: const Text('Tambah'),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        }),
      ),
      isScrollControlled: true,
    );
  }

  void _showBusPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => _BusPickerSheet(
        buses: controller.readyBuses,
        onSelected: (bus) {
          Navigator.pop(context);
          controller.assignSelectedBus(group, bus);
        },
      ),
    );
  }

  void _showHotelPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => _HotelPickerSheet(
        hotels: controller.readyHotels,
        onSelected: (hotel) {
          Navigator.pop(context);
          controller.assignSelectedHotel(group, hotel);
        },
      ),
    );
  }

  void _showMutawwifPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => _MutawwifPickerSheet(
        mutawwifs: controller.readyMutawwifs,
        onSelected: (mutawwif) {
          Navigator.pop(context);
          controller.assignSelectedMutawwif(group, mutawwif);
        },
      ),
    );
  }
}

class _GroupMemberTile extends StatelessWidget {
  final GroupMemberModel member;
  final AdminGroupController controller;

  const _GroupMemberTile({required this.member, required this.controller});

  @override
  Widget build(BuildContext context) {
    final name = controller.getJamaahName(member.jamaahId);
    final email = controller.getJamaahEmail(member.jamaahId);

    return Card(
      color: member.isLeader ? Colors.orange.shade50 : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: member.isLeader
              ? Colors.orange.shade100
              : Colors.green.shade100,
          child: Icon(
            member.isLeader ? Icons.star : Icons.person,
            color: member.isLeader ? Colors.orange.shade800 : Colors.green,
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: member.isLeader ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        subtitle: Text(
          member.isLeader ? 'Ketua Rombongan\n$email' : 'Anggota\n$email',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'leader') {
              controller.setLeader(member);
            }

            if (value == 'delete') {
              controller.removeMember(member);
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'leader', child: Text('Jadikan Ketua')),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Hapus dari Group'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupTitleRow extends StatelessWidget {
  final GroupModel group;
  final AdminGroupController controller;

  const _GroupTitleRow({required this.group, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(Icons.groups, color: Colors.green.shade800),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            group.groupName ?? 'Tanpa Nama Rombongan',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          color: Colors.red,
          onPressed: () => _showDeleteDialog(),
        ),
      ],
    );
  }

  void _showDeleteDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Hapus Group'),
        content: Text(
          'Yakin ingin menghapus ${group.groupName ?? 'group ini'}?',
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Batal')),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              controller.deleteGroup(group);
            },
            icon: const Icon(Icons.delete),
            label: const Text('Hapus'),
          ),
        ],
      ),
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
        '${assignment.city.isEmpty ? assignment.route : assignment.city} • ${assignment.route}',
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
}

class _BusPickerSheet extends StatelessWidget {
  final List<BusModel> buses;
  final void Function(BusModel bus) onSelected;

  const _BusPickerSheet({required this.buses, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return _PickerContainer(
      title: 'Pilih Bus',
      children: buses.map((bus) {
        return ListTile(
          leading: const Icon(Icons.directions_bus),
          title: Text(bus.busNumber),
          subtitle: Text('${bus.city}\n${bus.route}'),
          onTap: () => onSelected(bus),
        );
      }).toList(),
    );
  }
}

class _HotelPickerSheet extends StatelessWidget {
  final List<HotelModel> hotels;
  final void Function(HotelModel hotel) onSelected;

  const _HotelPickerSheet({required this.hotels, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return _PickerContainer(
      title: 'Pilih Hotel',
      children: hotels.map((hotel) {
        return ListTile(
          leading: const Icon(Icons.hotel),
          title: Text(hotel.hotelName),
          subtitle: Text('${hotel.city}\nCheck-in sampai check-out tersedia'),
          onTap: () => onSelected(hotel),
        );
      }).toList(),
    );
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
    return _PickerContainer(
      title: 'Pilih Mutawwif',
      children: mutawwifs.map((mutawwif) {
        return ListTile(
          leading: CircleAvatar(
            child: Text(_initial(mutawwif.fullName ?? 'M')),
          ),
          title: Text(mutawwif.fullName ?? '-'),
          subtitle: Text(mutawwif.phoneNumber ?? '-'),
          onTap: () => onSelected(mutawwif),
        );
      }).toList(),
    );
  }
}

class _PickerContainer extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _PickerContainer({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

String _initial(String value) {
  final clean = value.trim();

  if (clean.isEmpty) return '-';

  return clean.substring(0, 1).toUpperCase();
}
