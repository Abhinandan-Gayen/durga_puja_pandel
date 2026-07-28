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
    with SingleTickerProviderStateMixin {
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

  late final AnimationController _animController;
  late final Animation<double> _fadeSlide;

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
    _city = pandal.city;
    _crowdLevel = pandal.crowdLevel;
    _isFeatured = pandal.isFeatured;
    _isActive = pandal.isActive;
    _parkingAvailable = pandal.parkingAvailable;
    _thumbnailUrl = pandal.thumbnailUrl;
    _imageUrls = [...pandal.images];
    _videoUrls = [...pandal.videos];

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeSlide = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _animController.forward();
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
    _animController.dispose();
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
      latitude: double.parse(_latitudeController.text.trim()),
      longitude: double.parse(_longitudeController.text.trim()),
      themeName: _themeNameController.text.trim(),
      organizerName: _organizerNameController.text.trim(),
      openingTime: _openingTimeController.text.trim(),
      closingTime: _closingTimeController.text.trim(),
      entryFee: double.parse(_entryFeeController.text.trim()),
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
    if (initial.id.isEmpty) {
      await admin.addPandal(pandal);
    } else {
      await admin.updatePandal(pandal);
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
    final file = await _pickSingleImage();
    if (file == null || !mounted) return;
    final url = await context.read<AdminPandalController>().uploadThumbnail(file);
    if (!mounted) return;
    if (url == null) {
      SnackbarHelper.showError(
        context,
        context.read<AdminPandalController>().errorMessage ?? 'Upload failed',
      );
      return;
    }
    setState(() => _thumbnailUrl = url);
  }

  Future<void> _uploadImages() async {
    final files = await _pickMultipleImages();
    if (files.isEmpty || !mounted) return;
    final urls = await context.read<AdminPandalController>().uploadImages(files);
    if (!mounted) return;
    if (urls.isEmpty) {
      SnackbarHelper.showError(
        context,
        context.read<AdminPandalController>().errorMessage ?? 'Upload failed',
      );
      return;
    }
    setState(() => _imageUrls.addAll(urls));
  }

  Future<void> _uploadVideos() async {
    final files = await _pickMultipleVideos();
    if (files.isEmpty || !mounted) return;
    final urls = await context.read<AdminPandalController>().uploadVideos(files);
    if (!mounted) return;
    if (urls.isEmpty) {
      SnackbarHelper.showError(
        context,
        context.read<AdminPandalController>().errorMessage ?? 'Upload failed',
      );
      return;
    }
    setState(() => _videoUrls.addAll(urls));
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

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required int index, required List<Widget> children}) {
    return FadeTransition(
      opacity: _fadeSlide,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animController,
          curve: Interval(
            (index * 0.12).clamp(0.0, 0.88),
            1.0,
            curve: Curves.easeOutCubic,
          ),
        )),
        child: Card(
          margin: const EdgeInsets.only(bottom: 20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialPandal != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Pandal' : 'Add Pandal'),
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: Consumer<AdminPandalController>(
        builder: (context, admin, _) {
          return Stack(
            children: [
              Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  children: [
                    if (admin.errorMessage != null) ...[
                      _ErrorBanner(message: admin.errorMessage!),
                      const SizedBox(height: 16),
                    ],

                    _sectionHeader('Basic Information', Icons.info_outline_rounded),
                    _sectionCard(index: 0, children: [
                      _buildTextField(
                        controller: _nameController,
                        label: 'Pandal Name',
                        icon: Icons.temple_hindu_rounded,
                        validator: (v) => Validators.required(v, 'Pandal name'),
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        icon: Icons.description_outlined,
                        maxLines: 4,
                        validator: (v) => Validators.required(v, 'Description'),
                      ),
                    ]),

                    _sectionHeader('Location', Icons.location_on_outlined),
                    _sectionCard(index: 1, children: [
                      _buildTextField(
                        controller: _areaController,
                        label: 'Area',
                        icon: Icons.place_outlined,
                        validator: (v) => Validators.required(v, 'Area'),
                      ),
                      const SizedBox(height: 14),
                      _buildDropdown<String>(
                        value: _city,
                        label: 'City',
                        icon: Icons.location_city_rounded,
                        items: AppConstants.supportedCities,
                        itemBuilder: (city) => city,
                        onChanged: (v) => setState(() => _city = v ?? _city),
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _addressController,
                        label: 'Full Address',
                        icon: Icons.home_rounded,
                        validator: (v) => Validators.required(v, 'Full address'),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _latitudeController,
                              label: 'Latitude',
                              icon: Icons.swap_vert_rounded,
                              keyboardType: TextInputType.number,
                              validator: Validators.latitude,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _longitudeController,
                              label: 'Longitude',
                              icon: Icons.swap_horiz_rounded,
                              keyboardType: TextInputType.number,
                              validator: Validators.longitude,
                            ),
                          ),
                        ],
                      ),
                    ]),

                    _sectionHeader('Details', Icons.format_list_bulleted_rounded),
                    _sectionCard(index: 2, children: [
                      _buildTextField(
                        controller: _themeNameController,
                        label: 'Theme Name',
                        icon: Icons.palette_outlined,
                        validator: (v) => Validators.required(v, 'Theme name'),
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _organizerNameController,
                        label: 'Organizer Name',
                        icon: Icons.people_outline_rounded,
                        validator: (v) => Validators.required(v, 'Organizer name'),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _openingTimeController,
                              label: 'Opening Time',
                              icon: Icons.access_time_rounded,
                              hint: 'e.g. 6:00 AM',
                              validator: (v) => Validators.required(v, 'Opening time'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _closingTimeController,
                              label: 'Closing Time',
                              icon: Icons.access_time_rounded,
                              hint: 'e.g. 11:00 PM',
                              validator: (v) => Validators.required(v, 'Closing time'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _entryFeeController,
                        label: 'Entry Fee',
                        icon: Icons.currency_rupee_rounded,
                        keyboardType: TextInputType.number,
                        hint: '0 for free',
                        validator: (v) => Validators.nonNegativeNumber(v, 'Entry fee'),
                      ),
                    ]),

                    _sectionHeader('Settings', Icons.tune_rounded),
                    _sectionCard(index: 3, children: [
                      _buildDropdown<String>(
                        value: _crowdLevel,
                        label: 'Crowd Level',
                        icon: Icons.group_rounded,
                        items: AppConstants.crowdLevels,
                        itemBuilder: (level) => level,
                        onChanged: (v) => setState(() => _crowdLevel = v ?? _crowdLevel),
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _nearbyTransportController,
                        label: 'Nearby Transport',
                        icon: Icons.directions_bus_rounded,
                        maxLines: 3,
                        hint: 'One per line',
                        validator: (v) => Validators.required(v, 'Nearby transport'),
                      ),
                      const Divider(height: 26),
                      _buildSettingTile(
                        icon: Icons.local_parking_rounded,
                        label: 'Parking Available',
                        value: _parkingAvailable,
                        onChanged: (v) => setState(() => _parkingAvailable = v),
                      ),
                      _buildSettingTile(
                        icon: Icons.star_rounded,
                        label: 'Featured Pandal',
                        subtitle: 'Shows in featured section on home',
                        value: _isFeatured,
                        onChanged: (v) => setState(() => _isFeatured = v),
                      ),
                      _buildSettingTile(
                        icon: Icons.visibility_rounded,
                        label: 'Active Listing',
                        subtitle: 'Visible to all users',
                        value: _isActive,
                        onChanged: (v) => setState(() => _isActive = v),
                      ),
                    ]),

                    _sectionHeader('Media', Icons.perm_media_outlined),
                    _sectionCard(index: 4, children: [
                      _MediaUploadTile(
                        title: 'Thumbnail Image',
                        icon: Icons.image_rounded,
                        urls: _thumbnailUrl.isEmpty ? const [] : [_thumbnailUrl],
                        onUpload: admin.isLoading ? null : _uploadThumbnail,
                        onRemove: (_) => setState(() => _thumbnailUrl = ''),
                        enabled: !admin.isLoading,
                        required: true,
                      ),
                      const Divider(height: 20),
                      _MediaUploadTile(
                        title: 'Gallery Images',
                        icon: Icons.collections_rounded,
                        urls: _imageUrls,
                        onUpload: admin.isLoading ? null : _uploadImages,
                        onRemove: (url) => setState(() => _imageUrls.remove(url)),
                        enabled: !admin.isLoading,
                      ),
                      const Divider(height: 20),
                      _MediaUploadTile(
                        title: 'Videos',
                        icon: Icons.videocam_rounded,
                        urls: _videoUrls,
                        onUpload: admin.isLoading ? null : _uploadVideos,
                        onRemove: (url) => setState(() => _videoUrls.remove(url)),
                        enabled: !admin.isLoading,
                      ),
                    ]),

                    const SizedBox(height: 4),
                    FadeTransition(
                      opacity: _fadeSlide,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.15),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _animController,
                          curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
                        )),
                        child: Container(
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [AppColors.premiumDarkGradientStart, AppColors.premiumDarkGradientEnd]
                                  : [AppColors.deepRed, AppColors.vermilion],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.deepRed.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: admin.isLoading ? null : _submit,
                              child: Center(
                                child: admin.isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.save_rounded, color: Colors.white, size: 22),
                                          const SizedBox(width: 10),
                                          Text(
                                            isEditing ? 'Update Pandal' : 'Create Pandal',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (admin.isLoading)
                Positioned.fill(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.6),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required String label,
    required IconData icon,
    required List<T> items,
    required String Function(T) itemBuilder,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(itemBuilder(item))))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String label,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        subtitle: subtitle != null
            ? Text(subtitle, style: Theme.of(context).textTheme.bodySmall)
            : null,
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _MediaUploadTile extends StatelessWidget {
  const _MediaUploadTile({
    required this.title,
    required this.icon,
    required this.urls,
    required this.onUpload,
    required this.onRemove,
    required this.enabled,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      if (required) ...[
                        const SizedBox(width: 6),
                        const Text('*', style: TextStyle(color: AppColors.danger, fontSize: 14, fontWeight: FontWeight.w700)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${urls.length} uploaded',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Container(
              height: 36,
              decoration: BoxDecoration(
                gradient: enabled
                    ? LinearGradient(
                        colors: isDark
                            ? [AppColors.premiumDarkGradientStart, AppColors.premiumDarkGradientEnd]
                            : [AppColors.deepRed, AppColors.vermilion],
                      )
                    : null,
                color: enabled ? null : Theme.of(context).disabledColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: onUpload,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_upload_rounded,
                          size: 16,
                          color: enabled ? Colors.white : Theme.of(context).disabledColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          urls.isEmpty ? 'Upload' : 'Add',
                          style: TextStyle(
                            color: enabled ? Colors.white : Theme.of(context).disabledColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (urls.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final url in urls)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.link_rounded,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 180),
                        child: Text(
                          url,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: () => onRemove(url),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
