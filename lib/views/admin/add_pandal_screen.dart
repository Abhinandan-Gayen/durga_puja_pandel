import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/admin_pandal_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/location_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../core/utils/validators.dart';
import '../../models/pandal_model.dart';
import 'location_picker_screen.dart';

class AddPandalScreen extends StatelessWidget {
  const AddPandalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PandalFormScreen();
  }
}

class PandalFormScreen extends StatefulWidget {
  const PandalFormScreen({super.key, this.initialPandal});

  final PandalModel? initialPandal;

  @override
  State<PandalFormScreen> createState() => _PandalFormScreenState();
}

class _PandalFormScreenState extends State<PandalFormScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _areaController;
  late final TextEditingController _addressController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final TextEditingController _themeNameController;
  late final TextEditingController _organizerNameController;
  late final TextEditingController _openingTimeController;
  late final TextEditingController _closingTimeController;
  late final TextEditingController _entryFeeController;
  late final TextEditingController _nearbyTransportController;
  late final TextEditingController _thumbnailUrlController;
  late final TextEditingController _galleryUrlsController;
  late final TextEditingController _videoUrlsController;
  late String _city;
  late String _crowdLevel;
  late bool _isFeatured;
  late bool _isActive;
  late bool _parkingAvailable;

  bool _locationLoading = false;
  LocationPickerResult? _locationPreview;

  late final AnimationController _anim;
  late final AnimationController _pulseAnim;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    final pandal = widget.initialPandal ?? PandalModel.empty();
    _nameController = TextEditingController(text: pandal.name);
    _areaController = TextEditingController(text: pandal.area);
    _addressController = TextEditingController(text: pandal.address);
    _descriptionController = TextEditingController(text: pandal.description);
    _latitudeController = TextEditingController(text: '${pandal.latitude}');
    _longitudeController = TextEditingController(text: '${pandal.longitude}');
    _themeNameController = TextEditingController(text: pandal.themeName);
    _organizerNameController = TextEditingController(
      text: pandal.organizerName,
    );
    _openingTimeController = TextEditingController(text: pandal.openingTime);
    _closingTimeController = TextEditingController(text: pandal.closingTime);
    _entryFeeController = TextEditingController(text: '${pandal.entryFee}');
    _nearbyTransportController = TextEditingController(
      text: pandal.nearbyTransport.join('\n'),
    );
    _thumbnailUrlController = TextEditingController(text: pandal.thumbnailUrl);
    _galleryUrlsController = TextEditingController(
      text: pandal.images.join('\n'),
    );
    _videoUrlsController = TextEditingController(
      text: pandal.videos.join('\n'),
    );
    _thumbnailUrlController.addListener(_onMediaChanged);
    _galleryUrlsController.addListener(_onMediaChanged);
    _videoUrlsController.addListener(_onMediaChanged);

    _city = AppConstants.supportedCities.contains(pandal.city)
        ? pandal.city
        : AppConstants.supportedCities.first;
    _crowdLevel = AppConstants.crowdLevels.contains(pandal.crowdLevel)
        ? pandal.crowdLevel
        : AppConstants.crowdLevels.first;
    _isFeatured = pandal.isFeatured;
    _isActive = pandal.isActive;
    _parkingAvailable = pandal.parkingAvailable;

    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 1.0,
      end: 1.04,
    ).animate(CurvedAnimation(parent: _pulseAnim, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _anim.forward();
    });
  }

  void _onMediaChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _themeNameController.dispose();
    _organizerNameController.dispose();
    _openingTimeController.dispose();
    _closingTimeController.dispose();
    _entryFeeController.dispose();
    _nearbyTransportController.dispose();
    _thumbnailUrlController.removeListener(_onMediaChanged);
    _thumbnailUrlController.dispose();
    _galleryUrlsController.removeListener(_onMediaChanged);
    _galleryUrlsController.dispose();
    _videoUrlsController.removeListener(_onMediaChanged);
    _videoUrlsController.dispose();
    _anim.dispose();
    _pulseAnim.dispose();
    super.dispose();
  }

  // ─── URL helpers ───

  static List<String> _parseUrls(String value) {
    final seen = <String>{};
    final result = <String>[];
    for (final url in value.split(RegExp(r'\r?\n'))) {
      final trimmed = url.trim();
      if (trimmed.isNotEmpty && seen.add(trimmed)) {
        result.add(trimmed);
      }
    }
    return result;
  }

  static String? _validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return 'Enter a valid URL';
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return 'URL must start with http or https';
    }
    return null;
  }

  static String? _validateUrlList(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final urls = _parseUrls(value);
    for (final url in urls) {
      final error = _validateUrl(url);
      if (error != null) return error;
    }
    return null;
  }

  int get _galleryUrlCount => _parseUrls(_galleryUrlsController.text).length;
  int get _videoUrlCount => _parseUrls(_videoUrlsController.text).length;

  // ─── location ───

  void _setCityFromReverseGeocode(String? cityName) {
    if (cityName == null || cityName.trim().isEmpty) return;
    final match = AppConstants.supportedCities.firstWhere(
      (c) => c.toLowerCase() == cityName.trim().toLowerCase(),
      orElse: () => '',
    );
    if (match.isNotEmpty) {
      _city = match;
    }
  }

  void _applyPlacemark(Placemark pm) {
    final area = pm.subLocality?.isNotEmpty == true
        ? pm.subLocality!
        : (pm.locality?.isNotEmpty == true ? pm.locality! : '');
    if (area.isNotEmpty) {
      _areaController.text = area;
    }

    _setCityFromReverseGeocode(pm.administrativeArea ?? pm.locality);
  }

  Future<void> _resolveCurrentLocation() async {
    if (_locationLoading) return;
    setState(() => _locationLoading = true);
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

      Position? position;
      try {
        position = await locationService
            .getCurrentPosition()
            .timeout(const Duration(seconds: 15));
      } catch (_) {
        if (mounted) {
          SnackbarHelper.showError(
            context,
            'Unable to fetch current location. Please try again.',
          );
        }
        return;
      }
      if (position == null || !mounted) return;

      List<Placemark> placemarks;
      try {
        placemarks =
            await placemarkFromCoordinates(
              position.latitude,
              position.longitude,
            );
      } catch (_) {
        placemarks = [];
      }
      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        _applyPlacemark(placemarks.first);
      }

      final addressParts = placemarks.isNotEmpty
          ? [
              placemarks.first.name,
              placemarks.first.subLocality,
              placemarks.first.locality,
              placemarks.first.administrativeArea,
              placemarks.first.country,
            ].where((e) => e != null && e.isNotEmpty).join(', ')
          : '';
      if (addressParts.isNotEmpty) {
        _addressController.text = addressParts;
      }

      _latitudeController.text = position.latitude.toStringAsFixed(6);
      _longitudeController.text = position.longitude.toStringAsFixed(6);

      setState(() {
        _locationPreview = LocationPickerResult(
          latitude: position!.latitude,
          longitude: position!.longitude,
          area: _areaController.text,
          city: _city,
          address: _addressController.text,
        );
      });
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(
          context,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _locationLoading = false);
    }
  }

  Future<void> _openMapPicker() async {
    final lat = double.tryParse(_latitudeController.text.trim()) ?? 22.5726;
    final lng = double.tryParse(_longitudeController.text.trim()) ?? 88.3639;

    final result = await Navigator.of(context).push<LocationPickerResult>(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          initialLatitude: lat,
          initialLongitude: lng,
        ),
      ),
    );
    if (result == null || !mounted) return;

    _latitudeController.text = result.latitude.toStringAsFixed(6);
    _longitudeController.text = result.longitude.toStringAsFixed(6);

    _setCityFromReverseGeocode(result.city);

    if (result.address != null && result.address!.isNotEmpty) {
      _addressController.text = result.address!;
    }

    if (result.area != null && result.area!.isNotEmpty) {
      _areaController.text = result.area!;
    }

    setState(() => _locationPreview = result);
  }

  void _clearLocationPreview() {
    setState(() => _locationPreview = null);
  }

  // ─── submit ───

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final thumbnailUrl = _thumbnailUrlController.text.trim();
    if (thumbnailUrl.isEmpty) {
      SnackbarHelper.showError(context, 'Thumbnail image URL is required');
      return;
    }

    final images = _parseUrls(_galleryUrlsController.text);
    final videos = _parseUrls(_videoUrlsController.text);

    if (videos.length > 2) {
      SnackbarHelper.showError(context, 'Maximum 2 video URLs are allowed');
      return;
    }

    final lat = double.tryParse(_latitudeController.text.trim()) ?? 0.0;
    final lng = double.tryParse(_longitudeController.text.trim()) ?? 0.0;

    final initial = widget.initialPandal ?? PandalModel.empty();
    final uid = context.read<AuthController>().firebaseUser?.uid ?? '';
    final pandal = initial.copyWith(
      name: _nameController.text.trim(),
      city: _city,
      area: _areaController.text.trim(),
      address: _addressController.text.trim(),
      description: _descriptionController.text.trim(),
      latitude: lat,
      longitude: lng,
      themeName: _themeNameController.text.trim(),
      organizerName: _organizerNameController.text.trim(),
      openingTime: _openingTimeController.text.trim(),
      closingTime: _closingTimeController.text.trim(),
      entryFee: double.tryParse(_entryFeeController.text.trim()) ?? 0.0,
      crowdLevel: _crowdLevel,
      isFeatured: _isFeatured,
      isActive: _isActive,
      thumbnailUrl: thumbnailUrl,
      images: images,
      videos: videos,
      nearbyTransport: _linesFromController(_nearbyTransportController),
      parkingAvailable: _parkingAvailable,
      createdBy: initial.createdBy.isEmpty ? uid : initial.createdBy,
    );
    final admin = context.read<AdminPandalController>();
    try {
      if (initial.id.isEmpty) {
        await admin.addPandal(pandal);
      } else {
        await admin.updatePandal(pandal);
      }
    } catch (_) {
      if (!mounted) return;
      SnackbarHelper.showError(context, admin.errorMessage ?? 'Save failed');
      return;
    }
    if (!mounted) return;
    if (admin.errorMessage != null) {
      SnackbarHelper.showError(context, admin.errorMessage!);
      return;
    }
    SnackbarHelper.showSuccess(context, 'Pandal saved');
    context.pop();
  }

  List<String> _linesFromController(TextEditingController controller) {
    return controller.text
        .split('\n')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
  }

  Widget _sep(double h) => SizedBox(height: h);

  Widget _animateIn(int index, Widget child) {
    return FadeTransition(
      opacity: _anim,
      child: SlideTransition(
        position:
            Tween<Offset>(
              begin: Offset(0, 0.15 + (index * 0.03)),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _anim,
                curve: Interval(
                  (index * 0.09).clamp(0.0, 0.9),
                  1.0,
                  curve: Curves.easeOutCubic,
                ),
              ),
            ),
        child: child,
      ),
    );
  }

  Widget _buildLocationPreview() {
    final preview = _locationPreview;
    if (preview == null) return _sep(0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.deepRed.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.deepRed.withValues(alpha: 0.18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 18, color: AppColors.deepRed),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    preview.address?.isNotEmpty == true
                        ? preview.address!
                        : 'Location selected',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.deepRed,
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: _clearLocationPreview,
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Text(
                      'Change',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.vermilion,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.pin_drop_outlined,
                    size: 16, color: AppColors.deepRed),
                const SizedBox(width: 6),
                Text(
                  '${preview.latitude.toStringAsFixed(6)}, ${preview.longitude.toStringAsFixed(6)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationActions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: _LocationActionButton(
              icon: Icons.my_location_rounded,
              label: 'Use Current Location',
              isLoading: _locationLoading,
              onTap: _resolveCurrentLocation,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _LocationActionButton(
              icon: Icons.map_rounded,
              label: 'Select on Map',
              onTap: _openMapPicker,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialPandal != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gradientColors = isDark
        ? const [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)]
        : [AppColors.deepRed, AppColors.vermilion, const Color(0xFFC62828)];

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Pandal' : 'New Pandal'),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: gradientColors.first,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<AdminPandalController>(
        builder: (context, admin, _) {
          return Stack(
            children: [
              Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: gradientColors,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(32),
                        ),
                      ),
                      padding: const EdgeInsets.only(top: 12, bottom: 32),
                      child: _HeroHeader(
                        isEditing: isEditing,
                        count: admin.totalPandals,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                      child: Column(
                        children: [
                          if (admin.errorMessage != null) ...[
                            _ErrorBanner(message: admin.errorMessage!),
                            _sep(16),
                          ],

                          _animateIn(
                            0,
                            _SectionCard(
                              title: 'Basic Info',
                              icon: Icons.info_outline_rounded,
                              children: [
                                _Field(
                                  _nameController,
                                  'Pandal Name',
                                  Icons.temple_hindu_rounded,
                                  validator: (v) =>
                                      Validators.required(v, 'Pandal name'),
                                ),
                                _sep(16),
                                _Field(
                                  _descriptionController,
                                  'Description',
                                  Icons.description_outlined,
                                  maxLines: 4,
                                  validator: (v) =>
                                      Validators.required(v, 'Description'),
                                ),
                              ],
                            ),
                          ),

                          _sep(16),

                          _animateIn(
                            1,
                            _SectionCard(
                              title: 'Location',
                              icon: Icons.location_on_outlined,
                              children: [
                                _buildLocationActions(),
                                _buildLocationPreview(),
                                _Field(
                                  _areaController,
                                  'Area',
                                  Icons.place_outlined,
                                  validator: (v) =>
                                      Validators.required(v, 'Area'),
                                ),
                                _sep(16),
                                _Dropdown<String>(
                                  value: _city,
                                  label: 'City',
                                  icon: Icons.location_city_rounded,
                                  items: AppConstants.supportedCities,
                                  display: (c) => c,
                                  onChanged: (v) =>
                                      setState(() => _city = v ?? _city),
                                ),
                                _sep(16),
                                _Field(
                                  _addressController,
                                  'Full Address',
                                  Icons.home_rounded,
                                  validator: (v) =>
                                      Validators.required(v, 'Full address'),
                                ),
                                _sep(16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _Field(
                                        _latitudeController,
                                        'Latitude',
                                        Icons.swap_vert_rounded,
                                        keyboardType: TextInputType.number,
                                        validator: Validators.latitude,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _Field(
                                        _longitudeController,
                                        'Longitude',
                                        Icons.swap_horiz_rounded,
                                        keyboardType: TextInputType.number,
                                        validator: Validators.longitude,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          _sep(16),

                          _animateIn(
                            2,
                            _SectionCard(
                              title: 'Event Details',
                              icon: Icons.auto_awesome_rounded,
                              children: [
                                _Field(
                                  _themeNameController,
                                  'Theme Name',
                                  Icons.palette_outlined,
                                  validator: (v) =>
                                      Validators.required(v, 'Theme name'),
                                ),
                                _sep(16),
                                _Field(
                                  _organizerNameController,
                                  'Organizer',
                                  Icons.people_outline_rounded,
                                  validator: (v) =>
                                      Validators.required(v, 'Organizer name'),
                                ),
                                _sep(16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _Field(
                                        _openingTimeController,
                                        'Opens',
                                        Icons.sunny,
                                        hint: '6:00 AM',
                                        validator: (v) => Validators.required(
                                          v,
                                          'Opening time',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _Field(
                                        _closingTimeController,
                                        'Closes',
                                        Icons.nights_stay_rounded,
                                        hint: '11:00 PM',
                                        validator: (v) => Validators.required(
                                          v,
                                          'Closing time',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                _sep(16),
                                _Field(
                                  _entryFeeController,
                                  'Entry Fee',
                                  Icons.currency_rupee_rounded,
                                  keyboardType: TextInputType.number,
                                  hint: '0 = free',
                                  validator: (v) =>
                                      Validators.nonNegativeNumber(
                                        v,
                                        'Entry fee',
                                      ),
                                ),
                              ],
                            ),
                          ),

                          _sep(16),

                          _animateIn(
                            3,
                            _SectionCard(
                              title: 'Settings',
                              icon: Icons.tune_rounded,
                              children: [
                                _CrowdSelector(
                                  selected: _crowdLevel,
                                  onChanged: (v) =>
                                      setState(() => _crowdLevel = v),
                                ),
                                _sep(18),
                                _Field(
                                  _nearbyTransportController,
                                  'Nearby Transport',
                                  Icons.directions_bus_rounded,
                                  maxLines: 3,
                                  hint: 'One per line',
                                  validator: (v) => Validators.required(
                                    v,
                                    'Nearby transport',
                                  ),
                                ),
                                _sep(4),
                                const Divider(),
                                _sep(4),
                                _SettingToggle(
                                  Icons.local_parking_rounded,
                                  'Parking Available',
                                  _parkingAvailable,
                                  (v) => setState(() => _parkingAvailable = v),
                                ),
                                _SettingToggle(
                                  Icons.star_rounded,
                                  'Featured Pandal',
                                  _isFeatured,
                                  (v) => setState(() => _isFeatured = v),
                                  sub: 'Shown in featured section on home',
                                ),
                                _SettingToggle(
                                  Icons.visibility_rounded,
                                  'Active Listing',
                                  _isActive,
                                  (v) => setState(() => _isActive = v),
                                  sub: 'Visible to all users',
                                ),
                              ],
                            ),
                          ),

                          _sep(16),

                          _animateIn(
                            4,
                            _SectionCard(
                              title: 'Media',
                              icon: Icons.perm_media_outlined,
                              children: [
                                _Field(
                                  _thumbnailUrlController,
                                  'Thumbnail Image URL',
                                  Icons.image_rounded,
                                  hint: 'Enter public image URL',
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty)
                                      return 'Thumbnail URL is required';
                                    return _validateUrl(v);
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 4,
                                    top: 4,
                                  ),
                                  child: Text(
                                    _thumbnailUrlController.text
                                            .trim()
                                            .isNotEmpty
                                        ? '1 thumbnail'
                                        : 'No thumbnail',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ),
                                _sep(16),
                                _MultilineField(
                                  _galleryUrlsController,
                                  'Gallery Image URLs',
                                  Icons.collections_rounded,
                                  hint: 'Enter one public image URL per line',
                                  minLines: 4,
                                  maxLines: 7,
                                  validator: _validateUrlList,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 4,
                                    top: 4,
                                  ),
                                  child: Text(
                                    '$_galleryUrlCount image URL${_galleryUrlCount == 1 ? '' : 's'}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ),
                                _sep(16),
                                _MultilineField(
                                  _videoUrlsController,
                                  'Video URLs',
                                  Icons.videocam_rounded,
                                  hint:
                                      'Enter one public video URL per line',
                                  minLines: 3,
                                  maxLines: 5,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty)
                                      return null;
                                    final error = _validateUrlList(v);
                                    if (error != null) return error;
                                    if (_parseUrls(v).length > 2)
                                      return 'Maximum 2 video URLs are allowed';
                                    return null;
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 4,
                                    top: 4,
                                  ),
                                  child: Text(
                                    '$_videoUrlCount/2 video URLs',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          _sep(16),

                          _animateIn(
                            5,
                            _SaveButton(
                              isEditing: isEditing,
                              isLoading: admin.isLoading,
                              isDark: isDark,
                              pulse: _pulse,
                              onTap: _submit,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (admin.isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.35),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ─── hero header ───

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.isEditing, required this.count});
  final bool isEditing;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.temple_hindu_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isEditing ? 'Edit Pandal' : 'Create New Pandal',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isEditing
                ? 'Update the pandal details below'
                : 'Fill in the details to add a new pandal',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.grid_view_rounded,
                  color: Colors.white70,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '$count pandals in system',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── section card ───

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.deepRed.withValues(alpha: 0.15),
                        AppColors.vermilion.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: AppColors.deepRed),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── form field ───

class _Field extends StatelessWidget {
  const _Field(
    this.controller,
    this.label,
    this.icon, {
    this.hint,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? minLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: minLines,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(
          color: Theme.of(context).hintColor.withValues(alpha: 0.6),
          fontSize: 14,
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.deepRed.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.deepRed),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.deepRed, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}

// ─── dropdown ───

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.value,
    required this.label,
    required this.icon,
    required this.items,
    required this.display,
    required this.onChanged,
  });

  final T value;
  final String label;
  final IconData icon;
  final List<T> items;
  final String Function(T) display;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final safeValue = items.contains(value) ? value : null;
    return DropdownButtonFormField<T>(
      value: safeValue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.deepRed.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.deepRed),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.deepRed, width: 1.8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem(value: item, child: Text(display(item))),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

// ─── toggle ───

class _SettingToggle extends StatelessWidget {
  const _SettingToggle(
    this.icon,
    this.label,
    this.value,
    this.onChanged, {
    this.sub,
  });
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: value
                ? AppColors.deepRed.withValues(alpha: 0.12)
                : Theme.of(context).dividerColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 19,
            color: value ? AppColors.deepRed : Theme.of(context).disabledColor,
          ),
        ),
        title: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        subtitle: sub != null
            ? Text(sub!, style: Theme.of(context).textTheme.bodySmall)
            : null,
        value: value,
        activeColor: AppColors.deepRed,
        onChanged: onChanged,
      ),
    );
  }
}

// ─── crowd chips ───

class _CrowdSelector extends StatelessWidget {
  const _CrowdSelector({required this.selected, required this.onChanged});
  final String selected;
  final ValueChanged<String> onChanged;

  static const _levels = ['low', 'medium', 'high'];
  static const _labels = ['Low', 'Medium', 'High'];
  static const _colors = [
    AppColors.success,
    AppColors.warning,
    AppColors.danger,
  ];
  static const _icons = [
    Icons.sentiment_satisfied_alt,
    Icons.sentiment_neutral,
    Icons.sentiment_very_dissatisfied,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.deepRed.withValues(alpha: 0.15),
                    AppColors.vermilion.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.group_rounded,
                size: 18,
                color: AppColors.deepRed,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Crowd Level',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(3, (i) {
            final sel = selected == _levels[i];
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
                child: GestureDetector(
                  onTap: () => onChanged(_levels[i]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: sel ? _colors[i] : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: sel
                            ? _colors[i]
                            : Theme.of(
                                context,
                              ).dividerColor.withValues(alpha: 0.4),
                        width: sel ? 2 : 1,
                      ),
                      boxShadow: sel
                          ? [
                              BoxShadow(
                                color: _colors[i].withValues(alpha: 0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _icons[i],
                          color: sel
                              ? Colors.white
                              : Theme.of(context).disabledColor,
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _labels[i],
                          style: TextStyle(
                            color: sel
                                ? Colors.white
                                : Theme.of(context).textTheme.bodySmall?.color,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ─── location action button ───

class _LocationActionButton extends StatelessWidget {
  const _LocationActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.deepRed.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isLoading ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.deepRed,
                      ),
                    )
                  : Icon(icon, size: 20, color: AppColors.deepRed),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepRed,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── multiline field ───

class _MultilineField extends StatelessWidget {
  const _MultilineField(
    this.controller,
    this.label,
    this.icon, {
    this.hint,
    this.validator,
    this.maxLines = 4,
    this.minLines = 3,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final String? Function(String?)? validator;
  final int maxLines;
  final int? minLines;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.deepRed.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.deepRed),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: controller,
            validator: validator,
            maxLines: maxLines,
            minLines: minLines,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              hintStyle: TextStyle(
                color: Theme.of(context).hintColor.withValues(alpha: 0.6),
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppColors.deepRed, width: 1.8),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppColors.danger, width: 1.2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppColors.danger, width: 1.8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── save button ───

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.isEditing,
    required this.isLoading,
    required this.isDark,
    required this.pulse,
    required this.onTap,
  });

  final bool isEditing;
  final bool isLoading;
  final bool isDark;
  final Animation<double> pulse;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: isLoading ? const AlwaysStoppedAnimation(1.0) : pulse,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLoading
                ? [Colors.grey.shade400, Colors.grey.shade500]
                : isDark
                    ? [const Color(0xFF7B2FF7), const Color(0xFF4A00E0)]
                    : [AppColors.deepRed, AppColors.vermilion],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isLoading
              ? null
              : [
                  BoxShadow(
                    color: AppColors.deepRed.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isLoading ? null : onTap,
            splashColor: Colors.white.withValues(alpha: 0.15),
            highlightColor: Colors.white.withValues(alpha: 0.08),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.save_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isEditing ? 'Update Pandal' : 'Create Pandal',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── error banner ───

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Theme.of(context).colorScheme.onErrorContainer,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
