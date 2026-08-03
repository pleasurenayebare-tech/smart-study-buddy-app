import 'package:flutter/material.dart';
import '../firebase_service.dart';
import '../theme.dart';

class UploadScreen extends StatefulWidget {
  final String userId;
  final String groupId;

  const UploadScreen({
    super.key,
    required this.userId,
    required this.groupId,
  });

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  bool _isLoading = false;
  final _firebaseService = FirebaseService();

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    final subject = _subjectController.text.trim();

    if (title.isEmpty || subject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a title and subject.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _firebaseService.saveNote(
        groupId: widget.groupId,
        userId: widget.userId,
        title: title,
        subject: subject,
        noteFile: null,
      );

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note shared with your study group!'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Share Note or Link'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Share with your group',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You can share study tips, raw notes, or a link to a file on Google Drive/OneDrive.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            
            const Text(
              'Title',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'e.g., Introduction to Algorithms - Week 1',
                prefixIcon: const Icon(Icons.title, color: AppTheme.primary),
              ),
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Subject',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _subjectController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Paste your notes here, or a link to your PDF...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 40),
            
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Share Note',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    super.dispose();
  }
}
