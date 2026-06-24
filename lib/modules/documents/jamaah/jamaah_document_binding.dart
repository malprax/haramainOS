import 'package:get/get.dart';

import 'jamaah_document_controller.dart';

class JamaahDocumentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JamaahDocumentController>(() => JamaahDocumentController());
  }
}
