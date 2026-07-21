import 'package:flutter/material.dart';
import '../firebase_service.dart';
import '../theme.dart';
import 'course_selection_screen.dart';
import 'upload_screen.dart';
import 'discover_screen.dart';

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
  static bool _hasShownWelcome = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasShownWelcome && mounted) {
        _showWelcomeDialog();
        _hasShownWelcome = true;
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
      setState(() => _isLoading = false);
    }
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF005F5F), Color(0xFF008080), Color(0xFF00A8A8)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.celebration, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  'Welcome Back,\n$_welcomeName!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Ready to learn and collaborate\nwith your peers?',
                  style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Let\'s Go! 🚀',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
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
      backgroundColor: const Color(0xFFF0F7F7),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: 4,
                    child: Icon(Icons.menu_book_rounded, size: 18, color: Colors.white),
                  ),
                  Positioned(
                    top: 4,
                    child: Icon(Icons.lightbulb, size: 10, color: Color(0xFFFFD700)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Smart Study Buddy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: _showMainMenu,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
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
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, $_welcomeName! 👋',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Ready to study smart today?',
                              style: TextStyle(fontSize: 13, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _selectCourses,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.school_outlined, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            _selectedCourses.take(2).join(' • '),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.edit, color: Colors.white70, size: 14),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action buttons row — Upload Notes + Find Study Partners
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const UploadScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload_file, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Upload Notes',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const DiscoverScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD700).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, color: Colors.black87, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Find Partners',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Stats row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildStatCard('Notes Shared', '24', Icons.upload_file, AppTheme.info),
                  const SizedBox(width: 10),
                  _buildStatCard('Groups Joined', '3', Icons.group, AppTheme.success),
                  const SizedBox(width: 10),
                  _buildStatCard('Downloads', '12', Icons.download, AppTheme.warning),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Quick access section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Quick Access',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.3,
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

            const SizedBox(height: 24),

            // Recent Notes section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Notes & Past Papers',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  TextButton(
                    onPressed: _showNotesBottomSheet,
                    child: const Text(
                      'See all',
                      style: TextStyle(color: AppTheme.primary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
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
                  NoteCard(
                    title: 'Operating Systems Past Paper 2022',
                    course: 'BCS 3201',
                    uploadedBy: 'Kimara Cyrus Kilibo',
                    type: 'Past Paper',
                  ),
                  NoteCard(
                    title: 'Software Engineering - Notes',
                    course: 'BCS 3102',
                    uploadedBy: 'Nayebare Pleasure',
                    type: 'Notes',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
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

  Widget _buildQuickAccessCard(String title, IconData icon, Color color) {
    return InkWell(
      onTap: () => _navigateToCard(title),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCard(String title) {
    switch (title) {
      case 'Notes':
        _showNotesBottomSheet();
        break;
      case 'Past Papers':
        _showPastPapersBottomSheet();
        break;
      case 'Groups':
        // Navigate to groups tab via bottom nav
        break;
      case 'Messages':
        // Navigate to messages tab via bottom nav
        break;
      case 'Notifications':
        // Navigate to notifications tab via bottom nav
        break;
      case 'Invite Friends':
        _showInviteFriendsDialog();
        break;
    }
  }

  void _showNotesBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, controller) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.note_alt, color: AppTheme.info),
                  SizedBox(width: 8),
                  Text(
                    'All Notes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  NoteCard(title: 'Introduction to Programming - Notes', course: 'BCS 1101', uploadedBy: 'Nayebare Pleasure', type: 'Notes'),
                  NoteCard(title: 'Database Systems - Lecture 4', course: 'BCS 2105', uploadedBy: 'Alinaitwe Queen Denise', type: 'Notes'),
                  NoteCard(title: 'Software Engineering - Notes', course: 'BCS 3102', uploadedBy: 'Nayebare Pleasure', type: 'Notes'),
                  NoteCard(title: 'Computer Networks - Lecture 3', course: 'BCS 2103', uploadedBy: 'Mukobeza Nambi Anna', type: 'Notes'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPastPapersBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, controller) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.assignment, color: AppTheme.warning),
                  SizedBox(width: 8),
                  Text(
                    'Past Papers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  NoteCard(title: 'Data Structures Past Paper 2023', course: 'BCS 2203', uploadedBy: 'Mukobeza Nambi Anna', type: 'Past Paper'),
                  NoteCard(title: 'Operating Systems Past Paper 2022', course: 'BCS 3201', uploadedBy: 'Kimara Cyrus Kilibo', type: 'Past Paper'),
                  NoteCard(title: 'Database Systems Past Paper 2023', course: 'BCS 2105', uploadedBy: 'Alinaitwe Queen Denise', type: 'Past Paper'),
                  NoteCard(title: 'Software Engineering Past Paper 2022', course: 'BCS 3102', uploadedBy: 'Nayebare Pleasure', type: 'Past Paper'),
                ],
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
      MaterialPageRoute(builder: (context) => const CourseSelectionScreen()),
    );
    if (result != null) {
      setState(() => _selectedCourses = result);
    }
  }

  void _showMainMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
            _buildMenuOption('Notes', Icons.note_alt, AppTheme.info, () {
              Navigator.pop(context);
              _showNotesBottomSheet();
            }),
            _buildMenuOption('Past Papers', Icons.assignment, AppTheme.warning, () {
              Navigator.pop(context);
              _showPastPapersBottomSheet();
            }),
            _buildMenuOption('Upload Resource', Icons.upload_file, AppTheme.success, () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadScreen()));
            }),
            _buildMenuOption('Find Study Partners', Icons.people_outline, AppTheme.info, () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DiscoverScreen()));
            }),
            _buildMenuOption('Invite Friends', Icons.person_add, AppTheme.orange, () {
              Navigator.pop(context);
              _showInviteFriendsDialog();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(String title, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.15),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showInviteFriendsDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppTheme.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.share, size: 32, color: AppTheme.success),
              ),
              const SizedBox(height: 16),
              const Text(
                'Invite Your Friends',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Share Smart Study Buddy with friends and study together!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.successLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.success.withOpacity(0.4)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SSB2024X7K9Q',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 2,
                        color: AppTheme.success,
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
    final typeColor = type == 'Notes' ? AppTheme.info : AppTheme.warning;
    final typeLightColor = type == 'Notes' ? AppTheme.infoLight : AppTheme.warningLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: typeLightColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                type == 'Past Paper' ? Icons.assignment : Icons.note_alt_outlined,
                color: typeColor,
                size: 26,
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
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Color(0xFF1A1A2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      course,
                      style: TextStyle(
                        color: typeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'by $uploadedBy',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.download_outlined, color: typeColor, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
