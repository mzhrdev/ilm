import 'package:cloud_firestore/cloud_firestore.dart';

class DirectMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime time;

  DirectMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.time,
  });

  /// Whether this message was sent by the currently logged-in user.
  bool isMe(String currentUserId) {
    return senderId == currentUserId;
  }

  /// Convert Firestore document → DirectMessage
  factory DirectMessage.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    if (data == null) {
      throw StateError('Message document ${doc.id} has no data.');
    }

    final timestamp = data['timestamp'];

    return DirectMessage(
      id: doc.id,
      senderId: data['senderId'] as String,
      receiverId: data['receiverId'] as String,
      text: data['text'] as String,
      time: timestamp is Timestamp ? timestamp.toDate() : DateTime.parse(timestamp as String),
    );
  }

  /// Convert DirectMessage → Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': Timestamp.fromDate(time),
    };
  }
}
