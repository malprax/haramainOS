import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/data/models/booking_notification_model.dart';
import 'jamaah_notification_controller.dart';

class JamaahNotificationView extends GetView<JamaahNotificationController> {
  const JamaahNotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi Jamaah'),
        centerTitle: true,
        actions: [
          Obx(() {
            if (controller.notifications.isEmpty) {
              return const SizedBox();
            }

            return TextButton(
              onPressed: controller.markAllAsRead,
              child: const Text('Baca semua'),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final notifications = controller.notifications;

        if (notifications.isEmpty) {
          return const _EmptyNotificationView();
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = notifications[index];

              return _NotificationCard(
                notification: item,
                onTap: () => controller.openNotification(item),
              );
            },
          ),
        );
      }),
    );
  }
}

class _EmptyNotificationView extends StatelessWidget {
  const _EmptyNotificationView();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: Get.find<JamaahNotificationController>().refreshData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 160),
          Icon(Icons.notifications_none, size: 54, color: Colors.grey),
          SizedBox(height: 14),
          Center(
            child: Text(
              'Belum ada notifikasi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          SizedBox(height: 6),
          Center(
            child: Text(
              'Informasi booking dan dokumen akan tampil di sini.',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final BookingNotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;
    final statusColor = _colorByStatus(notification.status);

    return Card(
      color: isRead ? Colors.white : Colors.green.shade50,
      elevation: isRead ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isRead ? Colors.black12 : Colors.green.withValues(alpha: 0.22),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: isRead
                    ? Colors.grey.shade200
                    : statusColor.withValues(alpha: 0.15),
                child: Icon(
                  _iconByStatus(notification.status),
                  color: isRead ? Colors.grey.shade700 : statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isRead)
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Baru',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ),
                    Text(
                      notification.title ?? '-',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      notification.message ?? '-',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _NotificationMeta(notification: notification),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconByStatus(String? status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
        return Icons.hourglass_top;
      default:
        return Icons.notifications;
    }
  }

  Color _colorByStatus(String? status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }
}

class _NotificationMeta extends StatelessWidget {
  final BookingNotificationModel notification;

  const _NotificationMeta({required this.notification});

  @override
  Widget build(BuildContext context) {
    final status = notification.status?.trim() ?? '';
    final createdAt = notification.createdAt;

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (status.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor(status).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _statusText(status),
              style: TextStyle(
                fontSize: 11,
                color: _statusColor(status),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (createdAt != null)
          Text(
            _formatDate(createdAt),
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
      ],
    );
  }

  String _statusText(String status) {
    switch (status) {
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'pending':
        return 'Pending';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }
}
