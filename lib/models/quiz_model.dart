class Quiz {
  final String id;
  final String courseId;
  final String title;
  final List<QuizQuestion> questions;
  final String createdBy;

  Quiz({required this.id, required this.courseId, required this.title, required this.questions, required this.createdBy});

  factory Quiz.fromMap(String id, Map<String, dynamic> map) => Quiz(
    id: id,
    courseId: map['courseId'],
    title: map['title'],
    createdBy: map['createdBy'],
    questions: (map['questions'] as List)
        .map((q) => QuizQuestion.fromMap(q))
        .toList(),
  );
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  QuizQuestion({required this.question, required this.options, required this.correctIndex});

  factory QuizQuestion.fromMap(Map<String, dynamic> map) => QuizQuestion(
    question: map['question'],
    options: List<String>.from(map['options']),
    correctIndex: map['correctIndex'],
  );
}
