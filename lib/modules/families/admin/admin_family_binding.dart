import 'package:get/get.dart';

import 'admin_family_controller.dart';

class AdminFamilyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminFamilyController>(
      () => AdminFamilyController(),
      fenix: true,
    );
  }
}
