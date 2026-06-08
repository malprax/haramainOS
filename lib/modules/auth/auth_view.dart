import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haramain_os/modules/auth/auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(
          () => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'HaramainOS',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      controller.isLoginMode.value
                          ? 'Login Akun'
                          : 'Register Jamaah',
                    ),
                    const SizedBox(height: 24),

                    if (!controller.isLoginMode.value)
                      TextField(
                        controller: controller.fullNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Lengkap',
                          border: OutlineInputBorder(),
                        ),
                      ),

                    if (!controller.isLoginMode.value)
                      const SizedBox(height: 12),

                    TextField(
                      controller: controller.emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: controller.passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                if (controller.isLoginMode.value) {
                                  controller.login();
                                } else {
                                  controller.registerJamaah();
                                }
                              },
                        child: Text(
                          controller.isLoginMode.value ? 'Login' : 'Register',
                        ),
                      ),
                    ),

                    TextButton(
                      onPressed: controller.toggleMode,
                      child: Text(
                        controller.isLoginMode.value
                            ? 'Belum punya akun? Daftar'
                            : 'Sudah punya akun? Login',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
