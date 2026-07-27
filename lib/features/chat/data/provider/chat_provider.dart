// lib/features/messages/data/provider/messages_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/chat_model.dart';

enum MessageTab { chat, calls }

final messagesProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});

class ChatState {
  final List<ChatModel> messages;
  final MessageTab currentTab;
  final bool isLoading;
  final String searchQuery;

  ChatState({
    required this.messages,
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
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      currentTab: currentTab ?? this.currentTab,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(ChatState(messages: _mockMessages, isLoading: true)) {
    _loadMessages();
  }

  static final List<ChatModel> _mockMessages = [
    ChatModel(
      id: '1',
      senderId: 'user_2',
      senderName: 'Ateeq Taj',
      senderAvatar: null,
      lastMessage: "Hi, How's you? How's everything?",
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: 3,
      isOnline: true,
    ),
    ChatModel(
      id: '2',
      senderId: 'user_3',
      senderName: 'Ateeq Taj',
      senderAvatar: null,
      lastMessage: "Hi, How's you? How's everything?",
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      unreadCount: 3,
      isOnline: false,
    ),
    ChatModel(
      id: '3',
      senderId: 'user_4',
      senderName: 'Ateeq Taj',
      senderAvatar: null,
      lastMessage: "Hi, How's you? How's everything?",
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCount: 3,
      isOnline: true,
    ),
    ChatModel(
      id: '4',
      senderId: 'user_5',
      senderName: 'John Doe',
      senderAvatar: null,
      lastMessage: 'Thanks for the update!',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      unreadCount: 0,
      isOnline: false,
    ),
    ChatModel(
      id: '5',
      senderId: 'user_6',
      senderName: 'Sarah Smith',
      senderAvatar: null,
      lastMessage: 'See you tomorrow',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 1,
      isOnline: true,
    ),
  ];

  Future<void> _loadMessages() async {
    state = state.copyWith(isLoading: true);

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    state = state.copyWith(messages: _mockMessages, isLoading: false);
  }

  void switchTab(MessageTab tab) {
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
    await _loadMessages();
  }
}
