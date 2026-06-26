enum RelationshipType {
  headFamily,
  spouse,
  child,
  parent,
  sibling,
  grandparent,
  grandchild,
  uncle,
  aunt,
  cousin,
  relative,
  friend,
  companion,
}

class FamilyMemberModel {
  final String? id;
  final String familyId;
  final String jamaahId;
  final RelationshipType relationshipType;
  final bool isGuardian;
  final bool needsCompanion;
  final DateTime? createdAt;

  FamilyMemberModel({
    this.id,
    required this.familyId,
    required this.jamaahId,
    required this.relationshipType,
    this.isGuardian = false,
    this.needsCompanion = false,
    this.createdAt,
  });

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) {
    return FamilyMemberModel(
      id: json['id']?.toString(),
      familyId: json['familyId']?.toString() ?? '',
      jamaahId: json['jamaahId']?.toString() ?? '',
      relationshipType: _parseRelationship(json['relationshipType']),
      isGuardian: json['isGuardian'] == true,
      needsCompanion: json['needsCompanion'] == true,
      createdAt: DateTime.tryParse(
        json['createdAt']?.toString() ?? json['created']?.toString() ?? '',
      ),
    );
  }

  static RelationshipType _parseRelationship(dynamic value) {
    final text = value?.toString().trim() ?? '';

    return RelationshipType.values.firstWhere(
      (item) => item.name == text,
      orElse: () => RelationshipType.relative,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'familyId': familyId,
      'jamaahId': jamaahId,
      'relationshipType': relationshipType.name,
      'isGuardian': isGuardian,
      'needsCompanion': needsCompanion,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
