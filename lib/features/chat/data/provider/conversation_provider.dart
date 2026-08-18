import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/core/data/services/firebase_firestore_services.dart';
import 'package:lms/features/auth/data/providers/auth_provider.dart';
import 'package:lms/features/chat/data/model/direct_message.dart';

final conversationProvider = StateNotifierProvider<ConversationNotifier, List<DirectMessage>>((ref) {
  final firestoreServices = ref.watch(firestoreServicesProvider);

  return ConversationNotifier(firestoreServices);
});

class ConversationNotifier extends StateNotifier<List<DirectMessage>> {
  ConversationNotifier(this._firestoreServices) : super([]);

  final FirebaseFirestoreServices _firestoreServices;

  StreamSubscription<List<DirectMessage>>? _messagesSubscription;

  String? _conversationId;

  /// Start listening to a conversation.
  void startConversation(String otherUserId) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      state = [];
      return;
    }

    _messagesSubscription?.cancel();
    _conversationId = _firestoreServices.getConversationId(currentUserId, otherUserId);

    _firestoreServices.markConversationRead(conversationId: _conversationId!, userId: currentUserId);

    _messagesSubscription = _firestoreServices
        .getMessages(_conversationId!)
        .listen((messages) => state = messages, onError: (error) {});
  }

  /// Send a new message.
  Future<void> sendMessage({
    required String text,
    required String receiverId,
    required String senderName,
    required String receiverName,
    String? senderAvatar,
    String? receiverAvatar,
  }) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final conversationId = _conversationId ?? _firestoreServices.getConversationId(currentUserId, receiverId);
    _conversationId = conversationId;

    final messageId = DateTime.now().millisecondsSinceEpoch.toString();

    final message = DirectMessage(
      id: messageId,
      senderId: currentUserId,
      receiverId: receiverId,
      text: trimmedText,
      time: DateTime.now(),
    );

    await _firestoreServices.sendMessage(
      conversationId: conversationId,
      message: message,
      senderName: senderName,
      receiverName: receiverName,
      senderAvatar: senderAvatar,
      receiverAvatar: receiverAvatar,
    );
  }

  /// Stop listening to the current conversation.
  void stopConversation() {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    _conversationId = null;
    state = [];
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }
}
