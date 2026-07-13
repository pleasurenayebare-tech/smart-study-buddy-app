import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  // Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ══════════════════════════════════════
  // AUTHENTICATION METHODS
  // ══════════════════════════════════════

  // Get current logged in user
  User? get currentUser => _auth.currentUser;

  // Sign up with email and password
  Future<String?> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user details to Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'uid': result.user!.uid,
        'fullName': fullName,
        'email': email,
        'joinedGroups': [],
        'uploadCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // null means success
    } catch (e) {
      return e.toString(); // return error message
    }
  }

  // Login with email and password
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // null means success
    } catch (e) {
      return e.toString(); // return error message
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ══════════════════════════════════════
  // NOTES METHODS
  // ══════════════════════════════════════

  // Get all notes from Firestore
  Stream<QuerySnapshot> getNotes() {
    return _firestore
        .collection('notes')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // ══════════════════════════════════════
  // STUDY GROUPS METHODS
  // ══════════════════════════════════════

  // Get all study groups from Firestore
  Stream<QuerySnapshot> getStudyGroups() {
    return _firestore
        .collection('study_groups')
        .snapshots();
  }

  // Join a study group
  Future<void> joinGroup(String groupId) async {
    String uid = _auth.currentUser!.uid;

    await _firestore.collection('study_groups').doc(groupId).update({
      'members': FieldValue.arrayUnion([uid]),
    });

    await _firestore.collection('users').doc(uid).update({
      'joinedGroups': FieldValue.arrayUnion([groupId]),
    });
  }

  // Leave a study group
  Future<void> leaveGroup(String groupId) async {
    String uid = _auth.currentUser!.uid;

    await _firestore.collection('study_groups').doc(groupId).update({
      'members': FieldValue.arrayRemove([uid]),
    });

    await _firestore.collection('users').doc(uid).update({
      'joinedGroups': FieldValue.arrayRemove([groupId]),
    });
  }

  // ══════════════════════════════════════
  // USER PROFILE METHODS
  // ══════════════════════════════════════

  // Get current user profile from Firestore
  Future<Map<String, dynamic>?> getUserProfile() async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    DocumentSnapshot doc =
        await _firestore.collection('users').doc(uid).get();

    return doc.data() as Map<String, dynamic>?;
  }
}
