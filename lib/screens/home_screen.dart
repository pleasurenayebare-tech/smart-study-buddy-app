import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase_service.dart';
import 'upload_screen.dart';
import 'discover_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final firebaseService = FirebaseService();

    return Scaffold(
      appBar: AppBar(title: const Text('Smart Study Buddy')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: firebaseService.getUserProfile(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = snapshot.data!;
          final course = profile['course'] as String?;
          final joinedGroups = List<String>.from(profile['joinedGroups'] ?? []);

          return Column(
            children: [
              // ... your existing home screen content ...

              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Notes'),
                onPressed: () {
                  if (joinedGroups.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Join a study group first')),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UploadScreen(
                        userId: currentUserId,
                        groupId: joinedGroups.first,
                      ),
                    ),
                  );
                },
              ),

              ElevatedButton.icon(
                icon: const Icon(Icons.people),
                label: const Text('Find Study Partners'),
                onPressed: () {
                  if (course == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Set your course in your profile first')),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DiscoverScreen(
                        currentUserId: currentUserId,
                        course: course,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
