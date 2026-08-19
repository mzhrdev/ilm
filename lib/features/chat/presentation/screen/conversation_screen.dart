import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/presentation/widgets/custom_icon_button.dart';
import 'package:lms/core/routing/app_routing.dart';
import 'package:lms/features/auth/data/providers/auth_provider.dart';
import 'package:lms/features/chat/data/model/call_model.dart';
import 'package:lms/features/chat/data/model/direct_message.dart';
import 'package:lms/features/chat/data/provider/active_call_provider.dart';
import 'package:lms/features/chat/data/provider/conversation_provider.dart';

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
  final int _lastMessageCount = 0;

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

    ref.listen<List<DirectMessage>>(conversationProvider, (previous, next) {
      if (previous?.length != next.length) {
        _scrollToBottom();
      }
    });
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            // User Avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle),
              child: const Icon(Icons.person, color: Colors.grey, size: 20),
            ),
            const SizedBox(width: 12),
            // User Name
            Expanded(
              child: Text(
                widget.userName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ],
        ),
        actions: [
          // Audio Call Button
          IconButton(
            icon: const Icon(Icons.call, color: Colors.black),
            onPressed: () {
              // 1. Create a CallModel for this session
              final callModel = CallModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                contactName: widget.userName,
                callType: CallType.audio,
                status: CallStatus.answeredOutgoing,
                timestamp: DateTime.now(),
              );
              // 2. Start the call in the provider (this removes the 'null' state)
              ref.read(activeCallProvider.notifier).startCall(callModel);
              context.push(Routes.audioCall);
            },
          ),
          // Video Call Button
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.black),
            onPressed: () {
              // 1. Create a CallModel for this session
              final callModel = CallModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                contactName: widget.userName,
                callType: CallType.video,
                status: CallStatus.answeredOutgoing,
                timestamp: DateTime.now(),
              );

              // 2. Start the call in the provider
              ref.read(activeCallProvider.notifier).startCall(callModel);
              context.push(Routes.videoCall);
            },
          ),
          const SizedBox(width: 8),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
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
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) async => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                // Send Button
                CustomIconButton(
                  splashColor: AppColors.kGrey,
                  highlightColor: AppColors.kGrey,
                  onTap: _sendMessage,
                  icon: Icons.send,
                  iconColor: AppColors.kBlack,
                  iconSize: context.w(6.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Message Bubble
  Widget _buildMessageBubble(DirectMessage message) {
    final currentUser = ref.watch(currentUserProvider);
    final isMe = message.isMe(currentUser?.id ?? '');

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? Colors.black : Colors.grey[100], // Theme colors
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                _formatTime(message.time),
                style: TextStyle(color: isMe ? Colors.white70 : Colors.grey[600], fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
