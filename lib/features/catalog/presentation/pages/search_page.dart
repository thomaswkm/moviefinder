import 'package:flutter/material.dart';

import '../../domain/entities/media_item.dart';
import '../controllers/search_controller.dart' as catalog;
import '../widgets/media_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    required this.controller,
    required this.onItemSelected,
    required this.onBack,
  });

  final catalog.MediaSearchController controller;
  final ValueChanged<MediaItem> onItemSelected;
  final VoidCallback onBack;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    widget.controller.loadSuggestions();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _textController.dispose();
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
                      IconButton(
                        onPressed: widget.onBack,
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          autofocus: true,
                          textInputAction: TextInputAction.search,
                          onSubmitted: controller.search,
                          decoration: InputDecoration(
                            hintText: 'Buscar peliculas',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(child: _SearchResults(controller: controller, onItemSelected: widget.onItemSelected)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.controller, required this.onItemSelected});

  final catalog.MediaSearchController controller;
  final ValueChanged<MediaItem> onItemSelected;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.message != null) {
      return Center(child: Text(controller.message!));
    }

    if (!controller.hasSearched && controller.hasSuggestions) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Sugerencias',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              itemCount: controller.suggestions.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 26,
                mainAxisSpacing: 22,
              ),
              itemBuilder: (context, index) {
                final item = controller.suggestions[index];
                return MediaCard(
                    item: item, onTap: () => onItemSelected(item));
              },
            ),
          ),
        ],
      );
    }

    if (controller.items.isEmpty) {
      return const Center(child: Text('Busca una pelicula por titulo.'));
    }

    return GridView.builder(
      itemCount: controller.items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 26,
        mainAxisSpacing: 22,
      ),
      itemBuilder: (context, index) {
        final item = controller.items[index];
        return MediaCard(item: item, onTap: () => onItemSelected(item));
      },
    );
  }
}
