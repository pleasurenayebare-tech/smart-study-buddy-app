import 'package:flutter/material.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final List<Map<String, dynamic>> _groups = [
    {
      'name': 'Introduction to Programming',
      'course': 'BCS 1101',
      'members': 12,
      'joined': false,
    },
    {
      'name': 'Data Structures & Algorithms',
      'course': 'BCS 2203',
      'members': 8,
      'joined': false,
    },
    {
      'name': 'Database Systems Study Group',
      'course': 'BCS 2105',
      'members': 15,
      'joined': true,
    },
    {
      'name': 'Operating Systems',
      'course': 'BCS 3201',
      'members': 6,
      'joined': false,
    },
    {
      'name': 'Software Engineering',
      'course': 'BCS 3102',
      'members': 10,
      'joined': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Groups'),
        backgroundColor: const Color(0xFF1F4E79),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Find a group for your course',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F4E79),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _groups.length,
                itemBuilder: (context, index) {
                  final group = _groups[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F4FD),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.group,
                              color: Color(0xFF1F4E79),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  group['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  group['course'],
                                  style: const TextStyle(
                                    color: Color(0xFF1F4E79),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${group['members']} members',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _groups[index]['joined'] =
                                    !_groups[index]['joined'];
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: group['joined']
                                  ? Colors.grey[200]
                                  : const Color(0xFF1F4E79),
                              foregroundColor: group['joined']
                                  ? Colors.grey[700]
                                  : Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Text(
                              group['joined'] ? 'Joined' : 'Join',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF1F4E79),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
