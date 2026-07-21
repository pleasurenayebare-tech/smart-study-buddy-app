import 'package:flutter/material.dart';
import '../firebase_service.dart';

class DiscoverScreen extends StatelessWidget {
  final String currentUserId;
  final String course;

  const DiscoverScreen({
    super.key,
    required this.currentUserId,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();

    return Scaffold(
      appBar: AppBar(title: const Text('Find Study Partners')),
      body: StreamBuilder(
        stream: firebaseService.discoverUsersByCourse(course, currentUserId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs
              .where((d) => d.id != currentUserId)
              .toList();

          if (docs.isEmpty) {
            return const Center(child: Text('No one else in this course yet'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data();
              final name = data['fullName'] ?? 'Student';
              final username = data['username'] ?? '';

              return ListTile(
                leading: CircleAvatar(
                  child: Text(name.isNotEmpty ? name[0] : '?'),
                ),
                title: Text(name),
                subtitle: Text('@$username'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // navigate to their profile later
                },
              );
            },
          );
        },
      ),
    );
  }
}
