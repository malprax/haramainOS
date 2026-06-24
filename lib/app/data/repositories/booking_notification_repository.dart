import 'package:get/get.dart';

import '../../core/database/database_service.dart';
import '../models/booking_notification_model.dart';

class BookingNotificationRepository {
  final DatabaseService _database = Get.find();

  static const String collection = 'booking_notifications';

  Future<void> createBookingNotification({
    required String jamaahId,
    required String packageId,
    required int seatNumber,
    required String status,
    required String title,
    required String message,
    String? routeName,
  }) async {
    final cleanRouteName = routeName?.trim() ?? '';

    final notification = BookingNotificationModel(
      id: 'notification_${DateTime.now().millisecondsSinceEpoch}',
      jamaahId: jamaahId.trim(),
      packageId: packageId.trim(),
      seatNumber: seatNumber,
      status: status.trim(),
      title: title.trim(),
      message: message.trim(),
      routeName: cleanRouteName,
      isRead: false,
      createdAt: DateTime.now(),
    );

    await _database.create(
      collection: collection,
      documentId: notification.id ?? '',
      data: notification.toJson(),
    );
  }

  Future<List<BookingNotificationModel>> getByJamaahId(String jamaahId) async {
    final id = jamaahId.trim();

    if (id.isEmpty) return [];

    final result = await _database.readAll(collection: collection);

    final notifications = result
        .map((item) => BookingNotificationModel.fromJson(item))
        .where((item) => item.jamaahId?.trim() == id)
        .toList();

    notifications.sort((a, b) {
      final dateA = a.createdAt ?? DateTime(2000);
      final dateB = b.createdAt ?? DateTime(2000);

      return dateB.compareTo(dateA);
    });

    return notifications;
  }

  Future<void> markAsRead(BookingNotificationModel notification) async {
    final notificationId = notification.id?.trim() ?? '';

    if (notificationId.isEmpty) return;

    final updated = BookingNotificationModel(
      id: notification.id,
      jamaahId: notification.jamaahId,
      packageId: notification.packageId,
      seatNumber: notification.seatNumber,
      status: notification.status,
      title: notification.title,
      message: notification.message,
      routeName: notification.routeName,
      isRead: true,
      createdAt: notification.createdAt,
    );

    await _database.update(
      collection: collection,
      documentId: notificationId,
      data: updated.toJson(),
    );
  }

  Future<void> markAllAsRead(String jamaahId) async {
    final items = await getByJamaahId(jamaahId);

    for (final item in items) {
      if (!item.isRead) {
        await markAsRead(item);
      }
    }
  }
}
