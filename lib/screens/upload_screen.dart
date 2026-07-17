import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/upload_service.dart';

class UploadScreen extends StatefulWidget {
  final String userId;
  final List<String> courses; // pass in the user's enrolled courses

  const UploadScreen({super.key, required this.userId, required this.courses});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _titleController = TextEditingController();
  String? _selectedCourse;
  File? _pickedFile;
  double? _progress;
  final _uploadService = UploadService();

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _pickedFile = File(result.files.single.path!));
    }
  }

  void _startUpload() {
    if (_pickedFile == null || _selectedCourse == null || _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields and pick a file')),
      );
      return;
    }

    _uploadService.uploadNote(
      file: _pickedFile!,
      courseId: _selectedCourse!,
      userId: widget.userId,
      title: _titleController.text,
      onComplete: (note) {
        setState(() => _progress = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload complete!')),
        );
        Navigator.pop(context);
      },
    ).listen((progress) {
      setState(() => _progress = progress);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Note')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCourse,
              decoration: const InputDecoration(labelText: 'Course'),
              items: widget.courses
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCourse = val),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.attach_file),
              label: Text(_pickedFile?.path.split('/').last ?? 'Choose a file'),
            ),
            const SizedBox(height: 24),
            if (_progress != null) LinearProgressIndicator(value: _progress),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _progress == null ? _startUpload : null,
              child: const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
}
