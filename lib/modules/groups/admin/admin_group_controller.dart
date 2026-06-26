import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:haramain_os/app/data/models/bus_model.dart';
import 'package:haramain_os/app/data/models/group_assignment_model.dart';
import 'package:haramain_os/app/data/models/group_dashboard_model.dart';
import 'package:haramain_os/app/data/models/group_member_model.dart';
import 'package:haramain_os/app/data/models/group_model.dart';
import 'package:haramain_os/app/data/models/hotel_model.dart';
import 'package:haramain_os/app/data/models/mutawwif_model.dart';
import 'package:haramain_os/app/data/models/user_model.dart';
import 'package:haramain_os/app/data/repositories/auth_repository.dart';
import 'package:haramain_os/app/data/repositories/group_member_repository.dart';
import 'package:haramain_os/app/data/repositories/group_repository.dart';

class AdminGroupController extends GetxController {
  final GroupRepository _repository = GroupRepository();
  final GroupMemberRepository _memberRepository = GroupMemberRepository();
  final AuthRepository _authRepository = AuthRepository();

  final isLoading = false.obs;

  final groups = <GroupModel>[].obs;
  final members = <GroupMemberModel>[].obs;
  final assignments = <GroupAssignmentModel>[].obs;
  final dashboards = <GroupDashboardModel>[].obs;

  final readyBuses = <BusModel>[].obs;
  final readyHotels = <HotelModel>[].obs;
  final readyMutawwifs = <MutawwifModel>[].obs;
  final availableJamaah = <UserModel>[].obs;

  final groupNameController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadSampleResources();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;

    try {
      await loadAvailableJamaah();
      await loadData();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadInitialData();
  }

  Future<void> loadAvailableJamaah() async {
    try {
      final users = await _authRepository.getUsers();

      availableJamaah.assignAll(
        users.where((user) => user.role == UserRole.jamaah).toList(),
      );

      availableJamaah.refresh();

      debugPrint('TOTAL AVAILABLE JAMAAH: ${availableJamaah.length}');
    } catch (error) {
      debugPrint('LOAD AVAILABLE JAMAAH ERROR: $error');
    }
  }

