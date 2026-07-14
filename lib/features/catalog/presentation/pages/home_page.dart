import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/movie_finder_logo.dart';
import '../../domain/entities/media_item.dart';
import '../controllers/home_controller.dart';
import '../widgets/featured_media_card.dart';
import '../widgets/main_bottom_navigation.dart';
import '../widgets/media_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.controller,
    required this.onItemSelected,
    required this.onSearchPressed,
    required this.onWishlistPressed,
    required this.onProfilePressed,
  });

  final HomeController controller;
  final ValueChanged<MediaItem> onItemSelected;
  final VoidCallback onSearchPressed;
  final VoidCallback onWishlistPressed;
  final VoidCallback onProfilePressed;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController _featuredController;
  int _featuredIndex = 0;
  bool _showAll = false;
  _HomeFilter _selectedFilter = _HomeFilter.trending;

  @override
  void initState() {
    super.initState();
    _featuredController = PageController(viewportFraction: 0.62);
    widget.controller.addListener(_onControllerChanged);
    widget.controller.loadItems();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _featuredController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: _buildBody(context),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.fromLTRB(20, 0, 20, 18),
        child: MainBottomNavigation(
          onHomePressed: widget.controller.loadItems,
          onSearchPressed: widget.onSearchPressed,
          onWishlistPressed: widget.onWishlistPressed,
          onProfilePressed: widget.onProfilePressed,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final controller = widget.controller;

    if (controller.isLoading && controller.items.isEmpty) {
      return const _HomeLoadingState();
    }

    if (controller.message != null) {
      return _HomeMessage(
        icon: Icons.error_outline,
        title: controller.message!,
        actionLabel: 'Reintentar',
        onActionPressed: controller.loadItems,
      );
    }

    if (controller.items.isEmpty) {
      return const _HomeMessage(
        icon: Icons.movie_filter_outlined,
        title: 'No encontramos contenido para mostrar.',
      );
    }

    final items = _filteredItems(controller.items);

    if (items.isEmpty) {
      return _HomeScaffoldContent(
        selectedFilter: _selectedFilter,
        onFilterChanged: _selectFilter,
        child: const _HomeMessage(
          icon: Icons.movie_filter_outlined,
          title: 'No encontramos contenido para este filtro.',
        ),
      );
    }

    final featuredItem = items[_featuredIndex.clamp(0, items.length - 1)];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 116),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MovieFinderLogo(size: 60),
          const SizedBox(height: 6),
          _HomeTabs(
            selectedFilter: _selectedFilter,
            onFilterChanged: _selectFilter,
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 374,
            child: PageView.builder(
              controller: _featuredController,
            itemCount: _showAll ? items.length : (items.length > 10 ? 10 : items.length),
              onPageChanged: (index) {
                setState(() {
                  _featuredIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final selectedDistance = (index - _featuredIndex).abs();
                final scale = selectedDistance == 0 ? 1.0 : 0.82;

                return FeaturedMediaCard(
                  item: items[index],
                  scale: scale,
                  onTap: () => widget.onItemSelected(items[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              featuredItem.releaseYear.toString(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.secondaryText,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              featuredItem.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _MediaChips(item: featuredItem),
          const SizedBox(height: 18),
          _FeaturedDots(count: items.length.clamp(0, 6), index: _featuredIndex),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'For you',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showAll = !_showAll;
                  });
                },
                child: Text(
                  _showAll ? 'Show less' : 'See all',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 21,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _showAll ? items.length : (items.length > 10 ? 10 : items.length),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 26,
              mainAxisSpacing: 22,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return MediaCard(
                key: ValueKey('media_card_${item.id}'),
                item: item,
                onTap: () => widget.onItemSelected(item),
              );
            },
          ),
        ],
      ),
    );
  }

  List<MediaItem> _filteredItems(List<MediaItem> items) {
    return switch (_selectedFilter) {
      _HomeFilter.trending => items,
      _HomeFilter.movies =>
        items
            .where((item) => item.type == MediaType.movie)
            .toList(growable: false),
      _HomeFilter.series || _HomeFilter.tvShows =>
        items
            .where((item) => item.type == MediaType.series)
            .toList(growable: false),
    };
  }

  void _selectFilter(_HomeFilter filter) {
    if (_selectedFilter == filter) {
      return;
    }

    setState(() {
      _selectedFilter = filter;
      _featuredIndex = 0;
    });

    if (_featuredController.hasClients) {
      _featuredController.jumpToPage(0);
    }
  }
}

class _HomeTabs extends StatelessWidget {
  const _HomeTabs({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final _HomeFilter selectedFilter;
  final ValueChanged<_HomeFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final inactiveColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF9A9A9A)
        : AppColors.secondaryText;

    return SizedBox(
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            _HomeTab(
              key: const Key('home_filter_trending'),
              label: 'Trending',
              color: selectedFilter == _HomeFilter.trending
                  ? AppColors.primary
                  : inactiveColor,
              onTap: () => onFilterChanged(_HomeFilter.trending),
            ),
            const SizedBox(width: 28),
            _HomeTab(
              key: const Key('home_filter_movies'),
              label: 'Movies',
              color: selectedFilter == _HomeFilter.movies
                  ? AppColors.primary
                  : inactiveColor,
              onTap: () => onFilterChanged(_HomeFilter.movies),
            ),
            const SizedBox(width: 28),
            _HomeTab(
              key: const Key('home_filter_series'),
              label: 'Series',
              color: selectedFilter == _HomeFilter.series
                  ? AppColors.primary
                  : inactiveColor,
              onTap: () => onFilterChanged(_HomeFilter.series),
            ),
            const SizedBox(width: 28),
            _HomeTab(
              key: const Key('home_filter_tv_shows'),
              label: 'TV shows',
              color: selectedFilter == _HomeFilter.tvShows
                  ? AppColors.primary
                  : inactiveColor,
              onTap: () => onFilterChanged(_HomeFilter.tvShows),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          label,
          maxLines: 1,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontSize: 25,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _HomeScaffoldContent extends StatelessWidget {
  const _HomeScaffoldContent({
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.child,
  });

  final _HomeFilter selectedFilter;
  final ValueChanged<_HomeFilter> onFilterChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 116),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MovieFinderLogo(size: 60),
          const SizedBox(height: 6),
          _HomeTabs(
            selectedFilter: selectedFilter,
            onFilterChanged: onFilterChanged,
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

enum _HomeFilter { trending, movies, series, tvShows }

class _MediaChips extends StatelessWidget {
  const _MediaChips({required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _InfoChip(
          label: item.genres.isEmpty ? 'Sin genero' : item.genres.first,
          textColor: AppColors.primary,
        ),
        const SizedBox(width: 18),
        _InfoChip(
          icon: Icons.schedule_outlined,
          label: _secondaryLabel(item),
          textColor: AppColors.primary,
        ),
        const SizedBox(width: 18),
        _InfoChip(
          icon: Icons.star_rounded,
          label: item.rating.toStringAsFixed(1),
          textColor: const Color(0xFFFFD166),
        ),
      ],
    );
  }

  String _secondaryLabel(MediaItem item) {
    return switch (item.type) {
      MediaType.movie => item.durationMinutes != null
          ? _formatDuration(item.durationMinutes!)
          : 'Sin datos',
      MediaType.series => item.seasonsCount != null
          ? '${item.seasonsCount} seasons'
          : 'Sin datos',
    };
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}min';
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, this.icon, this.textColor});

  final String label;
  final IconData? icon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = textColor ?? Colors.white;

    return Container(
      width: icon != null ? 118 : 100,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.black,
        borderRadius: BorderRadius.circular(18),
      ),
      child: icon != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            )
          : Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
    );
  }
}

class _FeaturedDots extends StatelessWidget {
  const _FeaturedDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (dotIndex) {
        final isActive = dotIndex == index % count;
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.onSurface
                : AppColors.secondaryText.withValues(alpha: 0.42),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class _HomeMessage extends StatelessWidget {
  const _HomeMessage({
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 58),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center),
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: 16),
              TextButton(onPressed: onActionPressed, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _HomeLoadingState extends StatefulWidget {
  const _HomeLoadingState();

  @override
  State<_HomeLoadingState> createState() => _HomeLoadingStateState();
}

class _HomeLoadingStateState extends State<_HomeLoadingState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.42, end: 1).animate(_controller),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_movies_outlined, size: 58),
            const SizedBox(height: 18),
            Text(
              'Cargando peliculas...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
