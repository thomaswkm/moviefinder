import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/provider_recommendation.dart';
import '../controllers/recommendations_controller.dart';

class RecommendationsPage extends StatefulWidget {
  const RecommendationsPage({
    super.key,
    required this.controller,
    required this.onBack,
  });

  final RecommendationsController controller;
  final VoidCallback onBack;

  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.controller.load();
      }
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
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
                        key: const Key('recommendations_back_button'),
                        onPressed: widget.onBack,
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.auto_awesome,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Recomendaciones',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _RecommendationsContent(controller: controller),
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

class _RecommendationsContent extends StatefulWidget {
  const _RecommendationsContent({required this.controller});

  final RecommendationsController controller;

  @override
  State<_RecommendationsContent> createState() =>
      _RecommendationsContentState();
}

class _RecommendationsContentState extends State<_RecommendationsContent> {
  static const int _visibleRecommendationLimit = 3;

  bool _showAllRecommendations = false;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.message != null) {
      return _MessageState(
        icon: Icons.error_outline,
        title: controller.message!,
        actionLabel: 'Reintentar',
        onActionPressed: controller.load,
      );
    }

    if (controller.totalMovies == 0) {
      return const _MessageState(
        icon: Icons.favorite_border,
        title: 'Agrega peliculas a tu watchlist para recibir recomendaciones.',
      );
    }

    if (controller.recommendations.isEmpty) {
      return const _MessageState(
        icon: Icons.live_tv_outlined,
        title: 'No encontramos plataformas para tu watchlist.',
      );
    }

    final topCoveredMovies = controller.recommendations.first.coveredMovies;
    final topRecommendations = controller.recommendations
        .where(
          (recommendation) => recommendation.coveredMovies == topCoveredMovies,
        )
        .toList(growable: false);
    final hasHiddenRecommendations =
        controller.recommendations.length > _visibleRecommendationLimit;
    final visibleRecommendations =
        _showAllRecommendations || !hasHiddenRecommendations
        ? controller.recommendations
        : controller.recommendations
              .take(_visibleRecommendationLimit)
              .toList(growable: false);
    final hiddenRecommendationsCount =
        controller.recommendations.length - visibleRecommendations.length;

    return ListView.separated(
      itemCount:
          visibleRecommendations.length +
          1 +
          (hasHiddenRecommendations ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _RecommendationSummary(
            recommendations: topRecommendations,
            totalMovies: controller.totalMovies,
          );
        }

        if (index <= visibleRecommendations.length) {
          final recommendation = visibleRecommendations[index - 1];
          return _RecommendationTile(
            rank: index,
            recommendation: recommendation,
          );
        }

        return _ShowMoreRecommendationsButton(
          isExpanded: _showAllRecommendations,
          hiddenCount: hiddenRecommendationsCount,
          onPressed: () {
            setState(() {
              _showAllRecommendations = !_showAllRecommendations;
            });
          },
        );
      },
    );
  }
}

class _RecommendationSummary extends StatelessWidget {
  const _RecommendationSummary({
    required this.recommendations,
    required this.totalMovies,
  });

  final List<ProviderRecommendation> recommendations;
  final int totalMovies;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = _primaryTextColor(context);
    final coveredMovies = recommendations.first.coveredMovies;
    final providerNames = recommendations
        .take(3)
        .map((recommendation) => recommendation.providerName)
        .toList(growable: false);
    final title = providerNames.length == 1
        ? 'Te recomendamos ${providerNames.first}'
        : 'Te recomendamos ${_joinProviderNames(providerNames)}';
    final coverageText = providerNames.length == 1 ? 'Cubre' : 'Cubren';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F1D1D) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.07),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mejor opcion',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$coverageText $coveredMovies/$totalMovies peliculas de tu watchlist.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: textColor, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  const _RecommendationTile({required this.rank, required this.recommendation});

  final int rank;
  final ProviderRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = _primaryTextColor(context);

    return DecoratedBox(
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
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _PlatformMark(recommendation: recommendation),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rank == 1
                        ? 'Te recomendamos ${recommendation.providerName}'
                        : 'Tambien te recomendamos ${recommendation.providerName}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Cumple ${recommendation.coveredMovies}/${recommendation.totalMovies} peliculas (${recommendation.coveragePercentage.toStringAsFixed(1)}%).',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: recommendation.totalMovies == 0
                        ? 0
                        : recommendation.coveredMovies /
                              recommendation.totalMovies,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(999),
                    backgroundColor: AppColors.secondaryText.withValues(
                      alpha: 0.16,
                    ),
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _SourceTypePill(type: recommendation.sourceType),
          ],
        ),
      ),
    );
  }
}

class _PlatformMark extends StatelessWidget {
  const _PlatformMark({required this.recommendation});

  final ProviderRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    if (recommendation.logoAssetPath.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          recommendation.logoAssetPath,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _FallbackMark(label: recommendation.providerName),
        ),
      );
    }

    return _FallbackMark(label: recommendation.providerName);
  }
}

class _FallbackMark extends StatelessWidget {
  const _FallbackMark({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label.trim().isEmpty ? '?' : label.trim()[0].toUpperCase(),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: _primaryTextColor(context),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SourceTypePill extends StatelessWidget {
  const _SourceTypePill({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _label(type),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _label(String type) {
    return switch (type) {
      'sub' => 'Incluida',
      'free' => 'Gratis',
      'rent' => 'Arriendo',
      'buy' => 'Compra',
      _ => 'Info',
    };
  }
}

class _ShowMoreRecommendationsButton extends StatelessWidget {
  const _ShowMoreRecommendationsButton({
    required this.isExpanded,
    required this.hiddenCount,
    required this.onPressed,
  });

  final bool isExpanded;
  final int hiddenCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textColor = _primaryTextColor(context);

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        isExpanded ? Icons.expand_less : Icons.expand_more,
        color: textColor,
      ),
      label: Text(
        isExpanded
            ? 'Ver menos'
            : 'Ver $hiddenCount ${hiddenCount == 1 ? 'plataforma mas' : 'plataformas mas'}',
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor,
        minimumSize: const Size.fromHeight(48),
        side: BorderSide(
          color: AppColors.secondaryText.withValues(alpha: 0.35),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    this.actionLabel,
    this.onActionPressed,
  });

  final IconData icon;
  final String title;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final textColor = _primaryTextColor(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: AppColors.secondaryText),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onActionPressed,
                child: Text(actionLabel!),
              ),
            ],
          ],
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

String _joinProviderNames(List<String> names) {
  if (names.length <= 2) {
    return names.join(' y ');
  }

  return '${names.take(names.length - 1).join(', ')} y ${names.last}';
}
