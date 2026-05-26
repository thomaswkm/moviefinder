import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/media_item.dart';

class FeaturedMediaCard extends StatelessWidget {
  const FeaturedMediaCard({
    super.key,
    required this.item,
    required this.scale,
    required this.onTap,
  });

  final MediaItem item;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.secondaryText.withValues(alpha: 0.18),
            ),
            child: Image.asset(
              item.posterAssetPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.movie_outlined, size: 48),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
