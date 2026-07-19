import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../controllers/map_controller.dart';
import '../../controllers/pandal_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/distance_helper.dart';
import '../../models/pandal_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/empty_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/rating_widget.dart';

class RoutePlannerScreen extends StatefulWidget {
  const RoutePlannerScreen({super.key});

  @override
  State<RoutePlannerScreen> createState() => _RoutePlannerScreenState();
}

class _RoutePlannerScreenState extends State<RoutePlannerScreen> {
  final List<PandalModel> _selectedPandals = [];
  bool _hasLoadedLocation = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasLoadedLocation) {
      return;
    }
    _hasLoadedLocation = true;
    context.read<MapController>().loadUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    final pandalController = context.watch<PandalController>();
    final mapController = context.watch<MapController>();
    final activePandals = pandalController.activePandals;

    return Scaffold(
      appBar: AppBar(title: const Text('Route planner')),
      body: pandalController.isLoading && activePandals.isEmpty
          ? const LoadingWidget(message: 'Loading active pandals')
          : activePandals.isEmpty
          ? const EmptyWidget(
              title: 'No active pandals',
              message: 'Active pandals will appear here for route planning.',
              icon: Icons.route,
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _PlannerHeader(
                  selectedCount: _selectedPandals.length,
                  totalDistance: _totalDistanceKm(
                    mapController.currentPosition,
                  ),
                  hasLocation: mapController.currentPosition != null,
                  isLoadingLocation: mapController.isLoading,
                  onRefreshLocation: mapController.loadUserLocation,
                ),
                const SizedBox(height: 16),
                _SelectedRouteCard(
                  selectedPandals: _selectedPandals,
                  currentPosition: mapController.currentPosition,
                  onReorder: _reorderSelectedPandals,
                  onRemove: _removePandal,
                ),
                const SizedBox(height: 16),
                _RouteActions(
                  hasSelection: _selectedPandals.isNotEmpty,
                  onOpenRoute: () => _openRoute(mapController),
                  onClear: () => setState(_selectedPandals.clear),
                ),
                const SizedBox(height: 20),
                Text(
                  'Choose pandals',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                for (final pandal in activePandals)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SelectablePandalTile(
                      pandal: pandal,
                      isSelected: _selectedPandals.any(
                        (selected) => selected.id == pandal.id,
                      ),
                      onChanged: (selected) =>
                          selected ? _addPandal(pandal) : _removePandal(pandal),
                    ),
                  ),
              ],
            ),
    );
  }

  void _addPandal(PandalModel pandal) {
    if (_selectedPandals.any((selected) => selected.id == pandal.id)) {
      return;
    }
    setState(() => _selectedPandals.add(pandal));
  }

  void _removePandal(PandalModel pandal) {
    setState(
      () =>
          _selectedPandals.removeWhere((selected) => selected.id == pandal.id),
    );
  }

  void _reorderSelectedPandals(int oldIndex, int newIndex) {
    setState(() {
      final pandal = _selectedPandals.removeAt(oldIndex);
      _selectedPandals.insert(newIndex, pandal);
    });
  }

  Future<void> _openRoute(MapController mapController) async {
    if (_selectedPandals.isEmpty) {
      return;
    }
    if (_selectedPandals.length == 1) {
      await mapController.openDirectionToPandal(_selectedPandals.first);
      return;
    }
    await mapController.openGoogleMapsWithAllPandals(_selectedPandals);
  }

  double _totalDistanceKm(Position? currentPosition) {
    if (_selectedPandals.isEmpty) {
      return 0;
    }

    var total = 0.0;
    if (currentPosition != null) {
      total += DistanceHelper.calculateDistanceInKm(
        currentPosition.latitude,
        currentPosition.longitude,
        _selectedPandals.first.latitude,
        _selectedPandals.first.longitude,
      );
    }

    for (var index = 0; index < _selectedPandals.length - 1; index++) {
      final start = _selectedPandals[index];
      final end = _selectedPandals[index + 1];
      total += DistanceHelper.calculateDistanceInKm(
        start.latitude,
        start.longitude,
        end.latitude,
        end.longitude,
      );
    }
    return total;
  }
}

class _PlannerHeader extends StatelessWidget {
  const _PlannerHeader({
    required this.selectedCount,
    required this.totalDistance,
    required this.hasLocation,
    required this.isLoadingLocation,
    required this.onRefreshLocation,
  });

