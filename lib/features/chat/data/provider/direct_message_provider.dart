// Renamed from chatProvider to conversationProvider
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/chat/data/model/direct_message.dart';

final conversationProvider = StateNotifierProvider<ConversationNotifier, List<DirectMessage>>((ref) {
  return ConversationNotifier();
});

// Renamed from ChatNotifier to ConversationNotifier
class ConversationNotifier extends StateNotifier<List<DirectMessage>> {
  ConversationNotifier() : super(_mockMessages);

  static final List<DirectMessage> _mockMessages = [
    DirectMessage(
      id: '1',
      text: "Hi, How's you? How's everything?",
      isMe: false,
      time: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    DirectMessage(
      id: '2',
      text: "I'm doing great! Just finished the new UI design for the LMS app.",
      isMe: true,
      time: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
    DirectMessage(
      id: '3',
      text: "That sounds awesome! Can you share a preview?",
      isMe: false,
      time: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
  ];

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final newMessage = DirectMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isMe: true,
      time: DateTime.now(),
    );
    state = [...state, newMessage];
  }
}
