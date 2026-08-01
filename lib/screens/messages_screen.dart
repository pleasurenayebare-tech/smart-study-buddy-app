import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import '../firebase_service.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final FirebaseService _service = FirebaseService();
  late final String _myUid;

  @override
  void initState() {
    super.initState();
    _myUid = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream: _service.getUserConversations(_myUid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          // Group messages by conversationId, keeping only the most recent
          // message per conversation for the list preview.
          final Map<String, Map<String, dynamic>> latestByConversation = {};
          for (final doc in docs) {
            final data = doc.data();
            final convId = data['conversationId'] as String;
            if (!latestByConversation.containsKey(convId)) {
              latestByConversation[convId] = data;
            }
          }

          final conversations = latestByConversation.values.toList();

          if (conversations.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No conversations yet. Find a study partner and say hello!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: conversations.length,
            itemBuilder: (context, i) {
              final data = conversations[i];
              final participants = List<String>.from(data['participants']);
              final otherUserId =
                  participants.firstWhere((id) => id != _myUid);
              final names = Map<String, dynamic>.from(
                  data['participantNames'] ?? {});
              final otherUserName = names[otherUserId] ?? 'Student';
              final lastMessage = data['text'] ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.info,
                    child: Text(
                      otherUserName.isNotEmpty ? otherUserName[0] : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(otherUserName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          otherUserId: otherUserId,
                          otherUserName: otherUserName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
