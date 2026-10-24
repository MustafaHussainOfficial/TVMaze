import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 8, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text('See All', style: TextStyle(color: AppColors.primaryLight)),
            ),
        ],
      ),
    );
  }
}
