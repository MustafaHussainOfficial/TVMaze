import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.rating, this.compact = false});

  final double rating;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 8, vertical: compact ? 2 : 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: AppColors.rating, size: compact ? 12 : 16),
          const SizedBox(width: 2),
          Text(
            compact ? rating.toStringAsFixed(1) : '${rating.toStringAsFixed(1)}/10',
            style: TextStyle(fontSize: compact ? 11 : 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
