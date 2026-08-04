import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lms/features/auth/data/model/user_model.dart';


class FirebaseFirestoreServices {
  FirebaseFirestoreServices({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');


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
}