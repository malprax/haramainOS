import 'package:get/get.dart';

import '../../data/models/booking_model.dart';
import '../../data/models/package_model.dart';
import '../../data/repositories/booking_repository.dart';

class BookingController extends GetxController {
  final BookingRepository _repository = BookingRepository();

  final isLoading = false.obs;

  final selectedPackage = Rxn<PackageModel>();
  final bookings = <BookingModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    createSamplePackage();
    loadBookings();
  }

  void createSamplePackage() {
    final now = DateTime.now();

    selectedPackage.value = PackageModel(
      id: 'package-umrah-september-2026',
      packageName: 'Umrah Reguler September 2026',
      durationDays: 9,
      capacity: 45,
      bookedSeats: 0,
      price: 28500000,
      departureDate: DateTime(2026, 9, 12),
      returnDate: DateTime(2026, 9, 21),
      makkahHotel: 'Anjum Hotel Makkah',
      madinahHotel: 'Pullman Zamzam Madinah',
      guideId: 'guide-ustadz-ahmad',
      isActive: true,
    );
  }

  Future<void> loadBookings() async {
    isLoading.value = true;

    try {
      bookings.value = await _repository.getBookings();
    } finally {
      isLoading.value = false;
    }
  }

  BookingModel? getBookingBySeat(int seatNumber) {
    return bookings.firstWhereOrNull(
      (booking) =>
          booking.packageId == selectedPackage.value?.id &&
          booking.seatNumber == seatNumber &&
          booking.status != BookingStatus.rejected,
    );
  }

  Future<void> bookSeat(int seatNumber) async {
    final package = selectedPackage.value;
    if (package == null) return;

    final existingBooking = getBookingBySeat(seatNumber);
    if (existingBooking != null) return;

    final now = DateTime.now();

    final booking = BookingModel(
      id: 'booking-${package.id}-$seatNumber',
      packageId: package.id,
      jamaahId: 'jamaah-demo',
      seatNumber: seatNumber,
      status: BookingStatus.pending,
      bookingDate: now,
    );

    await _repository.createBooking(booking);
    await loadBookings();
  }

  Future<void> approveBooking(BookingModel booking) async {
    final updatedBooking = BookingModel(
      id: booking.id,
      packageId: booking.packageId,
      jamaahId: booking.jamaahId,
      seatNumber: booking.seatNumber,
      status: BookingStatus.approved,
      bookingDate: booking.bookingDate,
    );

    await _repository.updateBooking(updatedBooking);
    await loadBookings();
  }

  Future<void> rejectBooking(BookingModel booking) async {
    final updatedBooking = BookingModel(
      id: booking.id,
      packageId: booking.packageId,
      jamaahId: booking.jamaahId,
      seatNumber: booking.seatNumber,
      status: BookingStatus.rejected,
      bookingDate: booking.bookingDate,
    );

    await _repository.updateBooking(updatedBooking);
    await loadBookings();
  }

  int get approvedCount {
    return bookings
        .where((item) => item.status == BookingStatus.approved)
        .length;
  }

  int get pendingCount {
    return bookings
        .where((item) => item.status == BookingStatus.pending)
        .length;
  }

  int get rejectedCount {
    return bookings
        .where((item) => item.status == BookingStatus.rejected)
        .length;
  }

  int get availableCount {
    final capacity = selectedPackage.value?.capacity ?? 0;
    return capacity - approvedCount - pendingCount;
  }
}
