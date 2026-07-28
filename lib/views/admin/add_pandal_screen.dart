import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../controllers/admin_pandal_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../core/utils/validators.dart';
import '../../models/pandal_model.dart';

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
  final _imagePicker = ImagePicker();
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
  late String _city;
  late String _crowdLevel;
  late bool _isFeatured;
  late bool _isActive;
  late bool _parkingAvailable;
  late String _thumbnailUrl;
  late List<String> _imageUrls;
  late List<String> _videoUrls;

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
    _organizerNameController = TextEditingController(text: pandal.organizerName);
    _openingTimeController = TextEditingController(text: pandal.openingTime);
    _closingTimeController = TextEditingController(text: pandal.closingTime);
    _entryFeeController = TextEditingController(text: '${pandal.entryFee}');
    _nearbyTransportController = TextEditingController(
      text: pandal.nearbyTransport.join('\n'),
    );
    _city = AppConstants.supportedCities.contains(pandal.city)
        ? pandal.city
        : AppConstants.supportedCities.first;
    _crowdLevel = AppConstants.crowdLevels.contains(pandal.crowdLevel)
        ? pandal.crowdLevel
        : AppConstants.crowdLevels.first;
    _isFeatured = pandal.isFeatured;
    _isActive = pandal.isActive;
    _parkingAvailable = pandal.parkingAvailable;
    _thumbnailUrl = pandal.thumbnailUrl;
    _imageUrls = [...pandal.images];
    _videoUrls = [...pandal.videos];

    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseAnim, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _anim.forward();
    });
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
    _anim.dispose();
    _pulseAnim.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_thumbnailUrl.isEmpty) {
      SnackbarHelper.showError(context, 'Thumbnail image is required');
      return;
    }
    final initial = widget.initialPandal ?? PandalModel.empty();
    final uid = context.read<AuthController>().firebaseUser?.uid ?? '';
    final pandal = initial.copyWith(
      name: _nameController.text.trim(),
      city: _city,
      area: _areaController.text.trim(),
      address: _addressController.text.trim(),
      description: _descriptionController.text.trim(),
      latitude: double.tryParse(_latitudeController.text.trim()) ?? 0.0,
      longitude: double.tryParse(_longitudeController.text.trim()) ?? 0.0,
      themeName: _themeNameController.text.trim(),
      organizerName: _organizerNameController.text.trim(),
      openingTime: _openingTimeController.text.trim(),
      closingTime: _closingTimeController.text.trim(),
      entryFee: double.tryParse(_entryFeeController.text.trim()) ?? 0.0,
      crowdLevel: _crowdLevel,
      isFeatured: _isFeatured,
      isActive: _isActive,
      thumbnailUrl: _thumbnailUrl,
      images: _imageUrls,
      videos: _videoUrls,
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

  Future<void> _uploadThumbnail() async {
    try {
      final file = await _pickSingleImage();
      if (file == null || !mounted) return;
      final url =
          await context.read<AdminPandalController>().uploadThumbnail(file);
      if (!mounted) return;
      if (url == null) {
        SnackbarHelper.showError(
          context,
          context.read<AdminPandalController>().errorMessage ?? 'Upload failed',
        );
        return;
      }
      setState(() => _thumbnailUrl = url);
    } catch (_) {
      if (!mounted) return;
      SnackbarHelper.showError(
        context,
        context.read<AdminPandalController>().errorMessage ?? 'Upload failed',
      );
    }
  }

  Future<void> _uploadImages() async {
    try {
      final files = await _pickMultipleImages();
      if (files.isEmpty || !mounted) return;
      final urls =
          await context.read<AdminPandalController>().uploadImages(files);
      if (!mounted) return;
      if (urls.isEmpty) {
        SnackbarHelper.showError(
          context,
          context.read<AdminPandalController>().errorMessage ?? 'Upload failed',
        );
        return;
      }
      setState(() {
        for (final url in urls) {
          if (!_imageUrls.contains(url)) _imageUrls.add(url);
        }
      });
    } catch (_) {
      if (!mounted) return;
      SnackbarHelper.showError(
        context,
        context.read<AdminPandalController>().errorMessage ?? 'Upload failed',
      );
    }
  }

  Future<void> _uploadVideos() async {
    try {
      final files = await _pickMultipleVideos();
      if (files.isEmpty || !mounted) return;
      final urls =
          await context.read<AdminPandalController>().uploadVideos(files);
      if (!mounted) return;
      if (urls.isEmpty) {
        SnackbarHelper.showError(
          context,
          context.read<AdminPandalController>().errorMessage ?? 'Upload failed',
        );
        return;
      }
      setState(() {
        for (final url in urls) {
          if (!_videoUrls.contains(url)) _videoUrls.add(url);
        }
      });
    } catch (_) {
      if (!mounted) return;
      SnackbarHelper.showError(
        context,
        context.read<AdminPandalController>().errorMessage ?? 'Upload failed',
      );
    }
  }

  Future<File?> _pickSingleImage() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    return File(image.path);
  }

  Future<List<File>> _pickMultipleImages() async {
    final images = await _imagePicker.pickMultiImage();
    return images.map((image) => File(image.path)).toList();
  }

  Future<List<File>> _pickMultipleVideos() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: true,
    );
    if (result == null) return [];
    return result.files
        .where((file) => file.path != null)
        .map((file) => File(file.path!))
        .toList();
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
        position: Tween<Offset>(
          begin: Offset(0, 0.15 + (index * 0.03)),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _anim,
          curve: Interval(
            (index * 0.09).clamp(0.0, 0.9),
            1.0,
            curve: Curves.easeOutCubic,
          ),
        )),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialPandal != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Pandal' : 'New Pandal'),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<AdminPandalController>(
        builder: (context, admin, _) {
          return Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 260,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF1A1A2E), const Color(0xFF16213E), const Color(0xFF0F3460)]
                          : [AppColors.deepRed, AppColors.vermilion, const Color(0xFFC62828)],
                    ),
                  ),
                ),
              ),
              Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _HeroHeader(
                      isEditing: isEditing,
                      count: admin.totalPandals,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                      child: Column(
                        children: [
                          if (admin.errorMessage != null) ...[
                            _ErrorBanner(message: admin.errorMessage!),
                            _sep(16),
                          ],

                          _animateIn(0, _SectionCard(
                            title: 'Basic Info',
                            icon: Icons.info_outline_rounded,
                            children: [
                              _Field(_nameController, 'Pandal Name', Icons.temple_hindu_rounded,
                                  validator: (v) => Validators.required(v, 'Pandal name')),
                              _sep(16),
                              _Field(_descriptionController, 'Description', Icons.description_outlined, maxLines: 4,
                                  validator: (v) => Validators.required(v, 'Description')),
                            ],
                          )),

                          _sep(16),

                          _animateIn(1, _SectionCard(
                            title: 'Location',
                            icon: Icons.location_on_outlined,
                            children: [
                              _Field(_areaController, 'Area', Icons.place_outlined,
                                  validator: (v) => Validators.required(v, 'Area')),
                              _sep(16),
                              _Dropdown<String>(
                                value: _city, label: 'City', icon: Icons.location_city_rounded,
                                items: AppConstants.supportedCities,
                                display: (c) => c,
                                onChanged: (v) => setState(() => _city = v ?? _city),
                              ),
                              _sep(16),
                              _Field(_addressController, 'Full Address', Icons.home_rounded,
                                  validator: (v) => Validators.required(v, 'Full address')),
                              _sep(16),
                              Row(children: [
                                Expanded(child: _Field(_latitudeController, 'Latitude', Icons.swap_vert_rounded,
                                    keyboardType: TextInputType.number, validator: Validators.latitude)),
                                const SizedBox(width: 12),
                                Expanded(child: _Field(_longitudeController, 'Longitude', Icons.swap_horiz_rounded,
                                    keyboardType: TextInputType.number, validator: Validators.longitude)),
                              ]),
                            ],
                          )),

                          _sep(16),

                          _animateIn(2, _SectionCard(
                            title: 'Event Details',
                            icon: Icons.auto_awesome_rounded,
                            children: [
                              _Field(_themeNameController, 'Theme Name', Icons.palette_outlined,
                                  validator: (v) => Validators.required(v, 'Theme name')),
                              _sep(16),
                              _Field(_organizerNameController, 'Organizer', Icons.people_outline_rounded,
                                  validator: (v) => Validators.required(v, 'Organizer name')),
                              _sep(16),
                              Row(children: [
                                Expanded(child: _Field(_openingTimeController, 'Opens', Icons.sunny, hint: '6:00 AM',
                                    validator: (v) => Validators.required(v, 'Opening time'))),
                                const SizedBox(width: 12),
                                Expanded(child: _Field(_closingTimeController, 'Closes', Icons.nights_stay_rounded,
                                    hint: '11:00 PM', validator: (v) => Validators.required(v, 'Closing time'))),
                              ]),
                              _sep(16),
                              _Field(_entryFeeController, 'Entry Fee', Icons.currency_rupee_rounded,
                                  keyboardType: TextInputType.number, hint: '0 = free',
                                  validator: (v) => Validators.nonNegativeNumber(v, 'Entry fee')),
                            ],
                          )),

                          _sep(16),

                          _animateIn(3, _SectionCard(
                            title: 'Settings',
                            icon: Icons.tune_rounded,
                            children: [
                              _CrowdSelector(
                                selected: _crowdLevel,
                                onChanged: (v) => setState(() => _crowdLevel = v),
                              ),
                              _sep(18),
                              _Field(_nearbyTransportController, 'Nearby Transport', Icons.directions_bus_rounded,
                                  maxLines: 3, hint: 'One per line',
                                  validator: (v) => Validators.required(v, 'Nearby transport')),
                              _sep(4), const Divider(), _sep(4),
                              _SettingToggle(Icons.local_parking_rounded, 'Parking Available', _parkingAvailable,
                                  (v) => setState(() => _parkingAvailable = v)),
                              _SettingToggle(Icons.star_rounded, 'Featured Pandal', _isFeatured,
                                  (v) => setState(() => _isFeatured = v), sub: 'Shown in featured section on home'),
                              _SettingToggle(Icons.visibility_rounded, 'Active Listing', _isActive,
                                  (v) => setState(() => _isActive = v), sub: 'Visible to all users'),
                            ],
                          )),

                          _sep(16),

                          _animateIn(4, _SectionCard(
                            title: 'Media',
                            icon: Icons.perm_media_outlined,
                            children: [
                              _MediaTile(
                                title: 'Thumbnail Image', icon: Icons.image_rounded,
                                urls: _thumbnailUrl.isEmpty ? const [] : [_thumbnailUrl],
                                onUpload: admin.isLoading ? null : _uploadThumbnail,
                                onRemove: (_) => setState(() => _thumbnailUrl = ''),
                                enabled: !admin.isLoading, required: true,
                              ),
                              _sep(4), const Divider(), _sep(4),
                              _MediaTile(
                                title: 'Gallery Images', icon: Icons.collections_rounded, urls: _imageUrls,
                                onUpload: admin.isLoading ? null : _uploadImages,
                                onRemove: (url) => setState(() => _imageUrls.remove(url)),
                                enabled: !admin.isLoading,
                              ),
                              _sep(4), const Divider(), _sep(4),
                              _MediaTile(
                                title: 'Videos', icon: Icons.videocam_rounded, urls: _videoUrls,
                                onUpload: admin.isLoading ? null : _uploadVideos,
                                onRemove: (url) => setState(() => _videoUrls.remove(url)),
                                enabled: !admin.isLoading,
                              ),
                            ],
                          )),

                          _sep(16),

                          _animateIn(5, _SaveButton(
                            isEditing: isEditing,
                            isLoading: admin.isLoading,
                            isDark: isDark,
                            pulse: _pulse,
                            onTap: _submit,
                          )),
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
                    child: const Center(child: CircularProgressIndicator(color: Colors.white)),
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
    final topPad = MediaQuery.of(context).viewPadding.top + kToolbarHeight + 16;
    return Padding(
      padding: EdgeInsets.only(top: topPad, left: 24, right: 24),
      child: Column(
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
            ),
            child: const Icon(Icons.temple_hindu_rounded, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            isEditing ? 'Edit Pandal' : 'Create New Pandal',
            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
          const SizedBox(height: 6),
          Text(
            isEditing ? 'Update the pandal details below' : 'Fill in the details to add a new pandal',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
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
                const Icon(Icons.grid_view_rounded, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Text(
                  '$count pandals in system',
                  style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
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
  const _SectionCard({required this.title, required this.icon, required this.children});
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Row(children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.deepRed.withValues(alpha: 0.15), AppColors.vermilion.withValues(alpha: 0.08)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: AppColors.deepRed),
              ),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: -0.2)),
            ]),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
          ),
        ],
      ),
    );
  }
}

