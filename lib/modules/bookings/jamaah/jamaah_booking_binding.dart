import 'package:get/get.dart';
import 'package:haramain_os/modules/bookings/jamaah/jamaah_booking_controller.dart';

class JamaahBookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JamaahBookingController>(() => JamaahBookingController());
  }
}
