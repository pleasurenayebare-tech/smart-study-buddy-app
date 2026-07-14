import 'package:flutter/material.dart';
import '../theme.dart';
import '../firebase_service.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final FirebaseService _service = FirebaseService();
  String _userName = 'Student';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final profile = await _service.getUserProfile();
    if (profile != null && mounted) {
      setState(() {
        _userName = profile['fullName'] ?? profile['username'] ?? 'Student';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.background,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search conversations',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          // Messages list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                _buildMessageConversation(
                  'Nayebare Pleasure',
                  'Hey, did you understand the last lecture?',
                  '2 min ago',
                  AppTheme.info,
                  Icons.person,
                ),
                _buildMessageConversation(
                  'BCS 1101 Study Group',
                  'Let\'s schedule a study session',
                  '1 hour ago',
                  AppTheme.success,
                  Icons.group,
                ),
                _buildMessageConversation(
                  'Mukobeza Nambi Anna',
                  'Can I share the past papers with you?',
                  '3 hours ago',
                  AppTheme.purple,
                  Icons.person,
                ),
                _buildMessageConversation(
                  'Class Discussion',
                  'New message from 5 members',
                  '1 day ago',
                  AppTheme.warning,
                  Icons.people,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNewMessageDialog(context);
        },
        backgroundColor: AppTheme.success,
        foregroundColor: Colors.white,
        child: const Icon(Icons.message),
      ),
    );
  }

  Widget _buildMessageConversation(String name, String lastMessage, String time,
      Color color, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        onTap: () {},
      ),
    );
  }

  void _showNewMessageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Start a New Conversation'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.info,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  title: const Text('Direct Message'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.success,
                    child: const Icon(Icons.group, color: Colors.white),
                  ),
                  title: const Text('Start Group Chat'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
