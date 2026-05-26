import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/media_item.dart';

class MediaCard extends StatelessWidget {
  const MediaCard({super.key, required this.item, required this.onTap});

  final MediaItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.secondaryText.withValues(alpha: 0.16),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                item.posterAssetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.movie_outlined, size: 36),
                  );
                },
              ),
              Positioned(
                top: 8,
                right: 8,
                child: _MediaTypeBadge(type: item.type),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MediaTypeBadge extends StatelessWidget {
  const _MediaTypeBadge({required this.type});

  final MediaType type;

  @override
  Widget build(BuildContext context) {
    final label = switch (type) {
      MediaType.movie => 'Movie',
      MediaType.series => 'Series',
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
