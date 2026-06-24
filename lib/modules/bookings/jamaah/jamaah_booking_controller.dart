import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:haramain_os/app/data/models/booking_model.dart';
import 'package:haramain_os/app/data/models/package_model.dart';
import 'package:haramain_os/app/data/repositories/booking_repository.dart';

import 'package:haramain_os/modules/auth/auth_controller.dart';

import 'package:pocketbase/pocketbase.dart';

class JamaahBookingController extends GetxController {
  final BookingRepository _bookingRepository = BookingRepository();
  final PocketBase _pb = Get.find<PocketBase>();

  final AuthController authController = Get.find<AuthController>();

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

  String get currentJamaahId {
    return authController.currentUser.value?.id.trim() ?? '';
  }

  Future<void> subscribeBookingRealtime() async {
    try {
      await _pb.collection('bookings').subscribe('*', (event) async {
        if (_isClosed) return;

        debugPrint('JAMAAH BOOKING REALTIME EVENT: ${event.action}');

        await loadData();
      });

      debugPrint('JAMAAH BOOKING REALTIME SUBSCRIBED');
    } catch (error) {
      debugPrint('JAMAAH BOOKING REALTIME ERROR: $error');
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

      debugPrint('TOTAL JAMAAH BOOKINGS: ${bookings.length}');
    } catch (error) {
      debugPrint('LOAD JAMAAH BOOKING ERROR: $error');

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

  bool isMyBooking(BookingModel booking) {
    final bookingJamaahId = booking.jamaahId?.trim() ?? '';

    if (currentJamaahId.isEmpty) return false;
    if (bookingJamaahId.isEmpty) return false;

    return bookingJamaahId == currentJamaahId;
  }

  bool isSeatAvailableForBooking(int seatNumber) {
    final booking = getBookingBySeat(seatNumber);

    if (booking == null) return true;

    return booking.status == BookingStatus.rejected;
  }

  List<BookingModel> get myApprovedBookings {
    if (currentJamaahId.isEmpty) return [];

    return bookings.where((item) {
      final bookingJamaahId = item.jamaahId?.trim() ?? '';

      return bookingJamaahId == currentJamaahId &&
          item.status == BookingStatus.approved;
    }).toList();
  }

  List<BookingModel> get myPendingBookings {
    if (currentJamaahId.isEmpty) return [];

    return bookings.where((item) {
      final bookingJamaahId = item.jamaahId?.trim() ?? '';

      return bookingJamaahId == currentJamaahId &&
          item.status == BookingStatus.pending;
    }).toList();
  }

  Future<void> bookSeat(int seatNumber) async {
    debugPrint('JAMAAH BOOK SEAT CLICKED: $seatNumber');

    final package = selectedPackage.value;

    if (package == null || package.id == null || package.id!.trim().isEmpty) {
      Get.snackbar(
        'Paket belum dipilih',
        'Silakan pilih paket terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (currentJamaahId.isEmpty) {
      Get.snackbar(
        'Akun tidak ditemukan',
        'Silakan login ulang terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      if (!isSeatAvailableForBooking(seatNumber)) {
        Get.snackbar(
          'Seat tidak tersedia',
          'Seat ini sudah dipilih jamaah lain',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final existingBooking = getBookingBySeat(seatNumber);

      if (existingBooking != null &&
          existingBooking.status == BookingStatus.rejected &&
          existingBooking.id != null &&
          existingBooking.id!.isNotEmpty) {
        await _bookingRepository.deleteBooking(existingBooking.id!);
      }

      final booking = BookingModel(
        packageId: package.id!.trim(),
        jamaahId: currentJamaahId,
        seatNumber: seatNumber,
        status: BookingStatus.pending,
        bookingDate: DateTime.now(),
      );

      debugPrint('JAMAAH BOOKING PAYLOAD: ${booking.toJson()}');

      await _bookingRepository.createBooking(booking);
      await loadData();

      Get.snackbar(
        'Berhasil',
        'Seat berhasil dibooking dan menunggu persetujuan admin',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      debugPrint('JAMAAH BOOK SEAT ERROR: $error');

      Get.snackbar(
        'Gagal booking seat',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> cancelMyBooking(BookingModel booking) async {
    if (booking.id == null || booking.id!.isEmpty) return;

    if (!isMyBooking(booking)) {
      Get.snackbar(
        'Tidak diizinkan',
        'Anda hanya dapat membatalkan booking milik Anda sendiri',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await _bookingRepository.deleteBooking(booking.id!);
      await loadData();

      Get.snackbar(
        'Berhasil',
        'Booking seat berhasil dibatalkan',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      debugPrint('CANCEL JAMAAH BOOKING ERROR: $error');

      Get.snackbar(
        'Gagal membatalkan booking',
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
