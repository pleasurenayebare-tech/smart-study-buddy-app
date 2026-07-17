class NoteModel {
  final String id;
  final String courseId;
  final String title;
  final String fileUrl;
  final String uploadedBy;
  final DateTime? timestamp;

  NoteModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.fileUrl,
    required this.uploadedBy,
    this.timestamp,
  });

  factory NoteModel.fromMap(String id, Map<String, dynamic> map) {
    return NoteModel(
      id: id,
      courseId: map['courseId'] ?? '',
      title: map['title'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      uploadedBy: map['uploadedBy'] ?? '',
      timestamp: map['timestamp']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'courseId': courseId,
    'title': title,
    'fileUrl': fileUrl,
    'uploadedBy': uploadedBy,
    'timestamp': FieldValue.serverTimestamp(),
  };
}
