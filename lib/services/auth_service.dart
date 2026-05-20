import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:lifetours/models/models.dart';
import 'package:lifetours/models/firestore_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserModel?> fetchUserModel(String uid) async {
    final doc = await _firestore.collection(FirestoreCollections.users).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromDocumentSnapshot(doc);
  }

  Future<UserModel?> fetchUserByEmail(String email) async {
    final snap = await _firestore
        .collection(FirestoreCollections.users)
        .where(UserFields.email, isEqualTo: email)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return UserModel.fromDocumentSnapshot(snap.docs.first);
  }

  Stream<UserModel?> userStream(String uid) {
    return _firestore
        .collection(FirestoreCollections.users)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromDocumentSnapshot(doc) : null);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
