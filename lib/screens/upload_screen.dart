import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../firebase_service.dart';

class UploadScreen extends StatefulWidget {
  String? userId;
  String? groupId;

  const UploadScreen({super.key, this.userId, this.groupId});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _titleController = TextEditingController();
  String? _pickedFilePath;
  double? _progress;
  final _firebaseService = FirebaseService();

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _pickedFilePath = result.files.single.path!);
    }
  }

  void _startUpload() {
    if (_pickedFilePath == null || _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a title and pick a file')),
      );
      return;
    }

    _firebaseService
        .uploadNote(
          filePath: _pickedFilePath!,
          groupId: widget.groupId,
          userId: widget.userId,
          title: _titleController.text,
        )
        .listen(
      (progress) {
        setState(() => _progress = progress);
        if (progress >= 1.0) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Upload complete!')),
            );
            Navigator.pop(context);
          });
        }
      },
      onError: (_) {
        setState(() => _progress = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload failed. Please try again.')),
        );
      },
    );
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
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.attach_file),
              label: Text(_pickedFilePath?.split('/').last ?? 'Choose a file'),
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
