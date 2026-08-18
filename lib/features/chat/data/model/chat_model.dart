import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { chat, call }

class ChatModel {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String lastMessage;
  final DateTime timestamp;
  final int unreadCount;
  final bool isOnline;
  final MessageType type;

  ChatModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.lastMessage,
    required this.timestamp,
    this.unreadCount = 0,
    this.isOnline = false,
    this.type = MessageType.chat,
  });

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      final hour = timestamp.hour;
      final minute = timestamp.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      senderAvatar: json['senderAvatar'] as String?,
      lastMessage: json['lastMessage'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      unreadCount: json['unreadCount'] as int? ?? 0,
      isOnline: json['isOnline'] as bool? ?? false,
      type: json['type'] == 'call' ? MessageType.call : MessageType.chat,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'lastMessage': lastMessage,
      'timestamp': timestamp.toIso8601String(),
      'unreadCount': unreadCount,
      'isOnline': isOnline,
      'type': type == MessageType.call ? 'call' : 'chat',
    };
  }

  ChatModel copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? lastMessage,
    DateTime? timestamp,
    int? unreadCount,
    bool? isOnline,
    MessageType? type,
  }) {
    return ChatModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      lastMessage: lastMessage ?? this.lastMessage,
      timestamp: timestamp ?? this.timestamp,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      type: type ?? this.type,
    );
  }

  /// Build an inbox row from a `conversations/{id}` document, from the
  /// perspective of [currentUserId].
  factory ChatModel.fromConversationDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String currentUserId,
  }) {
    final data = doc.data() ?? {};

    final participantIds = List<String>.from(data['participantIds'] as List? ?? []);
    final otherUserId = participantIds.firstWhere((id) => id != currentUserId, orElse: () => currentUserId);

    final names = Map<String, dynamic>.from(data['participantNames'] as Map? ?? {});
    final avatars = Map<String, dynamic>.from(data['participantAvatars'] as Map? ?? {});
    final unreadCounts = Map<String, dynamic>.from(data['unreadCounts'] as Map? ?? {});

    final lastMessageAt = data['lastMessageAt'];

    return ChatModel(
      id: doc.id,
      senderId: otherUserId,
      senderName: names[otherUserId] as String? ?? 'Unknown',
      senderAvatar: avatars[otherUserId] as String?,
      lastMessage: data['lastMessage'] as String? ?? '',
      timestamp: lastMessageAt is Timestamp ? lastMessageAt.toDate() : DateTime.now(),
      unreadCount: (unreadCounts[currentUserId] as num?)?.toInt() ?? 0,
      isOnline: false, // presence isn't tracked yet — see note below
    );
  }
}
