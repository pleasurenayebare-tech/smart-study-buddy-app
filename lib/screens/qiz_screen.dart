import 'package:flutter/material.dart';
import '../firebase_service.dart';
import '../models/quiz_model.dart';
import '../theme.dart';

class QuizScreen extends StatefulWidget {
  final Quiz quiz;
  final String userId;

  const QuizScreen({super.key, required this.quiz, required this.userId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _firebaseService = FirebaseService();
  int _currentQuestion = 0;
  int _score = 0;
  int? _selectedOption;
  bool _finished = false;
  bool _saving = false;

  void _selectOption(int index) {
    setState(() => _selectedOption = index);
  }

  void _nextQuestion() {
    final question = widget.quiz.questions[_currentQuestion];
    if (_selectedOption == question.correctIndex) {
      _score++;
    }

    if (_currentQuestion < widget.quiz.questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedOption = null;
      });
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    setState(() {
      _finished = true;
      _saving = true;
    });

    await _firebaseService.saveQuizProgress(
      userId: widget.userId,
      quizId: widget.quiz.id,
      score: _score,
      totalQuestions: widget.quiz.questions.length,
    );

    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return Scaffold(
        backgroundColor: const Color(0xFFF0F7F7),
        appBar: AppBar(
          title: const Text('Results'),
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, size: 60, color: Colors.amber),
              const SizedBox(height: 16),
              Text(
                'You scored $_score / ${widget.quiz.questions.length}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              if (_saving) const CircularProgressIndicator(),
              if (!_saving)
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
            ],
          ),
        ),
      );
    }

    final question = widget.quiz.questions[_currentQuestion];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F7),
      appBar: AppBar(
        title: Text('Question ${_currentQuestion + 1}/${widget.quiz.questions.length}'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.question,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            ...List.generate(question.options.length, (index) {
              final isSelected = _selectedOption == index;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => _selectOption(index),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary.withOpacity(0.1) : Colors.white,
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(question.options[index]),
                  ),
                ),
              );
            }),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _selectedOption == null ? null : _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  _currentQuestion < widget.quiz.questions.length - 1 ? 'Next' : 'Finish',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
