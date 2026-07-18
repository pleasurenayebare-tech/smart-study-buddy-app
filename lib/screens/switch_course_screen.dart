import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase_service.dart';

class SwitchCourseScreen extends StatefulWidget {
  const SwitchCourseScreen({super.key});

  @override
  State<SwitchCourseScreen> createState() => _SwitchCourseScreenState();
}

class _SwitchCourseScreenState extends State<SwitchCourseScreen> {
  final _firebaseService = FirebaseService();
  String? _selectedCourse;
  bool _isLoading = false;

  final List<String> _courses = [
    'BSc Computer Science',
    'BSc Software Engineering',
    'BSc Information Technology',
    'BSc Information Systems',
  ];

  Future<void> _switchCourse() async {
    if (_selectedCourse == null) return;
    setState(() => _isLoading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    await _firebaseService.switchCourse(uid: uid, newCourse: _selectedCourse!);

    setState(() => _isLoading = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Switched to $_selectedCourse and assigned a new group!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Switch Course')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Select your new course:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCourse,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: _courses.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _selectedCourse = val),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _switchCourse,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Confirm Switch'),
            ),
          ],
        ),
      ),
    );
  }
}
