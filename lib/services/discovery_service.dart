import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class DiscoveryService {
  final _firestore = FirebaseFirestore.instance;

  Stream<List<UserModel>> discoverUsersByCourse(String courseId, String currentUserId) {
    return _firestore
        .collection('users')
        .where('enrolledCourses', arrayContains: courseId)
        .snapshots()
        .map((snap) => snap.docs
            .where((d) => d.id != currentUserId) // exclude yourself
            .map((d) => UserModel.fromMap(d.id, d.data()))
            .toList());
  }
}
