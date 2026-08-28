import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';
import 'package:lms/core/presentation/widgets/custom_icon_button.dart';
import 'package:lms/core/presentation/widgets/custom_safe_area.dart';
import 'package:lms/core/presentation/widgets/snackbar.dart';
import 'package:lms/features/auth/data/providers/current_user_provider.dart';
import 'package:lms/features/calls/data/services/stream_video_service.dart';
import 'package:lms/features/chat/data/model/direct_message.dart';
import 'package:lms/features/chat/data/provider/conversation_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// Renamed from ChatScreen to ConversationScreen
class ConversationScreen extends ConsumerStatefulWidget {
  final String userId;
  final String userName;
  const ConversationScreen({super.key, required this.userId, required this.userName});
  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isInitiatingCall = false;

  // InitState
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conversationProvider.notifier).startConversation(widget.userId);
    });
  }

  // Dispose Method override
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ScrollToBottom Method
  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      final position = _scrollController.position.maxScrollExtent;

      if (animated) {
        _scrollController.animateTo(
          position,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(position);
      }
    });
  }

  // Send Message Method
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final currentUser = ref.read(currentUserProvider);
    _messageController.clear();
    await ref
        .read(conversationProvider.notifier)
        .sendMessage(
          text: text,
          receiverId: widget.userId,
          senderName: currentUser?.name ?? 'Unknown',
          receiverName: widget.userName,
        );
  }

  // Time Format Method
  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  // Build Method
  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(conversationProvider);

    // Method To Animate To Latest Message
    ref.listen<List<DirectMessage>>(conversationProvider, (previous, next) {
      if (previous?.length != next.length) {
        _scrollToBottom();
      }
    });
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.kWhite,
        appBar: AppBar(
          backgroundColor: AppColors.kWhite,
          elevation: 0,
          leading: CustomIconButton(
            onTap: () => context.pop(),
            icon: Icons.arrow_back_ios_new,
            iconColor: AppColors.kBlack,
          ),
          title: Row(
            children: [
              // User Avatar
              Container(
                width: context.w(10),
                height: context.h(8),
                decoration: BoxDecoration(color: AppColors.kGrey, shape: BoxShape.circle),
                child: Icon(Icons.person, color: AppColors.kBlack.withAlpha(150), size: context.h(3)),
              ),
              SizedBox(width: context.w(3)),
              // User Name
              Expanded(child: Text(widget.userName, style: AppTextStyle.kSectionTitle)),
            ],
          ),
          actions: [
            // Audio Call Button
            CustomIconButton(
              onTap: _isInitiatingCall
                  ? null
                  : () async {
                      setState(() => _isInitiatingCall = true);
                      try {
                        // Request Mic & Camera Permissions
                        final statuses = await [Permission.microphone, Permission.camera].request();

                        if (statuses[Permission.microphone] != PermissionStatus.granted) {
                          throw Exception('Microphone permission is required to place a call.');
                        }
                        await StreamVideoService.instance.initiateAudioCall(
                          ref: ref,
                          receiverUid: widget.userId,
                          receiverName: widget.userName,
                          receiverAvatar: null,
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Failed to start call: $e')));
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _isInitiatingCall = false);
                        }
                      }
                    },
              icon: _isInitiatingCall
                  ? Icons.wifi_protected_setup_rounded
                  : Icons.published_with_changes_outlined,
              iconColor: AppColors.kBlack,
              iconSize: context.h(3),
            ),
            //Video Call Button
            CustomIconButton(
              onTap: () {
                ShowSnackbar1.error(context, 'Video Call Functionality Not Available Right Now!');
                // final currentUser = ref.read(currentUserProvider);
                // // 1. Create a CallModel for this session
                // final callModel = CallModel(
                //   id: DateTime.now().millisecondsSinceEpoch.toString(),
                //   callerUid: currentUser?.id ?? '',
                //   receiverUid: widget.userId,
                //   contactName: widget.userName,
                //   callType: CallType.video,
                //   status: CallStatus.answeredOutgoing,
                //   timestamp: DateTime.now(),
                // );
                // // 2. Start the call in the provider
                // ref.read(activeCallProvider.notifier).startCall(callModel);
                // context.push(Routes.videoCall);
              },
              icon: Icons.videocam_rounded,
              iconColor: AppColors.kBlack,
              iconSize: context.h(4),
            ),
          ],
        ),
        body: Column(
          children: [
            // Messages List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),
            // Bottom Input Area
            Container(
              padding: EdgeInsets.symmetric(horizontal: context.w(3), vertical: context.h(1.5)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.w(8)),
                color: AppColors.kGrey.withAlpha(150),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.kBlack.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Text Field
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: AppColors.kBlack.withAlpha(150)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(context.w(6)),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.kWhite,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: context.w(3),
                          vertical: context.h(1.5),
                        ),
                      ),
                      onSubmitted: (_) async => _sendMessage(),
                    ),
                  ),
                  SizedBox(width: context.w(2)),
                  // Send Button
                  CustomIconButton(
                    splashColor: AppColors.kGrey,
                    highlightColor: AppColors.kGrey,
                    onTap: _sendMessage,
                    icon: Icons.send_rounded,
                    iconColor: AppColors.kBlack,
                    iconSize: context.w(8),
                    usedInAppBar: false,
                  ),
                ],
              ),
            ).padAll(context.w(3)),
          ],
        ),
      ),
    );
  }

  // Message Bubble
  Widget _buildMessageBubble(DirectMessage message) {
    final currentUser = ref.watch(currentUserProvider);
    final isMe = message.isMe(currentUser?.id ?? '');

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      // Main Container
      child: Container(
        margin: EdgeInsets.only(bottom: context.h(1)),
        padding: EdgeInsets.symmetric(horizontal: context.w(5), vertical: context.h(1.5)),
        constraints: BoxConstraints(maxWidth: context.w(75)),
        decoration: BoxDecoration(
          color: isMe ? AppColors.kBlack : AppColors.kGrey.withAlpha(150), // Theme colors
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(context.w(5)),
            topRight: Radius.circular(context.w(5)),
            bottomLeft: Radius.circular(isMe ? context.w(5) : context.w(2)),
            bottomRight: Radius.circular(isMe ? context.w(0.5) : context.w(5)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Message Text
            Text(
              message.text,
              style: AppTextStyle.kBodyMedium.copyWith(
                color: isMe ? AppColors.kGrey : AppColors.kBlack,
                fontSize: context.h(2),
              ),
            ),
            SizedBox(height: context.h(0.75)),
            // Formatted Time
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                _formatTime(message.time),
                style: AppTextStyle.kBodySmall.copyWith(
                  color: isMe ? AppColors.kWhite : AppColors.kGrey,
                  fontSize: context.h(1.25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
