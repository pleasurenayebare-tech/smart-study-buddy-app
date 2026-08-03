import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final CollectionReference<Map<String, dynamic>> _usersRef =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference<Map<String, dynamic>> _groupsRef =
      FirebaseFirestore.instance.collection('groups');
  final CollectionReference<Map<String, dynamic>> _notesRef =
      FirebaseFirestore.instance.collection('notes');
  final CollectionReference<Map<String, dynamic>> _messagesRef =
      FirebaseFirestore.instance.collection('messages');
  final CollectionReference<Map<String, dynamic>> _conversationsRef =
      FirebaseFirestore.instance.collection('conversations');

  static const int _maxGroupMembers = 8;

  // ########################################################
  // # AUTHENTICATION METHODS
  // ########################################################

  User? get currentUser => _auth.currentUser;

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<bool> isUsernameUnique(String username) async {
    final querySnapshot = await _usersRef
        .where('username', isEqualTo: username.toLowerCase().trim())
        .get();
    return querySnapshot.docs.isEmpty;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserByUsername(
      String username) async {
    final querySnapshot = await _usersRef
        .where('username', isEqualTo: username.toLowerCase().trim())
        .get();
    if (querySnapshot.docs.isEmpty) return null;
    return querySnapshot.docs.first;
  }

  Future<String?> signUp({
    required String fullName,
    required String username,
    required String email,
    required String password,
    required String course,
    String? bio,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user!.uid;

      await _usersRef.doc(uid).set({
        'fullName': fullName,
        'username': username.toLowerCase().trim(),
        'email': email,
        'course': course,
        'bio': bio ?? 'Student focused on collaborative learning.',
        'photoUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'uploadCount': 0,
        'joinedGroups': [],
      });

      // Automatically place the new student into a study group for their course
      await _assignUserToGroup(uid, course);

      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyAuthError(e.code);
    } catch (e) {
      return 'Something went wrong while creating your account: $e';
    }
  }

  Future<String?> login({
    required String emailOrUsername,
    required String password,
  }) async {
    try {
      String email = emailOrUsername;
      if (!emailOrUsername.contains('@')) {
        final user = await getUserByUsername(emailOrUsername);
        if (user == null) return 'Username not found.';
        email = user['email'];
      }

      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyAuthError(e.code);
    } catch (e) {
      return 'Login failed: $e';
    }
  }

  String _friendlyAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'That email is already registered. Try logging in instead.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a few minutes and try again.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email/username or password.';
      default:
        return 'Something went wrong ($code). Please try again.';
    }
  }

  // ########################################################
  // # USER PROFILE METHODS
  // ########################################################

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final doc = await _usersRef.doc(_auth.currentUser!.uid).get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _usersRef.doc(_auth.currentUser!.uid).update(data);
  }

  Future<String> uploadProfilePicture(
      Uint8List fileBytes, String fileName) async {
    try {
      final uid = _auth.currentUser!.uid;
      final ref = _storage.ref('profile_pictures/$uid.jpg');
      await ref.putData(fileBytes, SettableMetadata(contentType: 'image/jpeg'));
      final url = await ref.getDownloadURL();
      await _usersRef.doc(uid).update({'photoUrl': url});
      return url;
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  // ########################################################
  // # GROUP METHODS
  // ########################################################

  Future<void> _assignUserToGroup(String uid, String course) async {
    final openGroups = await _groupsRef
        .where('course', isEqualTo: course)
        .where('memberCount', isLessThan: _maxGroupMembers)
        .limit(1)
        .get();

    String groupId;
    if (openGroups.docs.isNotEmpty) {
      final groupDoc = openGroups.docs.first;
      groupId = groupDoc.id;
      await groupDoc.reference.update({
        'members': FieldValue.arrayUnion([uid]),
        'memberCount': FieldValue.increment(1),
      });
    } else {
      final countSnap =
          await _groupsRef.where('course', isEqualTo: course).count().get();
      final groupNumber = (countSnap.count ?? 0) + 1;
      final newGroup = await _groupsRef.add({
        'name': '$course - Group $groupNumber',
        'course': course,
        'members': [uid],
        'memberCount': 1,
        'createdAt': FieldValue.serverTimestamp(),
      });
      groupId = newGroup.id;
    }

    await _usersRef.doc(uid).update({
      'joinedGroups': FieldValue.arrayUnion([groupId]),
    });
  }

  Future<void> createGroup(String name, String course) async {
    await _groupsRef.add({
      'name': name,
      'course': course,
      'members': [_auth.currentUser!.uid],
      'memberCount': 1,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': _auth.currentUser!.uid,
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserGroups() {
    return _groupsRef
        .where('members', arrayContains: _auth.currentUser!.uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserJoinedGroups(String uid) {
    return _groupsRef.where('members', arrayContains: uid).snapshots();
  }

  Future<void> joinGroup(String groupId) async {
    final uid = _auth.currentUser!.uid;
    await _groupsRef.doc(groupId).update({
      'members': FieldValue.arrayUnion([uid]),
      'memberCount': FieldValue.increment(1),
    });
    await _usersRef.doc(uid).update({
      'joinedGroups': FieldValue.arrayUnion([groupId]),
    });
  }

  Future<void> switchCourse({
    required String uid,
    required String newCourse,
  }) async {
    final userDoc = await _usersRef.doc(uid).get();
    final oldCourse = userDoc.data()?['course'] as String?;

    if (oldCourse != null) {
      final oldGroups = await _groupsRef
          .where('course', isEqualTo: oldCourse)
          .where('members', arrayContains: uid)
          .get();
      for (final g in oldGroups.docs) {
        await g.reference.update({
          'members': FieldValue.arrayRemove([uid]),
          'memberCount': FieldValue.increment(-1),
        });
      }
    }

    await _usersRef.doc(uid).update({
      'course': newCourse,
      'joinedGroups': [],
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _assignUserToGroup(uid, newCourse);
  }

  // ########################################################
  // # MESSAGING METHODS
  // ########################################################

  String getConversationId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return ids.join('_');
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String message,
  }) async {
    final parts = conversationId.split('_');

    await _messagesRef.add({
      'conversationId': conversationId,
      'senderId': senderId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _conversationsRef.doc(conversationId).set({
      'participants': parts,
      'lastMessage': message,
      'lastSenderId': senderId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessagesForConversation(
      String conversationId) {
    return _messagesRef
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('timestamp')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserConversations(
      String userId) {
    return _conversationsRef
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  // ########################################################
  // # NOTE/UPLOAD METHODS
  // ########################################################

  Future<void> saveNote({
    required String groupId,
    required String userId,
    required String title,
    required String subject,
    dynamic noteFile,
  }) async {
    await _notesRef.add({
      'groupId': groupId,
      'uploadedBy': userId,
      'title': title,
      'subject': subject,
      'ratingSum': 0,
      'ratingCount': 0,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _usersRef.doc(userId).update({
      'uploadCount': FieldValue.increment(1),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getNotesForGroup(
      String groupId) {
    return _notesRef
        .where('groupId', isEqualTo: groupId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> rateNote({
    required String noteId,
    required String userId,
    required int rating,
  }) async {
    await _notesRef.doc(noteId).update({
      'ratingSum': FieldValue.increment(rating),
      'ratingCount': FieldValue.increment(1),
    });
  }

  Future<void> flagNote({
    required String noteId,
    required String userId,
    required String reason,
  }) async {
    await _firestore.collection('flags').add({
      'noteId': noteId,
      'userId': userId,
      'reason': reason,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ########################################################
  // # QUIZ METHODS
  // ########################################################

  Stream<QuerySnapshot<Map<String, dynamic>>> getQuizzesForCourse(
      String course) {
    return _firestore
        .collection('quizzes')
        .where('course', isEqualTo: course)
        .snapshots();
  }

  Future<void> saveQuizProgress({
    required String userId,
    required String quizId,
    required int score,
    required int totalQuestions,
  }) async {
    await _usersRef.doc(userId).collection('quizzes').add({
      'quizId': quizId,
      'score': score,
      'totalQuestions': totalQuestions,
      'percentage': totalQuestions == 0 ? 0 : (score / totalQuestions * 100).toInt(),
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  // ########################################################
  // # DISCOVER METHODS
  // ########################################################

  Stream<QuerySnapshot<Map<String, dynamic>>> discoverUsersByCourse(
      String course, String currentUserId) {
    return _usersRef.where('course', isEqualTo: course).snapshots();
  }

  // ########################################################
  // # ACTIVITY METHODS
  // ########################################################

  Future<void> markActiveNow() async {
    try {
      await _usersRef.doc(_auth.currentUser!.uid).update({
        'lastActive': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silently fail for activity tracking
    }
  }
}
