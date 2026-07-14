import 'package:flutter/material.dart';
import '../firebase_service.dart';
import '../theme.dart';
import 'course_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _service = FirebaseService();
  String _welcomeName = 'Student';
  bool _isLoading = true;
  List<String> _selectedCourses = ['BCS 1101', 'BCS 2105'];
  bool _welcomeShown = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_welcomeShown && mounted) {
        _showWelcomeDialog();
        _welcomeShown = true;
      }
    });
  }

  Future<void> _loadProfile() async {
    final profile = await _service.getUserProfile();
    if (profile != null) {
      setState(() {
        _welcomeName = profile['fullName'] ?? profile['username'] ?? 'Student';
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.7)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.celebration,
                  size: 60,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome Back, $_welcomeName!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ready to learn and collaborate with your peers?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Smart Study Buddy'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: _showMainMenu,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course selection bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.info, AppTheme.accent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Courses',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedCourses.join(', '),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _selectCourses,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.info,
                    ),
                  ),
                ],
              ),
            ),
            // Welcome section
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $_welcomeName!',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Here\'s what\'s new in your courses',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            // Quick access menu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildQuickAccessCard('Notes', Icons.note_alt, AppTheme.info),
                  _buildQuickAccessCard('Past Papers', Icons.assignment, AppTheme.warning),
                  _buildQuickAccessCard('Groups', Icons.group, AppTheme.success),
                  _buildQuickAccessCard('Messages', Icons.mail, AppTheme.purple),
                  _buildQuickAccessCard('Notifications', Icons.notifications, AppTheme.error),
                  _buildQuickAccessCard('Invite Friends', Icons.person_add, AppTheme.orange),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Recent Notes section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'Recent Notes & Past Papers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  NoteCard(
                    title: 'Introduction to Programming - Notes',
                    course: 'BCS 1101',
                    uploadedBy: 'Nayebare Pleasure',
                    type: 'Notes',
                  ),
                  NoteCard(
                    title: 'Data Structures Past Paper 2023',
                    course: 'BCS 2203',
                    uploadedBy: 'Mukobeza Nambi Anna',
                    type: 'Past Paper',
                  ),
                  NoteCard(
                    title: 'Database Systems - Lecture 4',
                    course: 'BCS 2105',
                    uploadedBy: 'Alinaitwe Queen Denise',
                    type: 'Notes',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppTheme.success,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload'),
      ),
    );
  }

  Widget _buildQuickAccessCard(String title, IconData icon, Color color) {
    return InkWell(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectCourses() async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (context) => const CourseSelectionScreen(),
      ),
    );
    if (result != null) {
      setState(() {
        _selectedCourses = result;
      });
    }
  }

  void _showMainMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _buildMenuOption(
              'Notes',
              Icons.note_alt,
              AppTheme.info,
              () => Navigator.pop(context),
            ),
            _buildMenuOption(
              'Past Papers',
              Icons.assignment,
              AppTheme.warning,
              () => Navigator.pop(context),
            ),
            _buildMenuOption(
              'Study Groups',
              Icons.group,
              AppTheme.success,
              () => Navigator.pop(context),
            ),
            _buildMenuOption(
              'In-App Messages',
              Icons.mail,
              AppTheme.purple,
              () => Navigator.pop(context),
            ),
            _buildMenuOption(
              'Notifications',
              Icons.notifications,
              AppTheme.error,
              () => Navigator.pop(context),
            ),
            _buildMenuOption(
              'Profile / Account',
              Icons.person,
              AppTheme.primary,
              () => Navigator.pop(context),
            ),
            _buildMenuOption(
              'Invite Friends',
              Icons.person_add,
              AppTheme.orange,
              _showInviteFriendsDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showInviteFriendsDialog() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.share,
                size: 48,
                color: AppTheme.success,
              ),
              const SizedBox(height: 16),
              const Text(
                'Invite Your Friends',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Share your referral code with friends and earn rewards!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.successLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.success),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SSB2024X7K9Q',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 2,
                      ),
                    ),
                    Icon(Icons.copy, color: AppTheme.success),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                      ),
                      child: const Text('Share'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  final String title;
  final String course;
  final String uploadedBy;
  final String type;

  const NoteCard({
    super.key,
    required this.title,
    required this.course,
    required this.uploadedBy,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = AppColors.getColorByType(type);
    final typeLightColor = type == 'Notes' ? AppTheme.infoLight : AppTheme.warningLight;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: typeLightColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                type == 'Past Paper' ? Icons.assignment : Icons.note_alt_outlined,
                color: typeColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course,
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'by $uploadedBy',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.download_outlined, color: typeColor),
          ],
        ),
      ),
    );
  }
}