// ─── form field ───

class _Field extends StatelessWidget {
  const _Field(this.controller, this.label, this.icon, {
    this.hint, this.validator, this.keyboardType, this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Theme.of(context).hintColor.withValues(alpha: 0.6), fontSize: 14),
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.deepRed.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 20, color: AppColors.deepRed),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.4))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.4))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.deepRed, width: 1.8)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.danger, width: 1.2)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.danger, width: 1.8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

// ─── dropdown ───

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.value, required this.label, required this.icon,
    required this.items, required this.display, required this.onChanged,
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
          decoration: BoxDecoration(color: AppColors.deepRed.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 20, color: AppColors.deepRed),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.4))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.deepRed, width: 1.8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(display(item)))).toList(),
      onChanged: onChanged,
    );
  }
}

// ─── toggle ───

class _SettingToggle extends StatelessWidget {
  const _SettingToggle(this.icon, this.label, this.value, this.onChanged, {this.sub});
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
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: value ? AppColors.deepRed.withValues(alpha: 0.12) : Theme.of(context).dividerColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 19, color: value ? AppColors.deepRed : Theme.of(context).disabledColor),
        ),
        title: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        subtitle: sub != null ? Text(sub!, style: Theme.of(context).textTheme.bodySmall) : null,
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
  static const _colors = [AppColors.success, AppColors.warning, AppColors.danger];
  static const _icons = [Icons.sentiment_satisfied_alt, Icons.sentiment_neutral, Icons.sentiment_very_dissatisfied];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [AppColors.deepRed.withValues(alpha: 0.15), AppColors.vermilion.withValues(alpha: 0.08)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.group_rounded, size: 18, color: AppColors.deepRed),
          ),
          const SizedBox(width: 10),
          const Text('Crowd Level', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ]),
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
                        color: sel ? _colors[i] : Theme.of(context).dividerColor.withValues(alpha: 0.4),
                        width: sel ? 2 : 1,
                      ),
                      boxShadow: sel
                          ? [BoxShadow(color: _colors[i].withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4))]
                          : null,
                    ),
                    child: Column(children: [
                      Icon(_icons[i], color: sel ? Colors.white : Theme.of(context).disabledColor, size: 22),
                      const SizedBox(height: 4),
                      Text(_labels[i], style: TextStyle(
                          color: sel ? Colors.white : Theme.of(context).textTheme.bodySmall?.color,
                          fontWeight: FontWeight.w700, fontSize: 13)),
                    ]),
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

