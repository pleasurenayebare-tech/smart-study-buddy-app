import 'package:cloud_firestore/cloud_firestore.dart';

class QuizProgress {
  final String id;
  final String userId;
  final String quizId;
  final int score;
  final int totalQuestions;
  final DateTime completedAt;

  QuizProgress({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.score,
    required this.totalQuestions,
    required this.completedAt,
  });

  factory QuizProgress.fromMap(String id, Map<String, dynamic> map) {
    final rawTimestamp = map['completedAt'];
    return QuizProgress(
      id: id,
      userId: map['userId'] ?? '',
      quizId: map['quizId'] ?? '',
      score: map['score'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      completedAt: rawTimestamp is Timestamp
          ? rawTimestamp.toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'quizId': quizId,
      'score': score,
      'totalQuestions': totalQuestions,
      'completedAt': FieldValue.serverTimestamp(),
    };
  }

  double get percentage =>
      totalQuestions == 0 ? 0 : (score / totalQuestions) * 100;
}
