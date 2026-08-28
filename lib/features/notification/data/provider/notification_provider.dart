// lib/features/notifications/data/provider/notification_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/notification_model.dart';

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, List<NotificationModel>>((ref) {
  return NotificationsNotifier();
});

class NotificationsNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationsNotifier() : super(_mockNotifications);

  // Mock Notification List
  static final List<NotificationModel> _mockNotifications = [
    NotificationModel(
      id: '1',
      title: 'Transaction Successfully!',
      description: 'Lorem ipsum dolor sit amet consectetur.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      type: NotificationType.transaction,
      isRead: false,
    ),
    NotificationModel(
      id: '2',
      title: 'Transaction Successfully!',
      description: 'Lorem ipsum dolor sit amet consectetur.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      type: NotificationType.success,
      isRead: false,
    ),
    NotificationModel(
      id: '3',
      title: 'Lorem ipsum',
      description: 'Lorem ipsum dolor sit amet consectetur.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      type: NotificationType.transaction,
      isRead: false,
    ),
    NotificationModel(
      id: '4',
      title: 'Lorem ipsum',
      description: 'Lorem ipsum dolor sit amet consectetur.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      type: NotificationType.transaction,
      isRead: false,
    ),
  ];

  // Mark as Read Method Definition
  void markAsRead(String notificationId) {
    state = state.map((notification) {
      if (notification.id == notificationId) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();
  }

  // Mark All as Read Method Definition
  void markAllAsRead() {
    state = state.map((notification) {
      return notification.copyWith(isRead: true);
    }).toList();
  }

  // Delete Notification Method Definition
  void deleteNotification(String notificationId) {
    state = state.where((notification) => notification.id != notificationId).toList();
  }

  // Clear Notification Method Definition
  void clearAllNotifications() {
    state = [];
  }

  // Add Notification Method
  void addNotification(NotificationModel notification) {
    state = [notification, ...state];
  }

  // Getter Method for Unread Count
  int get unreadCount {
    return state.where((notification) => !notification.isRead).length;
  }
}