class FamilyGroupModel {
  final String? id;
  final String familyName;
  final String? packageId;
  final String? notes;
  final int priorityLevel;
  final bool isActive;
  final DateTime? createdAt;

  FamilyGroupModel({
    this.id,
    required this.familyName,
    this.packageId,
    this.notes,
    this.priorityLevel = 3,
    this.isActive = true,
    this.createdAt,
  });

  factory FamilyGroupModel.fromJson(Map<String, dynamic> json) {
    return FamilyGroupModel(
      id: json['id']?.toString(),
      familyName: json['familyName']?.toString() ?? '',
      packageId: json['packageId']?.toString(),
      notes: json['notes']?.toString(),
      priorityLevel: int.tryParse(json['priorityLevel']?.toString() ?? '') ?? 3,
      isActive: json['isActive'] == true,
      createdAt: DateTime.tryParse(
        json['createdAt']?.toString() ?? json['created']?.toString() ?? '',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'familyName': familyName,
      'packageId': packageId,
      'notes': notes,
      'priorityLevel': priorityLevel,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
