// lib/features/notifications/presentation/widgets/notification_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/model/notification_model.dart';
import '../../data/provider/notification_provider.dart';

class NotificationCard extends ConsumerWidget {
  final NotificationModel notification;

  const NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    IconData getIcon() {
      switch (notification.type) {
        case NotificationType.success:
          return Icons.thumb_up;
        case NotificationType.transaction:
          return Icons.check;
        case NotificationType.info:
          return Icons.info_outline;
        case NotificationType.warning:
          return Icons.warning;
      }
    }

    Color getIconBackgroundColor() {
      if (notification.isRead) {
        return Colors.grey[300]!;
      }
      return Colors.black;
    }

    return GestureDetector(
      onTap: () {
        ref.read(notificationsProvider.notifier).markAsRead(notification.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.grey[100] : Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: notification.isRead ? Colors.grey[200]! : Colors.blue[200]!),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: getIconBackgroundColor(), shape: BoxShape.circle),
              child: Icon(getIcon(), color: notification.isRead ? Colors.grey[600] : Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(notification.description, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              ),
            ),
            // Time
            Text(notification.timeAgo, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}
