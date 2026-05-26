import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/movie_finder_logo.dart';

class AuthBackgroundMark extends StatelessWidget {
  const AuthBackgroundMark({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IgnorePointer(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 350),
        opacity: 1,
        child: MovieFinderLogo(
          size: size,
          color: isDark ? AppColors.darkPrimary : AppColors.primary,
          opacity: isDark ? 0.65 : 0.24,
        ),
      ),
    );
  }
}
