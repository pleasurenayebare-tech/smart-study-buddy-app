import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';

class UploadService {
  final _storage = FirebaseStorage.instance;
  final _firestore = FirebaseFirestore.instance;

  // Returns a stream of upload progress (0.0 to 1.0)
  Stream<double> uploadNote({
    required File file,
    required String courseId,
    required String userId,
    required String title,
    required Function(NoteModel) onComplete,
  }) {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final ref = _storage.ref('notes/$courseId/$fileName');
    final uploadTask = ref.putFile(file);

    // Listen for completion separately
    uploadTask.then((snapshot) async {
      final url = await snapshot.ref.getDownloadURL();
      final docRef = await _firestore.collection('notes').add({
        'courseId': courseId,
        'uploadedBy': userId,
        'title': title,
        'fileUrl': url,
        'timestamp': FieldValue.serverTimestamp(),
      });
      final doc = await docRef.get();
      onComplete(NoteModel.fromMap(doc.id, doc.data()!));
    });

    // Progress stream for the UI
    return uploadTask.snapshotEvents.map(
      (event) => event.bytesTransferred / event.totalBytes,
    );
  }

  Stream<List<NoteModel>> getNotesForCourse(String courseId) {
    return _firestore
        .collection('notes')
        .where('courseId', isEqualTo: courseId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => NoteModel.fromMap(d.id, d.data())).toList());
  }
}
