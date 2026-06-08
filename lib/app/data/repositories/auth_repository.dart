import 'package:get/get.dart';

import '../../core/database/database_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final DatabaseService _database = Get.find();

  static const String collection = 'users';

  Future<void> createUser(UserModel user) async {
    await _database.create(
      collection: collection,
      documentId: user.id,
      data: user.toJson(),
    );
  }

  Future<List<UserModel>> getUsers() async {
    final result = await _database.readAll(collection: collection);

    return result.map((item) => UserModel.fromJson(item)).toList();
  }
}
