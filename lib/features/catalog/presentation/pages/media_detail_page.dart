import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../streaming/domain/entities/streaming_source.dart';
import '../../../streaming/domain/usecases/get_streaming_sources.dart';
import '../../../streaming/presentation/widgets/streaming_platform_list.dart';
import '../../domain/entities/media_item.dart';
import '../controllers/wishlist_controller.dart';

class MediaDetailPage extends StatefulWidget {
  const MediaDetailPage({
    super.key,
    required this.item,
    required this.getStreamingSources,
    required this.wishlistController,
    required this.onBack,
  });

  final MediaItem item;
  final GetStreamingSources getStreamingSources;
  final WishlistController wishlistController;
  final VoidCallback onBack;

  @override
  State<MediaDetailPage> createState() => _MediaDetailPageState();
}

class _MediaDetailPageState extends State<MediaDetailPage> {
  late final Future<List<StreamingSource>> _streamingSources;

  @override
  void initState() {
    super.initState();
    widget.wishlistController.addListener(_onWishlistChanged);
    widget.wishlistController.loadIds();
    _streamingSources = widget.getStreamingSources(widget.item.id);
  }

  @override
  void dispose() {
    widget.wishlistController.removeListener(_onWishlistChanged);
    super.dispose();
  }

  void _onWishlistChanged() {
    if (!mounted) {
      return;
    }

    final schedulerPhase = WidgetsBinding.instance.schedulerPhase;
    if (schedulerPhase == SchedulerPhase.persistentCallbacks ||
        schedulerPhase == SchedulerPhase.transientCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final item = widget.item;
    final isLiked = widget.wishlistController.contains(item.id);
    final isWishlistPending = widget.wishlistController.isPending(item.id);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Stack(
              children: [
                CustomScrollView(
                  key: const Key('media_detail_scroll_view'),
                  slivers: [
                    SliverToBoxAdapter(child: _PosterHeader(item: item)),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
                      sliver: SliverList.list(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: textTheme.headlineLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              _LikeButton(
                                isLiked: isLiked,
                                isPending: isWishlistPending,
                                onPressed: () => widget.wishlistController.toggle(item),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: Text(
                              isLiked
                                  ? 'Agregada a tu watchlist'
                                  : 'Agregar a watchlist',
                              key: ValueKey(isLiked),
                              style: textTheme.bodySmall?.copyWith(
                                color: isLiked
                                    ? AppColors.primary
                                    : AppColors.secondaryText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (item.originalTitle != item.title) ...[
                            const SizedBox(height: 6),
                            Text(
                              item.originalTitle,
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _DetailChip(
                                icon: Icons.calendar_today_outlined,
                                label: item.releaseYear.toString(),
                              ),
                              _DetailChip(
                                icon: Icons.star_rounded,
                                label: item.rating.toStringAsFixed(1),
                              ),
                              _DetailChip(
                                icon: Icons.schedule_outlined,
                                label: _durationLabel(item),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _StreamingSection(sources: _streamingSources),
                          const SizedBox(height: 24),
                          Text(
                            'Sinopsis',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item.overview,
                            style: textTheme.bodyMedium?.copyWith(height: 1.45),
                          ),
                          const SizedBox(height: 24),
                          _InfoSection(
                            title: 'Generos',
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: item.genres
                                  .map((genre) => _GenrePill(label: genre))
                                  .toList(growable: false),
                            ),
                          ),
                          const SizedBox(height: 22),
                          _InfoRow(
                            label: _creditLabel(item),
                            value: _credit(item),
                          ),
                          if (item.type == MediaType.series) ...[
                            const SizedBox(height: 14),
                            _InfoRow(
                              label: 'Episodios',
                              value: '${item.episodesCount ?? 0}',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: _CircleButton(
                    key: const Key('media_detail_back_button'),
                    icon: Icons.arrow_back,
                    onPressed: widget.onBack,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _durationLabel(MediaItem item) {
    return switch (item.type) {
      MediaType.movie => _formatDuration(item.durationMinutes ?? 0),
      MediaType.series => '${item.seasonsCount ?? 0} temporadas',
    };
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}min';
  }

  String _creditLabel(MediaItem item) {
    return switch (item.type) {
      MediaType.movie => 'Director',
      MediaType.series => 'Creador',
    };
  }

  String _credit(MediaItem item) {
    return switch (item.type) {
      MediaType.movie => item.director ?? 'No disponible',
      MediaType.series => item.creator ?? 'No disponible',
    };
  }
}

class _LikeButton extends StatelessWidget {
  const _LikeButton({
    required this.isLiked,
    required this.isPending,
    required this.onPressed,
  });

  final bool isLiked;
  final bool isPending;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      key: const Key('media_detail_like_button'),
      button: true,
      selected: isLiked,
      label: isLiked ? 'Quitar de watchlist' : 'Agregar a watchlist',
      child: IconButton.filled(
        style: IconButton.styleFrom(
          backgroundColor: isLiked
              ? AppColors.primary
              : isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.06),
          foregroundColor: isLiked ? Colors.black : AppColors.secondaryText,
          fixedSize: const Size.square(48),
        ),
        onPressed: isPending ? null : onPressed,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: isPending
              ? const SizedBox.square(
                  key: ValueKey('wishlist_pending'),
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey(isLiked),
                ),
        ),
      ),
    );
  }
}

class _StreamingSection extends StatelessWidget {
  const _StreamingSection({required this.sources});

  final Future<List<StreamingSource>> sources;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StreamingSource>>(
      future: sources,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _StreamingLoadingState();
        }

        if (snapshot.hasError) {
          return const _StreamingErrorState();
        }

        return StreamingPlatformList(sources: snapshot.data ?? const []);
      },
    );
  }
}

class _StreamingLoadingState extends StatelessWidget {
  const _StreamingLoadingState();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 148,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _StreamingErrorState extends StatelessWidget {
  const _StreamingErrorState();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Padding(
        padding: EdgeInsets.all(18),
        child: Text('No se pudieron cargar las plataformas.'),
      ),
    );
  }
}

class _PosterHeader extends StatelessWidget {
  const _PosterHeader({required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.88,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _DetailPosterImage(path: item.posterUrl),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 22,
            child: Row(
              children: [
                _TypeBadge(type: item.type),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.genres.join(' / '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailPosterImage extends StatelessWidget {
  const _DetailPosterImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('http')) {
      return Image.network(path, fit: BoxFit.cover, errorBuilder: _errorBuilder);
    }
    return Image.asset(path, fit: BoxFit.cover, errorBuilder: _errorBuilder);
  }

  Widget _errorBuilder(BuildContext context, Object error, StackTrace? stackTrace) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.secondaryText.withValues(alpha: 0.16),
      ),
      child: const Center(child: Icon(Icons.movie_outlined, size: 72)),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({super.key, required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withValues(alpha: 0.52),
        foregroundColor: Colors.white,
      ),
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final MediaType type;

  @override
  Widget build(BuildContext context) {
    final label = switch (type) {
      MediaType.movie => 'Pelicula',
      MediaType.series => 'Serie',
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _GenrePill extends StatelessWidget {
  const _GenrePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.secondaryText.withValues(alpha: 0.5),
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(label),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