// ─── media tile ───

class _MediaTile extends StatelessWidget {
  const _MediaTile({
    required this.title, required this.icon, required this.urls,
    required this.onUpload, required this.onRemove, required this.enabled,
    this.required = false,
  });

  final String title;
  final IconData icon;
  final List<String> urls;
  final VoidCallback? onUpload;
  final ValueChanged<String> onRemove;
  final bool enabled;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(color: AppColors.deepRed.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: AppColors.deepRed),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                if (required) ...[
                  const SizedBox(width: 4),
                  const Text('*', style: TextStyle(color: AppColors.danger, fontSize: 15, fontWeight: FontWeight.w800)),
                ],
              ]),
              Text('${urls.length} file${urls.length == 1 ? '' : 's'}', style: Theme.of(context).textTheme.bodySmall),
            ]),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: enabled ? onUpload : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  gradient: enabled ? const LinearGradient(colors: [AppColors.deepRed, AppColors.vermilion]) : null,
                  color: enabled ? null : Theme.of(context).disabledColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.add_rounded, size: 16, color: enabled ? Colors.white : Theme.of(context).disabledColor),
                  const SizedBox(width: 4),
                  Text('Add', style: TextStyle(
                      color: enabled ? Colors.white : Theme.of(context).disabledColor,
                      fontSize: 13, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ),
        ]),
        if (urls.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(spacing: 10, runSpacing: 10, children: [
            for (final url in urls)
              Container(
                padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8, right: 6),
                decoration: BoxDecoration(
                  color: (Theme.of(context).colorScheme.surfaceContainerHighest ?? Theme.of(context).dividerColor).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.25)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(icon, size: 14, color: AppColors.deepRed.withValues(alpha: 0.7)),
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: Text(url, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () => onRemove(url),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.close_rounded, size: 16, color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ]),
              ),
          ]),
        ],
      ],
    );
  }
}

// ─── save button ───

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.isEditing, required this.isLoading, required this.isDark,
    required this.pulse, required this.onTap,
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
        width: double.infinity, height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLoading
                ? [Colors.grey.shade400, Colors.grey.shade500]
                : isDark
                    ? [const Color(0xFF7B2FF7), const Color(0xFF4A00E0)]
                    : [AppColors.deepRed, AppColors.vermilion],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isLoading ? null : [
            BoxShadow(color: AppColors.deepRed.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8)),
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
                  ? const SizedBox(width: 24, height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.save_rounded, color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Text(isEditing ? 'Update Pandal' : 'Create Pandal',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                    ]),
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
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.errorContainer, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Icon(Icons.error_outline_rounded, color: Theme.of(context).colorScheme.onErrorContainer, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(message, style: TextStyle(
            color: Theme.of(context).colorScheme.onErrorContainer, fontSize: 13, fontWeight: FontWeight.w500))),
      ]),
    );
  }
}
