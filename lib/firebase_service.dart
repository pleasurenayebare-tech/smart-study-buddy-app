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

      await _usersRef.doc(userCredential.user!.uid).set({
        'fullName': fullName,
        'username': username.toLowerCase().trim(),
        'email': email,
        'course': course,
        'bio': bio ?? 'Student focused on collaborative learning.',
        'photoUrl': null,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
        'uploadCount': 0,
        'joinedGroups': [],
      });

      return null;
    } catch (e) {
      return e.toString();
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
        if (user == null) return 'User not found';
        email = user['email'];
      }

      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } catch (e) {
      return e.toString();
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
    data['updatedAt'] = DateTime.now();
    await _usersRef.doc(_auth.currentUser!.uid).update(data);
  }

  Future<String> uploadProfilePicture(
      Uint8List fileBytes, String fileName) async {
    try {
      final ref = _storage.ref(
          'profile_pictures/${_auth.currentUser!.uid}/$fileName');
      await ref.putData(fileBytes);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  // ########################################################
  // # GROUP METHODS
  // ########################################################

  Future<void> createGroup(String name, String course) async {
    try {
      await _groupsRef.add({
        'name': name,
        'course': course,
        'members': [_auth.currentUser!.uid],
        'createdAt': DateTime.now(),
        'createdBy': _auth.currentUser!.uid,
      });
    } catch (e) {
      throw Exception('Failed to create group: $e');
    }
  }

  Stream<QuerySnapshot> getUserGroups() {
    return _groupsRef
        .where('members', arrayContains: _auth.currentUser!.uid)
        .snapshots();
  }

  Future<void> joinGroup(String groupId) async {
    try {
      await _groupsRef.doc(groupId).update({
        'members': FieldValue.arrayUnion([_auth.currentUser!.uid]),
      });

      await _usersRef.doc(_auth.currentUser!.uid).update({
        'joinedGroups': FieldValue.arrayUnion([groupId]),
      });
    } catch (e) {
      throw Exception('Failed to join group: $e');
    }
  }

  Future<void> switchCourse({
    required String uid,
    required String newCourse,
  }) async {
    try {
      await _usersRef.doc(uid).update({
        'course': newCourse,
        'joinedGroups': [],
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to switch course: $e');
    }
  }

  // ########################################################
  // # MESSAGING METHODS
  // ########################################################

  String getConversationId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join('_');
  }

  Future<void> sendMessage({
    required String receiverId,
    required String receiverName,
    required String text,
  }) async {
    try {
      final conversationId = getConversationId(
          _auth.currentUser!.uid, receiverId);

      final senderProfile = await getUserProfile();
      final senderName = senderProfile?['fullName'] ?? 'Student';

      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add({
        'senderId': _auth.currentUser!.uid,
        'senderName': senderName,
        'receiverId': receiverId,
        'receiverName': receiverName,
        'text': text,
        'timestamp': DateTime.now(),
      });

      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .set({
        'participants': [_auth.currentUser!.uid, receiverId],
        'participantNames': {
          _auth.currentUser!.uid: senderName,
          receiverId: receiverName,
        },
        'lastMessageTime': DateTime.now(),
        'text': text,
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Stream<QuerySnapshot> getMessagesForConversation(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getUserConversations(String userId) {
    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  // ########################################################
  // # NOTE/UPLOAD METHODS
  // ########################################################

  Future<void> saveNote({
    required String groupId,
    required String userId,
    required String title,
    required String content,
  }) async {
    try {
      await _groupsRef.doc(groupId).collection('notes').add({
        'title': title,
        'content': content,
        'userId': userId,
        'createdAt': DateTime.now(),
      });

      await _usersRef.doc(userId).update({
        'uploadCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to save note: $e');
    }
  }

  // ########################################################
  // # QUIZ METHODS
  // ########################################################

  Stream<QuerySnapshot> getQuizzesForCourse(String course) {
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
    try {
      await _usersRef.doc(userId).collection('quizzes').add({
        'quizId': quizId,
        'score': score,
        'totalQuestions': totalQuestions,
        'percentage': (score / totalQuestions * 100).toInt(),
        'completedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to save quiz progress: $e');
    }
  }

  // ########################################################
  // # DISCOVER METHODS
  // ########################################################

  Stream<QuerySnapshot> discoverUsersByCourse(
      String course, String currentUserId) {
    return _usersRef
        .where('course', isEqualTo: course)
        .where(FieldPath.documentId, isNotEqualTo: currentUserId)
        .snapshots();
  }

  // ########################################################
  // # ACTIVITY METHODS
  // ########################################################

  Future<void> markActiveNow() async {
    try {
      await _usersRef.doc(_auth.currentUser!.uid).update({
        'lastActive': DateTime.now(),
      });
    } catch (e) {
      // Silently fail for activity tracking
    }
  }
}
