import 'package:flutter/material.dart';
import '../firebase_service.dart';
import '../theme.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final _firebaseService = FirebaseService();

  static const int _notesGoal = 5;
  static const int _groupsGoal = 3;

  @override
  void initState() {
    super.initState();
    _firebaseService.markActiveNow();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F7),
      appBar: AppBar(
        title: const Text('My Progress'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _firebaseService.getUserProfile(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = snapshot.data!;
          final uploadCount = profile['uploadCount'] ?? 0;
          final joinedGroups = List<String>.from(profile['joinedGroups'] ?? []);
          final groupCount = joinedGroups.length;
          final course = profile['course'] as String?;
          final bio = profile['bio'] as String?;
          final photoUrl = profile['photoUrl'] as String?;

          final notesProgress = (uploadCount / _notesGoal).clamp(0.0, 1.0);
          final groupsProgress = (groupCount / _groupsGoal).clamp(0.0, 1.0);

          int completedFields = 0;
          if (course != null && course.isNotEmpty) completedFields++;
          if (bio != null && bio.isNotEmpty && bio != 'Student focused on collaborative learning.') completedFields++;
          if (photoUrl != null) completedFields++;
          completedFields++;
          final profileProgress = completedFields / 4;

          final overallPercent =
              ((notesProgress + groupsProgress + profileProgress) / 3 * 100).round();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Overall Progress',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 140,
                              height: 140,
                              child: CircularProgressIndicator(
                                value: overallPercent / 100,
                                strokeWidth: 12,
                                backgroundColor: AppTheme.primary.withOpacity(0.1),
                                valueColor: AlwaysStoppedAnimation(AppTheme.primary),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$overallPercent%',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const Text('complete', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Breakdown', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 12),

                _progressCard(
                  title: 'Notes Shared',
                  current: uploadCount,
                  goal: _notesGoal,
                  progress: notesProgress,
                  icon: Icons.description,
                  color: AppTheme.info,
                ),
                const SizedBox(height: 12),

                _progressCard(
                  title: 'Study Groups Joined',
                  current: groupCount,
                  goal: _groupsGoal,
                  progress: groupsProgress,
                  icon: Icons.group,
                  color: AppTheme.success,
                ),
                const SizedBox(height: 12),

                _progressCard(
                  title: 'Profile Completeness',
                  current: completedFields,
                  goal: 4,
                  progress: profileProgress,
                  icon: Icons.person_outline,
                  color: AppTheme.warning,
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.emoji_events_outlined, color: AppTheme.warning, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(_encouragementMessage(overallPercent), style: const TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _encouragementMessage(int percent) {
    if (percent < 30) {
      return 'Just getting started — complete your profile and join a group to boost your progress!';
    } else if (percent < 70) {
      return 'Good progress — keep sharing notes and staying active in your groups.';
    } else {
      return 'Excellent! You\'re making the most of Smart Study Buddy.';
    }
  }

  Widget _progressCard({
    required String title,
    required int current,
    required int goal,
    required double progress,
    required IconData icon,
    required Color color,
  }) {
    final percent = (progress * 100).round();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
              Text('$percent%', style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 6),
          Text('$current of $goal', style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}
