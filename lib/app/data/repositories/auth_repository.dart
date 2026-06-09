import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';

import '../models/user_model.dart';

class AuthRepository {
  final PocketBase _pb = Get.find<PocketBase>();

  static const String collection = 'users';

  Future<void> createUser(UserModel user) async {
    await _pb
        .collection(collection)
        .create(
          body: {
            'email': user.email,
            'password': user.password,
            'passwordConfirm': user.password,
            'fullName': user.fullName,
            'role': user.role.name,
            'phoneNumber': user.phoneNumber,
            'emailVisibility': true,
            'verified': true,
          },
        );
  }

  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    final authData = await _pb
        .collection(collection)
        .authWithPassword(email, password);

    final record = authData.record;

    final data = Map<String, dynamic>.from(record.data);
    data['id'] = record.id;
    data['email'] = record.data['email'] ?? email;

    return UserModel.fromJson(data);
  }

  Future<List<UserModel>> getUsers() async {
    final records = await _pb.collection(collection).getFullList();

    return records.map((record) {
      final data = Map<String, dynamic>.from(record.data);
      data['id'] = record.id;
      return UserModel.fromJson(data);
    }).toList();
  }

  Future<void> logout() async {
    _pb.authStore.clear();
  }
}
