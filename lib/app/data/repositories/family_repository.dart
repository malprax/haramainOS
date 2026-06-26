import 'package:get/get.dart';

import '../../core/database/database_service.dart';
import '../models/family_group_model.dart';
import '../models/family_member_model.dart';

class FamilyRepository {
  final DatabaseService _database = Get.find();

  static const String familyGroupsCollection = 'family_groups';
  static const String familyMembersCollection = 'family_members';

  Future<List<FamilyGroupModel>> getFamilyGroups() async {
    final result = await _database.readAll(collection: familyGroupsCollection);

    return result.map((item) {
      return FamilyGroupModel.fromJson(item);
    }).toList();
  }

  Future<List<FamilyMemberModel>> getFamilyMembers() async {
    final result = await _database.readAll(collection: familyMembersCollection);

    return result.map((item) {
      return FamilyMemberModel.fromJson(item);
    }).toList();
  }

  Future<void> createFamilyGroup(FamilyGroupModel family) async {
    await _database.create(
      collection: familyGroupsCollection,
      documentId: family.id ?? '',
      data: family.toJson(),
    );
  }

  Future<void> createFamilyMember(FamilyMemberModel member) async {
    await _database.create(
      collection: familyMembersCollection,
      documentId: member.id ?? '',
      data: member.toJson(),
    );
  }

  Future<void> deleteFamilyGroup(String familyId) async {
    await _database.delete(
      collection: familyGroupsCollection,
      documentId: familyId,
    );
  }

  Future<void> deleteFamilyMember(String memberId) async {
    await _database.delete(
      collection: familyMembersCollection,
      documentId: memberId,
    );
  }
}
