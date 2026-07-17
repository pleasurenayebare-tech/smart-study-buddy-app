import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final _firestore = FirebaseFirestore.instance;

  Stream<UserModel> getCurrentUser(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => UserModel.fromMap(doc.id, doc.data() ?? {}));
  }
}
