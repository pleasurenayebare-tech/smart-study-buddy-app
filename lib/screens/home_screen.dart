import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import 'upload_screen.dart';
import 'discover_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final userService = UserService();

    return Scaffold(
      appBar: AppBar(title: const Text('Smart Study Buddy')),
      body: StreamBuilder(
        stream: userService.getCurrentUser(currentUserId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data!;

          return Column(
            children: [
              // ... your existing home screen content ...

              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Notes'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UploadScreen(
                        userId: user.id,
                        courses: user.enrolledCourses,
                      ),
                    ),
                  );
                },
              ),

              ElevatedButton.icon(
                icon: const Icon(Icons.people),
                label: const Text('Find Study Partners'),
                onPressed: () {
                  if (user.enrolledCourses.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add a course to your profile first')),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DiscoverScreen(
                        courseId: user.enrolledCourses.first,
                        currentUserId: user.id,
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
}import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import 'upload_screen.dart';
import 'discover_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final userService = UserService();

    return Scaffold(
      appBar: AppBar(title: const Text('Smart Study Buddy')),
      body: StreamBuilder(
        stream: userService.getCurrentUser(currentUserId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data!;

          return Column(
            children: [
              // ... your existing home screen content ...

              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Notes'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UploadScreen(
                        userId: user.id,
                        courses: user.enrolledCourses,
                      ),
                    ),
                  );
                },
              ),

              ElevatedButton.icon(
                icon: const Icon(Icons.people),
                label: const Text('Find Study Partners'),
                onPressed: () {
                  if (user.enrolledCourses.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add a course to your profile first')),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DiscoverScreen(
                        courseId: user.enrolledCourses.first,
                        currentUserId: user.id,
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
              
                    
               
       


           
