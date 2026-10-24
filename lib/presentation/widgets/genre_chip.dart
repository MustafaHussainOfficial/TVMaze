import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class GenreChip extends StatelessWidget {
  const GenreChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }
}
