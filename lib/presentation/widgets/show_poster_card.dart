import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/show.dart';
import 'app_network_image.dart';
import 'rating_badge.dart';

class ShowPosterCard extends StatelessWidget {
  const ShowPosterCard({super.key, required this.show, required this.onTap, this.width});

  final Show show;
  final VoidCallback onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AppNetworkImage(
                      url: show.posterUrl,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  if (show.rating != null)
                    Positioned(top: 6, right: 6, child: RatingBadge(rating: show.rating!, compact: true)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              show.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              show.genresLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
