// class GroupMemberModel {
//   final String id;
//   final String groupId;
//   final String jamaahId;

//   final DateTime createdAt;

//   final bool isLeader;

//   GroupMemberModel({
//     required this.id,
//     required this.groupId,
//     required this.jamaahId,
//     required this.createdAt,
//     required this.isLeader,
//   });
// }

class GroupMemberModel {
  final String id;
  final String groupId;
  final String jamaahId;

  final bool isLeader;

  final DateTime createdAt;

  GroupMemberModel({
    required this.id,
    required this.groupId,
    required this.jamaahId,
    required this.isLeader,
    required this.createdAt,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      id: json['id'] ?? '',
      groupId: json['groupId'] ?? '',
      jamaahId: json['jamaahId'] ?? '',
      isLeader: json['isLeader'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'jamaahId': jamaahId,
      'isLeader': isLeader,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  GroupMemberModel copyWith({
    String? id,
    String? groupId,
    String? jamaahId,
    bool? isLeader,
    DateTime? createdAt,
  }) {
    return GroupMemberModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      jamaahId: jamaahId ?? this.jamaahId,
      isLeader: isLeader ?? this.isLeader,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