  final int selectedCount;
  final double totalDistance;
  final bool hasLocation;
  final bool isLoadingLocation;
  final VoidCallback onRefreshLocation;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.deepRed,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Plan your pandal hopping route',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _RouteMetric(
                    label: 'Selected',
                    value: '$selectedCount',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _RouteMetric(
                    label: hasLocation ? 'Total distance' : 'Route distance',
                    value: '${totalDistance.toStringAsFixed(1)} km',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: isLoadingLocation ? null : onRefreshLocation,
              icon: isLoadingLocation
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: Text(hasLocation ? 'Refresh location' : 'Use my location'),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteMetric extends StatelessWidget {
  const _RouteMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.white)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedRouteCard extends StatelessWidget {
  const _SelectedRouteCard({
    required this.selectedPandals,
    required this.currentPosition,
    required this.onReorder,
    required this.onRemove,
  });

  final List<PandalModel> selectedPandals;
  final Position? currentPosition;
  final ReorderCallback onReorder;
  final ValueChanged<PandalModel> onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected route',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (selectedPandals.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('Select pandals to build a route')),
              )
            else ...[
              _RouteLegs(
                selectedPandals: selectedPandals,
                currentPosition: currentPosition,
              ),
              const SizedBox(height: 12),
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                itemCount: selectedPandals.length,
                onReorderItem: onReorder,
                itemBuilder: (context, index) {
                  final pandal = selectedPandals[index];
                  return ListTile(
                    key: ValueKey(pandal.id),
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(pandal.name),
                    subtitle: Text('${pandal.area}, ${pandal.city}'),
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        IconButton(
                          tooltip: 'Remove',
                          onPressed: () => onRemove(pandal),
                          icon: const Icon(Icons.close),
                        ),
                        ReorderableDragStartListener(
                          index: index,
                          child: const Icon(Icons.drag_handle),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RouteLegs extends StatelessWidget {
  const _RouteLegs({
    required this.selectedPandals,
    required this.currentPosition,
  });

  final List<PandalModel> selectedPandals;
  final Position? currentPosition;

  @override
  Widget build(BuildContext context) {
    final legs = <String>[];
    if (selectedPandals.isNotEmpty) {
      if (currentPosition != null) {
        legs.add(
          'Your location to ${selectedPandals.first.name}: ${DistanceHelper.calculateDistanceInKm(currentPosition!.latitude, currentPosition!.longitude, selectedPandals.first.latitude, selectedPandals.first.longitude).toStringAsFixed(1)} km',
        );
      } else {
        legs.add('Enable location to include distance to the first pandal');
      }
    }

    for (var index = 0; index < selectedPandals.length - 1; index++) {
      final start = selectedPandals[index];
      final end = selectedPandals[index + 1];
      legs.add(
        '${start.name} to ${end.name}: ${DistanceHelper.calculateDistanceInKm(start.latitude, start.longitude, end.latitude, end.longitude).toStringAsFixed(1)} km',
      );
    }

    return Column(
      children: [
        for (final leg in legs)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.timeline),
            title: Text(leg),
          ),
      ],
    );
  }
}

class _RouteActions extends StatelessWidget {
  const _RouteActions({
    required this.hasSelection,
    required this.onOpenRoute,
    required this.onClear,
  });

  final bool hasSelection;
  final VoidCallback onOpenRoute;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            label: 'Open route',
            icon: Icons.alt_route,
            onPressed: hasSelection ? onOpenRoute : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: hasSelection ? onClear : null,
            icon: const Icon(Icons.clear),
            label: const Text('Clear route'),
          ),
        ),
      ],
    );
  }
}

class _SelectablePandalTile extends StatelessWidget {
  const _SelectablePandalTile({
    required this.pandal,
    required this.isSelected,
    required this.onChanged,
  });

  final PandalModel pandal;
  final bool isSelected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final imageUrl = pandal.thumbnailUrl.isNotEmpty
        ? pandal.thumbnailUrl
        : pandal.images.isEmpty
        ? null
        : pandal.images.first;

    return Card(
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (value) => onChanged(value ?? false),
        secondary: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 56,
            height: 56,
            child: imageUrl == null
                ? const ColoredBox(
                    color: Color(0xFFFFE6BE),
                    child: Icon(Icons.temple_hindu),
                  )
                : CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover),
          ),
        ),
        title: Text(pandal.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${pandal.area}, ${pandal.city}'),
            const SizedBox(height: 4),
            RatingWidget(rating: pandal.averageRating),
          ],
        ),
      ),
    );
  }
}
