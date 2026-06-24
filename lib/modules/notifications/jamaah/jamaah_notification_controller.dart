import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../auth/auth_controller.dart';
import '../../../app/data/models/booking_notification_model.dart';
import '../../../app/data/repositories/booking_notification_repository.dart';

class JamaahNotificationController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  final BookingNotificationRepository _repository =
      BookingNotificationRepository();

  final notifications = <BookingNotificationModel>[].obs;

  final isLoading = false.obs;

  String get jamaahId {
    final fromController = authController.currentUser.value?.id.trim() ?? '';

    if (fromController.isNotEmpty) {
      return fromController;
    }

    return Get.parameters['jamaahId']?.trim() ?? '';
  }

  int get unreadCount {
    return notifications.where((item) => item.isRead == false).length;
  }

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    final id = jamaahId;

    if (id.isEmpty) {
      debugPrint('JAMAAH NOTIFICATION ERROR: jamaahId kosong');
      return;
    }

    isLoading.value = true;

    try {
      final data = await _repository.getByJamaahId(id);

      notifications.assignAll(data);
      notifications.refresh();

      debugPrint('JAMAAH NOTIFICATION USER ID: $id');
      debugPrint('JAMAAH NOTIFICATION COUNT: ${notifications.length}');
      debugPrint('JAMAAH NOTIFICATION UNREAD: $unreadCount');
    } catch (error) {
      debugPrint('LOAD JAMAAH NOTIFICATION ERROR: $error');

      Get.snackbar(
        'Gagal memuat notifikasi',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadNotifications();
  }

  Future<void> openNotification(BookingNotificationModel notification) async {
    if (!notification.isRead) {
      await _repository.markAsRead(notification);
      await loadNotifications();
    }

    final route = notification.routeName?.trim() ?? '';

    debugPrint('================================');
    debugPrint('NOTIFICATION TITLE : ${notification.title}');
    debugPrint('NOTIFICATION ROUTE : $route');
    debugPrint('================================');

    if (route.isNotEmpty) {
      Get.toNamed(route);
      return;
    }

    Get.toNamed(AppRoutes.jamaahDashboard);
  }

  Future<void> markAllAsRead() async {
    final id = jamaahId;

    if (id.isEmpty) return;

    try {
      await _repository.markAllAsRead(id);

      await loadNotifications();

      Get.snackbar(
        'Berhasil',
        'Semua notifikasi ditandai sudah dibaca',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      debugPrint('MARK ALL JAMAah NOTIFICATION ERROR: $error');

      Get.snackbar(
        'Gagal',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void backToDashboard() {
    Get.offNamed(AppRoutes.jamaahDashboard);
  }
}
