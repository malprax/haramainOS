import 'package:get/get.dart';
import 'package:haramain_os/modules/dashboards/jamaah/jamaah_dashboard_controller.dart';

class JamaahDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JamaahDashboardController>(() => JamaahDashboardController());
  }
}
