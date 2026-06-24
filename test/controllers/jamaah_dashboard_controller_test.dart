import 'package:flutter_test/flutter_test.dart';
import 'package:haramain_os/app/data/models/booking_model.dart';

void main() {
  group('Booking Status Test', () {
    test('Approved booking', () {
      final booking = BookingModel(
        id: '1',
        jamaahId: 'jamaah1',
        seatNumber: 1,
        status: BookingStatus.approved,
      );

      expect(booking.status, BookingStatus.approved);
    });

    test('Pending booking', () {
      final booking = BookingModel(
        id: '2',
        jamaahId: 'jamaah1',
        seatNumber: 2,
        status: BookingStatus.pending,
      );

      expect(booking.status, BookingStatus.pending);
    });

    test('Rejected booking', () {
      final booking = BookingModel(
        id: '3',
        jamaahId: 'jamaah1',
        seatNumber: 3,
        status: BookingStatus.rejected,
      );

      expect(booking.status, BookingStatus.rejected);
    });
  });
}
