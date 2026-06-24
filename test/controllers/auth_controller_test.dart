import 'package:flutter_test/flutter_test.dart';
import 'package:haramain_os/app/data/models/user_model.dart';

void main() {
  group('UserModel Test', () {
    test('Create jamaah user', () {
      final user = UserModel(
        id: '1',
        fullName: 'Aulia Sabril',
        email: 'aulia@gmail.com',
        password: '123456',
        role: UserRole.jamaah,
      );

      expect(user.fullName, 'Aulia Sabril');
      expect(user.role, UserRole.jamaah);
    });

    test('Create admin travel user', () {
      final user = UserModel(
        id: '2',
        fullName: 'Admin Travel',
        email: 'admin@gmail.com',
        password: '123456',
        role: UserRole.adminTravel,
      );

      expect(user.role, UserRole.adminTravel);
    });
  });
}
