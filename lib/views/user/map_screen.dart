import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../controllers/map_controller.dart';
import '../../controllers/pandal_controller.dart';
import '../../core/constants/map_constants.dart';
import '../../models/pandal_model.dart';
import '../widgets/map_pandal_bottom_sheet.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _googleMapController;
  String _selectedArea = 'All';
  String _selectedFilter = 'All';
  bool _hasLoadedLocation = false;
  String _lastMarkerSignature = '';

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
  void dispose() {
    _googleMapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pandalController = context.watch<PandalController>();
    final mapController = context.watch<MapController>();
    final filteredPandals = _filteredPandals(pandalController, mapController);
    final visiblePandals = _areaFilteredPandals(filteredPandals, mapController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final signature =
          '${_selectedArea}_${filteredPandals.map((pandal) => pandal.id).join('|')}';
      if (_lastMarkerSignature == signature) {
        return;
      }
      _lastMarkerSignature = signature;
      context.read<MapController>().loadPandalMarkers(
        pandals: filteredPandals,
        area: _selectedArea,
        onMarkerTap: _showPandalSheet,
      );
    });

    final currentPosition = mapController.currentPosition;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pandal map'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Route all visible pandals',
            enabled: visiblePandals.isNotEmpty,
            icon: const Icon(Icons.alt_route),
            onSelected: (mode) => mapController.openGoogleMapsWithAllPandals(
              visiblePandals.take(8).toList(),
              travelMode: mode,
            ),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'driving', child: Text('Driving route')),
              PopupMenuItem(value: 'walking', child: Text('Walking route')),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                currentPosition?.latitude ?? MapConstants.kolkataLatitude,
                currentPosition?.longitude ?? MapConstants.kolkataLongitude,
              ),
              zoom: MapConstants.defaultZoom,
            ),
            onMapCreated: (controller) => _googleMapController = controller,
            markers: mapController.pandalMarkers,
            myLocationEnabled: currentPosition != null,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Column(
              children: [
                _AreaCountStrip(
                  counts: mapController.areaWisePandalCount,
                  selectedArea: _selectedArea,
                  onSelected: (area) => setState(() => _selectedArea = area),
                ),
                const SizedBox(height: 8),
                _MapFilterStrip(
                  selectedFilter: _selectedFilter,
                  onSelected: (filter) =>
                      setState(() => _selectedFilter = filter),
                ),
              ],
            ),
          ),
          Positioned(
            right: 14,
            bottom: 24,
            child: FloatingActionButton(
              heroTag: 'map-current-location',
              onPressed: () => _moveToCurrentLocation(mapController),
              child: mapController.isLoading
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }

  List<PandalModel> _filteredPandals(
    PandalController pandalController,
    MapController mapController,
  ) {
    var pandals = pandalController.activePandals;

    switch (_selectedFilter) {
      case 'Nearby':
        final currentPosition = mapController.currentPosition;
        if (currentPosition != null) {
          pandals = pandals
              .where(
                (pandal) =>
                    pandalController.calculateDistanceFromUser(
                      pandal,
                      currentPosition,
                    ) <=
                    10,
              )
              .toList();
        }
      case 'Low Crowd':
        pandals = pandals
            .where((pandal) => pandal.crowdLevel == 'low')
            .toList();
      case 'Featured':
        pandals = pandals.where((pandal) => pandal.isFeatured).toList();
      case 'Open Now':
        pandals = pandals.where(pandalController.isOpenNow).toList();
      case 'All':
      default:
        break;
    }

    return pandals;
  }

  List<PandalModel> _areaFilteredPandals(
    List<PandalModel> pandals,
    MapController mapController,
  ) {
    if (_selectedArea == 'All') {
      return pandals;
    }
    return mapController.getPandalsInArea(pandals, _selectedArea);
  }

  Future<void> _moveToCurrentLocation(MapController mapController) async {
    await mapController.loadUserLocation();
    final position = mapController.currentPosition;
    if (position == null || _googleMapController == null) {
      return;
    }
    await _googleMapController!.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        14,
      ),
    );
  }

  void _showPandalSheet(PandalModel pandal) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => MapPandalBottomSheet(pandal: pandal),
    );
  }
}

class _AreaCountStrip extends StatelessWidget {
  const _AreaCountStrip({
    required this.counts,
    required this.selectedArea,
    required this.onSelected,
  });

  final Map<String, int> counts;
  final String selectedArea;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final sortedAreas = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: selectedArea == 'All',
              label: const Text('All areas'),
              onSelected: (_) => onSelected('All'),
            ),
          ),
          for (final entry in sortedAreas)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                selected: selectedArea == entry.key,
                label: Text('${entry.key}: ${entry.value} pandals'),
                onSelected: (_) => onSelected(entry.key),
              ),
            ),
        ],
      ),
    );
  }
}

class _MapFilterStrip extends StatelessWidget {
  const _MapFilterStrip({
    required this.selectedFilter,
    required this.onSelected,
  });

  final String selectedFilter;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    const filters = ['All', 'Nearby', 'Low Crowd', 'Featured', 'Open Now'];
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          for (final filter in filters)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: selectedFilter == filter,
                label: Text(filter),
                onSelected: (_) => onSelected(filter),
              ),
            ),
        ],
      ),
    );
  }
}
