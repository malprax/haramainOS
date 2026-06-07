enum AssignmentType { bus, hotel, mutawwif }

class GroupAssignmentModel {
  final String id;
  final String groupId;
  final AssignmentType assignmentType;

  final String resourceId;
  final String resourceName;

  final String city;
  final String route;

  final DateTime startDate;
  final DateTime? endDate;

  final bool isActive;

  GroupAssignmentModel({
    required this.id,
    required this.groupId,
    required this.assignmentType,
    required this.resourceId,
    required this.resourceName,
    required this.city,
    required this.route,
    required this.startDate,
    this.endDate,
    required this.isActive,
  });

  factory GroupAssignmentModel.fromJson(Map<String, dynamic> json) {
    return GroupAssignmentModel(
      id: json['id'] ?? '',
      groupId: json['groupId'] ?? '',
      assignmentType: AssignmentType.values.firstWhere(
        (e) => e.name == json['assignmentType'],
        orElse: () => AssignmentType.bus,
      ),
      resourceId: json['resourceId'] ?? '',
      resourceName: json['resourceName'] ?? '',
      city: json['city'] ?? '',
      route: json['route'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] == null ? null : DateTime.parse(json['endDate']),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'assignmentType': assignmentType.name,
      'resourceId': resourceId,
      'resourceName': resourceName,
      'city': city,
      'route': route,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
    };
  }

  GroupAssignmentModel copyWith({
    String? id,
    String? groupId,
    AssignmentType? assignmentType,
    String? resourceId,
    String? resourceName,
    String? city,
    String? route,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return GroupAssignmentModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      assignmentType: assignmentType ?? this.assignmentType,
      resourceId: resourceId ?? this.resourceId,
      resourceName: resourceName ?? this.resourceName,
      city: city ?? this.city,
      route: route ?? this.route,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }
}
