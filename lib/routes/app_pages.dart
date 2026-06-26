import 'package:get/get.dart';
import 'package:haramain_os/modules/bookings/admin_requests/admin_booking_request_binding.dart';
import 'package:haramain_os/modules/bookings/admin_requests/admin_booking_request_view.dart';
import 'package:haramain_os/modules/families/admin/admin_family_binding.dart';
import 'package:haramain_os/modules/families/admin/admin_family_view.dart';
import 'package:haramain_os/modules/groups/admin/admin_group_binding.dart';
import 'package:haramain_os/modules/groups/admin/admin_group_view.dart';
import 'package:haramain_os/modules/notifications/admin/admin_notification_binding.dart';
import 'package:haramain_os/modules/notifications/admin/admin_notification_view.dart';
import 'package:haramain_os/modules/notifications/jamaah/jamaah_notification_binding.dart';
import 'package:haramain_os/modules/notifications/jamaah/jamaah_notification_view.dart';

import '../routes/app_routes.dart';

// AUTH
import '../modules/auth/auth_binding.dart';
import '../modules/auth/auth_view.dart';

// DASHBOARD
import '../modules/dashboards/admin/admin_dashboard_binding.dart';
import '../modules/dashboards/admin/admin_dashboard_view.dart';

import '../modules/dashboards/jamaah/jamaah_dashboard_binding.dart';
import '../modules/dashboards/jamaah/jamaah_dashboard_view.dart';

// PACKAGE
import '../modules/packages/admin/admin_package_binding.dart';
import '../modules/packages/admin/admin_package_view.dart';
import '../modules/packages/admin/admin_package_form.dart';

import '../modules/packages/jamaah/jamaah_package_binding.dart';
import '../modules/packages/jamaah/jamaah_package_view.dart';

// BOOKING
import '../modules/bookings/admin/admin_booking_binding.dart';
import '../modules/bookings/admin/admin_booking_view.dart';

import '../modules/bookings/jamaah/jamaah_booking_binding.dart';
import '../modules/bookings/jamaah/jamaah_booking_view.dart';

// DOCUMENT
import '../modules/documents/admin/admin_document_binding.dart';
import '../modules/documents/admin/admin_document_view.dart';

import '../modules/documents/jamaah/jamaah_document_binding.dart';
import '../modules/documents/jamaah/jamaah_document_view.dart';

class AppPages {
  static final routes = <GetPage>[
    // ==========================================================
    // AUTH
    // ==========================================================
    GetPage(
      name: AppRoutes.auth,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),

    // ==========================================================
    // ADMIN DASHBOARD
    // ==========================================================
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboardView(),
      binding: AdminDashboardBinding(),
    ),

    // ==========================================================
    // JAMAAH DASHBOARD
    // ==========================================================
    GetPage(
      name: AppRoutes.jamaahDashboard,
      page: () => const JamaahDashboardView(),
      binding: JamaahDashboardBinding(),
    ),

    // ==========================================================
    // ADMIN PACKAGE
    // ==========================================================
    GetPage(
      name: AppRoutes.adminPackages,
      page: () => const AdminPackageView(),
      binding: AdminPackageBinding(),
    ),

    GetPage(
      name: AppRoutes.adminPackageForm,
      page: () => const AdminPackageForm(),
      binding: AdminPackageBinding(),
    ),

    // ==========================================================
    // JAMAAH PACKAGE
    // ==========================================================
    GetPage(
      name: AppRoutes.jamaahPackages,
      page: () => const JamaahPackageView(),
      binding: JamaahPackageBinding(),
    ),

    // ==========================================================
    // ADMIN BOOKING
    // ==========================================================
    GetPage(
      name: AppRoutes.adminBooking,
      page: () => const AdminBookingView(),
      binding: AdminBookingBinding(),
    ),

    // ==========================================================
    // JAMAAH BOOKING
    // ==========================================================
    GetPage(
      name: AppRoutes.jamaahBooking,
      page: () => const JamaahBookingView(),
      binding: JamaahBookingBinding(),
    ),

    // ==========================================================
    // ADMIN DOCUMENT
    // ==========================================================
    GetPage(
      name: AppRoutes.adminDocuments,
      page: () => const AdminDocumentView(),
      binding: AdminDocumentBinding(),
    ),

    // ==========================================================
    // JAMAAH DOCUMENT
    // ==========================================================
    GetPage(
      name: AppRoutes.jamaahDocuments,
      page: () => const JamaahDocumentView(),
      binding: JamaahDocumentBinding(),
    ),

    // ==========================================================
    // NOTIFICATIONS
    // ==========================================================
    GetPage(
      name: AppRoutes.adminNotifications,
      page: () => const AdminNotificationView(),
      binding: AdminNotificationBinding(),
    ),
    GetPage(
      name: AppRoutes.jamaahNotifications,
      page: () => const JamaahNotificationView(),
      binding: JamaahNotificationBinding(),
    ),
    // ==========================================================
    // ADMIN BOOKING REQUESTS
    // ==========================================================
    GetPage(
      name: AppRoutes.adminBookingRequests,
      page: () => const AdminBookingRequestView(),
      binding: AdminBookingRequestBinding(),
    ),

    // ==========================================================
    // ADMIN GROUPS
    // ==========================================================
    GetPage(
      name: AppRoutes.adminGroups,
      page: () => const AdminGroupView(),
      binding: AdminGroupBinding(),
    ),

    // ==========================================================
    // ADMIN FAMILIES
    // ==========================================================
    GetPage(
      name: AppRoutes.adminFamilies,
      page: () => const AdminFamilyView(),
      binding: AdminFamilyBinding(),
    ),
  ];
}
