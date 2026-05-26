import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/movie_finder_logo.dart';
import '../../domain/entities/movie.dart';
import '../controllers/home_controller.dart';
import '../widgets/featured_movie_card.dart';
import '../widgets/main_bottom_navigation.dart';
import '../widgets/movie_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.controller,
    required this.onMovieSelected,
  });

  final HomeController controller;
  final ValueChanged<Movie> onMovieSelected;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController _featuredController;
  int _featuredIndex = 0;

  @override
  void initState() {
    super.initState();
    _featuredController = PageController(viewportFraction: 0.62);
    widget.controller.addListener(_onControllerChanged);
    widget.controller.loadMovies();
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
      bottomNavigationBar: const SafeArea(
        minimum: EdgeInsets.fromLTRB(20, 0, 20, 18),
        child: MainBottomNavigation(),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final controller = widget.controller;

    if (controller.isLoading && controller.movies.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.message != null) {
      return _HomeMessage(
        icon: Icons.error_outline,
        title: controller.message!,
        actionLabel: 'Reintentar',
        onActionPressed: controller.loadMovies,
      );
    }

    if (controller.movies.isEmpty) {
      return const _HomeMessage(
        icon: Icons.movie_filter_outlined,
        title: 'No encontramos peliculas para mostrar.',
      );
    }

    final movies = controller.movies;
    final featuredMovie = movies[_featuredIndex.clamp(0, movies.length - 1)];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 116),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MovieFinderLogo(size: 60),
          const SizedBox(height: 6),
          const _HomeTabs(),
          const SizedBox(height: 28),
          SizedBox(
            height: 374,
            child: PageView.builder(
              controller: _featuredController,
              itemCount: movies.length,
              onPageChanged: (index) {
                setState(() {
                  _featuredIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final selectedDistance = (index - _featuredIndex).abs();
                final scale = selectedDistance == 0 ? 1.0 : 0.82;

                return FeaturedMovieCard(
                  movie: movies[index],
                  scale: scale,
                  onTap: () => widget.onMovieSelected(movies[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              featuredMovie.releaseYear.toString(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.secondaryText,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              featuredMovie.title,
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
          _MovieChips(movie: featuredMovie),
          const SizedBox(height: 18),
          _FeaturedDots(
            count: movies.length.clamp(0, 6),
            index: _featuredIndex,
          ),
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
                onPressed: () {},
                child: Text(
                  'See all',
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
            itemCount: movies.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 26,
              mainAxisSpacing: 22,
            ),
            itemBuilder: (context, index) {
              final movie = movies[index];
              return MovieCard(
                key: ValueKey('movie_card_${movie.id}'),
                movie: movie,
                onTap: () => widget.onMovieSelected(movie),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HomeTabs extends StatelessWidget {
  const _HomeTabs();

  @override
  Widget build(BuildContext context) {
    final inactiveColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF9A9A9A)
        : AppColors.secondaryText;

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _HomeTab(label: 'Trending', color: AppColors.primary),
        ),
        Expanded(
          child: _HomeTab(label: 'Movies', color: inactiveColor),
        ),
        Expanded(
          child: _HomeTab(label: 'Series', color: inactiveColor),
        ),
        Expanded(
          flex: 2,
          child: _HomeTab(label: 'TV shows', color: inactiveColor),
        ),
      ],
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: color,
        fontSize: 21,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class _MovieChips extends StatelessWidget {
  const _MovieChips({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _InfoChip(label: movie.genres.first),
        const SizedBox(width: 18),
        _InfoChip(label: _formatDuration(movie.durationMinutes)),
        const SizedBox(width: 18),
        _InfoChip(label: movie.rating.toStringAsFixed(1)),
      ],
    );
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}min';
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 98,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.transparent : const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(18),
        border: isDark ? Border.all(color: Colors.white, width: 1) : null,
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.white,
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
