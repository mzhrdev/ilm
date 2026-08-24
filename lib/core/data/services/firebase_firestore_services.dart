import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lms/features/auth/data/model/user_model.dart';
import 'package:lms/features/chat/data/model/chat_model.dart';
import 'package:lms/features/chat/data/model/direct_message.dart';
import 'package:lms/features/courses/data/mappers/course_mapper.dart';
import 'package:lms/features/courses/data/model/course_draft_model.dart';
import 'package:lms/features/courses/data/model/course_model.dart';

class FirebaseFirestoreServices {
  FirebaseFirestoreServices({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _usersRef => _firestore.collection('users');

  // Saves the given [user] to Firestore.
  Future<void> saveUser(UserModel user, {bool onlyIfNew = false}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('Cannot save user: no authenticated user found.');
    }

    try {
      final docRef = _usersRef.doc(uid);

      if (onlyIfNew) {
        final snapshot = await docRef.get();
        if (snapshot.exists) {
          // Document already exists — do nothing.
          return;
        }
        await docRef.set(user.toJson());
      } else {
        await docRef.set(user.toJson(), SetOptions(merge: true));
      }
    } on FirebaseException catch (e) {
      throw Exception('Failed to save user: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while saving user: $e');
    }
  }

  // Fetches the currently logged-in user's document from Firestore.
  Future<UserModel?> getUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    try {
      final snapshot = await _usersRef.doc(uid).get();
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;

      return UserModel.fromJson(data);
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch user: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while fetching user: $e');
    }
  }

  // Save course from the draft
  Future<void> saveCourseFromDraft({
    required CourseDraft draft,
    required String instructorId,
    required String instructorName,
  }) async {
    try {
      // Generate Firestore document ID
      final docRef = _firestore.collection('courses').doc();

      // Convert Draft into complete CourseModel
      final course = draft.toCourse(
        id: docRef.id,
        instructorId: instructorId,
        instructorName: instructorName,
      );

      // Save course
      await docRef.set(course.toJson());
    } on FirebaseException catch (e) {
      throw Exception('Failed to save course: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while saving course: $e');
    }
  }

  // Saving Course to Firebase
  Future<void> saveCourseToFirebase(CourseModel course) async {
    final firestore = FirebaseFirestore.instance;

    await firestore.collection('courses').doc(course.id).set(course.toJson());
  }

  // Fetching Course from Firestore
  Stream<List<CourseModel>> getCourses() {
    return FirebaseFirestore.instance
        .collection('courses')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => CourseModel.fromFirestore(doc)).toList());
  }

  // ---------------------------------------------------------------------------
  // CHAT
  // ---------------------------------------------------------------------------

  CollectionReference<Map<String, dynamic>> get _conversationsRef => _firestore.collection('conversations');

  /// Creates a deterministic conversation ID for two users.
  ///
  /// Sorting the UIDs ensures that:
  /// userA -> userB
  /// and
  /// userB -> userA
  /// always produce the same conversation ID.
  String getConversationId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  /// Listen to all messages in a conversation in real time.
  Stream<List<DirectMessage>> getMessages(String conversationId) {
    return _conversationsRef
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => DirectMessage.fromFirestore(doc)).toList());
  }

  /// Send a message to Firestore. Also denormalizes names/avatars onto the
  /// conversation doc (for inbox display) and increments the receiver's
  /// unread count.
  Future<void> sendMessage({
    required String conversationId,
    required DirectMessage message,
    required String senderName,
    required String receiverName,
    String? senderAvatar,
    String? receiverAvatar,
  }) async {
    try {
      final conversationRef = _conversationsRef.doc(conversationId);

      await conversationRef.collection('messages').doc(message.id).set(message.toFirestore());

      await conversationRef.set({
        'participantIds': [message.senderId, message.receiverId],
        'participantNames': {message.senderId: senderName, message.receiverId: receiverName},
        'participantAvatars': {message.senderId: senderAvatar, message.receiverId: receiverAvatar},
        'lastMessage': message.text,
        'lastMessageAt': Timestamp.fromDate(message.time),
        'unreadCounts.${message.receiverId}': FieldValue.increment(1),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw Exception('Failed to send message: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while sending message: $e');
    }
  }

  /// Stream the current user's conversation list for the inbox.
  Stream<List<ChatModel>> getConversationsForUser(String userId) {
    return _conversationsRef
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => ChatModel.fromConversationDoc(doc, currentUserId: userId)).toList(),
        );
  }

  /// Reset the current user's unread count for a conversation to 0.
  Future<void> markConversationRead({required String conversationId, required String userId}) async {
    try {
      await _conversationsRef.doc(conversationId).set({'unreadCounts.$userId': 0}, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw Exception('Failed to mark conversation read: ${e.message}');
    }
  }

  /// Fetch all user profiles once, for the "start new chat" search.
  /// MVP-scale only: fetches the whole users collection client-side and
  /// filtering happens on the Dart side. Revisit with a proper indexed
  /// query (e.g. name prefix range query) if the user base grows.
  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _usersRef.get();
      return snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch users: ${e.message}');
    }
  }

  /// Verifies an instructor against the instructors collection.
  ///
  /// Returns true if the provided instructor ID and name match
  /// an existing instructor document.
  Future<bool> verifyInstructor({required String instructorId, required String instructorName}) async {
    try {
      final instructorDoc = await _firestore.collection('instructors').doc(instructorId).get();

      if (!instructorDoc.exists) {
        return false;
      }

      final data = instructorDoc.data();

      if (data == null) {
        return false;
      }

      final storedName = data['name'] as String?;

      return storedName != null && storedName.trim().toLowerCase() == instructorName.trim().toLowerCase();
    } on FirebaseException catch (e) {
      throw Exception('Failed to verify instructor: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while verifying instructor: $e');
    }
  }

  /// Updates the current user's role to instructor.
  Future<void> updateUserRole(String role) async {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      throw StateError('Cannot update role: no authenticated user found.');
    }

    try {
      await _usersRef.doc(uid).set({'role': role}, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw Exception('Failed to update user role: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while updating user role: $e');
    }
  }
}
