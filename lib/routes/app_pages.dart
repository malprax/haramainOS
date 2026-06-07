import 'package:get/get.dart';
import 'package:haramain_os/modules/bookings/booking_binding.dart';
import 'package:haramain_os/modules/bookings/booking_view.dart';

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

    GetPage(
      name: AppRoutes.booking,

      page: () => const BookingView(),

      binding: BookingBinding(),
    ),
  ];
}
