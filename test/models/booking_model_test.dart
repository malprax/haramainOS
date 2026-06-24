import 'package:flutter_test/flutter_test.dart';
import 'package:haramain_os/app/data/models/booking_model.dart';

void main() {
  group('BookingModel Test', () {
    test('fromJson should parse approved booking', () {
      final booking = BookingModel.fromJson({
        'id': 'booking_001',
        'jamaahId': 'jamaah_001',
        'packageId': 'package_001',
        'seatNumber': 7,
        'status': 'approved',
      });

      expect(booking.id, 'booking_001');
      expect(booking.jamaahId, 'jamaah_001');
      expect(booking.packageId, 'package_001');
      expect(booking.seatNumber, 7);
      expect(booking.status, BookingStatus.approved);
    });

    test('toJson should convert booking correctly', () {
      final booking = BookingModel(
        id: 'booking_002',
        jamaahId: 'jamaah_002',
        packageId: 'package_002',
        seatNumber: 12,
        status: BookingStatus.pending,
      );

      final json = booking.toJson();

      expect(json['jamaahId'], 'jamaah_002');
      expect(json['packageId'], 'package_002');
      expect(json['seatNumber'], 12);
      expect(json['status'], 'pending');
    });

    test('unknown status should fallback safely', () {
      final booking = BookingModel.fromJson({
        'id': 'booking_003',
        'status': 'unknown',
      });

      expect(booking.status, isNotNull);
    });
  });
}
