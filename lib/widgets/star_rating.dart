import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double average;
  final int count;
  final ValueChanged<int>? onRate; // pass null for read-only display

  const StarRating({
    super.key,
    required this.average,
    required this.count,
    this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 1; i <= 5; i++)
          GestureDetector(
            onTap: onRate == null ? null : () => onRate!(i),
            child: Icon(
              i <= average.round() ? Icons.star : Icons.star_border,
              size: 16,
              color: Colors.amber,
            ),
          ),
        const SizedBox(width: 4),
        Text(
          '($count)',
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }
}