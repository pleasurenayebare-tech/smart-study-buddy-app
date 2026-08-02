import 'dart:io';
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
    } catch (e) {
      return e.toString();
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
    } catch (e) {
      return e.toString();
    }
  }

  // ########################################################
  // # GROUP ASSIGNMENT
  // ########################################################

  // Finds a group for this course with open space and adds the user to it.
  // If no matching group has space, creates a brand new one for that course.
  // Returns the group ID the user was placed into.
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

    // No open group for this course — create a new one
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

  // ########################################################
  // # PROFILE / HOME SCREEN METHODS
  // ########################################################

  // Fetch the currently logged-in user's profile document
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _usersRef.doc(user.uid).get();
    return doc.data();
  }

  // Stream the study groups this user has joined
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserJoinedGroups(String userId) {
    return _groupsRef
        .where('memberIds', arrayContains: userId)
        .snapshots();
  }

  // Stream notes shared within a given group
  Stream<QuerySnapshot<Map<String, dynamic>>> getNotesForGroup(String groupId) {
    return _firestore
        .collection('notes')
        .where('groupId', isEqualTo: groupId)
        .orderBy('uploadedAt', descending: true)
        .snapshots();
  }

  // ########################################################
  // # RATINGS AND CONTENT VERIFICATION
  // ########################################################

  // Submit or update a student's 1-5 rating for a note.
  // Each user can only have one active rating per note; rating again
  // updates their existing score rather than adding a duplicate.
  Future<void> rateNote({
    required String noteId,
    required String userId,
    required int rating,
  }) async {
    assert(rating >= 1 && rating <= 5, 'Rating must be between 1 and 5');

    final noteRef = _firestore.collection('notes').doc(noteId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(noteRef);
      final data = snapshot.data() as Map<String, dynamic>? ?? {};
      final raters = Map<String, dynamic>.from(data['raters'] ?? {});

      int sum = (data['ratingSum'] ?? 0) as int;
      int count = (data['ratingCount'] ?? 0) as int;

      if (raters.containsKey(userId)) {
        // User already rated this note — replace their old score
        final previousRating = raters[userId] as int;
        sum = sum - previousRating + rating;
      } else {
        sum += rating;
        count += 1;
      }
      raters[userId] = rating;

      transaction.update(noteRef, {
        'ratingSum': sum,
        'ratingCount': count,
        'raters': raters,
      });
    });
  }

  // Flag a note as inaccurate, irrelevant, or otherwise problematic.
  // Stores the individual flag (with reason) plus a running count on the note.
  Future<void> flagNote({
    required String noteId,
    required String userId,
    required String reason,
  }) async {
    final noteRef = _firestore.collection('notes').doc(noteId);

    await noteRef.collection('flags').doc(userId).set({
      'reason': reason.trim(),
      'flaggedAt': FieldValue.serverTimestamp(),
    });

    await noteRef.update({
      'flagCount': FieldValue.increment(1),
    });
  }

  // Stream a single note's document so rating/flag counts update live in the UI
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamNote(String noteId) {
    return _firestore.collection('notes').doc(noteId).snapshots();
  }

  // ########################################################
  // # QUIZ METHODS
  // ########################################################

  // Get all quizzes available for a given course
  Stream<QuerySnapshot<Map<String, dynamic>>> getQuizzesForCourse(String course) {
    return _firestore
        .collection('quizzes')
        .where('courseId', isEqualTo: course)
        .snapshots();
  }

  // Save a completed quiz attempt's score
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
}