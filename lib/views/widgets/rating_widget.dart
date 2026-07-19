import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class RatingWidget extends StatelessWidget {
  const RatingWidget({super.key, required this.rating, this.reviewCount});

  final double rating;
  final int? reviewCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, color: AppColors.gold, size: 18),
        const SizedBox(width: 4),
        Text(rating.toStringAsFixed(1)),
        if (reviewCount != null) ...[
          const SizedBox(width: 4),
          Text('($reviewCount)', style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
  }
}
