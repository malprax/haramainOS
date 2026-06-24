import 'package:get/get.dart';

import 'admin_booking_request_controller.dart';

class AdminBookingRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminBookingRequestController>(
      () => AdminBookingRequestController(),
      fenix: true,
    );
  }
}
