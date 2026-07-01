import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/media_item.dart';
import '../controllers/wishlist_controller.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({
    super.key,
    required this.controller,
    required this.onItemSelected,
    required this.onBack,
  });

  final WishlistController controller;
  final ValueChanged<MediaItem> onItemSelected;
  final VoidCallback onBack;

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
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
                      IconButton(onPressed: widget.onBack, icon: const Icon(Icons.arrow_back)),
                      const SizedBox(width: 8),
                      Text(
                        'Watchlist',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(child: _WishlistContent(controller: controller, onItemSelected: widget.onItemSelected)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WishlistContent extends StatelessWidget {
  const _WishlistContent({required this.controller, required this.onItemSelected});

  final WishlistController controller;
  final ValueChanged<MediaItem> onItemSelected;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.message != null) {
      return Center(child: Text(controller.message!));
    }

    if (controller.items.isEmpty) {
      return const Center(child: Text('Aun no tienes peliculas guardadas.'));
    }

    return ListView.separated(
      itemCount: controller.items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final item = controller.items[index];
        return _WishlistMediaTile(
          item: item,
          onTap: () => onItemSelected(item),
        );
      },
    );
  }
}

class _WishlistMediaTile extends StatelessWidget {
  const _WishlistMediaTile({required this.item, required this.onTap});

  final MediaItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        height: 132,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F1D1D) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
              child: SizedBox(
                width: 92,
                height: double.infinity,
                child: _PosterImage(path: item.posterUrl),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${item.releaseYear == 0 ? 'Sin fecha' : item.releaseYear} • ${_typeLabel(item.type)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.genres.isEmpty ? 'Sin genero' : item.genres.take(2).join(' / '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(MediaType type) {
    return switch (type) {
      MediaType.movie => 'Pelicula',
      MediaType.series => 'Serie',
    };
  }
}

class _PosterImage extends StatelessWidget {
  const _PosterImage({required this.path});

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
      child: const Center(child: Icon(Icons.movie_outlined, size: 32)),
    );
  }
}
