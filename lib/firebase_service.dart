import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference<Map<String, dynamic>> _usersRef =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference<Map<String, dynamic>> _groupsRef =
      FirebaseFirestore.instance.collection('groups');

  static const int _maxGroupMembers = 8;

  // ########################################################
  // # AUTHENTICATION METHODS
  // ########################################################

  User? get currentUser => _auth.currentUser;

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
      case 'operation-not-allowed':
        return 'Email/password sign-up is currently disabled. Contact the app admin.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email/username or password.';
      default:
        return 'Something went wrong ($code). Please try again.';
    }
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
      final normalizedUsername = username.toLowerCase().trim();

      if (!await isUsernameUnique(normalizedUsername)) {
        return 'That username is already taken. Please choose another one.';
      }

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = result.user;
      if (user == null) {
        return 'Unable to create account. Please try again.';
      }

      await user.sendEmailVerification();

      // Automatically place the new user into a group for their course
      final assignedGroupId = await _assignUserToGroup(user.uid, course.trim());

      await _usersRef.doc(user.uid).set({
        'uid': user.uid,
        'fullName': fullName.trim(),
        'username': normalizedUsername,
        'email': email.trim(),
        'bio': bio?.trim() ?? 'Student focused on collaborative learning.',
        'course': course.trim(),
        'joinedGroups': [assignedGroupId],
        'uploadCount': 0,
        'emailVerified': user.emailVerified,
        'usernameVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyAuthError(e.code);
    } on FirebaseException catch (e) {
      return 'Database error (${e.code}): ${e.message}';
    } catch (e) {
      return 'Something went wrong while creating your account. Details: ${e.runtimeType} — $e';
    }
  }

  Future<String?> login({
    required String emailOrUsername,
    required String password,
  }) async {
    try {
      final trimmedInput = emailOrUsername.trim();
      String loginEmail = trimmedInput;
      DocumentSnapshot<Map<String, dynamic>>? profileDoc;

      if (!trimmedInput.contains('@')) {
        profileDoc = await getUserByUsername(trimmedInput);
        if (profileDoc == null) {
          return 'Username not found. Please use a registered email or verified username.';
        }
        final profileData = profileDoc.data();
        if (profileData == null || !profileData.containsKey('email')) {
          return 'Invalid user record. Please contact support.';
        }
        loginEmail = profileData['email'] as String;
      }

      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: loginEmail,
        password: password,
      );

      final user = result.user;
      if (user == null) {
        return 'Login failed. Please try again.';
      }

      await user.reload();

      // Email verification enforcement intentionally disabled during development.
      // Re-enable before final submission if required by your project spec.

      profileDoc ??= await _usersRef.doc(user.uid).get();

      if (profileDoc.exists) {
        final profileData = profileDoc.data()!;
        if (profileData['usernameVerified'] != true) {
          await _usersRef.doc(user.uid).update({
            'usernameVerified': true,
            'emailVerified': true,
          });
        }
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyAuthError(e.code);
    } catch (e) {
      return 'Login failed. Details: ${e.runtimeType} — $e';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ########################################################
  // # GROUP ASSIGNMENT
  // ########################################################

  Future<String> _assignUserToGroup(String userId, String course) async {
    final openGroupQuery = await _groupsRef
        .where('course', isEqualTo: course)
        .where('memberCount', isLessThan: _maxGroupMembers)
        .orderBy('memberCount')
        .limit(1)
        .get();

    if (openGroupQuery.docs.isNotEmpty) {
      final groupDoc = openGroupQuery.docs.first;
      await groupDoc.reference.update({
        'memberIds': FieldValue.arrayUnion([userId]),
        'memberCount': FieldValue.increment(1),
      });
      return groupDoc.id;
    }

    final courseGroupCount = await _groupsRef
        .where('course', isEqualTo: course)
        .count()
        .get();
    final groupNumber = (courseGroupCount.count ?? 0) + 1;

    final newGroupRef = await _groupsRef.add({
      'name': '$course - Group $groupNumber',
      'course': course,
      'memberIds': [userId],
      'memberCount': 1,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return newGroupRef.id;
  }

  Future<void> switchCourse({required String uid, required String newCourse}) async {
    final userDoc = await _usersRef.doc(uid).get();
    final userData = userDoc.data();
    if (userData == null) return;

    final oldCourse = userData['course'] as String?;

    if (oldCourse != null) {
      final oldCourseGroups = await _groupsRef
          .where('course', isEqualTo: oldCourse)
          .where('memberIds', arrayContains: uid)
          .get();

      for (final groupDoc in oldCourseGroups.docs) {
        await groupDoc.reference.update({
          'memberIds': FieldValue.arrayRemove([uid]),
          'memberCount': FieldValue.increment(-1),
        });
        await _usersRef.doc(uid).update({
          'joinedGroups': FieldValue.arrayRemove([groupDoc.id]),
        });
      }
    }

    await _usersRef.doc(uid).update({'course': newCourse});
    final newGroupId = await _assignUserToGroup(uid, newCourse);
    await _usersRef.doc(uid).update({
      'joinedGroups': FieldValue.arrayUnion([newGroupId]),
    });
  }

  Future<void> joinGroup(String groupId) async {
    final uid = _auth.currentUser!.uid;
    await _groupsRef.doc(groupId).update({
      'memberIds': FieldValue.arrayUnion([uid]),
      'memberCount': FieldValue.increment(1),
    });
    await _usersRef.doc(uid).update({
      'joinedGroups': FieldValue.arrayUnion([groupId]),
    });
  }

  Future<void> leaveGroup(String groupId) async {
    final uid = _auth.currentUser!.uid;
    await _groupsRef.doc(groupId).update({
      'memberIds': FieldValue.arrayRemove([uid]),
      'memberCount': FieldValue.increment(-1),
    });
    await _usersRef.doc(uid).update({
      'joinedGroups': FieldValue.arrayRemove([groupId]),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getStudyGroups() {
    return _groupsRef.snapshots();
  }

  // ########################################################
  // # PROFILE / HOME SCREEN METHODS
  // ########################################################

  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _usersRef.doc(user.uid).get();
    return doc.data();
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _usersRef.doc(uid).update(data);
  }

  Future<String> uploadProfilePicture(Uint8List fileBytes, String fileName) async {
    final uid = _auth.currentUser!.uid;
    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_pictures')
        .child('$uid.jpg');

    await ref.putData(fileBytes, SettableMetadata(contentType: 'image/jpeg'));
    final downloadUrl = await ref.getDownloadURL();

    await _usersRef.doc(uid).update({'photoUrl': downloadUrl});
    return downloadUrl;
  }

  Future<void> markActiveNow() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _usersRef.doc(uid).update({
      'lastActiveAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserJoinedGroups(String userId) {
    return _groupsRef.where('memberIds', arrayContains: userId).snapshots();
  }

  // ########################################################
  // # DISCOVERY METHODS
  // ########################################################

  Stream<QuerySnapshot<Map<String, dynamic>>> discoverUsersByCourse(
      String course, String currentUserId) {
    return _usersRef.where('course', isEqualTo: course).snapshots();
  }
  
  // ########################################################
  // # NOTES METHODS
  // ########################################################

  Future<void> saveNote({
    required String groupId,
    required String userId,
    required String title,
    required String content,
  }) async {
    await _firestore.collection('notes').add({
      'groupId': groupId,
      'userId': userId,
      'title': title,
      'content': content,
      'uploadedAt': FieldValue.serverTimestamp(),
    });

    await _usersRef.doc(userId).update({
      'uploadCount': FieldValue.increment(1),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getNotesForGroup(String groupId) {
    return _firestore
        .collection('notes')
        .where('groupId', isEqualTo: groupId)
        .orderBy('uploadedAt', descending: true)
        .snapshots();
  }

  // ########################################################
  // # QUIZ METHODS
  // ########################################################

  Stream<QuerySnapshot<Map<String, dynamic>>> getQuizzesForCourse(String course) {
    return _firestore
        .collection('quizzes')
        .where('courseId', isEqualTo: course)
        .snapshots();
  }

  Future<void> saveQuizProgress({
    required String userId,
    required String quizId,
    required int score,
    required int totalQuestions,
  }) async {
    await _firestore.collection('quiz_results').add({
      'userId': userId,
      'quizId': quizId,
      'score': score,
      'totalQuestions': totalQuestions,
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserProgress(String userId) {
    return _firestore
        .collection('quiz_results')
        .where('userId', isEqualTo: userId)
        .orderBy('completedAt', descending: true)
        .snapshots();
  }
}
