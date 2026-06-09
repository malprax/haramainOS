import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haramain_os/app/data/models/booking_model.dart';
import 'package:haramain_os/app/data/models/package_model.dart';
import 'package:haramain_os/app/data/repositories/booking_repository.dart';
import 'package:pocketbase/pocketbase.dart';

class BookingController extends GetxController {
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

        debugPrint('BOOKING REALTIME EVENT: ${event.action}');

        await loadData();
      });

      debugPrint('BOOKING REALTIME SUBSCRIBED');
    } catch (error) {
      debugPrint('BOOKING REALTIME ERROR: $error');
    }
  }

  Future<void> loadData() async {
    if (_isClosed) return;

    try {
      final data = await _bookingRepository.getBookings();

      if (_isClosed) return;

      bookings.assignAll(data);
      bookings.refresh();

      debugPrint('TOTAL BOOKINGS: ${bookings.length}');
    } catch (error) {
      debugPrint('LOAD BOOKING ERROR: $error');
    }
  }

  BookingModel? getBookingBySeat(int seatNumber) {
    final packageId = selectedPackage.value?.id?.toString().trim();

    return bookings.firstWhereOrNull((booking) {
      final bookingPackageId = booking.packageId?.toString().trim();
      final bookingSeat = booking.seatNumber;

      return bookingPackageId == packageId && bookingSeat == seatNumber;
    });
  }

  Future<void> bookSeatByJamaah(int seatNumber) async {
    debugPrint('BOOK SEAT CLICKED: $seatNumber');

    final package = selectedPackage.value;

    if (package == null || package.id == null) {
      Get.snackbar(
        'Paket belum dipilih',
        'Silakan pilih paket terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final existingBooking = getBookingBySeat(seatNumber);

      if (existingBooking != null &&
          existingBooking.status != BookingStatus.rejected) {
        Get.snackbar(
          'Seat tidak tersedia',
          'Seat ini sudah dipilih jamaah lain',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (existingBooking != null &&
          existingBooking.status == BookingStatus.rejected &&
          existingBooking.id != null) {
        await _bookingRepository.deleteBooking(existingBooking.id!);
      }

      final booking = BookingModel(
        packageId: package.id,
        jamaahId: 'jamaah-demo',
        seatNumber: seatNumber,
        status: BookingStatus.pending,
        bookingDate: DateTime.now(),
      );

      debugPrint('BOOKING PAYLOAD: ${booking.toJson()}');

      await _bookingRepository.createBooking(booking);
      await loadData();

      Get.snackbar(
        'Berhasil',
        'Seat berhasil dibooking',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      debugPrint('BOOK SEAT ERROR: $error');

      Get.snackbar(
        'Gagal booking seat',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> cancelBookingByJamaah(BookingModel booking) async {
    if (booking.id == null) return;

    try {
      await _bookingRepository.deleteBooking(booking.id!);
      await loadData();

      Get.snackbar(
        'Berhasil',
        'Booking seat berhasil dibatalkan',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      debugPrint('CANCEL BOOKING BY JAMAAH ERROR: $error');

      Get.snackbar(
        'Gagal membatalkan booking',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> approveBooking(BookingModel booking) async {
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
      debugPrint('APPROVE BOOKING ERROR: $error');

      Get.snackbar(
        'Gagal menyetujui booking',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> cancelBooking(BookingModel booking) async {
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
        'Booking berhasil dibatalkan',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      debugPrint('CANCEL BOOKING ERROR: $error');

      Get.snackbar(
        'Gagal membatalkan booking',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> resetBooking(BookingModel booking) async {
    if (booking.id == null) return;

    try {
      await _bookingRepository.deleteBooking(booking.id!);
      await loadData();

      Get.snackbar(
        'Berhasil',
        'Seat berhasil direset',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      debugPrint('RESET BOOKING ERROR: $error');

      Get.snackbar(
        'Gagal reset seat',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  int approvedCountBySelectedPackage() {
    final packageId = selectedPackage.value?.id ?? '';

    return bookings
        .where(
          (item) =>
              item.packageId == packageId &&
              item.status == BookingStatus.approved,
        )
        .length;
  }

  int pendingCountBySelectedPackage() {
    final packageId = selectedPackage.value?.id ?? '';

    return bookings
        .where(
          (item) =>
              item.packageId == packageId &&
              item.status == BookingStatus.pending,
        )
        .length;
  }

  int rejectedCountBySelectedPackage() {
    final packageId = selectedPackage.value?.id ?? '';

    return bookings
        .where(
          (item) =>
              item.packageId == packageId &&
              item.status == BookingStatus.rejected,
        )
        .length;
  }

  int availableCountBySelectedPackage() {
    final capacity = selectedPackage.value?.capacity ?? 0;

    return capacity -
        approvedCountBySelectedPackage() -
        pendingCountBySelectedPackage();
  }

  @override
  void onClose() {
    _isClosed = true;

    _pb.collection('bookings').unsubscribe('*');

    super.onClose();
  }
}
