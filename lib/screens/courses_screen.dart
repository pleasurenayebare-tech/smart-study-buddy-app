import 'package:flutter/material.dart';
import '../models/course.dart';
import '../widgets/course_card.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Courses')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: demoCourses.length,
        itemBuilder: (context, i) {
          final course = demoCourses[i];
          return CourseCard(
            title: course.title,
            chapters: course.chapters,
            duration: course.duration,
            learners: course.learners,
            imageUrl: course.imageUrl,
          );
        },
      ),
    );
  }
}