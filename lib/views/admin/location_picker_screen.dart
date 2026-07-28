import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/services/location_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/snackbar_helper.dart';

class LocationPickerResult {
  const LocationPickerResult({
    required this.latitude,
    required this.longitude,
    this.area,
    this.city,
    this.address,
  });

  final double latitude;
  final double longitude;
  final String? area;
  final String? city;
  final String? address;
}

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
  });

  final double initialLatitude;
  final double initialLongitude;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  late LatLng _selectedPosition;
  final Set<Marker> _markers = {};
  String? _resolvedAddress;
  String? _resolvedArea;
  String? _resolvedCity;
  bool _isResolvingLocation = false;
  bool _isResolvingAddress = false;
  bool _hasMovedMarker = false;

  @override
  void initState() {
    super.initState();
    _selectedPosition = LatLng(
      widget.initialLatitude,
      widget.initialLongitude,
    );
    _addMarker();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _resolveAddress();
    });
  }

  void _addMarker() {
    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('selected'),
        position: _selectedPosition,
      ),
    );
  }

  void _updatePosition(LatLng position) {
    setState(() {
      _selectedPosition = position;
      _hasMovedMarker = true;
      _addMarker();
    });
    _resolveAddress();
  }

  Future<void> _resolveAddress() async {
    if (_isResolvingAddress) return;
    setState(() => _isResolvingAddress = true);
    try {
      final placemarks = await placemarkFromCoordinates(
        _selectedPosition.latitude,
        _selectedPosition.longitude,
      );
      if (!mounted) return;
      final pm = placemarks.isNotEmpty ? placemarks.first : null;
      if (pm != null) {
        final parts = [
          pm.name,
          pm.subLocality,
          pm.locality,
          pm.administrativeArea,
          pm.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');
        setState(() {
          _resolvedAddress = parts.isNotEmpty ? parts : null;
          _resolvedArea = pm.subLocality ?? pm.locality;
          _resolvedCity = pm.administrativeArea ?? pm.locality;
        });
      } else {
        setState(() => _resolvedAddress = null);
      }
    } catch (_) {
      if (mounted) setState(() => _resolvedAddress = null);
    } finally {
      if (mounted) setState(() => _isResolvingAddress = false);
    }
  }

  Future<void> _useCurrentLocation() async {
    if (_isResolvingLocation) return;
    setState(() => _isResolvingLocation = true);
    try {
      final locationService = context.read<LocationService>();

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!mounted) return;
      if (!serviceEnabled) {
        SnackbarHelper.showError(
          context,
          'Location services are disabled. Please enable them in Settings.',
        );
        return;
      }

      final granted = await locationService.requestLocationPermission();
      if (!mounted) return;
      if (!granted) {
        SnackbarHelper.showError(context, 'Location permission denied.');
        return;
      }

      final position = await locationService.getCurrentPosition().timeout(
        const Duration(seconds: 15),
      );
      if (!mounted) return;

      _updatePosition(LatLng(position.latitude, position.longitude));
      _animateToSelected(zoom: 16);
    } catch (_) {
      if (mounted) {
        SnackbarHelper.showError(
          context,
          'Unable to fetch current location. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isResolvingLocation = false);
    }
  }

  void _animateToSelected({double zoom = 14}) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_selectedPosition, zoom),
    );
  }

  void _confirm() {
    _resolveAddress().then((_) {
      if (!mounted) return;
      Navigator.of(context).pop(  LocationPickerResult(
        latitude: _selectedPosition.latitude,
        longitude: _selectedPosition.longitude,
        area: _resolvedArea,
        city: _resolvedCity,
        address: _resolvedAddress,
      ));
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        backgroundColor: AppColors.deepRed,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton.icon(
            onPressed: _confirm,
            icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            label: const Text(
              'Confirm',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedPosition,
              zoom: 14,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onTap: _updatePosition,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(bottom: 48),
            child: const Icon(
              Icons.location_on,
              color: AppColors.deepRed,
              size: 48,
            ),
          ),
          Positioned(
            bottom: 120,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: AppColors.deepRed),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _resolvedAddress ?? 'Tap map to select location',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: _resolvedAddress != null
                                ? Theme.of(context).textTheme.bodyMedium?.color
                                : Theme.of(context).hintColor,
                          ),
                        ),
                      ),
                      if (_isResolvingAddress)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.deepRed,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.pin_drop, size: 16,
                          color: AppColors.deepRed),
                      const SizedBox(width: 6),
                      Text(
                        '${_selectedPosition.latitude.toStringAsFixed(6)}, ${_selectedPosition.longitude.toStringAsFixed(6)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 96,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MapFAB(
                  icon: Icons.my_location_rounded,
                  tooltip: 'Use Current Location',
                  isLoading: _isResolvingLocation,
                  onPressed: _useCurrentLocation,
                ),
                const SizedBox(height: 8),
                _MapFAB(
                  icon: Icons.center_focus_strong_rounded,
                  tooltip: 'Center on marker',
                  onPressed: () => _animateToSelected(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapFAB extends StatelessWidget {
  const _MapFAB({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isLoading = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      shape: const CircleBorder(),
      color: Theme.of(context).cardColor,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.deepRed,
                  ),
                )
              : Icon(icon, color: AppColors.deepRed, size: 22),
        ),
      ),
    );
  }
}
