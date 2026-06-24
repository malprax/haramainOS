import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:haramain_os/app/data/models/booking_model.dart';
import 'package:haramain_os/app/data/models/document_status.dart';
import 'package:haramain_os/app/data/models/jamaah_document_model.dart';
import 'package:haramain_os/app/data/models/package_model.dart';

import 'package:haramain_os/app/data/repositories/booking_repository.dart';
import 'package:haramain_os/app/data/repositories/document_repository.dart';
import 'package:haramain_os/app/data/repositories/package_repository.dart';

import '../../../routes/app_routes.dart';
import '../../auth/auth_controller.dart';

class AdminDashboardController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  final PackageRepository _packageRepository = PackageRepository();
  final BookingRepository _bookingRepository = BookingRepository();
  final DocumentRepository _documentRepository = DocumentRepository();

  final isLoading = false.obs;

  final packages = <PackageModel>[].obs;
  final bookings = <BookingModel>[].obs;
  final documents = <JamaahDocumentModel>[].obs;

  final unreadNotificationCount = 0.obs;
  final recentActivities = <AdminActivityItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  String get adminName {
    final fullName = authController.currentUser.value?.fullName.trim() ?? '';
    return fullName.isEmpty ? 'Admin Travel' : fullName;
  }

  int get totalJamaahCount {
    final ids = bookings
        .map((item) => item.jamaahId)
        .where((id) => id != null && id.trim().isNotEmpty)
        .map((id) => id!.trim())
        .toSet();

    return ids.length;
  }

  int get activePackageCount {
    return packages.where((item) => item.isActive == true).length;
  }

  int get pendingBookingCount {
    return bookings.where((item) {
      return item.status == BookingStatus.pending;
    }).length;
  }

  int get pendingDocumentCount {
    return documents
        .where((item) => item.status == DocumentStatus.pending)
        .length;
  }

  Future<void> refreshData() async {
    isLoading.value = true;

    try {
      await Future.wait([_loadPackages(), _loadBookings(), _loadDocuments()]);

      _buildRecentActivities();
      _recalculateUnread();
    } catch (error) {
      debugPrint('LOAD ADMIN DASHBOARD ERROR: $error');

      Get.snackbar(
        'Gagal memuat dashboard',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadPackages() async {
    final data = await _packageRepository.getPackages();
    packages.assignAll(data);
  }

  Future<void> _loadBookings() async {
    final data = await _bookingRepository.getBookings();
    bookings.assignAll(data);
  }

  Future<void> _loadDocuments() async {
    final data = await _documentRepository.getAllDocuments();
    documents.assignAll(data);
  }

  void _buildRecentActivities() {
    final items = <AdminActivityItem>[];

    if (pendingDocumentCount > 0) {
      items.add(
        AdminActivityItem(
          title: 'Dokumen jamaah menunggu verifikasi',
          subtitle: '$pendingDocumentCount dokumen perlu diperiksa',
          icon: Icons.folder_copy,
          routeName: AppRoutes.adminDocuments,
          isRead: false,
        ),
      );
    }

    if (pendingBookingCount > 0) {
      items.add(
        AdminActivityItem(
          title: 'Booking seat baru',
          subtitle: '$pendingBookingCount booking menunggu approval',
          icon: Icons.event_seat,
          routeName: AppRoutes.adminBookingRequests,
          isRead: false,
        ),
      );
    }

    if (activePackageCount > 0) {
      items.add(
        AdminActivityItem(
          title: 'Paket umrah aktif',
          subtitle: '$activePackageCount paket sedang ditawarkan',
          icon: Icons.card_travel,
          routeName: AppRoutes.adminPackages,
          isRead: true,
        ),
      );
    }

    items.addAll([
      AdminActivityItem(
        title: 'Data jamaah perlu diperbarui',
        subtitle: 'Lengkapi profil dan dokumen jamaah',
        icon: Icons.people,
        routeName: AppRoutes.adminDocuments,
        isRead: true,
      ),
      AdminActivityItem(
        title: 'Broadcast terakhir terkirim',
        subtitle: 'Informasi perjalanan dikirim ke jamaah',
        icon: Icons.campaign,
        routeName: AppRoutes.adminDashboard,
        isRead: true,
      ),
    ]);

    recentActivities.assignAll(items.take(5).toList());
  }

  void openActivity(AdminActivityItem item) {
    item.isRead = true;
    recentActivities.refresh();
    _recalculateUnread();

    Get.toNamed(item.routeName);
  }

  void openAllActivities() {
    for (final item in recentActivities) {
      item.isRead = true;
    }

    recentActivities.refresh();
    _recalculateUnread();

    if (AppRoutes.adminActivities.isNotEmpty) {
      Get.toNamed(AppRoutes.adminActivities);
    }
  }

  void _recalculateUnread() {
    unreadNotificationCount.value = recentActivities
        .where((item) => item.isRead == false)
        .length;
  }

  void logout() {
    authController.currentUser.value = null;
    Get.offAllNamed(AppRoutes.auth);
  }
}

class AdminActivityItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String routeName;
  bool isRead;

  AdminActivityItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.routeName,
    required this.isRead,
  });
}
