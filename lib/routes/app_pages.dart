import 'package:get/get.dart';
import 'package:haramain_os/modules/bookings/admin_booking_view.dart';
import 'package:haramain_os/modules/bookings/jamaah_booking_view.dart';

import '../modules/admin_dashboard/admin_dashboard_binding.dart';
import '../modules/admin_dashboard/admin_dashboard_view.dart';

import '../modules/auth/auth_binding.dart';
import '../modules/auth/auth_view.dart';

import '../modules/jamaah_dashboard/jamaah_dashboard_binding.dart';
import '../modules/jamaah_dashboard/jamaah_dashboard_view.dart';

import '../modules/packages/package_binding.dart';
import '../modules/packages/admin_package_view.dart';
import '../modules/packages/jamaah_package_view.dart';
import '../modules/packages/package_form.dart';

import '../modules/bookings/booking_binding.dart';

import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.auth,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => AdminDashboardView(),
      binding: AdminDashboardBinding(),
    ),

    GetPage(
      name: AppRoutes.jamaahDashboard,
      page: () => JamaahDashboardView(),
      binding: JamaahDashboardBinding(),
    ),

    // ==========================
    // ADMIN PACKAGE
    // ==========================
    GetPage(
      name: AppRoutes.adminPackages,
      page: () => AdminPackageView(),
      binding: PackageBinding(),
    ),

    // ==========================
    // JAMAAH PACKAGE
    // ==========================
    GetPage(
      name: AppRoutes.jamaahPackages,
      page: () => JamaahPackageView(),
      binding: PackageBinding(),
    ),

    // ==========================
    // PACKAGE FORM
    // ==========================
    GetPage(
      name: AppRoutes.packageForm,
      page: () => PackageForm(),
      binding: PackageBinding(),
    ),

    // ==========================
    // SEAT BOOKING
    // ==========================
    GetPage(
      name: AppRoutes.adminBooking,
      page: () => AdminBookingView(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: AppRoutes.jamaahBooking,
      page: () => JamaahBookingView(),
      binding: BookingBinding(),
    ),
  ];
}
