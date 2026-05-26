import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/streaming_source.dart';

class StreamingPlatformCard extends StatelessWidget {
  const StreamingPlatformCard({super.key, required this.source});

  final StreamingSource source;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: DecoratedBox(
                decoration: const BoxDecoration(color: Colors.black),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Image.asset(
                        source.logoAssetPath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              source.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      left: 10,
                      right: 10,
                      bottom: 10,
                      child: _AccessBadge(type: source.type),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            source.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _AccessBadge extends StatelessWidget {
  const _AccessBadge({required this.type});

  final StreamingSourceType type;

  @override
  Widget build(BuildContext context) {
    final label = switch (type) {
      StreamingSourceType.subscription => 'Incluida',
      StreamingSourceType.rent => 'Arriendo',
      StreamingSourceType.buy => 'Compra',
      StreamingSourceType.free => 'Gratis',
      StreamingSourceType.unknown => 'No especificada',
    };

    final color = switch (type) {
      StreamingSourceType.subscription => AppColors.primary,
      StreamingSourceType.rent => const Color(0xFFFFD166),
      StreamingSourceType.buy => const Color(0xFFFF8A80),
      StreamingSourceType.free => const Color(0xFF80DEEA),
      StreamingSourceType.unknown => AppColors.secondaryText,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
