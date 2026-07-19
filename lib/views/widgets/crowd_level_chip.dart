import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class CrowdLevelChip extends StatelessWidget {
  const CrowdLevelChip({super.key, required this.level});

  final String level;

  @override
  Widget build(BuildContext context) {
    final normalizedLevel = level.toLowerCase();
    final color = switch (normalizedLevel) {
      'low' => AppColors.success,
      'medium' => AppColors.warning,
      'high' => AppColors.festiveOrange,
      _ => AppColors.danger,
    };

    return Chip(
      visualDensity: VisualDensity.compact,
      label: Text(normalizedLevel),
      labelStyle: const TextStyle(color: AppColors.white),
      backgroundColor: color,
      side: BorderSide.none,
    );
  }
}
