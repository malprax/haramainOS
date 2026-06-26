import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:haramain_os/app/data/models/family_group_model.dart';
import 'package:haramain_os/app/data/models/family_member_model.dart';
import 'package:haramain_os/app/data/models/user_model.dart';
import 'package:haramain_os/app/data/repositories/auth_repository.dart';
import 'package:haramain_os/app/data/repositories/family_repository.dart';

class AdminFamilyController extends GetxController {
  final FamilyRepository _familyRepository = FamilyRepository();
  final AuthRepository _authRepository = AuthRepository();

  final isLoading = false.obs;

  final familyGroups = <FamilyGroupModel>[].obs;
  final familyMembers = <FamilyMemberModel>[].obs;
  final availableJamaah = <UserModel>[].obs;

  final familyNameController = TextEditingController();
  final notesController = TextEditingController();

  final selectedRelationship = RelationshipType.relative.obs;
  final isGuardian = false.obs;
  final needsCompanion = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;

    try {
      await loadAvailableJamaah();
      await loadFamilies();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadInitialData();
  }

  Future<void> loadFamilies() async {
    try {
      familyGroups.assignAll(await _familyRepository.getFamilyGroups());
      familyMembers.assignAll(await _familyRepository.getFamilyMembers());

      familyGroups.refresh();
      familyMembers.refresh();

      debugPrint('TOTAL FAMILY GROUPS: ${familyGroups.length}');
      debugPrint('TOTAL FAMILY MEMBERS: ${familyMembers.length}');
    } catch (error) {
      debugPrint('LOAD FAMILY ERROR: $error');

      Get.snackbar(
        'Gagal memuat keluarga',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> loadAvailableJamaah() async {
    try {
      final users = await _authRepository.getUsers();

      availableJamaah.assignAll(
        users.where((user) => user.role == UserRole.jamaah).toList(),
      );

      availableJamaah.refresh();

      debugPrint('TOTAL AVAILABLE JAMAAH FAMILY: ${availableJamaah.length}');
    } catch (error) {
      debugPrint('LOAD AVAILABLE JAMAAH FAMILY ERROR: $error');
    }
  }

  int get totalFamilies => familyGroups.length;

  int get totalFamilyMembers => familyMembers.length;

  int get totalGuardians {
    return familyMembers.where((item) => item.isGuardian).length;
  }

  int get totalNeedCompanion {
    return familyMembers.where((item) => item.needsCompanion).length;
  }

  int get totalActiveFamilies {
    return familyGroups.where((item) => item.isActive).length;
  }

  int get totalPriorityRoom {
    return familyGroups.where((item) => item.priorityLevel == 1).length;
  }

  int get totalPriorityBus {
    return familyGroups.where((item) => item.priorityLevel == 2).length;
  }

  List<FamilyGroupModel> get activeFamilyGroups {
    return familyGroups.where((item) => item.isActive).toList();
  }

  List<FamilyMemberModel> getMembersByFamily(String? familyId) {
    final id = familyId?.trim() ?? '';

    if (id.isEmpty) return [];

    return familyMembers.where((item) => item.familyId == id).toList();
  }

  FamilyMemberModel? getFamilyMemberByJamaah(String? jamaahId) {
    final id = jamaahId?.trim() ?? '';

    if (id.isEmpty) return null;

    return familyMembers.firstWhereOrNull((item) => item.jamaahId == id);
  }

  bool isJamaahAlreadyInFamily(String? jamaahId) {
    return getFamilyMemberByJamaah(jamaahId) != null;
  }

  List<UserModel> getAvailableJamaahForFamily(String? familyId) {
    final currentMembers = getMembersByFamily(familyId);
    final currentMemberIds = currentMembers
        .map((item) => item.jamaahId)
        .toSet();

    return availableJamaah.where((jamaah) {
      return !currentMemberIds.contains(jamaah.id);
    }).toList();
  }

  String getJamaahName(String? jamaahId) {
    final id = jamaahId?.trim() ?? '';

    if (id.isEmpty) return '-';

    final user = availableJamaah.firstWhereOrNull((item) => item.id == id);

    if (user == null) return 'Jamaah tidak ditemukan';

    if (user.fullName.trim().isNotEmpty) {
      return user.fullName.trim();
    }

    if (user.email.trim().isNotEmpty) {
      return user.email.trim();
    }

    return '-';
  }

  String getJamaahEmail(String? jamaahId) {
    final id = jamaahId?.trim() ?? '';

    if (id.isEmpty) return '-';

    final user = availableJamaah.firstWhereOrNull((item) => item.id == id);

    if (user == null) return '-';

    return user.email.trim().isEmpty ? '-' : user.email.trim();
  }

  String relationshipLabel(RelationshipType type) {
    switch (type) {
      case RelationshipType.headFamily:
        return 'Kepala Keluarga';
      case RelationshipType.spouse:
        return 'Suami/Istri';
      case RelationshipType.child:
        return 'Anak';
      case RelationshipType.parent:
        return 'Orang Tua';
      case RelationshipType.sibling:
        return 'Saudara Kandung';
      case RelationshipType.grandparent:
        return 'Kakek/Nenek';
      case RelationshipType.grandchild:
        return 'Cucu';
      case RelationshipType.uncle:
        return 'Paman';
      case RelationshipType.aunt:
        return 'Bibi';
      case RelationshipType.cousin:
        return 'Sepupu';
      case RelationshipType.relative:
        return 'Kerabat';
      case RelationshipType.friend:
        return 'Teman';
      case RelationshipType.companion:
        return 'Pendamping';
    }
  }

  String priorityLabel(int priorityLevel) {
    switch (priorityLevel) {
      case 1:
        return 'Wajib Satu Kamar';
      case 2:
        return 'Wajib Satu Bus';
      case 3:
        return 'Usahakan Bersama';
      case 4:
        return 'Bebas';
      default:
        return 'Usahakan Bersama';
    }
  }

  Color priorityColor(int priorityLevel) {
    switch (priorityLevel) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.green;
      case 4:
        return Colors.grey;
      default:
        return Colors.green;
    }
  }

  Future<void> createFamilyGroup() async {
    final familyName = familyNameController.text.trim();
    final notes = notesController.text.trim();

    if (familyName.isEmpty) {
      Get.snackbar(
        'Nama keluarga wajib diisi',
        'Contoh: Keluarga Pak Ahmad',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final now = DateTime.now();

      final family = FamilyGroupModel(
        id: 'family_${now.millisecondsSinceEpoch}',
        familyName: familyName,
        packageId: '',
        notes: notes,
        priorityLevel: 3,
        isActive: true,
        createdAt: now,
      );

      await _familyRepository.createFamilyGroup(family);

      familyNameController.clear();
      notesController.clear();

      await loadFamilies();

      Get.back();

      Get.snackbar(
        'Berhasil',
        'Family group berhasil dibuat',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Gagal membuat family group',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> addJamaahToFamily({
    required FamilyGroupModel family,
    required UserModel jamaah,
    required RelationshipType relationshipType,
    bool isGuardianValue = false,
    bool needsCompanionValue = false,
  }) async {
    final familyId = family.id?.trim() ?? '';

    if (familyId.isEmpty) {
      Get.snackbar(
        'Family tidak valid',
        'ID family tidak ditemukan',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final existsInFamily = familyMembers.any(
        (item) => item.familyId == familyId && item.jamaahId == jamaah.id,
      );

      if (existsInFamily) {
        Get.snackbar(
          'Sudah ada',
          'Jamaah sudah berada dalam family ini',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final member = FamilyMemberModel(
        id: 'family_member_${DateTime.now().microsecondsSinceEpoch}',
        familyId: familyId,
        jamaahId: jamaah.id,
        relationshipType: relationshipType,
        isGuardian: isGuardianValue,
        needsCompanion: needsCompanionValue,
        createdAt: DateTime.now(),
      );

      await _familyRepository.createFamilyMember(member);

      await loadFamilies();

      Get.snackbar(
        'Berhasil',
        '${jamaah.fullName} ditambahkan ke ${family.familyName}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Gagal tambah jamaah',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteFamilyGroup(FamilyGroupModel family) async {
    final familyId = family.id?.trim() ?? '';

    if (familyId.isEmpty) return;

    try {
      final members = getMembersByFamily(familyId);

      for (final member in members) {
        final memberId = member.id?.trim() ?? '';

        if (memberId.isNotEmpty) {
          await _familyRepository.deleteFamilyMember(memberId);
        }
      }

      await _familyRepository.deleteFamilyGroup(familyId);

      await loadFamilies();

      Get.snackbar(
        'Berhasil',
        'Family group berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Gagal hapus family group',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> removeFamilyMember(FamilyMemberModel member) async {
    final memberId = member.id?.trim() ?? '';

    if (memberId.isEmpty) return;

    try {
      await _familyRepository.deleteFamilyMember(memberId);

      await loadFamilies();

      Get.snackbar(
        'Berhasil',
        '${getJamaahName(member.jamaahId)} dihapus dari family',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Gagal hapus anggota family',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    familyNameController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
