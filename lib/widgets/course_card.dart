import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final String title;
  final int chapters;
  final String duration; // e.g. "20h 0m"
  final String learners; // e.g. "1.41M+"
  final String? imageUrl; // instructor/course photo (network)
  final List<Color> gradientColors;
  final VoidCallback? onTap;

  const CourseCard({
    super.key,
    required this.title,
    required this.chapters,
    required this.duration,
    required this.learners,
    this.imageUrl,
    this.gradientColors = const [Color(0xFFD6E9FF), Color(0xFFBFDCFF)],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: gradient background + title + photo
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          imageUrl!,
                          width: 72,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 72,
                            height: 90,
                            color: Colors.white,
                            child: const Icon(Icons.person, color: Colors.grey),
                          ),
                        ),
                      ),
                    if (imageUrl != null) const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A2B3C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Stats row
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    _stat(Icons.smart_display_outlined, 'Chapters', '$chapters'),
                    _divider(),
                    _stat(Icons.access_time, 'Duration', duration),
                    _divider(),
                    _stat(Icons.people_alt_outlined, 'Learners', learners),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 36, color: Colors.grey.withOpacity(0.2));
}