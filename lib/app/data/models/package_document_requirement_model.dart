class PackageDocumentRequirementModel {
  final String id;
  final String packageId;
  final String documentRequirementId;
  final bool isRequired;
  final int sortOrder;

  PackageDocumentRequirementModel({
    required this.id,
    required this.packageId,
    required this.documentRequirementId,
    required this.isRequired,
    required this.sortOrder,
  });

  factory PackageDocumentRequirementModel.fromJson(Map<String, dynamic> json) {
    return PackageDocumentRequirementModel(
      id: json['id'] ?? '',
      packageId: json['packageId'] ?? '',
      documentRequirementId: json['documentRequirementId'] ?? '',
      isRequired: json['isRequired'] ?? true,
      sortOrder: json['sortOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'packageId': packageId,
      'documentRequirementId': documentRequirementId,
      'isRequired': isRequired,
      'sortOrder': sortOrder,
    };
  }

  PackageDocumentRequirementModel copyWith({
    String? id,
    String? packageId,
    String? documentRequirementId,
    bool? isRequired,
    int? sortOrder,
  }) {
    return PackageDocumentRequirementModel(
      id: id ?? this.id,
      packageId: packageId ?? this.packageId,
      documentRequirementId:
          documentRequirementId ?? this.documentRequirementId,
      isRequired: isRequired ?? this.isRequired,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
