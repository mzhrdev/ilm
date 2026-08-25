// lib/features/messages/presentation/widgets/message_list_item.dart

import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';

import '../../data/model/chat_model.dart';

class ChatListItem extends StatelessWidget {
  final ChatModel message;
  final VoidCallback onTap;

  const ChatListItem({super.key, required this.message, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.w(3), vertical: context.h(1.75)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.w(5)),
          border: Border.all(color: AppColors.kGrey, width: context.w(0.5)),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: context.w(15),
              height: context.h(6),
              decoration: BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle),
              child: message.senderAvatar != null
                  ? ClipOval(
                      child: Image.network(
                        message.senderAvatar!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            color: AppColors.kBlack.withAlpha(150),
                            size: context.w(8),
                          );
                        },
                      ),
                    )
                  : Icon(Icons.person, color: AppColors.kBlack.withAlpha(150), size: context.w(8)),
            ),
            SizedBox(width: context.w(4)),
            // Message Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Sender Name
                      Expanded(
                        child: Text(
                          message.senderName,
                          style: AppTextStyle.kSectionTitle.copyWith(fontWeight: FontWeight.w900),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Time - e.g; 3d ago
                      Text(
                        message.formattedTime,
                        style: AppTextStyle.kBodySmall.copyWith(color: AppColors.kBlack.withAlpha(150)),
                      ),
                    ],
                  ),
                  SizedBox(height: context.h(1)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Last Text Sent
                      Expanded(
                        child: Text(
                          message.lastMessage,
                          style: AppTextStyle.kBodyLarge.copyWith(color: AppColors.kBlack.withAlpha(90)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Message Count
                      if (message.unreadCount > 0)
                        Container(
                          margin: EdgeInsets.only(left: context.w(4)),
                          padding: EdgeInsets.symmetric(horizontal: context.w(3), vertical: context.h(1)),
                          decoration: const BoxDecoration(color: AppColors.kBlack, shape: BoxShape.circle),
                          child: Text(
                            message.unreadCount > 99 ? '99+' : '${message.unreadCount}',
                            style: AppTextStyle.kBodyLarge,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
