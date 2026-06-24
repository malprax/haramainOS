import 'package:get/get.dart';

import '../admin/admin_package_controller.dart';

class AdminPackageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminPackageController>(
      () => AdminPackageController(),
      fenix: true,
    );
  }
}
