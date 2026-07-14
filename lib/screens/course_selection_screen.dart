import 'package:flutter/material.dart';
import '../theme.dart';

class CourseSelectionScreen extends StatefulWidget {
  const CourseSelectionScreen({super.key});

  @override
  State<CourseSelectionScreen> createState() => _CourseSelectionScreenState();
}

class _CourseSelectionScreenState extends State<CourseSelectionScreen> {
  final List<Map<String, dynamic>> courses = [
    {
      'code': 'BCS 1101',
      'title': 'Introduction to Programming',
      'color': AppTheme.info,
      'members': 45,
      'isSelected': false,
    },
    {
      'code': 'BCS 1102',
      'title': 'Discrete Mathematics',
      'color': AppTheme.success,
      'members': 38,
      'isSelected': true,
    },
    {
      'code': 'BCS 2203',
      'title': 'Data Structures & Algorithms',
      'color': AppTheme.warning,
      'members': 42,
      'isSelected': false,
    },
    {
      'code': 'BCS 2105',
      'title': 'Database Systems',
      'color': AppTheme.error,
      'members': 35,
      'isSelected': true,
    },
    {
      'code': 'BCS 3102',
      'title': 'Software Engineering',
      'color': AppTheme.purple,
      'members': 28,
      'isSelected': false,
    },
    {
      'code': 'BCS 3201',
      'title': 'Operating Systems',
      'color': AppTheme.orange,
      'members': 32,
      'isSelected': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Courses'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryLightBg,
            child: const Text(
              'Choose the courses you are taking to get personalized content and connect with classmates.',
              style: TextStyle(fontSize: 14, color: Color(0xFF1F4E79)),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: CheckboxListTile(
                    title: Text(
                      course['code'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(course['title']),
                    secondary: CircleAvatar(
                      backgroundColor: course['color'],
                      child: Text(
                        '${course['members']}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    value: course['isSelected'],
                    onChanged: (value) {
                      setState(() {
                        courses[index]['isSelected'] = value ?? false;
                      });
                    },
                    activeColor: course['color'],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final selectedCourses = courses
                          .where((c) => c['isSelected'] == true)
                          .map((c) => c['code'])
                          .toList();
                      Navigator.pop(context, selectedCourses);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                    ),
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
