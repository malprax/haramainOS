import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:haramain_os/app/data/models/booking_model.dart';
import 'package:haramain_os/app/data/models/package_model.dart';
import 'package:haramain_os/app/data/repositories/booking_notification_repository.dart';
import 'package:haramain_os/app/data/repositories/booking_repository.dart';
import 'package:haramain_os/app/data/repositories/package_repository.dart';

import '../../../routes/app_routes.dart';

class AdminBookingRequestController extends GetxController {
  final BookingRepository _bookingRepository = BookingRepository();
  final PackageRepository _packageRepository = PackageRepository();
  final BookingNotificationRepository _notificationRepository =
      BookingNotificationRepository();

  final isLoading = false.obs;

  final bookings = <BookingModel>[].obs;
  final packages = <PackageModel>[].obs;

  final selectedFilter = 'Pending'.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;

    try {
      final bookingData = await _bookingRepository.getBookings();
      final packageData = await _packageRepository.getPackages();

      bookings.assignAll(bookingData);
      packages.assignAll(packageData);
    } catch (error) {
      debugPrint('LOAD BOOKING REQUEST ERROR: $error');

      Get.snackbar(
        'Gagal memuat booking',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<BookingModel> get filteredBookings {
    return bookings.where((item) {
      final status = item.status ?? BookingStatus.available;

      if (selectedFilter.value == 'Semua') return true;
      if (selectedFilter.value == 'Pending')
        return status == BookingStatus.pending;
      if (selectedFilter.value == 'Approved')
        return status == BookingStatus.approved;
      if (selectedFilter.value == 'Rejected')
        return status == BookingStatus.rejected;

      return true;
    }).toList();
  }

  int get pendingCount {
    return bookings
        .where((item) => item.status == BookingStatus.pending)
        .length;
  }

  int get approvedCount {
    return bookings
        .where((item) => item.status == BookingStatus.approved)
        .length;
  }

  int get rejectedCount {
    return bookings
        .where((item) => item.status == BookingStatus.rejected)
        .length;
  }

  String getPackageName(String? packageId) {
    final id = packageId?.trim() ?? '';

    final package = packages.firstWhereOrNull((item) => item.id?.trim() == id);

    return package?.packageName ?? 'Paket tidak ditemukan';
  }

  PackageModel? getPackage(String? packageId) {
    final id = packageId?.trim() ?? '';

    return packages.firstWhereOrNull((item) => item.id?.trim() == id);
  }

  void changeFilter(String value) {
    selectedFilter.value = value;
  }

  Future<void> approveBooking(BookingModel booking) async {
    final bookingId = booking.id?.trim() ?? '';

    if (bookingId.isEmpty) return;

    try {
      final approvedBooking = BookingModel(
        id: booking.id,
        packageId: booking.packageId,
        jamaahId: booking.jamaahId,
        seatNumber: booking.seatNumber,
        status: BookingStatus.approved,
        bookingDate: booking.bookingDate,
      );

      await _bookingRepository.updateBooking(approvedBooking);

      await _notificationRepository.createBookingNotification(
        jamaahId: booking.jamaahId ?? '',
        packageId: booking.packageId ?? '',
        seatNumber: booking.seatNumber ?? 0,
        status: 'approved',
        title: 'Booking Seat Disetujui',
        message:
            'Alhamdulillah, booking seat #${booking.seatNumber} telah disetujui admin.',
      );

      await loadData();

      Get.snackbar(
        'Berhasil',
        'Booking disetujui dan jamaah sudah diberi notifikasi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Gagal approve booking',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> rejectBooking(BookingModel booking) async {
    final bookingId = booking.id?.trim() ?? '';

    if (bookingId.isEmpty) return;

    try {
      await _notificationRepository.createBookingNotification(
        jamaahId: booking.jamaahId ?? '',
        packageId: booking.packageId ?? '',
        seatNumber: booking.seatNumber ?? 0,
        status: 'rejected',
        title: 'Booking Seat Ditolak',
        message:
            'Mohon maaf, booking seat #${booking.seatNumber} ditolak oleh admin. Silakan pilih seat lain.',
      );

      await _bookingRepository.deleteBooking(bookingId);

      await loadData();

      Get.snackbar(
        'Booking Ditolak',
        'Jamaah sudah diberi notifikasi dan seat tersedia kembali',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Gagal reject booking',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void openSeatMap(BookingModel booking) {
    final package = getPackage(booking.packageId);

    if (package == null) {
      Get.snackbar(
        'Paket tidak ditemukan',
        'Data paket untuk booking ini tidak tersedia',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.toNamed(AppRoutes.adminBooking, arguments: package);
  }
}
