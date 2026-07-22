import 'package:flutter/material.dart';
import '../firebase_service.dart';
import '../theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseService _service = FirebaseService();
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  bool _isEditing = false;

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _service.getUserProfile();
    setState(() {
      _profile = profile;
      _isLoading = false;
      if (profile != null) {
        _nameController.text = profile['fullName'] ?? '';
        _usernameController.text = profile['username'] ?? '';
        _bioController.text = profile['bio'] ?? '';
      }
    });
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      await _service.updateUserProfile({
        'fullName': _nameController.text.trim(),
        'username': _usernameController.text.trim(),
        'bio': _bioController.text.trim(),
      });
      await _loadProfile();
      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully!'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F7),
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isEditing)
            TextButton.icon(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit, color: Color(0xFFFFD700), size: 18),
              label: const Text(
                'Edit',
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() => _isEditing = false);
                    _loadProfile();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                TextButton(
                  onPressed: _saveProfile,
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF005F5F),
                          Color(0xFF008080),
                          Color(0xFF00A8A8),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Profile picture upload coming soon!',
                                      ),
                                      backgroundColor: AppTheme.primary,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFD700),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _isEditing
                            ? TextField(
                                controller: _nameController,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Full Name',
                                  hintStyle: const TextStyle(
                                    color: Colors.white54,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFFFD700),
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.1),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                ),
                              )
                            : Text(
                                _profile?['fullName'] ?? 'Student',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                        const SizedBox(height: 4),
                        _isEditing
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: TextField(
                                  controller: _usernameController,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '@username',
                                    hintStyle: const TextStyle(
                                      color: Colors.white38,
                                    ),
                                    prefixText: '@',
                                    prefixStyle: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFFFD700),
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.1),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                              )
                            : Text(
                                '@${_profile?['username'] ?? 'username'}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                        const SizedBox(height: 10),
                        _isEditing
                            ? Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: TextField(
                                  controller: _bioController,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Write something about yourself...',
                                    hintStyle: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 13,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFFFD700),
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.1),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _profile?['bio'] ?? 'No bio yet. Tap Edit to add one.',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                        if (_isEditing) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD700),
                                foregroundColor: Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Activity stats
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildActivityCard(
                          'Notes\nShared',
                          '${_profile?['uploadCount'] ?? 0}',
                          Icons.upload_file,
                          AppTheme.info,
                        ),
                        const SizedBox(width: 10),
                        _buildActivityCard(
                          'Groups\nJoined',
                          '${(_profile?['joinedGroups'] as List?)?.length ?? 0}',
                          Icons.group,
                          AppTheme.success,
                        ),
                        const SizedBox(width: 10),
                        _buildActivityCard(
                          'Downloads',
                          '0',
                          Icons.download,
                          AppTheme.warning,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Info card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.person_outline,
                            'Full Name',
                            _profile?['fullName'] ?? '-',
                            AppTheme.primary,
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            Icons.alternate_email,
                            'Username',
                            '@${_profile?['username'] ?? '-'}',
                            AppTheme.info,
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            Icons.email_outlined,
                            'Email',
                            _profile?['email'] ?? '-',
                            AppTheme.warning,
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            Icons.school_outlined,
                            'Course',
                            _profile?['course'] ?? 'Not set',
                            AppTheme.success,
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            Icons.info_outline,
                            'Bio',
                            _profile?['bio'] ?? 'No bio added yet',
                            AppTheme.purple,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildActionButton(
                          'My Uploaded Notes',
                          Icons.note_alt_outlined,
                          AppTheme.info,
                          () {},
                        ),
                        const SizedBox(height: 10),
                        _buildActionButton(
                          'My Study Groups',
                          Icons.group_outlined,
                          AppTheme.success,
                          () {},
                        ),
                        const SizedBox(height: 10),
                        _buildActionButton(
                          'Sign Out',
                          Icons.logout,
                          AppTheme.error,
                          () async {
                            await _service.signOut();
                            if (mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/',
                                (route) => false,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildActivityCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey.shade100, indent: 64);
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios,
                size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
