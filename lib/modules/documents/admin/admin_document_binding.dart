import 'package:get/get.dart';

import 'admin_document_controller.dart';

class AdminDocumentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminDocumentController>(() => AdminDocumentController());
  }
}
