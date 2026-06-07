import 'package:get/get.dart';
import 'package:haramain_os/app/data/models/bus_model.dart';
import 'package:haramain_os/app/data/models/group_assignment_model.dart';
import 'package:haramain_os/app/data/models/group_dashboard_model.dart';
import 'package:haramain_os/app/data/models/group_member_model.dart';
import 'package:haramain_os/app/data/models/group_model.dart';
import 'package:haramain_os/app/data/models/hotel_model.dart';
import 'package:haramain_os/app/data/models/mutawwif_model.dart';
import 'package:haramain_os/app/data/repositories/group_repository.dart';

class GroupController extends GetxController {
  final GroupRepository _repository = GroupRepository();

  final isLoading = false.obs;

  final groups = <GroupModel>[].obs;
  final members = <GroupMemberModel>[].obs;
  final assignments = <GroupAssignmentModel>[].obs;
  final dashboards = <GroupDashboardModel>[].obs;

  final readyBuses = <BusModel>[].obs;
  final readyHotels = <HotelModel>[].obs;
  final readyMutawwifs = <MutawwifModel>[].obs;

  final jamaahCount = 12.obs;

  @override
  void onInit() {
    super.onInit();
    loadSampleResources();
    loadData();
  }

  void loadSampleResources() {
    final now = DateTime.now();

    readyBuses.value = [
      BusModel(
        id: 'bus-1',
        busNumber: 'Bus 12',
        city: 'Madinah',
        route: 'Prince Mohammad Bin Abdulaziz Airport - Hotel Madinah',
        departureTime: now.add(const Duration(hours: 2)),
        isReady: true,
      ),
      BusModel(
        id: 'bus-2',
        busNumber: 'Bus 27',
        city: 'Makkah',
        route: 'Hotel Makkah - Masjidil Haram',
        departureTime: now.add(const Duration(hours: 6)),
        isReady: true,
      ),
      BusModel(
        id: 'bus-3',
        busNumber: 'Bus 33',
        city: 'Makkah',
        route: 'Makkah - Jeddah Airport',
        departureTime: now.add(const Duration(days: 10, hours: 3)),
        isReady: true,
      ),
    ];

    readyHotels.value = [
      HotelModel(
        id: 'hotel-1',
        hotelName: 'Hotel Al Kiswah',
        city: 'Madinah',
        checkIn: now,
        checkOut: now.add(const Duration(days: 5)),
        isReady: true,
      ),
      HotelModel(
        id: 'hotel-2',
        hotelName: 'Hotel Safwah Tower',
        city: 'Makkah',
        checkIn: now.add(const Duration(days: 5)),
        checkOut: now.add(const Duration(days: 10)),
        isReady: true,
      ),
    ];

    readyMutawwifs.value = [
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
    ];
  }

  Future<void> loadData() async {
    isLoading.value = true;

    try {
      groups.value = await _repository.getGroups();
      members.value = await _repository.getMembers();
      assignments.value = await _repository.getAssignments();
      buildDashboard();
    } finally {
      isLoading.value = false;
    }
  }

  void buildDashboard() {
    final dashboardList = groups.map((group) {
      final groupMembers = members.where((m) => m.groupId == group.id).toList();

      final groupAssignments = assignments
          .where((a) => a.groupId == group.id && a.isActive)
          .toList();

      return GroupDashboardModel(
        group: group,
        totalMembers: jamaahCount.value,
        totalAssignments: groupAssignments.length,
        totalMutawwifAssignments: groupAssignments
            .where((a) => a.assignmentType == AssignmentType.mutawwif)
            .length,
        totalHotelAssignments: groupAssignments
            .where((a) => a.assignmentType == AssignmentType.hotel)
            .length,
        totalBusAssignments: groupAssignments
            .where((a) => a.assignmentType == AssignmentType.bus)
            .length,
      );
    }).toList();

    dashboards.value = dashboardList;
  }

  Future<void> createSampleGroup() async {
    final now = DateTime.now();

    final group = GroupModel(
      id: now.millisecondsSinceEpoch.toString(),
      groupName: 'Rombongan A',
      description: 'Rombongan jamaah umrah reguler',
      createdAt: now,
    );

    await _repository.createGroup(group);
    await loadData();
  }

  Future<void> deleteGroup(GroupModel group) async {
    if (group.id == null) return;

    await _repository.deleteGroup(group.id!);
    await loadData();
  }

  void increaseJamaah() {
    jamaahCount.value++;
    buildDashboard();
  }

  void decreaseJamaah() {
    if (jamaahCount.value > 0) {
      jamaahCount.value--;
      buildDashboard();
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
    final now = DateTime.now();

    final assignment = GroupAssignmentModel(
      id: now.microsecondsSinceEpoch.toString(),
      groupId: group.id ?? '',
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
  }
}
