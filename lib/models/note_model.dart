import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String groupId;
  final String title;
  final String content;
  final String userId;
  final DateTime? timestamp;

  NoteModel({
    required this.id,
    required this.groupId,
    required this.title,
    required this.content,
    required this.userId,
    this.timestamp,
  });

  factory NoteModel.fromMap(String id, Map<String, dynamic> map) {
    return NoteModel(
      id: id,
      groupId: map['groupId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? map['fileUrl'] ?? '', // Fallback for old data
      userId: map['userId'] ?? map['uploadedBy'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'groupId': groupId,
    'title': title,
    'content': content,
    'userId': userId,
    'timestamp': FieldValue.serverTimestamp(),
  };
}
