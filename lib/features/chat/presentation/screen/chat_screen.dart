import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Edvance/core/constants/app_colors.dart';
import 'package:Edvance/core/constants/app_text_styles.dart';
import 'package:Edvance/core/presentation/widgets/custom_text_field.dart';
import 'package:Edvance/core/routing/app_routing.dart';
import 'package:Edvance/features/chat/data/model/chat_model.dart';
import 'package:Edvance/features/chat/data/provider/call_provider.dart';
import 'package:Edvance/features/chat/data/provider/chat_provider.dart';
import 'package:Edvance/features/chat/presentation/widget/call_list_item.dart';
import 'package:Edvance/features/chat/presentation/widget/chat_list_item.dart';

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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.kBlack),
        onPressed: () => context.go(Routes.home),
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
      onSubmitted: (value) {
        if (value == null) return;
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
    if (chatState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<ChatModel> messages = chatState.filteredMessages;

    if (messages.isEmpty) {
      return _buildEmptyState(
        context: context,
        isChat: true,
        title: 'No messages yet',
        subtitle: 'When you receive messages, they will appear here',
      );
    }

    return ListView.separated(
      itemCount: messages.length,
      separatorBuilder: (_, __) => Divider(height: context.h(0.05)),
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

  // Calls List
  Widget _buildCallsList(callsState, BuildContext context) {
    if (callsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final calls = callsState.filteredCalls;
    if (calls.isEmpty) {
      return _buildEmptyState(
        context: context,
        isChat: false,
        title: 'No recent calls',
        subtitle: 'Calls you make or receive will appear here',
      );
    }

    return ListView.separated(
      itemCount: calls.length,
      separatorBuilder: (_, __) => Divider(color: AppColors.kGrey, height: context.h(0.05)),
      itemBuilder: (context, index) {
        final call = calls[index];
        return CallListItem(call: call, onCallBack: () {});
      },
    );
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
