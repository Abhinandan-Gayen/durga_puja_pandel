import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as permissions;

import '../utils/distance_helper.dart';

class LocationService {
  Future<bool> requestLocationPermission() async {
    final status = await permissions.Permission.locationWhenInUse.request();
    return status.isGranted || status.isLimited;
  }

  Future<bool> checkLocationPermission() async {
    final status = await permissions.Permission.locationWhenInUse.status;
    if (status.isGranted || status.isLimited) {
      return true;
    }
    final geolocatorPermission = await Geolocator.checkPermission();
    return geolocatorPermission == LocationPermission.always ||
        geolocatorPermission == LocationPermission.whileInUse;
  }

  Future<Position> getCurrentPosition() {
    return determinePosition();
  }

  double calculateDistanceBetweenTwoPoints(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return DistanceHelper.calculateDistanceInKm(lat1, lon1, lat2, lon2);
  }

  Future<Position> determinePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final granted = await requestLocationPermission();
      if (!granted) {
        permission = await Geolocator.requestPermission();
      } else {
        permission = await Geolocator.checkPermission();
      }
    }
    if (permission == LocationPermission.denied) {
      throw Exception('Location permission was denied.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission is permanently denied.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }
}
