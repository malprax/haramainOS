import 'package:haramain_os/app/data/models/group_model.dart';

class GroupDashboardModel {
  final GroupModel group;
  final int totalMembers;
  final int totalAssignments;
  final int totalMutawwifAssignments;
  final int totalHotelAssignments;
  final int totalBusAssignments;

  GroupDashboardModel({
    required this.group,
    required this.totalMembers,
    required this.totalAssignments,
    required this.totalMutawwifAssignments,
    required this.totalHotelAssignments,
    required this.totalBusAssignments,
  });
}
