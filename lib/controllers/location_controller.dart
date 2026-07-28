import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../core/services/location_service.dart';

class LocationController extends ChangeNotifier {
  LocationController(this._locationService);

  final LocationService _locationService;

  Position? currentPosition;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadLocation() async {
    isLoading = true;
    errorMessage = null;
    Future.microtask(notifyListeners);
    try {
      currentPosition = await _locationService.determinePosition();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
