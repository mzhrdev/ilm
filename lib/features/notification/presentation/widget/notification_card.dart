// lib/features/notifications/presentation/widgets/notification_card.dart

import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';

import '../../data/model/notification_model.dart';
import '../../data/provider/notification_provider.dart';

class NotificationCard extends ConsumerWidget {
  final NotificationModel notification;

  const NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Getter Icon Method Definition
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

    // Getter Icon Color Method Definition
    Color getIconBackgroundColor() {
      if (notification.isRead) {
        return AppColors.kGrey;
      }
      return AppColors.kBlack;
    }

    return GestureDetector(
      onTap: () {
        ref.read(notificationsProvider.notifier).markAsRead(notification.id);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: context.h(1.5)),
        padding: EdgeInsets.all(context.w(4)),
        decoration: BoxDecoration(
          color: notification.isRead ? AppColors.kGrey.withAlpha(100) : AppColors.kBlue.withAlpha(50),
          borderRadius: BorderRadius.circular(context.w(4)),
          border: Border.all(color: notification.isRead ? AppColors.kBlack : AppColors.kBlue),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: context.w(12),
              height: context.h(6),
              decoration: BoxDecoration(color: getIconBackgroundColor(), shape: BoxShape.circle),
              child: Icon(
                getIcon(),
                color: notification.isRead ? AppColors.kBlack.withAlpha(150) : AppColors.kWhite,
                size: context.h(3),
              ),
            ),
            SizedBox(width: context.w(3)),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title, style: AppTextStyle.kSectionTitle),
                  SizedBox(height: context.h(1)),
                  Text(
                    notification.description,
                    style: AppTextStyle.kBodyMedium.copyWith(color: AppColors.kBlack.withAlpha(120)),
                  ),
                ],
              ),
            ),
            // Time
            Text(
              notification.timeAgo,
              style: AppTextStyle.kBodySmall.copyWith(color: AppColors.kBlack.withAlpha(150)),
            ),
          ],
        ),
      ),
    );
  }
}
