class Course {
  final String title;
  final int chapters;
  final String duration;
  final String learners;
  final String? imageUrl;

  const Course({
    required this.title,
    required this.chapters,
    required this.duration,
    required this.learners,
    this.imageUrl,
  });
}

final List<Course> demoCourses = [
  Course(title: 'Data Structures', chapters: 12, duration: '18h 30m', learners: '340'),
  Course(title: 'Theory of Computation', chapters: 16, duration: '20h 0m', learners: '1.41M+'),
  Course(title: 'Mobile App Development', chapters: 10, duration: '14h 15m', learners: '210'),
];