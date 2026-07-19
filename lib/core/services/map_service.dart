import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/pandal_model.dart';

class MapService {
  String buildGoogleMapsUrl({
    required double destinationLat,
    required double destinationLng,
    double? originLat,
    double? originLng,
    String travelMode = 'driving',
  }) {
    final origin = originLat == null || originLng == null
        ? ''
        : '&origin=$originLat,$originLng';
    return 'https://www.google.com/maps/dir/?api=1$origin&destination=$destinationLat,$destinationLng&travelmode=$travelMode';
  }

  String buildMultiStopMapsUrl({
    required List<PandalModel> pandals,
    Position? origin,
    String travelMode = 'driving',
  }) {
    if (pandals.isEmpty) {
      return 'https://www.google.com/maps';
    }

    final last = pandals.length == 1 ? pandals.first : pandals.last;
    final waypointPandals = pandals.length <= 1
        ? <PandalModel>[]
        : origin == null
        ? pandals.sublist(1, pandals.length - 1)
        : pandals.sublist(0, pandals.length - 1);
    final waypoints = waypointPandals.isEmpty
        ? ''
        : '&waypoints=${waypointPandals.map((pandal) => '${pandal.latitude},${pandal.longitude}').join('|')}';
    final originValue = origin == null
        ? '${pandals.first.latitude},${pandals.first.longitude}'
        : '${origin.latitude},${origin.longitude}';

    return 'https://www.google.com/maps/dir/?api=1&origin=$originValue&destination=${last.latitude},${last.longitude}$waypoints&travelmode=$travelMode';
  }

  Future<void> openSinglePandalDirection({
    required PandalModel pandal,
    Position? origin,
    String travelMode = 'driving',
  }) async {
    final url = buildGoogleMapsUrl(
      destinationLat: pandal.latitude,
      destinationLng: pandal.longitude,
      originLat: origin?.latitude,
      originLng: origin?.longitude,
      travelMode: travelMode,
    );
    await _launch(url);
  }

  Future<void> openMultiStopRoute({
    required List<PandalModel> pandals,
    Position? origin,
    String travelMode = 'driving',
  }) async {
    final url = buildMultiStopMapsUrl(
      pandals: pandals,
      origin: origin,
      travelMode: travelMode,
    );
    await _launch(url);
  }

  Future<void> openInMaps({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final encodedLabel = Uri.encodeComponent(label ?? 'Pujo Pandal');
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude($encodedLabel)';
    await _launch(url);
  }

  Future<void> openDirections({
    required double latitude,
    required double longitude,
    String? label,
    Position? origin,
    String travelMode = 'driving',
  }) async {
    final url = buildGoogleMapsUrl(
      destinationLat: latitude,
      destinationLng: longitude,
      originLat: origin?.latitude,
      originLng: origin?.longitude,
      travelMode: travelMode,
    );
    await _launch(url);
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not open Google Maps.');
    }
  }
}
