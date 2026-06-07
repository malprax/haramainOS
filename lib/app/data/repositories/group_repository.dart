import 'package:get/get.dart';

import '../../core/database/database_service.dart';

import '../models/group_model.dart';
import '../models/group_member_model.dart';
import '../models/group_assignment_model.dart';

class GroupRepository {
  final DatabaseService _database = Get.find();

  static const String groupsCollection = 'groups';
  static const String membersCollection = 'group_members';
  static const String assignmentsCollection = 'group_assignments';

  // GROUP

  Future<void> createGroup(GroupModel group) async {
    await _database.create(
      collection: groupsCollection,
      documentId: group.id!,
      data: group.toJson(),
    );
  }

  Future<List<GroupModel>> getGroups() async {
    final result = await _database.readAll(collection: groupsCollection);

    return result.map((item) => GroupModel.fromJson(item)).toList();
  }

  Future<void> updateGroup(GroupModel group) async {
    await _database.update(
      collection: groupsCollection,
      documentId: group.id!,
      data: group.toJson(),
    );
  }

  Future<void> deleteGroup(String groupId) async {
    await _database.delete(collection: groupsCollection, documentId: groupId);
  }

  // MEMBER

  Future<void> addMember(GroupMemberModel member) async {
    await _database.create(
      collection: membersCollection,
      documentId: member.id,
      data: member.toJson(),
    );
  }

  Future<List<GroupMemberModel>> getMembers() async {
    final result = await _database.readAll(collection: membersCollection);

    return result.map((item) => GroupMemberModel.fromJson(item)).toList();
  }

  // ASSIGNMENT

  Future<void> createAssignment(GroupAssignmentModel assignment) async {
    await _database.create(
      collection: assignmentsCollection,
      documentId: assignment.id,
      data: assignment.toJson(),
    );
  }

  Future<List<GroupAssignmentModel>> getAssignments() async {
    final result = await _database.readAll(collection: assignmentsCollection);

    return result.map((item) => GroupAssignmentModel.fromJson(item)).toList();
  }

  Future<void> updateAssignment(GroupAssignmentModel assignment) async {
    await _database.update(
      collection: assignmentsCollection,
      documentId: assignment.id,
      data: assignment.toJson(),
    );
  }
}
