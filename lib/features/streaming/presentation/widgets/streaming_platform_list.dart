import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/streaming_source.dart';
import 'streaming_platform_card.dart';

class StreamingPlatformList extends StatelessWidget {
  const StreamingPlatformList({super.key, required this.sources});

  final List<StreamingSource> sources;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final uniqueSources = _deduplicate(sources);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Platforms',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: uniqueSources.isEmpty ? null : () {},
              child: Text(
                'See all',
                style: textTheme.titleLarge?.copyWith(
                  color: uniqueSources.isEmpty ? AppColors.secondaryText : null,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (uniqueSources.isEmpty)
          const _EmptyStreamingState()
        else
          SizedBox(
            height: 148,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: uniqueSources.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                return StreamingPlatformCard(source: uniqueSources[index]);
              },
            ),
          ),
      ],
    );
  }

  List<StreamingSource> _deduplicate(List<StreamingSource> sources) {
    final seen = <String>{};
    final result = <StreamingSource>[];
    for (final source in sources) {
      if (source.logoAssetPath.isEmpty) continue;
      final key = source.name.toLowerCase();
      if (seen.add(key)) {
        result.add(source);
      }
    }
    return result;
  }
}

class _EmptyStreamingState extends StatelessWidget {
  const _EmptyStreamingState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        'No hay plataformas disponibles.',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText),
      ),
    );
  }
}
