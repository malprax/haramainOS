import 'package:flutter_test/flutter_test.dart';
import 'package:haramain_os/app/data/models/user_model.dart';

void main() {
  test('UserModel fromJson parses jamaah role', () {
    final user = UserModel.fromJson({
      'id': 'u1',
      'fullName': 'Musa',
      'email': 'musa@gmail.com',
      'password': '123456',
      'role': 'jamaah',
    });

    expect(user.id, 'u1');
    expect(user.fullName, 'Musa');
    expect(user.role, UserRole.jamaah);
  });
}