  Future<void> loadData() async {
    try {
      groups.assignAll(await _repository.getGroups());
      members.assignAll(await _repository.getMembers());
      assignments.assignAll(await _repository.getAssignments());

      groups.refresh();
      members.refresh();
      assignments.refresh();

      _buildDashboard();

      debugPrint('TOTAL GROUPS: ${groups.length}');
      debugPrint('TOTAL GROUP MEMBERS: ${members.length}');
      debugPrint('TOTAL GROUP ASSIGNMENTS: ${assignments.length}');
    } catch (error) {
      debugPrint('LOAD ADMIN GROUP ERROR: $error');

      Get.snackbar(
        'Gagal memuat group',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void loadSampleResources() {
    final now = DateTime.now();

    readyBuses.assignAll([
      BusModel(
        id: 'bus-1',
        busNumber: 'Bus 1',
        city: 'Madinah',
        route: 'Bandara Madinah - Hotel Madinah',
        departureTime: now.add(const Duration(hours: 2)),
        isReady: true,
      ),
      BusModel(
        id: 'bus-2',
        busNumber: 'Bus 2',
        city: 'Makkah',
        route: 'Hotel Makkah - Masjidil Haram',
        departureTime: now.add(const Duration(hours: 6)),
        isReady: true,
      ),
      BusModel(
        id: 'bus-3',
        busNumber: 'Bus 3',
        city: 'Jeddah',
        route: 'Hotel Makkah - Bandara Jeddah',
        departureTime: now.add(const Duration(days: 8)),
        isReady: true,
      ),
    ]);

    readyHotels.assignAll([
      HotelModel(
        id: 'hotel-1',
        hotelName: 'Anjum Makkah',
        city: 'Makkah',
        checkIn: now.add(const Duration(days: 1)),
        checkOut: now.add(const Duration(days: 5)),
        isReady: true,
      ),
      HotelModel(
        id: 'hotel-2',
        hotelName: 'Pullman Zamzam Madinah',
        city: 'Madinah',
        checkIn: now.add(const Duration(days: 5)),
        checkOut: now.add(const Duration(days: 9)),
        isReady: true,
      ),
    ]);

    readyMutawwifs.assignAll([
      MutawwifModel(
        id: 'mutawwif-1',
        fullName: 'Ustadz Ahmad',
        phoneNumber: '+966500001111',
        whatsappNumber: '+966500001111',
        email: 'ahmad@haramainos.app',
        notes: 'Pendamping jamaah reguler',
        imageUrl: '',
        isActive: true,
      ),
      MutawwifModel(
        id: 'mutawwif-2',
        fullName: 'Ustadz Yusuf',
        phoneNumber: '+966500002222',
        whatsappNumber: '+966500002222',
        email: 'yusuf@haramainos.app',
        notes: 'Pendamping jamaah VIP',
        imageUrl: '',
        isActive: true,
      ),
    ]);
  }

  void _buildDashboard() {
    final dashboardList = groups.map((group) {
      final groupId = group.id ?? '';

      final groupMembers = members.where((item) {
        return item.groupId == groupId;
      }).toList();

      final activeAssignments = assignments.where((item) {
        return item.groupId == groupId && item.isActive;
      }).toList();

      return GroupDashboardModel(
        group: group,
        totalMembers: groupMembers.length,
        totalAssignments: activeAssignments.length,
        totalMutawwifAssignments: activeAssignments
            .where((item) => item.assignmentType == AssignmentType.mutawwif)
            .length,
        totalHotelAssignments: activeAssignments
            .where((item) => item.assignmentType == AssignmentType.hotel)
            .length,
        totalBusAssignments: activeAssignments
            .where((item) => item.assignmentType == AssignmentType.bus)
            .length,
      );
    }).toList();

    dashboards.assignAll(dashboardList);
    dashboards.refresh();
  }

  int get totalMembers => members.length;

  int get totalLeader {
    return members.where((item) => item.isLeader).length;
  }

  int get totalActiveAssignments {
    return assignments.where((item) => item.isActive).length;
  }

  List<GroupMemberModel> getMembersByGroup(String? groupId) {
    final id = groupId?.trim() ?? '';

    if (id.isEmpty) return [];

    return members.where((item) => item.groupId == id).toList();
  }

  GroupMemberModel? getLeaderByGroup(String? groupId) {
    final id = groupId?.trim() ?? '';

    if (id.isEmpty) return null;

    return members.firstWhereOrNull(
      (item) => item.groupId == id && item.isLeader,
    );
  }

  bool hasLeader(String? groupId) {
    return getLeaderByGroup(groupId) != null;
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

  List<UserModel> getAvailableJamaahForGroup(String? groupId) {
    final currentMembers = getMembersByGroup(groupId);
    final memberIds = currentMembers.map((item) => item.jamaahId).toSet();

    return availableJamaah.where((jamaah) {
      return !memberIds.contains(jamaah.id);
    }).toList();
  }

  List<GroupAssignmentModel> getActiveAssignmentsByGroup(String? groupId) {
    final id = groupId?.trim() ?? '';

    if (id.isEmpty) return [];

    return assignments.where((item) {
      return item.groupId == id && item.isActive;
    }).toList();
  }

  Future<void> createGroup() async {
    final groupName = groupNameController.text.trim();
    final description = descriptionController.text.trim();

    if (groupName.isEmpty) {
      Get.snackbar(
        'Nama wajib diisi',
        'Tuliskan nama rombongan terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final now = DateTime.now();

      final group = GroupModel(
        id: 'group_${now.millisecondsSinceEpoch}',
        groupName: groupName,
        description: description,
        createdAt: now,
      );

      await _repository.createGroup(group);

      groupNameController.clear();
      descriptionController.clear();

      await loadData();

      Get.back();

      Get.snackbar(
        'Berhasil',
        'Rombongan berhasil dibuat',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Gagal membuat rombongan',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteGroup(GroupModel group) async {
    final groupId = group.id?.trim() ?? '';

    if (groupId.isEmpty) return;

    try {
      final groupMembers = getMembersByGroup(groupId);

      for (final member in groupMembers) {
        await _memberRepository.deleteMember(member.id);
      }

      await _repository.deleteGroup(groupId);

      await loadData();

      Get.snackbar(
        'Berhasil',
        'Rombongan berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Gagal menghapus rombongan',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> addJamaahToGroup({
    required GroupModel group,
    required UserModel jamaah,
  }) async {
    final groupId = group.id?.trim() ?? '';

    if (groupId.isEmpty) {
      Get.snackbar(
        'Group tidak valid',
        'ID group tidak ditemukan',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final exists = members.any(
        (item) => item.groupId == groupId && item.jamaahId == jamaah.id,
      );

      if (exists) {
        Get.snackbar(
          'Sudah ada',
          'Jamaah sudah berada dalam group ini',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final member = GroupMemberModel(
        id: 'member_${DateTime.now().microsecondsSinceEpoch}',
        groupId: groupId,
        jamaahId: jamaah.id,
        isLeader: false,
        createdAt: DateTime.now(),
      );

      await _memberRepository.createMember(member);

      await loadData();

      Get.snackbar(
        'Berhasil',
        '${jamaah.fullName} ditambahkan ke ${group.groupName}',
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

  Future<void> removeMember(GroupMemberModel member) async {
    try {
      await _memberRepository.deleteMember(member.id);

      await loadData();

      Get.snackbar(
        'Berhasil',
        '${getJamaahName(member.jamaahId)} dihapus dari group',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Gagal hapus member',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> setLeader(GroupMemberModel member) async {
    try {
      final groupMembers = getMembersByGroup(member.groupId);

      for (final item in groupMembers) {
        if (item.isLeader) {
          await _memberRepository.updateMember(item.copyWith(isLeader: false));
        }
      }

      await _memberRepository.updateMember(member.copyWith(isLeader: true));

      await loadData();

      Get.snackbar(
        'Berhasil',
        '${getJamaahName(member.jamaahId)} ditetapkan sebagai Ketua Rombongan',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Gagal menetapkan leader',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> assignSelectedBus(GroupModel group, BusModel bus) async {
    await _createAssignment(
      group: group,
      assignmentType: AssignmentType.bus,
      resourceId: bus.id,
      resourceName: bus.busNumber,
      city: bus.city,
      route: bus.route,
      startDate: bus.departureTime,
      endDate: null,
    );
  }

  Future<void> assignSelectedHotel(GroupModel group, HotelModel hotel) async {
    await _createAssignment(
      group: group,
      assignmentType: AssignmentType.hotel,
      resourceId: hotel.id,
      resourceName: hotel.hotelName,
      city: hotel.city,
      route: 'Menginap di ${hotel.city}',
      startDate: hotel.checkIn,
      endDate: hotel.checkOut,
    );
  }

  Future<void> assignSelectedMutawwif(
    GroupModel group,
    MutawwifModel mutawwif,
  ) async {
    await _createAssignment(
      group: group,
      assignmentType: AssignmentType.mutawwif,
      resourceId: mutawwif.id ?? '',
      resourceName: mutawwif.fullName ?? '',
      city: '',
      route: mutawwif.notes ?? 'Pendamping jamaah',
      startDate: DateTime.now(),
      endDate: null,
    );
  }

  Future<void> _createAssignment({
    required GroupModel group,
    required AssignmentType assignmentType,
    required String resourceId,
    required String resourceName,
    required String city,
    required String route,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    final groupId = group.id?.trim() ?? '';

    if (groupId.isEmpty) return;

    try {
      final assignment = GroupAssignmentModel(
        id: 'assignment_${DateTime.now().microsecondsSinceEpoch}',
        groupId: groupId,
        assignmentType: assignmentType,
        resourceId: resourceId,
        resourceName: resourceName,
        city: city,
        route: route,
        startDate: startDate,
        endDate: endDate,
        isActive: true,
      );

      await _repository.createAssignment(assignment);

      await loadData();

      Get.snackbar(
        'Berhasil',
        'Assignment berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Gagal assignment',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    groupNameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
