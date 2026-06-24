import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../dashboards/admin/admin_dashboard_controller.dart';

class AdminNotificationController extends GetxController {
  final AdminDashboardController dashboardController =
      Get.find<AdminDashboardController>();

  List<AdminActivityItem> get notifications {
    return dashboardController.recentActivities;
  }

  int get unreadCount {
    return dashboardController.unreadNotificationCount.value;
  }

  void openNotification(AdminActivityItem item) {
    dashboardController.openActivity(item);
  }

  void markAllAsRead() {
    for (final item in dashboardController.recentActivities) {
      item.isRead = true;
    }

    dashboardController.recentActivities.refresh();
    dashboardController.unreadNotificationCount.value = 0;
  }

  void backToDashboard() {
    Get.offNamed(AppRoutes.adminDashboard);
  }
}
