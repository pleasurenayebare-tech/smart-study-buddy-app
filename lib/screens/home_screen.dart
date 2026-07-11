import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Study Buddy'),
        backgroundColor: const Color(0xFF1F4E79),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Notes & Past Papers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F4E79),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF1F4E79),
        foregroundColor: Colors.white,
        child: const Icon(Icons.upload_file),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: type == 'Past Paper'
                    ? const Color(0xFFE8F4FD)
                    : const Color(0xFFE6F4EA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                type == 'Past Paper'
                    ? Icons.assignment
                    : Icons.note_alt_outlined,
                color: type == 'Past Paper'
                    ? const Color(0xFF1F4E79)
                    : const Color(0xFF1E7E34),
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
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course,
                    style: const TextStyle(
                      color: Color(0xFF1F4E79),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Uploaded by $uploadedBy',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.download_outlined, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
