class DocumentRequirementModel {
  final String id;
  final String name;
  final String description;
  final bool isActive;
  final int sortOrder;

  DocumentRequirementModel({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.sortOrder,
  });

  factory DocumentRequirementModel.fromJson(Map<String, dynamic> json) {
    return DocumentRequirementModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      isActive: json['isActive'] ?? true,
      sortOrder: json['sortOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isActive': isActive,
      'sortOrder': sortOrder,
    };
  }
}
