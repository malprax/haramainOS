import 'package:get/get.dart';

import 'admin_group_controller.dart';

class AdminGroupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminGroupController>(
      () => AdminGroupController(),
      fenix: true,
    );
  }
}
