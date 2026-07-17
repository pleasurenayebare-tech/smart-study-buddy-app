Future<String> uploadNote({
  required File file,
  required String courseId,
  required String userId,
  required String title,
}) async {
  final ref = FirebaseStorage.instance
      .ref('notes/$courseId/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}');
  await ref.putFile(file);
  final url = await ref.getDownloadURL();

  await FirebaseFirestore.instance.collection('notes').add({
    'courseId': courseId,
    'uploadedBy': userId,
    'title': title,
    'fileUrl': url,
    'timestamp': FieldValue.serverTimestamp(),
  });
  return url;
}
