import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../models/pandal_model.dart';

class MapRouteResult {
  const MapRouteResult({
    required this.points,
    required this.durationText,
    required this.distanceText,
  });

  final List<LatLng> points;
  final String durationText;
  final String distanceText;
}

class MapService {
  String? _apiKey;

  Future<MapRouteResult> computeRoute({
    required double originLatitude,
    required double originLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
  }) async {
    final apiKey = await _loadApiKey();
    final response = await http.post(
      Uri.parse('https://routes.googleapis.com/directions/v2:computeRoutes'),
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
        'X-Goog-FieldMask':
            'routes.duration,routes.distanceMeters,'
            'routes.polyline.encodedPolyline',
      },
      body: jsonEncode({
        'origin': {
          'location': {
            'latLng': {
              'latitude': originLatitude,
              'longitude': originLongitude,
            },
          },
        },
        'destination': {
          'location': {
            'latLng': {
              'latitude': destinationLatitude,
              'longitude': destinationLongitude,
            },
          },
        },
        'travelMode': 'DRIVE',
        'routingPreference': 'TRAFFIC_AWARE',
        'computeAlternativeRoutes': false,
        'languageCode': 'en-US',
        'units': 'METRIC',
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Google could not calculate this route.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = data['routes'] as List<dynamic>? ?? const [];
    if (routes.isEmpty) {
      throw Exception('No road route was found.');
    }

    final route = routes.first as Map<String, dynamic>;
    final encodedPolyline =
        (route['polyline'] as Map<String, dynamic>?)?['encodedPolyline']
            as String?;
    if (encodedPolyline == null || encodedPolyline.isEmpty) {
      throw Exception('Google returned an empty route.');
    }

    final durationSeconds = _durationSeconds(route['duration'] as String?);
    final distanceMeters = (route['distanceMeters'] as num?)?.toInt() ?? 0;
    return MapRouteResult(
      points: _decodePolyline(encodedPolyline),
      durationText: _formatDuration(durationSeconds),
      distanceText: _formatDistance(distanceMeters),
    );
  }

  Future<String> _loadApiKey() async {
    final cached = _apiKey;
    if (cached != null && cached.isNotEmpty) return cached;

    final contents = await rootBundle.loadString('.env');
    for (final rawLine in const LineSplitter().convert(contents)) {
      final line = rawLine.trim();
      if (line.startsWith('apikey=')) {
        var value = line.substring('apikey='.length).trim();
        if ((value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'"))) {
          value = value.substring(1, value.length - 1);
        }
        if (value.isNotEmpty) {
          _apiKey = value;
          return value;
        }
      }
    }
    throw Exception('apikey is missing from the .env file.');
  }

  int _durationSeconds(String? value) {
    if (value == null) return 0;
    return double.tryParse(value.replaceAll('s', ''))?.round() ?? 0;
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '< 1 min';
    final minutes = (seconds / 60).ceil();
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return remainingMinutes == 0
        ? '$hours hr'
        : '$hours hr $remainingMinutes min';
  }

  String _formatDistance(int meters) {
    if (meters < 1000) return '$meters m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    var index = 0;
    var latitude = 0;
    var longitude = 0;

    while (index < encoded.length) {
      var shift = 0;
      var result = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      latitude += (result & 1) != 0 ? ~(result >> 1) : result >> 1;

      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      longitude += (result & 1) != 0 ? ~(result >> 1) : result >> 1;

      points.add(LatLng(latitude / 1e5, longitude / 1e5));
    }
    return points;
  }

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
