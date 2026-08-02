import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:durga_puja_pandel/controllers/map_controller.dart';
import 'package:durga_puja_pandel/views/widgets/pandel.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class FavouriteRouteMapScreen extends StatefulWidget {
  const FavouriteRouteMapScreen({super.key, required this.pandal});

  final Pandal pandal;

  @override
  State<FavouriteRouteMapScreen> createState() =>
      _FavouriteRouteMapScreenState();
}

class _FavouriteRouteMapScreenState extends State<FavouriteRouteMapScreen> {
  GoogleMapController? _googleMapController;
  BitmapDescriptor? _destinationMarkerIcon;
  bool _routeRequested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_routeRequested) return;
    _routeRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDestinationMarker();
      _loadRoute();
    });
  }

  Future<void> _loadDestinationMarker() async {
    final imageUrl = widget.pandal.image.trim();
    if (imageUrl.isEmpty) return;
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode < 200 || response.statusCode >= 300) return;
      final codec = await ui.instantiateImageCodec(
        response.bodyBytes,
        targetWidth: 160,
        targetHeight: 160,
      );
      final frame = await codec.getNextFrame();
      final markerBytes = await _paintImageMarker(frame.image);
      if (!mounted) return;
      setState(() {
        _destinationMarkerIcon = BitmapDescriptor.bytes(
          markerBytes,
          width: 58,
          height: 68,
        );
      });
    } catch (_) {
      // The default red Google Maps marker remains visible as the fallback.
    }
  }

  Future<Uint8List> _paintImageMarker(ui.Image image) async {
    const size = ui.Size(140, 164);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const center = Offset(70, 68);
    const outerRadius = 62.0;
    const imageRadius = 53.0;

    final pinPath = Path()
      ..moveTo(47, 112)
      ..lineTo(70, 158)
      ..lineTo(93, 112)
      ..close();
    canvas.drawPath(pinPath, Paint()..color = const Color(0xFFE50914));
    canvas.drawCircle(
      center,
      outerRadius,
      Paint()..color = const Color(0xFFE50914),
    );
    canvas.drawCircle(center, imageRadius + 3, Paint()..color = Colors.white);

    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: imageRadius)),
    );
    final sourceWidth = image.width.toDouble();
    final sourceHeight = image.height.toDouble();
    final cropSize = sourceWidth < sourceHeight ? sourceWidth : sourceHeight;
    final sourceRect = Rect.fromLTWH(
      (sourceWidth - cropSize) / 2,
      (sourceHeight - cropSize) / 2,
      cropSize,
      cropSize,
    );
    final destinationRect = Rect.fromCircle(
      center: center,
      radius: imageRadius,
    );
    canvas.drawImageRect(image, sourceRect, destinationRect, Paint());
    canvas.restore();

    final picture = recorder.endRecording();
    final markerImage = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final byteData = await markerImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    if (byteData == null) {
      throw StateError('Unable to create destination marker image.');
    }
    return byteData.buffer.asUint8List();
  }

  Future<void> _loadRoute() async {
    if (!mounted) return;
    final controller = context.read<MapController>();
    controller.clearRoute();
    final success = await controller.loadRouteTo(
      destinationId: 'favourite_${widget.pandal.en}',
      destinationLatitude: widget.pandal.latitude,
      destinationLongitude: widget.pandal.longitude,
    );
    if (!mounted) return;
    if (success) {
      await _fitRoute(controller.routePoints);
    }
  }

  Future<void> _fitRoute(List<LatLng> points) async {
    final map = _googleMapController;
    if (map == null || points.isEmpty) return;

    var minLatitude = points.first.latitude;
    var maxLatitude = points.first.latitude;
    var minLongitude = points.first.longitude;
    var maxLongitude = points.first.longitude;
    for (final point in points.skip(1)) {
      if (point.latitude < minLatitude) minLatitude = point.latitude;
      if (point.latitude > maxLatitude) maxLatitude = point.latitude;
      if (point.longitude < minLongitude) minLongitude = point.longitude;
      if (point.longitude > maxLongitude) maxLongitude = point.longitude;
    }

    if (minLatitude == maxLatitude && minLongitude == maxLongitude) {
      await map.animateCamera(CameraUpdate.newLatLngZoom(points.first, 16));
      return;
    }

    await map.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLatitude, minLongitude),
          northeast: LatLng(maxLatitude, maxLongitude),
        ),
        72,
      ),
    );
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MapController>();
    final destination = LatLng(widget.pandal.latitude, widget.pandal.longitude);
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('favourite_destination'),
        position: destination,
        infoWindow: InfoWindow(
          title: widget.pandal.en,
          snippet: widget.pandal.area,
        ),
        icon:
            _destinationMarkerIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
      if (controller.currentPosition != null)
        Marker(
          markerId: const MarkerId('route_origin'),
          position: LatLng(
            controller.currentPosition!.latitude,
            controller.currentPosition!.longitude,
          ),
          infoWindow: const InfoWindow(title: 'Your location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
    };

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: destination,
                zoom: 13,
              ),
              markers: markers,
              polylines: controller.routePolylines,
              myLocationEnabled: controller.currentPosition != null,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: true,
              padding: const EdgeInsets.only(top: 90, bottom: 120),
              onMapCreated: (mapController) {
                _googleMapController = mapController;
                if (controller.routePoints.isNotEmpty) {
                  _fitRoute(controller.routePoints);
                }
              },
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    _MapButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x26000000),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          widget.pandal.en,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF29231F),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 24,
            child: _RouteStatusCard(
              isLoading: controller.isRouteLoading,
              duration: controller.routeDurationText,
              distance: controller.routeDistanceText,
              walkingDuration: controller.walkingDurationText,
              transitDuration: controller.transitDurationText,
              error: controller.errorMessage,
              onRetry: _loadRoute,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: const Color(0xFFB91419)),
        ),
      ),
    );
  }
}

