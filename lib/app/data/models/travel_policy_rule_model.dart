enum TravelRuleCategory {
  document,
  room,
  bus,
  payment,
  visa,
  flight,
  hotel,
  family,
  custom,
}

enum TravelRuleValueType { boolean, number, text }

class TravelPolicyRuleModel {
  final String id;

  final String ruleCode;
  final String ruleName;

  final TravelRuleCategory category;
  final TravelRuleValueType valueType;

  final String ruleValue;

  final String packageId;

  final String countryScope;

  final bool isActive;

  final String notes;

  final DateTime? effectiveFrom;
  final DateTime? effectiveUntil;

  final DateTime? created;
  final DateTime? updated;

  const TravelPolicyRuleModel({
    required this.id,
    required this.ruleCode,
    required this.ruleName,
    required this.category,
    required this.valueType,
    required this.ruleValue,
    required this.packageId,
    required this.countryScope,
    required this.isActive,
    required this.notes,
    this.effectiveFrom,
    this.effectiveUntil,
    this.created,
    this.updated,
  });

  factory TravelPolicyRuleModel.fromJson(Map<String, dynamic> json) {
    return TravelPolicyRuleModel(
      id: json['id'] ?? '',

      ruleCode: json['ruleCode'] ?? '',

      ruleName: json['ruleName'] ?? '',

      category: TravelRuleCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TravelRuleCategory.custom,
      ),

      valueType: TravelRuleValueType.values.firstWhere(
        (e) => e.name == json['valueType'],
        orElse: () => TravelRuleValueType.text,
      ),

      ruleValue: json['ruleValue'] ?? '',

      packageId: json['packageId'] ?? '',

      countryScope: json['countryScope'] ?? '',

      isActive: json['isActive'] ?? true,

      notes: json['notes'] ?? '',

      effectiveFrom: json['effectiveFrom'] == null
          ? null
          : DateTime.parse(json['effectiveFrom']),

      effectiveUntil: json['effectiveUntil'] == null
          ? null
          : DateTime.parse(json['effectiveUntil']),

      created: json['created'] == null ? null : DateTime.parse(json['created']),

      updated: json['updated'] == null ? null : DateTime.parse(json['updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,

      'ruleCode': ruleCode,

      'ruleName': ruleName,

      'category': category.name,

      'valueType': valueType.name,

      'ruleValue': ruleValue,

      'packageId': packageId,

      'countryScope': countryScope,

      'isActive': isActive,

      'notes': notes,

      'effectiveFrom': effectiveFrom?.toIso8601String(),

      'effectiveUntil': effectiveUntil?.toIso8601String(),
    };
  }
}
