import 'package:get/get.dart';

import '../modules/groups/group_binding.dart';
import '../modules/groups/group_view.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.group,
      page: () => const GroupView(),
      binding: GroupBinding(),
    ),
  ];
}
