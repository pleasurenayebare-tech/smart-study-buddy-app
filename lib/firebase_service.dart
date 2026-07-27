import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference<Map<String, dynamic>> _usersRef =
      FirebaseFirestore.instance.collection('users');

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
        'bio': bio?.trim() ?? 'Student focused on collaborative learning.',
        'course': null,
        'joinedGroups': [],
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

      await
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
