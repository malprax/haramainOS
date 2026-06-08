import 'package:get/get.dart';
import 'package:haramain_os/app/data/models/booking_model.dart';
import 'package:haramain_os/app/data/models/package_model.dart';
import 'package:haramain_os/app/data/repositories/booking_repository.dart';

class BookingController extends GetxController {
  final BookingRepository _bookingRepository = BookingRepository();

  final isLoading = false.obs;

  final bookings = <BookingModel>[].obs;
  final selectedPackage = Rxn<PackageModel>();

  @override
  void onInit() {
    super.onInit();

    final argument = Get.arguments;

    if (argument is PackageModel) {
      selectedPackage.value = argument;
    }

    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;

    try {
      bookings.value = await _bookingRepository.getBookings();
    } finally {
      isLoading.value = false;
    }
  }

  BookingModel? getBookingBySeat(int seatNumber) {
    return bookings.firstWhereOrNull(
      (booking) =>
          booking.packageId == selectedPackage.value?.id &&
          booking.seatNumber == seatNumber,
    );
  }

  Future<void> bookSeatByJamaah(int seatNumber) async {
    final package = selectedPackage.value;

    if (package == null || package.id == null) {
      Get.snackbar(
        'Paket belum dipilih',
        'Silakan pilih paket terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

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

    final booking = BookingModel(
      id: 'booking-${package.id}-$seatNumber',
      packageId: package.id,
      jamaahId: 'jamaah-demo',
      seatNumber: seatNumber,
      status: BookingStatus.pending,
      bookingDate: DateTime.now(),
    );

    if (existingBooking != null &&
        existingBooking.status == BookingStatus.rejected &&
        existingBooking.id != null) {
      await _bookingRepository.deleteBooking(existingBooking.id!);
    }

    await _bookingRepository.createBooking(booking);
    await loadData();
  }

  Future<void> approveBooking(BookingModel booking) async {
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
  }

  Future<void> cancelBooking(BookingModel booking) async {
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
  }

  Future<void> resetBooking(BookingModel booking) async {
    if (booking.id == null) {
      return;
    }

    await _bookingRepository.deleteBooking(booking.id!);
    await loadData();
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
}
