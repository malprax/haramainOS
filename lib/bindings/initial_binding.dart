import 'package:get/get.dart';

import '../app/core/database/database_service.dart';
import '../app/core/database/local_database_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<DatabaseService>(LocalDatabaseService(), permanent: true);
  }
}
