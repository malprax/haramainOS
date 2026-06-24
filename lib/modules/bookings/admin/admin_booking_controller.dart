import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:haramain_os/app/data/models/booking_model.dart';
import 'package:haramain_os/app/data/models/package_model.dart';
import 'package:haramain_os/app/data/repositories/booking_repository.dart';

import 'package:pocketbase/pocketbase.dart';

class AdminBookingController extends GetxController {
  final BookingRepository _bookingRepository = BookingRepository();
  final PocketBase _pb = Get.find<PocketBase>();

  final isLoading = false.obs;

  final bookings = <BookingModel>[].obs;
  final selectedPackage = Rxn<PackageModel>();

  bool _isClosed = false;

  @override
  void onInit() {
    super.onInit();

    final argument = Get.arguments;

    if (argument is PackageModel) {
      selectedPackage.value = argument;
    }

    loadData();
    subscribeBookingRealtime();
  }

  Future<void> subscribeBookingRealtime() async {
    try {
      await _pb.collection('bookings').subscribe('*', (event) async {
        if (_isClosed) return;

        debugPrint('ADMIN BOOKING REALTIME EVENT: ${event.action}');

        await loadData();
      });

      debugPrint('ADMIN BOOKING REALTIME SUBSCRIBED');
    } catch (error) {
      debugPrint('ADMIN BOOKING REALTIME ERROR: $error');
    }
  }

  Future<void> loadData() async {
    if (_isClosed) return;

    isLoading.value = true;

    try {
      final data = await _bookingRepository.getBookings();

      if (_isClosed) return;

      bookings.assignAll(data);
      bookings.refresh();

      debugPrint('TOTAL ADMIN BOOKINGS: ${bookings.length}');
    } catch (error) {
      debugPrint('LOAD ADMIN BOOKING ERROR: $error');

      Get.snackbar(
        'Gagal memuat booking',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (!_isClosed) {
        isLoading.value = false;
      }
    }
  }

  BookingModel? getBookingBySeat(int seatNumber) {
    final packageId = selectedPackage.value?.id?.trim() ?? '';

    if (packageId.isEmpty) return null;

    return bookings.firstWhereOrNull((booking) {
      final bookingPackageId = booking.packageId?.trim() ?? '';

      return bookingPackageId == packageId && booking.seatNumber == seatNumber;
    });
  }

  Future<void> approveBooking(BookingModel booking) async {
    if (booking.id == null || booking.id!.isEmpty) return;

    try {
      await _bookingRepository.updateBooking(
        BookingModel(
          id: booking.id,
          packageId: booking.packageId,
          jamaahId: booking.jamaahId,
          seatNumber: booking.seatNumber,
          status: BookingStatus.approved,
          bookingDate: booking.bookingDate,
        ),
      );

      await loadData();

      Get.snackbar(
        'Berhasil',
        'Booking berhasil disetujui',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      debugPrint('APPROVE ADMIN BOOKING ERROR: $error');

      Get.snackbar(
        'Gagal menyetujui booking',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> rejectBooking(BookingModel booking) async {
    if (booking.id == null || booking.id!.isEmpty) return;

    try {
      await _bookingRepository.updateBooking(
        BookingModel(
          id: booking.id,
          packageId: booking.packageId,
          jamaahId: booking.jamaahId,
          seatNumber: booking.seatNumber,
          status: BookingStatus.rejected,
          bookingDate: booking.bookingDate,
        ),
      );

      await loadData();

      Get.snackbar(
        'Berhasil',
        'Booking berhasil ditolak',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      debugPrint('REJECT ADMIN BOOKING ERROR: $error');

      Get.snackbar(
        'Gagal menolak booking',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> resetBooking(BookingModel booking) async {
    if (booking.id == null || booking.id!.isEmpty) return;

    try {
      await _bookingRepository.deleteBooking(booking.id!);
      await loadData();

      Get.snackbar(
        'Berhasil',
        'Seat berhasil direset',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      debugPrint('RESET ADMIN BOOKING ERROR: $error');

      Get.snackbar(
        'Gagal reset seat',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  int approvedCountBySelectedPackage() {
    final packageId = selectedPackage.value?.id?.trim() ?? '';

    if (packageId.isEmpty) return 0;

    return bookings.where((item) {
      return item.packageId?.trim() == packageId &&
          item.status == BookingStatus.approved;
    }).length;
  }

  int pendingCountBySelectedPackage() {
    final packageId = selectedPackage.value?.id?.trim() ?? '';

    if (packageId.isEmpty) return 0;

    return bookings.where((item) {
      return item.packageId?.trim() == packageId &&
          item.status == BookingStatus.pending;
    }).length;
  }

  int rejectedCountBySelectedPackage() {
    final packageId = selectedPackage.value?.id?.trim() ?? '';

    if (packageId.isEmpty) return 0;

    return bookings.where((item) {
      return item.packageId?.trim() == packageId &&
          item.status == BookingStatus.rejected;
    }).length;
  }

  int availableCountBySelectedPackage() {
    final capacity = selectedPackage.value?.capacity ?? 0;

    final available =
        capacity -
        approvedCountBySelectedPackage() -
        pendingCountBySelectedPackage();

    if (available < 0) return 0;

    return available;
  }

  @override
  void onClose() {
    _isClosed = true;
    _pb.collection('bookings').unsubscribe('*');
    super.onClose();
  }
}
