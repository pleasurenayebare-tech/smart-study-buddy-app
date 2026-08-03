import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../firebase_service.dart';
import '../theme.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> currentProfile;

  const EditProfileScreen({super.key, required this.currentProfile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _service = FirebaseService();
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentProfile['fullName'] ?? '');
    _usernameController = TextEditingController(text: widget.currentProfile['username'] ?? '');
    _bioController = TextEditingController(text: widget.currentProfile['bio'] ?? '');
    _photoUrl = widget.currentProfile['photoUrl'];
  }

  Future<void> _pickAndUploadPhoto() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result == null || result.files.single.bytes == null) return;

    setState(() => _isUploadingPhoto = true);
    try {
      final bytes = result.files.single.bytes!;
      final fileName = result.files.single.name;

      final url = await _service.uploadProfilePicture(bytes, fileName);
      setState(() => _photoUrl = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload photo: $e'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await _service.updateUserProfile({
        'fullName': _nameController.text.trim(),
        'username': _usernameController.text.trim().toLowerCase(),
        'bio': _bioController.text.trim(),
        if (_photoUrl != null) 'photoUrl': _photoUrl,
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F7),
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    image: _photoUrl != null
                        ? DecorationImage(image: NetworkImage(_photoUrl!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _isUploadingPhoto
                      ? const Center(child: CircularProgressIndicator())
                      : (_photoUrl == null
                          ? Icon(Icons.person, size: 50, color: AppTheme.primary)
                          : null),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _isUploadingPhoto ? null : _pickAndUploadPhoto,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(color: Color(0xFFFFD700), shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, size: 16, color: Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username', prefixText: '@', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bioController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Bio', border: OutlineInputBorder()),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}