class _RouteStatusCard extends StatelessWidget {
  const _RouteStatusCard({
    required this.isLoading,
    required this.duration,
    required this.distance,
    required this.walkingDuration,
    required this.transitDuration,
    required this.error,
    required this.onRetry,
  });

  final bool isLoading;
  final String? duration;
  final String? distance;
  final String? walkingDuration;
  final String? transitDuration;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: isLoading
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 21,
                  height: 21,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFFB91419),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Finding the best road...',
                  style: TextStyle(
                    color: Color(0xFF29231F),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            )
          : error != null
          ? Row(
              children: [
                const Icon(Icons.error_outline, color: Color(0xFFB91419)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    error!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF5E554F)),
                  ),
                ),
                TextButton(onPressed: onRetry, child: const Text('Retry')),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: _TravelTime(
                    icon: Icons.directions_car_rounded,
                    label: 'Driving',
                    duration: duration ?? '--',
                    detail: distance,
                  ),
                ),
                const _ModeDivider(),
                Expanded(
                  child: _TravelTime(
                    icon: Icons.directions_walk_rounded,
                    label: 'Walking',
                    duration: walkingDuration ?? '--',
                  ),
                ),
                const _ModeDivider(),
                Expanded(
                  child: _TravelTime(
                    icon: Icons.train_rounded,
                    label: 'Train',
                    duration: transitDuration ?? '--',
                  ),
                ),
              ],
            ),
    );
  }
}

class _TravelTime extends StatelessWidget {
  const _TravelTime({
    required this.icon,
    required this.label,
    required this.duration,
    this.detail,
  });

  final IconData icon;
  final String label;
  final String duration;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFFB91419), size: 23),
        const SizedBox(height: 5),
        Text(
          duration,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF29231F),
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          detail == null || detail!.isEmpty ? label : '$label · $detail',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xFF746B65), fontSize: 10),
        ),
      ],
    );
  }
}

class _ModeDivider extends StatelessWidget {
  const _ModeDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 54,
      margin: const EdgeInsets.symmetric(horizontal: 7),
      color: const Color(0xFFE7D9D2),
    );
  }
}
