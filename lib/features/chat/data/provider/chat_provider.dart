// lib/features/messages/data/provider/messages_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/chat/data/dummy_data/mock_messages.dart';

import '../model/chat_model.dart';

enum MessageTab { chat, calls }

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});

class ChatState {
  final List<ChatModel> messages;
  final MessageTab currentTab;
  final bool isLoading;
  final String searchQuery;
  final TextEditingController searchController;

  ChatState({
    required this.messages,
    required this.searchController,
    this.currentTab = MessageTab.chat,
    this.isLoading = false,
    this.searchQuery = '',
  });

  List<ChatModel> get filteredMessages {
    if (searchQuery.isEmpty) {
      return messages;
    }
    return messages
        .where(
          (message) =>
              message.senderName.toLowerCase().contains(searchQuery.toLowerCase()) ||
              message.lastMessage.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
  }

  ChatState copyWith({
    List<ChatModel>? messages,
    MessageTab? currentTab,
    bool? isLoading,
    String? searchQuery,
    TextEditingController? searchController,
    String? selectedTab,
  }) {
    return ChatState(
      searchController: searchController ?? this.searchController,
      messages: messages ?? this.messages,
      currentTab: currentTab ?? this.currentTab,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier()
    : super(ChatState(messages: mockMessages, isLoading: true, searchController: TextEditingController())) {
    loadMessages();
  }

  Future<void> loadMessages() async {
    state = state.copyWith(isLoading: true);

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    state = state.copyWith(messages: mockMessages, isLoading: false);
  }

    // tab switching handled here
    void switchTab(MessageTab tab) {
    if (state.currentTab == tab) return; 
    state = state.copyWith(currentTab: tab);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void markAsRead(String messageId) {
    state = state.copyWith(
      messages: state.messages.map((message) {
        if (message.id == messageId) {
          return message.copyWith(unreadCount: 0);
        }
        return message;
      }).toList(),
    );
  }

  void markAllAsRead() {
    state = state.copyWith(
      messages: state.messages.map((message) {
        return message.copyWith(unreadCount: 0);
      }).toList(),
    );
  }

  Future<void> refreshMessages() async {
    await loadMessages();
  }
}
