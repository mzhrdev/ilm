import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/core/data/services/firebase_firestore_services.dart';
import 'package:lms/features/chat/data/model/chat_model.dart';

enum MessageTab { chat, calls }

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final firestoreServices = FirebaseFirestoreServices();
  return ChatNotifier(firestoreServices);
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
    final filtered = searchQuery.isEmpty
        ? messages
        : messages.where((message) {
            return message.senderName.toLowerCase().contains(searchQuery.toLowerCase()) ||
                message.lastMessage.toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();

    if (currentTab == MessageTab.calls) {
      return filtered.where((m) => m.type == MessageType.call).toList();
    }

    return filtered;
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
  ChatNotifier(this._firestoreServices)
    : super(ChatState(messages: [], isLoading: true, searchController: TextEditingController())) {
    _subscribeToConversations();
  }

  final FirebaseFirestoreServices _firestoreServices;
  StreamSubscription<List<ChatModel>>? _conversationsSubscription;

  void _subscribeToConversations() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      state = state.copyWith(messages: [], isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true);

    _conversationsSubscription?.cancel();
    _conversationsSubscription = _firestoreServices
        .getConversationsForUser(currentUserId)
        .listen(
          (conversations) {
            state = state.copyWith(messages: conversations, isLoading: false);
          },
          onError: (error) {
            state = state.copyWith(isLoading: false);
          },
        );
  }

  void switchTab(MessageTab tab) {
    if (state.currentTab == tab) return;
    state = state.copyWith(currentTab: tab);
  }

  void setSearchQuery(String query) => state = state.copyWith(searchQuery: query);

  Future<void> markAsRead(String messageId) async {
    // messageId here is actually the conversation doc id (ChatModel.id)
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;
    await _firestoreServices.markConversationRead(conversationId: messageId, userId: currentUserId);
  }

  Future<void> refreshMessages() async => _subscribeToConversations();

  @override
  void dispose() {
    _conversationsSubscription?.cancel();
    super.dispose();
  }
}
