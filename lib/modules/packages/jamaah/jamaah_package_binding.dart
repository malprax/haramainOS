import 'package:get/get.dart';

import 'jamaah_package_controller.dart';

class JamaahPackageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JamaahPackageController>(
      () => JamaahPackageController(),
      fenix: true,
    );
  }
}
