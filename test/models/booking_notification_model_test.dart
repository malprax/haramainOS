import 'package:flutter_test/flutter_test.dart';
import 'package:haramain_os/app/data/models/booking_notification_model.dart';

void main() {
  group('BookingNotificationModel Test', () {
    test('fromJson should parse notification', () {
      final notification = BookingNotificationModel.fromJson({
        'id': 'notif_001',
        'jamaahId': 'jamaah_001',
        'packageId': 'package_001',
        'seatNumber': 5,
        'status': 'rejected',
        'title': 'Foto Ditolak',
        'message': 'Foto tidak jelas',
        'routeName': '/jamaah-documents',
        'isRead': false,
        'createdAt': '2026-06-24 08:00:00.000Z',
      });

      expect(notification.id, 'notif_001');
      expect(notification.jamaahId, 'jamaah_001');
      expect(notification.status, 'rejected');
      expect(notification.routeName, '/jamaah-documents');
      expect(notification.isRead, false);
      expect(notification.createdAt, isNotNull);
    });

    test('toJson should include routeName and isRead', () {
      final notification = BookingNotificationModel(
        id: 'notif_002',
        jamaahId: 'jamaah_002',
        packageId: 'package_002',
        seatNumber: 9,
        status: 'approved',
        title: 'Paspor Disetujui',
        message: 'Dokumen telah diverifikasi',
        routeName: '/jamaah-documents',
        isRead: true,
        createdAt: DateTime.utc(2026, 6, 24, 8),
      );

      final json = notification.toJson();

      expect(json['jamaahId'], 'jamaah_002');
      expect(json['status'], 'approved');
      expect(json['routeName'], '/jamaah-documents');
      expect(json['isRead'], true);
      expect(json['createdAt'], isNotNull);
    });
  });
}
