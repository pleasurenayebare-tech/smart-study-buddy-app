import 'package:flutter/material.dart';
import '../theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          _buildNotificationItem(
            'New note shared',
            'Nayebare shared "Introduction to Programming - Notes" in BCS 1101',
            AppTheme.info,
            Icons.note_add,
            true,
          ),
          _buildNotificationItem(
            'Group invitation',
            'You were invited to join "Data Structures Study Group"',
            AppTheme.success,
            Icons.group_add,
            true,
          ),
          _buildNotificationItem(
            'New message',
            'Mukobeza sent you a message',
            AppTheme.purple,
            Icons.mail,
            true,
          ),
          _buildNotificationItem(
            'Friend request',
            'Alinaitwe Queen Denise wants to connect',
            AppTheme.warning,
            Icons.person_add,
            false,
          ),
          _buildNotificationItem(
            'Course update',
            'New materials available in BCS 2105',
            AppTheme.error,
            Icons.update,
            false,
          ),
          _buildNotificationItem(
            'Study session',
            'Reminder: Study group meeting in 2 hours',
            AppTheme.info,
            Icons.schedule,
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(String title, String message, Color color,
      IconData icon, bool isUnread) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      color: isUnread ? color.withOpacity(0.08) : Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            if (isUnread)
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Text(message, maxLines: 2, overflow: TextOverflow.ellipsis),
        isThreeLine: true,
        onTap: () {},
      ),
    );
  }
}
