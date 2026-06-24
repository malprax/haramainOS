import 'package:get/get.dart';

import 'admin_booking_controller.dart';

class AdminBookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminBookingController>(() => AdminBookingController());
  }
}
