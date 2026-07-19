import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/location_controller.dart';
import '../../controllers/pandal_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../models/pandal_model.dart';
import '../widgets/empty_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/pandal_card.dart';

class PandalListScreen extends StatefulWidget {
  const PandalListScreen({super.key});

  @override
  State<PandalListScreen> createState() => _PandalListScreenState();
}

class _PandalListScreenState extends State<PandalListScreen> {
  final _searchController = TextEditingController();
  final _areaController = TextEditingController();
  String _crowdLevel = 'any';
  String _sortBy = 'newest';
  double? _maxDistanceKm;
  double? _minRating;
  bool _openNow = false;
  bool _featured = false;

  @override
  void dispose() {
    _searchController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationController>().currentPosition;

    return Scaffold(
      appBar: AppBar(title: const Text('All pandals')),
      body: Consumer<PandalController>(
        builder: (context, controller, _) {
          if (controller.isLoading && controller.activePandals.isEmpty) {
            return const LoadingWidget(message: 'Loading pandals');
          }

          final pandals = controller.filterPandals(
            query: _searchController.text,
            maxDistanceKm: _maxDistanceKm,
            minRating: _minRating,
            crowdLevel: _crowdLevel,
            area: _areaController.text,
            openNow: _openNow,
            featured: _featured,
            sortBy: _sortBy,
            userPosition: location,
          );

          return Column(
            children: [
              _FiltersPanel(
                searchController: _searchController,
                areaController: _areaController,
                crowdLevel: _crowdLevel,
                sortBy: _sortBy,
                maxDistanceKm: _maxDistanceKm,
                minRating: _minRating,
                openNow: _openNow,
                featured: _featured,
                onChanged:
                    ({
                      String? crowdLevel,
                      String? sortBy,
                      double? maxDistanceKm,
                      double? minRating,
                      bool clearDistance = false,
                      bool clearRating = false,
                      bool? openNow,
                      bool? featured,
                    }) {
                      setState(() {
                        if (crowdLevel != null) _crowdLevel = crowdLevel;
                        if (sortBy != null) _sortBy = sortBy;
                        if (clearDistance) {
                          _maxDistanceKm = null;
                        } else if (maxDistanceKm != null) {
                          _maxDistanceKm = maxDistanceKm;
                        }
                        if (clearRating) {
                          _minRating = null;
                        } else if (minRating != null) {
                          _minRating = minRating;
                        }
                        if (openNow != null) _openNow = openNow;
                        if (featured != null) _featured = featured;
                      });
                    },
                onTextChanged: () => setState(() {}),
              ),
              Expanded(
                child: _PandalResults(pandals: pandals, controller: controller),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FiltersPanel extends StatelessWidget {
  const _FiltersPanel({
    required this.searchController,
    required this.areaController,
    required this.crowdLevel,
    required this.sortBy,
    required this.maxDistanceKm,
    required this.minRating,
    required this.openNow,
    required this.featured,
    required this.onChanged,
    required this.onTextChanged,
  });

  final TextEditingController searchController;
  final TextEditingController areaController;
  final String crowdLevel;
  final String sortBy;
  final double? maxDistanceKm;
  final double? minRating;
  final bool openNow;
  final bool featured;
  final void Function({
    String? crowdLevel,
    String? sortBy,
    double? maxDistanceKm,
    double? minRating,
    bool clearDistance,
    bool clearRating,
    bool? openNow,
    bool? featured,
  })
  onChanged;
  final VoidCallback onTextChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search name, area, city, theme',
              ),
              onChanged: (_) => onTextChanged(),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: areaController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.location_city_outlined),
                hintText: 'Filter by area',
              ),
              onChanged: (_) => onTextChanged(),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: crowdLevel,
                    decoration: const InputDecoration(labelText: 'Crowd'),
                    items: ['any', ...AppConstants.crowdLevels]
                        .map(
                          (level) => DropdownMenuItem(
                            value: level,
                            child: Text(level),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => onChanged(crowdLevel: value ?? 'any'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: sortBy,
                    decoration: const InputDecoration(labelText: 'Sort'),
                    items: const [
                      DropdownMenuItem(
                        value: 'nearest',
                        child: Text('Nearest'),
                      ),
                      DropdownMenuItem(
                        value: 'highest_rating',
                        child: Text('Highest rating'),
                      ),
                      DropdownMenuItem(
                        value: 'low_crowd',
                        child: Text('Low crowd'),
                      ),
                      DropdownMenuItem(value: 'newest', child: Text('Newest')),
                    ],
                    onChanged: (value) => onChanged(sortBy: value ?? 'newest'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  selected: maxDistanceKm != null,
                  label: Text(
                    maxDistanceKm == null
                        ? 'Distance'
                        : 'Within ${maxDistanceKm!.toStringAsFixed(0)} km',
                  ),
                  onSelected: (selected) =>
                      onChanged(maxDistanceKm: 10, clearDistance: !selected),
                ),
                FilterChip(
                  selected: minRating != null,
                  label: Text(
                    minRating == null
                        ? 'Rating'
                        : '${minRating!.toStringAsFixed(1)}+ rating',
                  ),
                  onSelected: (selected) =>
                      onChanged(minRating: 4, clearRating: !selected),
                ),
                FilterChip(
                  selected: openNow,
                  label: const Text('Open now'),
                  onSelected: (selected) => onChanged(openNow: selected),
                ),
                FilterChip(
                  selected: featured,
                  label: const Text('Featured'),
                  onSelected: (selected) => onChanged(featured: selected),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PandalResults extends StatelessWidget {
  const _PandalResults({required this.pandals, required this.controller});

  final List<PandalModel> pandals;
  final PandalController controller;

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationController>().currentPosition;
    if (pandals.isEmpty) {
      return const EmptyWidget(
        title: 'No pandals found',
        message: 'Try changing your search, filters, or sort order.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pandals.length,
      itemBuilder: (context, index) {
        final pandal = pandals[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PandalCard(
            pandal: pandal,
            distanceKm: location == null
                ? null
                : controller.calculateDistanceFromUser(pandal, location),
          ),
        );
      },
    );
  }
}
