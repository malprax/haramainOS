class GroupModel {
  String? id;
  String? groupName;
  String? description;
  DateTime? createdAt;

  GroupModel({this.id, this.groupName, this.description, this.createdAt});

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] as String?,
      groupName: json['groupName'] as String?,
      description: json['description'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupName': groupName,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
