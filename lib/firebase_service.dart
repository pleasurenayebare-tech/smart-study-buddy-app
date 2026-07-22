import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  // Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Users collection reference
  final CollectionReference<Map<String, dynamic>> _usersRef =
      FirebaseFirestore.instance.collection('users');

  // Maximum members per auto-assigned study group
  static const int _groupCapacity = 8;

  // Update user profile in Firestore
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).update(data);
  }

  // ########################################################
  // # AUTHENTICATION METHODS
  // ########################################################

  // Get current logged in user
  User? get currentUser => _auth.currentUser;

  // Check if a username is unique in Firestore
 Future<bool> isUsernameUnique(String username) async {
  final doc = await _firestore
      .collection('usernames')
      .doc(username.toLowerCase().trim())
      .get();
  return !doc.exists;
}

  // Find a user document by username
  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserByUsername(
    String username) async {
  final lookup = await _firestore
      .collection('usernames')
      .doc(username.toLowerCase().trim())
      .get();

  if (!lookup.exists) return null;
  final uid = lookup.data()?['uid'] as String?;
  if (uid == null) return null;

  return _usersRef.doc(uid).get();
}

  // Sign up with email, password, a verified username, and a course.
  // Automatically assigns the new user to a study group for their course.
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

      await _usersRef.doc(user.uid).set({
        'uid': user.uid,
        'fullName': fullName.trim(),
        'username': normalizedUsername,
        'email': email.trim(),
        'course': course,
        'bio': bio?.trim() ?? 'Student focused on collaborative learning.',
        'joinedGroups': [],
        'uploadCount': 0,
        'emailVerified': user.emailVerified,
        'usernameVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Automatically assign the new user to a study group for their course
      await assignToGroup(uid: user.uid, course: course);
      await _firestore.collection('usernames').doc(normalizedUsername).set({
        'uid': user.uid,
     });
      return null; // null means success
    } catch (e) {
      return e.toString(); // return error message
    }
  }

  // Finds a study group for this course with room, or creates a new one,
  // and adds the user to it. Runs as a transaction to avoid race conditions
  // when multiple students sign up for the same course at once.
  Future<void> assignToGroup({required String uid, required String course}) async {
    final groupsRef = _firestore.collection('study_groups');

    await _firestore.runTransaction((transaction) async {
      final candidates = await groupsRef
          .where('course', isEqualTo: course)
          .where('memberCount', isLessThan: _groupCapacity)
          .limit(1)
          .get();

      DocumentReference<Map<String, dynamic>> groupRef;

      if (candidates.docs.isNotEmpty) {
        groupRef = candidates.docs.first.reference;
        transaction.update(groupRef, {
          'members': FieldValue.arrayUnion([uid]),
          'memberCount': FieldValue.increment(1),
        });
      } else {
        groupRef = groupsRef.doc();
        final groupNumber = DateTime.now().millisecondsSinceEpoch % 1000;
        transaction.set(groupRef, {
          'name': '$course Study Group #$groupNumber',
          'course': course,
          'members': [uid],
          'memberCount': 1,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      transaction.update(_usersRef.doc(uid), {
        'joinedGroups': FieldValue.arrayUnion([groupRef.id]),
      });
    });
  }

  // Switch a user to a new course: leaves their current course-based group(s)
  // and gets auto-assigned to a group for the new course.
  Future<void> switchCourse({required String uid, required String newCourse}) async {
    final userDoc = await _usersRef.doc(uid).get();
    final userData = userDoc.data();
    if (userData == null) return;

    final oldCourse = userData['course'] as String?;
    final joinedGroups = List<String>.from(userData['joinedGroups'] ?? []);

    // Find and leave any group tied to the old course
    if (oldCourse != null && joinedGroups.isNotEmpty) {
      final groupsRef = _firestore.collection('study_groups');
      final oldCourseGroups = await groupsRef
          .where('course', isEqualTo: oldCourse)
          .where('members', arrayContains: uid)
          .get();

      for (final groupDoc in oldCourseGroups.docs) {
        await _firestore.runTransaction((transaction) async {
          transaction.update(groupDoc.reference, {
            'members': FieldValue.arrayRemove([uid]),
            'memberCount': FieldValue.increment(-1),
          });
        });

        await _usersRef.doc(uid).update({
          'joinedGroups': FieldValue.arrayRemove([groupDoc.id]),
        });
      }
    }

    // Update the user's course field
    await _usersRef.doc(uid).update({'course': newCourse});

    // Assign to a group for the new course
    await assignToGroup(uid: uid, course: newCourse);
  }

  // Login using email or verified username
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

        if (profileData['usernameVerified'] != true) {
          return 'Please verify your username by confirming your email first.';
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

      if (!user.emailVerified) {
        await user.sendEmailVerification();
        await _auth.signOut();
        return 'Email is not verified. A verification link has been resent to your inbox.';
      }

      if (profileDoc == null) {
        profileDoc = await _usersRef.doc(user.uid).get();
      }

      if (profileDoc.exists) {
        final profileData = profileDoc.data()!;
        if (profileData['usernameVerified'] != true) {
          await _usersRef.doc(user.uid).update({
            'usernameVerified': true,
            'emailVerified': true,
          });
        }
      }

      return null; // null means success
    } catch (e) {
      return e.toString(); // return error message
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ########################################################
  // # NOTES METHODS
  // ########################################################

  // Get all notes from Firestore
  Stream<QuerySnapshot<Map<String, dynamic>>> getNotes() {
    return _firestore
        .collection('notes')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get notes uploaded by the current user
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserNotes(String uid) {
    return _firestore
        .collection('notes')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get study groups joined by the current user
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserJoinedGroups(String uid) {
    return _firestore
        .collection('study_groups')
        .where('members', arrayContains: uid)
        .snapshots();
  }

  // ########################################################
  // # NOTES METHODS
  // ########################################################

  // Save a note (text or link) to Firestore (Free on Spark Plan)
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
      'content': content, // Stores the link or the note text
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _usersRef.doc(userId).update({
      'uploadCount': FieldValue.increment(1),
    });
  }

  // Get notes for a specific study group
  Stream<QuerySnapshot<Map<String, dynamic>>> getNotesForGroup(String groupId) {
    return _firestore
        .collection('notes')
        .where('groupId', isEqualTo: groupId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // ########################################################
  // # DISCOVERY METHODS
  // ########################################################

  // Find other users taking the same course
  Stream<QuerySnapshot<Map<String, dynamic>>> discoverUsersByCourse(
      String course, String currentUserId) {
    return _usersRef.where('course', isEqualTo: course).snapshots();
  }

  // ########################################################
  // # STUDY GROUPS METHODS
  // ########################################################

  // Get all study groups from Firestore
  Stream<QuerySnapshot<Map<String, dynamic>>> getStudyGroups() {
    return _firestore.collection('study_groups').snapshots();
  }

  // Join a study group
  Future<void> joinGroup(String groupId) async {
    final String uid = _auth.currentUser!.uid;
    await _firestore.collection('study_groups').doc(groupId).update({
      'members': FieldValue.arrayUnion([uid]),
    });
    await _usersRef.doc(uid).update({
      'joinedGroups': FieldValue.arrayUnion([groupId]),
    });
  }

  // Leave a study group
  Future<void> leaveGroup(String groupId) async {
    final String uid = _auth.currentUser!.uid;
    await _firestore.collection('study_groups').doc(groupId).update({
      'members': FieldValue.arrayRemove([uid]),
    });
    await _usersRef.doc(uid).update({
      'joinedGroups': FieldValue.arrayRemove([groupId]),
    });
  }

  // ########################################################
  // # USER PROFILE METHODS
  // ########################################################

  // Get current user profile from Firestore
  Future<Map<String, dynamic>?> getUserProfile() async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final DocumentSnapshot<Map<String, dynamic>> doc =
        await _usersRef.doc(uid).get();
    return doc.data();
  }
}
