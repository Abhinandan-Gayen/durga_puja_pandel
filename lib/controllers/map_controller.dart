import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../core/services/location_service.dart';
import '../core/services/map_service.dart';
import '../models/pandal_model.dart';

class MapController extends ChangeNotifier {
  MapController(this._mapService, this._locationService);

  final MapService _mapService;
  final LocationService _locationService;

  Position? currentPosition;
  Set<Marker> pandalMarkers = {};
  PandalModel? selectedPandal;
  Map<String, int> areaWisePandalCount = {};
  bool isLoading = false;
  bool isRouteLoading = false;
  String? routingDestinationId;
  String? routeDurationText;
  String? routeDistanceText;
  String? walkingDurationText;
  String? transitDurationText;
  List<LatLng> routePoints = [];
  Set<Polyline> routePolylines = {};
  String? errorMessage;

  Future<bool> loadRouteTo({
    required String destinationId,
    required double destinationLatitude,
    required double destinationLongitude,
  }) async {
    if (isRouteLoading) return false;
    isRouteLoading = true;
    routingDestinationId = destinationId;
    routeDurationText = null;
    routeDistanceText = null;
    walkingDurationText = null;
    transitDurationText = null;
    errorMessage = null;
    notifyListeners();

    try {
      currentPosition ??= await _locationService.getCurrentPosition();
      final origin = currentPosition!;
      final routes = await Future.wait([
        _mapService.computeRoute(
          originLatitude: origin.latitude,
          originLongitude: origin.longitude,
          destinationLatitude: destinationLatitude,
          destinationLongitude: destinationLongitude,
        ),
        _mapService.computeRoute(
          originLatitude: origin.latitude,
          originLongitude: origin.longitude,
          destinationLatitude: destinationLatitude,
          destinationLongitude: destinationLongitude,
          travelMode: 'WALK',
        ),
        _mapService.computeRoute(
          originLatitude: origin.latitude,
          originLongitude: origin.longitude,
          destinationLatitude: destinationLatitude,
          destinationLongitude: destinationLongitude,
          travelMode: 'TRANSIT',
        ),
      ]);
      final drivingRoute = routes[0];
      routePoints = drivingRoute.points;
      routeDurationText = drivingRoute.durationText;
      routeDistanceText = drivingRoute.distanceText;
      walkingDurationText = routes[1].durationText;
      transitDurationText = routes[2].durationText;
      routePolylines = {
        Polyline(
          polylineId: const PolylineId('active_direction_route'),
          points: drivingRoute.points,
          color: const Color(0xFF1565C0),
          width: 6,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      };
      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      routePoints = [];
      routePolylines = {};
      return false;
    } finally {
      isRouteLoading = false;
      notifyListeners();
    }
  }

  void clearRoute() {
    routingDestinationId = null;
    routeDurationText = null;
    routeDistanceText = null;
    walkingDurationText = null;
    transitDurationText = null;
    routePoints = [];
    routePolylines = {};
    errorMessage = null;
    notifyListeners();
  }

  Future<void> loadUserLocation() async {
    isLoading = true;
    errorMessage = null;
    Future.microtask(notifyListeners);
    try {
      currentPosition = await _locationService.getCurrentPosition();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void loadPandalMarkers({
    required List<PandalModel> pandals,
    String? area,
    void Function(PandalModel pandal)? onMarkerTap,
  }) {
    final visiblePandals = area == null || area == 'All'
        ? pandals
        : getPandalsInArea(pandals, area);

    pandalMarkers = visiblePandals
        .map(
          (pandal) => Marker(
            markerId: MarkerId(pandal.id),
            position: LatLng(pandal.latitude, pandal.longitude),
            infoWindow: InfoWindow(title: pandal.name, snippet: pandal.area),
            onTap: () {
              selectPandal(pandal, notify: false);
              onMarkerTap?.call(pandal);
            },
          ),
        )
        .toSet();
    calculateAreaWisePandalCount(pandals);
    notifyListeners();
  }

  void selectPandal(PandalModel? pandal, {bool notify = true}) {
    selectedPandal = pandal;
    if (notify) {
      notifyListeners();
    }
  }

  List<PandalModel> getPandalsInArea(List<PandalModel> pandals, String area) {
    return pandals.where((pandal) => pandal.area == area).toList();
  }

  Map<String, int> calculateAreaWisePandalCount(List<PandalModel> pandals) {
    final counts = <String, int>{};
    for (final pandal in pandals) {
      final area = pandal.area.trim().isEmpty ? 'Unknown' : pandal.area.trim();
      counts[area] = (counts[area] ?? 0) + 1;
    }
    areaWisePandalCount = counts;
    return areaWisePandalCount;
  }

  Future<void> openDirectionToPandal(
    PandalModel pandal, {
    String travelMode = 'driving',
  }) async {
    errorMessage = null;
    notifyListeners();
    try {
      currentPosition ??= await _locationService.getCurrentPosition();
      await _mapService.openSinglePandalDirection(
        pandal: pandal,
        origin: currentPosition,
        travelMode: travelMode,
      );
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> openGoogleMapsWithAllPandals(
    List<PandalModel> pandals, {
    String travelMode = 'driving',
  }) async {
    errorMessage = null;
    notifyListeners();
    try {
      currentPosition ??= await _locationService.getCurrentPosition();
      await _mapService.openMultiStopRoute(
        pandals: pandals,
        origin: currentPosition,
        travelMode: travelMode,
      );
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> openInMaps(PandalModel pandal) async {
    errorMessage = null;
    notifyListeners();
    try {
      await _mapService.openInMaps(
        latitude: pandal.latitude,
        longitude: pandal.longitude,
        label: pandal.name,
      );
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> openDirections(
    PandalModel pandal, {
    String travelMode = 'driving',
  }) {
    return openDirectionToPandal(pandal, travelMode: travelMode);
  }

  double? distanceTo(PandalModel pandal) {
    final position = currentPosition;
    if (position == null) {
      return null;
    }
    return _locationService.calculateDistanceBetweenTwoPoints(
      position.latitude,
      position.longitude,
      pandal.latitude,
      pandal.longitude,
    );
  }
}
