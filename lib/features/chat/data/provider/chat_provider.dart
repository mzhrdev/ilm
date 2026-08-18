import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/core/data/services/firebase_firestore_services.dart';
import 'package:lms/features/auth/data/model/user_model.dart';
import 'package:lms/features/auth/data/providers/auth_provider.dart';
import 'package:lms/features/chat/data/model/chat_model.dart';

enum MessageTab { chat, calls }

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final firestoreServices = ref.watch(firestoreServicesProvider);
  return ChatNotifier(firestoreServices);
});

class ChatState {
  final List<ChatModel> messages;

  final MessageTab currentTab;
  final bool isLoading;
  final String searchQuery;
  final TextEditingController searchController;
  final List<UserModel> matchingUsers;

  ChatState({
    required this.messages,
    required this.searchController,

    this.currentTab = MessageTab.chat,
    this.isLoading = false,
    this.searchQuery = '',
    this.matchingUsers = const [],
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
    List<UserModel>? matchingUsers,
  }) {
    return ChatState(
      searchController: searchController ?? this.searchController,
      messages: messages ?? this.messages,
      currentTab: currentTab ?? this.currentTab,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      matchingUsers: matchingUsers ?? this.matchingUsers,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(this._firestoreServices)
    : super(ChatState(messages: [], isLoading: true, searchController: TextEditingController())) {
    _subscribeToConversations();
    _loadAllUsers();
  }

  final FirebaseFirestoreServices _firestoreServices;
  StreamSubscription<List<ChatModel>>? _conversationsSubscription;
  List<UserModel> _allUsers = [];

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

  // CHANGED — now also computes matchingUsers
  void setSearchQuery(String query) {
    final matches = query.isEmpty
        ? const <UserModel>[]
        : _allUsers.where((u) => u.name.toLowerCase().contains(query.toLowerCase())).toList();

    state = state.copyWith(searchQuery: query, matchingUsers: matches);
  }

  // NEW
  Future<void> _loadAllUsers() async {
    try {
      final users = await _firestoreServices.getAllUsers();
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      _allUsers = users.where((u) => u.id != currentUserId).toList();
    } catch (_) {
      _allUsers = [];
    }
  }

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
