import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';
import 'package:lms/core/presentation/widgets/custom_icon_button.dart';
import 'package:lms/core/presentation/widgets/custom_text_field.dart';
import 'package:lms/core/routing/app_routing.dart';
import 'package:lms/features/auth/data/model/user_model.dart';
import 'package:lms/features/calls/data/providers/call_provider.dart';
import 'package:lms/features/calls/presentation/widget/call_list_item.dart';
import 'package:lms/features/chat/data/model/chat_model.dart';
import 'package:lms/features/chat/data/provider/chat_provider.dart';
import 'package:lms/features/chat/presentation/widget/chat_list_item.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);
    final callsState = ref.watch(callsProvider);
    final isChatTab = chatState.currentTab == MessageTab.chat;

    return Scaffold(
      backgroundColor: AppColors.kWhite,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // Build Search Field Method
          _buildSearchField(
            ref,
            chatState,
            isChatTab,
          ).padOnly(right: context.w(4), left: context.w(4), bottom: context.h(2)),
          // Build Tabs for Chats and Calls Method
          _buildTabs(context, ref, chatState, isChatTab).padHrz(context.w(2)),
          SizedBox(height: context.h(1.5)),
          Expanded(
            child: isChatTab ? _buildChatList(ref, chatState, context) : _buildCallsList(callsState, context),
          ),
        ],
      ),
    );
  }

  // AppBar
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.kWhite,
      elevation: 0,
      leading: CustomIconButton(
        icon: Icons.arrow_back_ios_new,
        iconColor: AppColors.kBlack,
        onTap: () => context.go(Routes.home),
      ),
      title: const Text('Inbox', style: AppTextStyle.kHeading),
    );
  }

  // Search field
  Widget _buildSearchField(WidgetRef ref, chatState, bool isChatTab) {
    return CustomTextField(
      labelText: null,
      controller: chatState.searchController,
      hintText: 'Search Here',
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      validator: FieldValidator.alphaNumeric(),
      preFixIcon: Icons.search,
      isPrefixIconEnabled: true,
      enabledBorderColor: AppColors.kGrey,
      focusedBorderColor: AppColors.kGrey,
      onChanged: (value) {
        if (isChatTab) {
          ref.read(chatProvider.notifier).setSearchQuery(value);
        } else {
          ref.read(callsProvider.notifier).setSearchQuery(value);
        }
      },
    );
  }

  // Tabs
  Widget _buildTabs(BuildContext context, WidgetRef ref, chatState, bool isChatTab) {
    final notifier = ref.read(chatProvider.notifier);
    return Container(
      height: context.h(7),
      decoration: BoxDecoration(
        color: AppColors.kTransparent,
        borderRadius: BorderRadius.circular(context.w(2)),
      ),
      child: Row(
        children: [
          // Chat Tab
          _buildTabItem(
            context: context,
            label: 'Chat',
            isSelected: isChatTab,
            onTap: () => notifier.switchTab(MessageTab.chat),
          ),
          // Call Tab
          _buildTabItem(
            context: context,
            label: 'Calls',
            isSelected: !isChatTab,
            onTap: () => notifier.switchTab(MessageTab.calls),
          ),
        ],
      ),
    ).padHrz(context.w(3));
  }

  Widget _buildTabItem({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.kBlack : AppColors.kGrey.withAlpha(10),
            borderRadius: BorderRadius.circular(context.w(5)),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyle.kBodyLarge.copyWith(
                fontSize: context.h(2.25),
                color: isSelected ? AppColors.kWhite : AppColors.kBlack.withAlpha(80),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Chat List
  Widget _buildChatList(WidgetRef ref, chatState, BuildContext context) {
    // Loading...
    if (chatState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<ChatModel> messages = chatState.filteredMessages;
    final List<UserModel> matchingUsers = chatState.matchingUsers;
    final bool isSearching = chatState.searchQuery.isNotEmpty;

    // Empty State
    if (messages.isEmpty && (!isSearching || matchingUsers.isEmpty)) {
      return _buildEmptyState(
        context: context,
        isChat: true,
        title: 'No messages yet',
        subtitle: isSearching ? 'No users found' : 'Search above to start a conversation',
      );
    }

    // Actual Chat List
    return ListView(
      children: [
        if (isSearching && matchingUsers.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(4), vertical: context.h(1)),
            child: const Text('Start new chat', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ...matchingUsers.map((user) => _buildUserSearchItem(context, user, ref)),
          if (messages.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.w(4), vertical: context.h(1)),
              child: const Text('Conversations', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
        ],
        ...messages.map(
          (message) => ChatListItem(
            message: message,
            onTap: () {
              ref.read(chatProvider.notifier).markAsRead(message.id);
              ref.read(chatProvider.notifier).clearSearch();
              context.push(
                '${Routes.conversation}'
                '?userId=${Uri.encodeComponent(message.senderId)}'
                '&name=${Uri.encodeComponent(message.senderName)}',
              );
            },
          ).padBottom(context.h(0.5)),
        ),
      ],
    ).padAll(context.w(3));
  }

  // Search Item Builder
  Widget _buildUserSearchItem(BuildContext context, UserModel user, WidgetRef ref) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.kGrey,
        backgroundImage: user.profileImageUrl != null ? NetworkImage(user.profileImageUrl!) : null,
        child: user.profileImageUrl == null
            ? Icon(Icons.person, color: AppColors.kBlack.withAlpha(150))
            : null,
      ),
      title: Text(user.name),
      onTap: () {
        ref.read(chatProvider.notifier).clearSearch();
        context.push(
          '${Routes.conversation}'
          '?userId=${Uri.encodeComponent(user.id)}'
          '&name=${Uri.encodeComponent(user.name)}',
        );
      },
    );
  }

  // Calls List
  Widget _buildCallsList(callsState, BuildContext context) {
    // Loading...
    if (callsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final calls = callsState.filteredCalls;

    // Empty State
    if (calls.isEmpty) {
      return _buildEmptyState(
        context: context,
        isChat: false,
        title: 'No recent calls',
        subtitle: 'Calls you make or receive will appear here',
      );
    }

    // Call List Item
    return ListView.separated(
      itemCount: calls.length,
      separatorBuilder: (_, __) => SizedBox(),
      itemBuilder: (context, index) {
        final call = calls[index];
        return CallListItem(call: call, onCallBack: () {}).padBottom(context.h(0.5));
      },
    ).padAll(context.w(3));
  }

  // Empty State
  Widget _buildEmptyState({
    required bool isChat,
    required String title,
    required String subtitle,
    required BuildContext context,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isChat ? Icons.chat_bubble_outline : Icons.call_end,
            size: context.h(3),
            color: AppColors.kGrey,
          ),
          SizedBox(height: context.h(3)),
          Text(title, style: AppTextStyle.kBodyLarge),
          SizedBox(height: context.h(2)),
          Text(subtitle, style: AppTextStyle.kBodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
