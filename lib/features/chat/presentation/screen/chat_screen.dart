import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';
import 'package:lms/core/presentation/widgets/custom_text_field.dart';
import 'package:lms/core/routing/app_routing.dart';
import 'package:lms/features/chat/data/provider/call_provider.dart';
import 'package:lms/features/chat/data/provider/chat_provider.dart';
import 'package:lms/features/chat/presentation/widget/call_list_item.dart';
import 'package:lms/features/chat/presentation/widget/chat_list_item.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<ChatScreen> {
  final _searchController = TextEditingController();
  String _selectedTab = 'Chat'; // 'Chat' or 'Calls'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final chatNotifier = ref.read(chatProvider.notifier);
    final callsState = ref.watch(callsProvider);
    final messages = chatState.filteredMessages;
    final calls = callsState.filteredCalls;

    return Scaffold(
      backgroundColor: AppColors.kWhite,
      appBar: AppBar(
        backgroundColor: AppColors.kWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.kBlack),
          onPressed: () => context.go(Routes.home),
        ),
        title: const Text('Inbox', style: AppTextStyle.kHeading),
      ),
      body: Column(
        children: [
          // Search Bar
          CustomTextField(
            controller: chatState.searchController,
            hintText: 'Search Here',
            labelText: null,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.search,
            validator: FieldValidator.alphaNumeric(),
            preFixIcon: Icons.search,
            isPrefixIconEnabled: true,
            contentPadding: EdgeInsets.symmetric(horizontal: context.w(3), vertical: context.h(2)),
            onSubmitted: (value) {
              if (_selectedTab == 'Chat') {
                ref.read(chatProvider.notifier).setSearchQuery(value!);
              } else {
                ref.read(callsProvider.notifier).setSearchQuery(value!);
              }
            },
          ),

          // Tabs
          Container(
            height: context.h(9),
            decoration: BoxDecoration(
              color: AppColors.kGrey,
              borderRadius: BorderRadius.circular(context.w(6)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // TO DO: Changing selected tab value to chat
                      chatNotifier.switchTab;
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: chatState.selectedTab == 'Chat' ? AppColors.kBlack : AppColors.kTransparent,
                        borderRadius: BorderRadius.circular(context.w(4)),
                      ),
                      child: Center(
                        child: Text(
                          'Chat',
                          style: AppTextStyle.kBodyMedium.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: chatState.selectedTab == 'Chat' ? AppColors.kWhite : AppColors.kGrey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // TO DO: Changing selected tab value to calls
                      chatNotifier.switchTab;
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _selectedTab == 'Calls' ? Colors.black : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Calls',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: _selectedTab == 'Calls' ? Colors.white : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ).padHrz(context.w(3)),

          const SizedBox(height: 16),

          // Content based on selected tab
          Expanded(
            child: chatState.selectedTab == 'Chat'
                ? _buildChatList(chatState, messages)
                : _buildCallsList(callsState, calls),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(messagesState, messages) {
    return messagesState.isLoading
        ? const Center(child: CircularProgressIndicator())
        : messages.isEmpty
        ? _buildEmptyState('No messages yet', 'When you receive messages, they will appear here')
        : ListView.separated(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: messages.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final message = messages[index];
              return ChatListItem(
                message: message,
                onTap: () {
                  ref.read(chatProvider.notifier).markAsRead(message.id);
                  context.push('${Routes.conversation}?name=${Uri.encodeComponent(message.senderName)}');
                },
              );
            },
          );
  }

  Widget _buildCallsList(callsState, calls) {
    return callsState.isLoading
        ? const Center(child: CircularProgressIndicator())
        : calls.isEmpty
        ? _buildEmptyState('No recent calls', 'Calls you make or receive will appear here')
        : ListView.separated(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: calls.length,
            separatorBuilder: (context, index) => Divider(color: Colors.grey[200], height: 1),
            itemBuilder: (context, index) {
              final call = calls[index];
              return CallListItem(
                call: call,
                onCallBack: () {
                  // Initiate callback
                },
              );
            },
          );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _selectedTab == 'Chat' ? Icons.chat_bubble_outline : Icons.call_end,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
