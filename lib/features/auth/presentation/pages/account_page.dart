import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/authenticated_user.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({
    super.key,
    required this.user,
    required this.onBack,
    required this.onRecommendationsPressed,
    required this.onLogoutPressed,
  });

  final AuthenticatedUser? user;
  final VoidCallback onBack;
  final VoidCallback onRecommendationsPressed;
  final VoidCallback onLogoutPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final textColor = _primaryTextColor(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        key: const Key('account_back_button'),
                        onPressed: onBack,
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.person_outline,
                        color: AppColors.primary,
                        size: 30,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Cuenta',
                        style: textTheme.titleLarge?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _AccountHeader(user: user),
                  const SizedBox(height: 24),
                  _AccountActionTile(
                    key: const Key('account_recommendations_button'),
                    icon: Icons.auto_awesome_outlined,
                    title: 'Recomendaciones',
                    subtitle: 'Ver plataformas sugeridas por tu watchlist',
                    onTap: onRecommendationsPressed,
                  ),
                  const SizedBox(height: 14),
                  _AccountActionTile(
                    key: const Key('account_logout_button'),
                    icon: Icons.logout,
                    title: 'Salir',
                    subtitle: 'Cerrar sesion en este dispositivo',
                    onTap: onLogoutPressed,
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({required this.user});

  final AuthenticatedUser? user;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = _primaryTextColor(context);
    final name = user?.username ?? 'Usuario';
    final email = user?.email ?? 'Sesion activa';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F1D1D) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary,
              child: Text(
                name.trim().isEmpty ? 'U' : name.trim()[0].toUpperCase(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountActionTile extends StatelessWidget {
  const _AccountActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = _primaryTextColor(context);
    final accentColor = isDestructive ? AppColors.error : AppColors.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F1D1D) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: textColor),
            ],
          ),
        ),
      ),
    );
  }
}

Color _primaryTextColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? Colors.white
      : Colors.black;
}
