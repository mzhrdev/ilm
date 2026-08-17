import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Edvance/features/auth/data/model/user_model.dart';
import 'package:Edvance/features/courses/data/mappers/course_mapper.dart';
import 'package:Edvance/features/courses/data/model/course_draft_model.dart';
import 'package:Edvance/features/courses/data/model/course_model.dart';

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
}
