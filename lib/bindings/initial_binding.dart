import 'package:get/get.dart';
import 'package:haramain_os/app/core/database/database_service.dart';
import 'package:haramain_os/app/core/database/pocketbase_database_service.dart';
import 'package:pocketbase/pocketbase.dart';
// import 'package:haramain_os/app/core/database/supabase_database_service.dart';

// import '../modules/auth/auth_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // supabase
    // Get.put<DatabaseService>(SupabaseDatabaseService(), permanent: true);

    // Get.put<AuthController>(AuthController(), permanent: true);
    // --------------
    // pocketbase
    Get.put<PocketBase>(PocketBase('http://127.0.0.1:8090'), permanent: true);
    Get.put<DatabaseService>(PocketBaseDatabaseService(), permanent: true);
    // --------------
  }
}
