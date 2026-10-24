import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
    this.placeholderIcon = Icons.movie_outlined,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: width,
        height: height,
        child: url == null
            ? _placeholder()
            : Image.network(
                url!,
                fit: fit,
                width: width,
                height: height,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : _placeholder(loading: true),
                errorBuilder: (_, _, _) => _placeholder(),
              ),
      ),
    );
  }

  Widget _placeholder({bool loading = false}) {
    return Container(
      color: AppColors.surfaceLight,
      alignment: Alignment.center,
      child: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(placeholderIcon, color: AppColors.textSecondary),
    );
  }
}
