import 'package:get/get.dart';

import '../../core/database/database_service.dart';
import '../models/travel_policy_rule_model.dart';

class TravelPolicyRuleRepository {
  final DatabaseService _database = Get.find();

  static const String collection = 'travel_policy_rules';

  Future<List<TravelPolicyRuleModel>> getRules() async {
    final result = await _database.readAll(collection: collection);

    return result.map((e) => TravelPolicyRuleModel.fromJson(e)).toList();
  }

  Future<void> createRule(TravelPolicyRuleModel rule) async {
    await _database.create(
      collection: collection,
      documentId: rule.id,
      data: rule.toJson(),
    );
  }

  Future<void> updateRule(TravelPolicyRuleModel rule) async {
    await _database.update(
      collection: collection,
      documentId: rule.id,
      data: rule.toJson(),
    );
  }

  Future<void> deleteRule(String id) async {
    await _database.delete(collection: collection, documentId: id);
  }

  Future<List<TravelPolicyRuleModel>> getRulesByPackage(
    String packageId,
  ) async {
    final rules = await getRules();

    return rules.where((e) {
      return e.packageId == packageId;
    }).toList();
  }

  Future<List<TravelPolicyRuleModel>> getActiveRules() async {
    final rules = await getRules();

    return rules.where((e) {
      return e.isActive;
    }).toList();
  }
}
