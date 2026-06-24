import 'package:get/get.dart';

import 'jamaah_notification_controller.dart';

class JamaahNotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JamaahNotificationController>(
      () => JamaahNotificationController(),
    );
  }
}
