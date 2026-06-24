import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Booking Logic Test', () {
    test('Pending booking count', () {
      final bookings = ['pending', 'pending', 'approved'];

      final pendingCount = bookings.where((e) => e == 'pending').length;

      expect(pendingCount, equals(2));
    });

    test('Approved booking count', () {
      final bookings = ['pending', 'approved', 'approved'];

      final approvedCount = bookings.where((e) => e == 'approved').length;

      expect(approvedCount, equals(2));
    });
  });
}
