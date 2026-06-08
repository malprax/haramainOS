import 'package:get/get.dart';
import 'package:haramain_os/app/core/database/database_service.dart';
import 'package:haramain_os/app/core/database/supabase_database_service.dart';

import '../modules/auth/auth_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<DatabaseService>(SupabaseDatabaseService(), permanent: true);

    Get.put<AuthController>(AuthController(), permanent: true);
  }
}
