import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:haramain_os/app/data/models/booking_model.dart';
import 'package:haramain_os/app/data/models/booking_notification_model.dart';
import 'package:haramain_os/app/data/models/package_model.dart';
import 'package:haramain_os/app/data/repositories/booking_notification_repository.dart';

import 'package:haramain_os/app/data/repositories/booking_repository.dart';
import 'package:haramain_os/app/data/repositories/package_repository.dart';

import '../../auth/auth_controller.dart';

class JamaahDashboardController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final BookingNotificationRepository _notificationRepository =
      BookingNotificationRepository();

  final notifications = <BookingNotificationModel>[].obs;

  final BookingRepository _bookingRepository = BookingRepository();
  final PackageRepository _packageRepository = PackageRepository();

  final isLoading = false.obs;

  final bookings = <BookingModel>[].obs;
  final packages = <PackageModel>[].obs;

  // ==========================================================
  // NOTIFICATION CENTER (sementara dummy)
  // ==========================================================

  final unreadNotificationCount = 0.obs;

  final recentActivities = <JamaahActivityItem>[].obs;

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void onInit() {
    super.onInit();
    loadData();
    loadActivities();
  }

  // ==========================================================
  // LOAD DATA
  // ==========================================================

  Future<void> loadData() async {
    isLoading.value = true;

    try {
      bookings.assignAll(await _bookingRepository.getBookings());

      packages.assignAll(await _packageRepository.getPackages());
      if (jamaahId.isNotEmpty) {
        notifications.assignAll(
          await _notificationRepository.getByJamaahId(jamaahId),
        );

        unreadNotificationCount.value = notifications
            .where((item) => item.isRead == false)
            .length;
      }

      debugPrint('LOGIN JAMAAH ID: $jamaahId');

      debugPrint('TOTAL BOOKING DASHBOARD: ${bookings.length}');

      for (final booking in bookings) {
        debugPrint(
          'BOOKING DASHBOARD => '
          'jamaahId=${booking.jamaahId}, '
          'packageId=${booking.packageId}, '
          'seat=${booking.seatNumber}, '
          'status=${booking.status}',
        );
      }

      debugPrint('MY APPROVED BOOKINGS: ${myApprovedBookings.length}');
    } catch (error) {
      debugPrint('LOAD JAMAAH DASHBOARD ERROR: $error');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadData();
    loadActivities();
  }

  // ==========================================================
  // USER INFO
  // ==========================================================

  String get userName {
    return authController.currentUser.value?.fullName ?? 'Jamaah';
  }

  String get jamaahId {
    return authController.currentUser.value?.id ?? '';
  }

  // ==========================================================
  // BOOKING DATA
  // ==========================================================

  List<BookingModel> get myApprovedBookings {
    return bookings.where((booking) {
      final sameJamaah = booking.jamaahId?.trim() == jamaahId.trim();

      final approved = booking.status == BookingStatus.approved;

      return sameJamaah && approved;
    }).toList();
  }

  List<BookingModel> get myPendingBookings {
    return bookings.where((booking) {
      final sameJamaah = booking.jamaahId?.trim() == jamaahId.trim();

      final pending = booking.status == BookingStatus.pending;

      return sameJamaah && pending;
    }).toList();
  }

  List<BookingModel> get myRejectedBookings {
    return bookings.where((booking) {
      final sameJamaah = booking.jamaahId?.trim() == jamaahId.trim();

      final rejected = booking.status == BookingStatus.rejected;

      return sameJamaah && rejected;
    }).toList();
  }

  // ==========================================================
  // PACKAGE
  // ==========================================================

  PackageModel? getPackageById(String? packageId) {
    if (packageId == null || packageId.isEmpty) {
      return null;
    }

    try {
      return packages.firstWhere((item) => item.id?.trim() == packageId.trim());
    } catch (_) {
      return null;
    }
  }

  // ==========================================================
  // DASHBOARD STATS
  // ==========================================================

  int get totalApprovedPackages {
    return myApprovedBookings.length;
  }

  int get totalPendingPackages {
    return myPendingBookings.length;
  }

  int get totalRejectedPackages {
    return myRejectedBookings.length;
  }

  bool get hasActivePackage {
    return myApprovedBookings.isNotEmpty;
  }

  String get activePackageSummary {
    if (myApprovedBookings.isEmpty) {
      return 'Belum memiliki paket aktif';
    }

    return '${myApprovedBookings.length} paket aktif';
  }

  int get completedTravelSteps {
    int completed = 0;

    if (myApprovedBookings.isNotEmpty) {
      completed++;
    }

    return completed;
  }

  int get totalTravelSteps {
    return 5;
  }

  double get progressValue {
    return completedTravelSteps / totalTravelSteps;
  }

  // ==========================================================
  // ACTIVITY CENTER
  // ==========================================================

  void loadActivities() {
    final activities = <JamaahActivityItem>[];

    for (final booking in myApprovedBookings) {
      activities.add(
        JamaahActivityItem(
          title: 'Booking Disetujui',
          subtitle: 'Seat ${booking.seatNumber ?? "-"} berhasil disetujui',
          icon: Icons.check_circle,
          isRead: false,
        ),
      );
    }

    for (final booking in myPendingBookings) {
      activities.add(
        JamaahActivityItem(
          title: 'Menunggu Verifikasi',
          subtitle: 'Seat ${booking.seatNumber ?? "-"} sedang diproses',
          icon: Icons.pending_actions,
          isRead: false,
        ),
      );
    }

    for (final booking in myRejectedBookings) {
      activities.add(
        JamaahActivityItem(
          title: 'Booking Ditolak',
          subtitle: 'Seat ${booking.seatNumber ?? "-"} perlu dipilih ulang',
          icon: Icons.cancel,
          isRead: false,
        ),
      );
    }

    recentActivities.assignAll(activities.take(5).toList());

    unreadNotificationCount.value = recentActivities.length;
  }

  void markActivityAsRead(JamaahActivityItem item) {
    item.isRead = true;

    recentActivities.refresh();

    unreadNotificationCount.value = recentActivities
        .where((e) => !e.isRead)
        .length;
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================

  void logout() {
    authController.currentUser.value = null;

    Get.offAllNamed('/auth');
  }
}

class JamaahActivityItem {
  final String title;
  final String subtitle;
  final IconData icon;

  bool isRead;

  JamaahActivityItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isRead,
  });
}
