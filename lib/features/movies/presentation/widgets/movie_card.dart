import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/movie.dart';

class MovieCard extends StatelessWidget {
  const MovieCard({super.key, required this.movie, required this.onTap});

  final Movie movie;
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
          child: Image.asset(
            movie.posterAssetPath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Icon(Icons.movie_outlined, size: 36));
            },
          ),
        ),
      ),
    );
  }
}
