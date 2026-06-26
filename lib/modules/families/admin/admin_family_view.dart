import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:haramain_os/app/data/models/family_group_model.dart';
import 'package:haramain_os/app/data/models/family_member_model.dart';
import 'package:haramain_os/app/data/models/user_model.dart';

import 'admin_family_controller.dart';

class AdminFamilyView extends GetView<AdminFamilyController> {
  const AdminFamilyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family Management'), centerTitle: true),
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
              if (controller.familyGroups.isEmpty)
                const _EmptyFamilyView()
              else
                ...controller.familyGroups.map(
                  (family) =>
                      _FamilyCard(family: family, controller: controller),
                ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateFamilyDialog,
        icon: const Icon(Icons.family_restroom),
        label: const Text('Tambah Family'),
      ),
    );
  }

  void _showCreateFamilyDialog() {
    controller.familyNameController.clear();
    controller.notesController.clear();

    Get.dialog(
      AlertDialog(
        title: const Text('Tambah Family Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller.familyNameController,
              decoration: const InputDecoration(
                labelText: 'Nama Family',
                hintText: 'Contoh: Keluarga Pak Ahmad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Catatan',
                hintText: 'Contoh: Jangan pisahkan dalam bus/hotel.',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Batal')),
          ElevatedButton.icon(
            onPressed: controller.createFamilyGroup,
            icon: const Icon(Icons.save),
            label: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final AdminFamilyController controller;

  const _SummarySection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryBox(
            title: 'Family',
            value: controller.totalFamilies.toString(),
            icon: Icons.family_restroom,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryBox(
            title: 'Member',
            value: controller.totalFamilyMembers.toString(),
            icon: Icons.people,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryBox(
            title: 'Guardian',
            value: controller.totalGuardians.toString(),
            icon: Icons.shield,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryBox(
            title: 'Companion',
            value: controller.totalNeedCompanion.toString(),
            icon: Icons.elderly,
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

class _EmptyFamilyView extends StatelessWidget {
  const _EmptyFamilyView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.family_restroom, size: 76, color: Colors.grey.shade400),
            const SizedBox(height: 14),
            const Text(
              'Belum ada family group',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Buat family group agar keluarga, kerabat, dan pendamping tidak terpisah.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}

class _FamilyCard extends StatelessWidget {
  final FamilyGroupModel family;
  final AdminFamilyController controller;

  const _FamilyCard({required this.family, required this.controller});

  @override
  Widget build(BuildContext context) {
    final members = controller.getMembersByFamily(family.id);

    debugPrint('FAMILY ${family.familyName} MEMBER COUNT = ${members.length}');
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FamilyTitleRow(family: family, controller: controller),
            const SizedBox(height: 4),
            Text(
              family.notes?.trim().isEmpty == false
                  ? family.notes!
                  : 'Tidak ada catatan',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  label: '${members.length} Jamaah',
                  icon: Icons.people,
                ),
              ],
            ),
            const Divider(height: 28),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Anggota Family',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showAddMemberSheet(),
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Tambah'),
                ),
              ],
            ),
            if (members.isEmpty)
              Text(
                'Belum ada anggota family',
                style: TextStyle(color: Colors.grey.shade700),
              )
            else
              ...members.map(
                (member) =>
                    _FamilyMemberTile(member: member, controller: controller),
              ),
          ],
        ),
      ),
    );
  }

  void _showAddMemberSheet() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.85,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Obx(() {
          final availableJamaah = controller.getAvailableJamaahForFamily(
            family.id,
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
                'Tambah Anggota - ${family.familyName}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: availableJamaah.isEmpty
                    ? const Center(child: Text('Tidak ada jamaah tersedia'))
                    : ListView.builder(
                        itemCount: availableJamaah.length,
                        itemBuilder: (context, index) {
                          final jamaah = availableJamaah[index];

                          return _AvailableJamaahTile(
                            family: family,
                            jamaah: jamaah,
                            controller: controller,
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
}

class _AvailableJamaahTile extends StatefulWidget {
  final FamilyGroupModel family;
  final UserModel jamaah;
  final AdminFamilyController controller;

  const _AvailableJamaahTile({
    required this.family,
    required this.jamaah,
    required this.controller,
  });

  @override
  State<_AvailableJamaahTile> createState() => _AvailableJamaahTileState();
}

class _AvailableJamaahTileState extends State<_AvailableJamaahTile> {
  RelationshipType selectedRelationship = RelationshipType.relative;
  bool isGuardian = false;
  bool needsCompanion = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: CircleAvatar(child: Text(_initial(widget.jamaah.fullName))),
        title: Text(widget.jamaah.fullName),
        subtitle: Text(widget.jamaah.email),
        childrenPadding: const EdgeInsets.all(12),
        children: [
          DropdownButtonFormField<RelationshipType>(
            value: selectedRelationship,
            decoration: const InputDecoration(
              labelText: 'Hubungan',
              border: OutlineInputBorder(),
            ),
            items: RelationshipType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(widget.controller.relationshipLabel(type)),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                selectedRelationship = value;
              });
            },
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            value: isGuardian,
            title: const Text('Wali / Penanggung Jawab'),
            onChanged: (value) {
              setState(() {
                isGuardian = value;
              });
            },
          ),
          SwitchListTile(
            value: needsCompanion,
            title: const Text('Butuh Pendamping'),
            onChanged: (value) {
              setState(() {
                needsCompanion = value;
              });
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await widget.controller.addJamaahToFamily(
                  family: widget.family,
                  jamaah: widget.jamaah,
                  relationshipType: selectedRelationship,
                  isGuardianValue: isGuardian,
                  needsCompanionValue: needsCompanion,
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambahkan'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FamilyMemberTile extends StatelessWidget {
  final FamilyMemberModel member;
  final AdminFamilyController controller;

  const _FamilyMemberTile({required this.member, required this.controller});

  @override
  Widget build(BuildContext context) {
    final name = controller.getJamaahName(member.jamaahId);
    final email = controller.getJamaahEmail(member.jamaahId);

    return Card(
      color: member.isGuardian ? Colors.orange.shade50 : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: member.isGuardian
              ? Colors.orange.shade100
              : Colors.green.shade100,
          child: Icon(
            member.needsCompanion ? Icons.elderly : Icons.person,
            color: member.isGuardian ? Colors.orange.shade800 : Colors.green,
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: member.isGuardian ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${controller.relationshipLabel(member.relationshipType)}\n$email'
          '${member.needsCompanion ? '\nButuh pendamping' : ''}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => controller.removeFamilyMember(member),
        ),
      ),
    );
  }
}

class _FamilyTitleRow extends StatelessWidget {
  final FamilyGroupModel family;
  final AdminFamilyController controller;

  const _FamilyTitleRow({required this.family, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(Icons.family_restroom, color: Colors.green.shade800),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            family.familyName,
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
        title: const Text('Hapus Family'),
        content: Text('Yakin ingin menghapus ${family.familyName}?'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Batal')),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              controller.deleteFamilyGroup(family);
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

String _initial(String value) {
  final clean = value.trim();

  if (clean.isEmpty) return '-';

  return clean.substring(0, 1).toUpperCase();
}
