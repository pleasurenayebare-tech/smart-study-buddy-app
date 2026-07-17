class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final List<String> enrolledCourses;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.enrolledCourses = const [],
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      enrolledCourses: List<String>.from(map['enrolledCourses'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'enrolledCourses': enrolledCourses,
    };
  }
}
