import 'package:flutter/material.dart';
import '../services/discovery_service.dart';

class DiscoverScreen extends StatelessWidget {
  final String courseId;
  final String currentUserId;

  const DiscoverScreen({super.key, required this.courseId, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final service = DiscoveryService();
    return Scaffold(
      appBar: AppBar(title: const Text('Find Study Partners')),
      body: StreamBuilder(
        stream: service.discoverUsersByCourse(courseId, currentUserId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final users = snapshot.data!;
          if (users.isEmpty) return const Center(child: Text('No one else in this course yet'));
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, i) {
              final user = users[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                  child: user.photoUrl == null ? Text(user.name[0]) : null,
                ),
                title: Text(user.name),
                subtitle: Text('${user.enrolledCourses.length} courses in common'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // navigate to their profile
                },
              );
            },
          );
        },
      ),
    );
  }
}
