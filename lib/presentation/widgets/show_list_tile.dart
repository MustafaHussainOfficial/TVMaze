import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/show.dart';
import 'app_network_image.dart';

class ShowListTile extends StatelessWidget {
  const ShowListTile({super.key, required this.show, required this.onTap, this.trailing});

  final Show show;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            AppNetworkImage(
              url: show.posterUrl,
              width: 60,
              height: 84,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    show.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(show.yearRange,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(
                    show.genresLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  if (show.rating != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: AppColors.rating),
                        const SizedBox(width: 3),
                        Text(show.rating!.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
