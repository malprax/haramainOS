import 'package:flutter_test/flutter_test.dart';

import 'package:haramain_os/app/data/models/booking_notification_model.dart';

void main() {
  group('Notification Model Test', () {
    test('Notification unread by default', () {
      final notification = BookingNotificationModel(
        id: '1',
        jamaahId: 'jamaah1',
        title: 'Dokumen Disetujui',
        message: 'Paspor telah disetujui',
      );

      expect(notification.isRead, false);
    });

    test('Notification mark read', () {
      final notification = BookingNotificationModel(
        id: '2',
        jamaahId: 'jamaah1',
        title: 'Dokumen Ditolak',
        message: 'Foto tidak jelas',
        isRead: true,
      );

      expect(notification.isRead, true);
    });
  });
}
