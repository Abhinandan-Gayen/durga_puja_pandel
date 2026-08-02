import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/services/location_service.dart';
import '../../core/services/map_service.dart';
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
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  List<String> _suggestions = const [];
  String? _resolvedAddress;
  String? _resolvedArea;
  String? _resolvedCity;
  bool _isResolvingLocation = false;
  bool _isResolvingAddress = false;
  bool _isSearching = false;
  bool _isLoadingSuggestions = false;
  bool _isSaving = false;
  bool _myLocationEnabled = false;

  @override
  void initState() {
    super.initState();
    _selectedPosition = LatLng(widget.initialLatitude, widget.initialLongitude);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _useCurrentLocation(showError: false);
    });
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _selectedPosition = position.target;
    });
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
          _resolvedCity = pm.locality ?? pm.administrativeArea;
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

  Future<void> _useCurrentLocation({bool showError = true}) async {
    if (_isResolvingLocation) return;
    setState(() => _isResolvingLocation = true);
    try {
      final locationService = context.read<LocationService>();

      final position = await locationService.getCurrentPosition();
      if (!mounted) return;

      setState(() {
        _selectedPosition = LatLng(position.latitude, position.longitude);
        _myLocationEnabled = true;
      });
      await _animateToSelected(zoom: 16);
      await _resolveAddress();
    } catch (error) {
      if (mounted && showError) {
        SnackbarHelper.showError(
          context,
          error.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _isResolvingLocation = false);
    }
  }

  Future<void> _animateToSelected({double zoom = 14}) async {
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_selectedPosition, zoom),
    );
  }

  Future<void> _searchPlace() async {
    final query = _searchController.text.trim();
    if (query.isEmpty || _isSearching) return;
    setState(() => _isSearching = true);
    try {
      final results = await locationFromAddress(query);
      if (!mounted) return;
      if (results.isEmpty) {
        SnackbarHelper.showError(context, 'Location not found.');
        return;
      }
      final result = results.first;
      setState(() {
        _selectedPosition = LatLng(result.latitude, result.longitude);
        _suggestions = const [];
      });
      await _animateToSelected(zoom: 16);
      await _resolveAddress();
      if (mounted) FocusScope.of(context).unfocus();
    } catch (_) {
      if (mounted) {
        SnackbarHelper.showError(
          context,
          'Unable to find that location. Try a more specific name.',
        );
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    final query = value.trim();
    if (query.length < 2) {
      setState(() {
        _suggestions = const [];
        _isLoadingSuggestions = false;
      });
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      _loadSuggestions(query);
    });
  }

  Future<void> _loadSuggestions(String query) async {
    if (!mounted || _searchController.text.trim() != query) return;
    setState(() => _isLoadingSuggestions = true);
    final results = await context.read<MapService>().placeSuggestions(
      query: query,
      latitude: _selectedPosition.latitude,
      longitude: _selectedPosition.longitude,
    );
    if (!mounted || _searchController.text.trim() != query) return;
    setState(() {
      _suggestions = results;
      _isLoadingSuggestions = false;
    });
  }

  void _selectSuggestion(String suggestion) {
    _searchDebounce?.cancel();
    setState(() => _suggestions = const []);
    _searchController.text = suggestion;
    _searchController.selection = TextSelection.collapsed(
      offset: suggestion.length,
    );
    _searchPlace();
  }

  Future<void> _confirm() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    await _resolveAddress();
    if (!mounted) return;
    Navigator.of(context).pop(
      LocationPickerResult(
        latitude: _selectedPosition.latitude,
        longitude: _selectedPosition.longitude,
        area: _resolvedArea,
        city: _resolvedCity,
        address: _resolvedAddress,
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchDebounce?.cancel();
    _searchController.dispose();
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
            onPressed: _isSaving ? null : _confirm,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.save_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
            label: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
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
            onMapCreated: (controller) {
              _mapController = controller;
              _animateToSelected();
            },
            onCameraMove: _onCameraMove,
            onCameraIdle: _resolveAddress,
            myLocationEnabled: _myLocationEnabled,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          const IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 38),
                child: Icon(
                  Icons.location_on,
                  color: AppColors.deepRed,
                  size: 50,
                  shadows: [
                    Shadow(
                      color: Colors.black38,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 14,
            left: 14,
            right: 14,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  color: Colors.white,
                  elevation: 5,
                  borderRadius: BorderRadius.circular(16),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onChanged: _onSearchChanged,
                    onSubmitted: (_) => _searchPlace(),
                    decoration: InputDecoration(
                      hintText: 'Search area, city or place...',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.deepRed,
                      ),
                      suffixIcon: _isSearching || _isLoadingSuggestions
                          ? const Padding(
                              padding: EdgeInsets.all(14),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.deepRed,
                                ),
                              ),
                            )
                          : IconButton(
                              onPressed: _searchPlace,
                              icon: const Icon(
                                Icons.arrow_forward_rounded,
                                color: AppColors.deepRed,
                              ),
                            ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                if (_suggestions.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Material(
                    color: Colors.white,
                    elevation: 6,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 270),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shrinkWrap: true,
                        itemCount: _suggestions.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1, indent: 48),
                        itemBuilder: (context, index) {
                          final suggestion = _suggestions[index];
                          return ListTile(
                            dense: true,
                            leading: const Icon(
                              Icons.location_on_outlined,
                              color: AppColors.deepRed,
                              size: 21,
                            ),
                            title: Text(
                              suggestion,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onTap: () => _selectSuggestion(suggestion),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ],
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
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.deepRed,
                      ),
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
                      const Icon(
                        Icons.pin_drop,
                        size: 16,
                        color: AppColors.deepRed,
                      ),
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
