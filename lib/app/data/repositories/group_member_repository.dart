import 'package:get/get.dart';

import '../../core/database/database_service.dart';
import '../models/group_member_model.dart';

class GroupMemberRepository {
  final DatabaseService _database = Get.find();

  static const String collection = 'group_members';

  Future<List<GroupMemberModel>> getMembers() async {
    final result = await _database.readAll(collection: collection);

    return result.map((item) {
      return GroupMemberModel.fromJson(item);
    }).toList();
  }

  Future<void> createMember(GroupMemberModel member) async {
    await _database.create(
      collection: collection,
      documentId: member.id,
      data: member.toJson(),
    );
  }

  Future<void> updateMember(GroupMemberModel member) async {
    await _database.update(
      collection: collection,
      documentId: member.id,
      data: member.toJson(),
    );
  }

  Future<void> deleteMember(String memberId) async {
    await _database.delete(collection: collection, documentId: memberId);
  }
}
