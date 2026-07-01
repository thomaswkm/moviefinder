import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class MainBottomNavigation extends StatelessWidget {
  const MainBottomNavigation({
    super.key,
    required this.onHomePressed,
    required this.onSearchPressed,
    required this.onWishlistPressed,
    required this.onProfilePressed,
  });

  final VoidCallback onHomePressed;
  final VoidCallback onSearchPressed;
  final VoidCallback onWishlistPressed;
  final VoidCallback onProfilePressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1F1D1D) : Colors.white;
    final inactiveColor = isDark ? const Color(0xFFB9B9B9) : Colors.grey;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(38),
        border: Border.all(
          color: isDark ? backgroundColor : Colors.black,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SizedBox(
        height: 74,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              key: const Key('home_nav_button'),
              onPressed: onHomePressed,
              icon: const Icon(Icons.home_outlined),
              color: AppColors.primary,
              iconSize: 34,
            ),
            IconButton(
              onPressed: onSearchPressed,
              icon: const Icon(Icons.search),
              color: inactiveColor,
              iconSize: 32,
            ),
            IconButton(
              onPressed: onWishlistPressed,
              icon: const Icon(Icons.favorite_border),
              color: inactiveColor,
              iconSize: 32,
            ),
            IconButton(
              onPressed: onProfilePressed,
              icon: const Icon(Icons.person_outline),
              color: inactiveColor,
              iconSize: 32,
            ),
          ],
        ),
      ),
    );
  }
}
