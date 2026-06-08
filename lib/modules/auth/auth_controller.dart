import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haramain_os/app/data/models/user_model.dart';
import 'package:haramain_os/app/data/repositories/auth_repository.dart';

import '../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _repository = AuthRepository();

  final isLoginMode = true.obs;
  final isLoading = false.obs;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final currentUser = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
  }

  void toggleMode() {
    isLoginMode.value = !isLoginMode.value;
  }

  Future<void> registerJamaah() async {
    if (isLoading.value) return;

    isLoading.value = true;

    try {
      final fullName = fullNameController.text.trim();
      final email = emailController.text.trim().toLowerCase();
      final password = passwordController.text.trim();

      debugPrint('REGISTER JAMAAH START');
      debugPrint('FULLNAME: $fullName');
      debugPrint('EMAIL: $email');

      if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
        Get.snackbar(
          'Gagal',
          'Nama lengkap, email, dan password wajib diisi',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (!GetUtils.isEmail(email)) {
        Get.snackbar(
          'Gagal',
          'Format email tidak valid',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (password.length < 6) {
        Get.snackbar(
          'Gagal',
          'Password minimal 6 karakter',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final users = await _repository.getUsers();

      final emailExists = users.any(
        (user) => user.email.toLowerCase() == email,
      );

      if (emailExists) {
        Get.snackbar(
          'Gagal',
          'Email sudah terdaftar',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final user = UserModel(
        id: 'jamaah-${DateTime.now().microsecondsSinceEpoch}',
        fullName: fullName,
        email: email,
        password: password,
        role: UserRole.jamaah,
      );

      debugPrint('USER TO CREATE: ${user.toJson()}');

      await _repository.createUser(user);

      debugPrint('JAMAAH CREATED');

      Get.snackbar(
        'Berhasil',
        'Akun jamaah berhasil dibuat. Silakan login.',
        snackPosition: SnackPosition.BOTTOM,
      );

      fullNameController.clear();
      emailController.clear();
      passwordController.clear();

      isLoginMode.value = true;
    } catch (error) {
      debugPrint('REGISTER JAMAAH ERROR: $error');

      Get.snackbar(
        'Gagal register',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login() async {
    if (isLoading.value) return;

    isLoading.value = true;

    try {
      final email = emailController.text.trim().toLowerCase();
      final password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        Get.snackbar(
          'Gagal',
          'Email dan password wajib diisi',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final users = await _repository.getUsers();

      debugPrint('TOTAL USERS: ${users.length}');

      for (final user in users) {
        debugPrint(
          'USER => ${user.email} | ${user.password} | ${user.role} | ${user.fullName}',
        );
      }

      final user = users.firstWhereOrNull(
        (item) =>
            item.email.toLowerCase() == email && item.password == password,
      );

      if (user == null) {
        Get.snackbar(
          'Gagal',
          'Email atau password salah',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      currentUser.value = user;

      emailController.clear();
      passwordController.clear();

      if (user.role == UserRole.adminTravel) {
        Get.offAllNamed(AppRoutes.adminDashboard);
      } else {
        Get.offAllNamed(AppRoutes.jamaahDashboard);
      }
    } catch (error) {
      debugPrint('LOGIN ERROR: $error');

      Get.snackbar(
        'Error',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    currentUser.value = null;

    fullNameController.clear();
    emailController.clear();
    passwordController.clear();

    Get.offAllNamed(AppRoutes.auth);
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
