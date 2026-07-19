import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../controllers/admin_pandal_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../core/utils/validators.dart';
import '../../models/pandal_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

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

class _PandalFormScreenState extends State<PandalFormScreen> {
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
    _city = pandal.city;
    _crowdLevel = pandal.crowdLevel;
    _isFeatured = pandal.isFeatured;
    _isActive = pandal.isActive;
    _parkingAvailable = pandal.parkingAvailable;
    _thumbnailUrl = pandal.thumbnailUrl;
    _imageUrls = [...pandal.images];
    _videoUrls = [...pandal.videos];
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
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
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
    if (!mounted) {
      return;
    }
    if (admin.errorMessage != null) {
      SnackbarHelper.showError(context, admin.errorMessage!);
      return;
    }
    SnackbarHelper.showSuccess(context, 'Pandal saved');
    context.pop();
  }

  Future<void> _uploadThumbnail() async {
    final file = await _pickSingleImage();
    if (file == null || !mounted) {
      return;
    }
    final url = await context.read<AdminPandalController>().uploadThumbnail(
      file,
    );
    if (!mounted) {
      return;
    }
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
    if (files.isEmpty || !mounted) {
      return;
    }
    final urls = await context.read<AdminPandalController>().uploadImages(
      files,
    );
    if (!mounted) {
      return;
    }
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
    if (files.isEmpty || !mounted) {
      return;
    }
    final urls = await context.read<AdminPandalController>().uploadVideos(
      files,
    );
    if (!mounted) {
      return;
    }
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
    if (image == null) {
      return null;
    }
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
    if (result == null) {
      return [];
    }
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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialPandal != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit pandal' : 'Add pandal')),
      body: Consumer<AdminPandalController>(
        builder: (context, admin, _) {
          return Stack(
            children: [
              Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (admin.errorMessage != null) ...[
                      _ErrorBanner(message: admin.errorMessage!),
                      const SizedBox(height: 12),
                    ],
                    CustomTextField(
                      controller: _nameController,
                      label: 'Pandal name',
                      validator: (value) =>
                          Validators.required(value, 'Pandal name'),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      maxLines: 4,
                      validator: (value) =>
                          Validators.required(value, 'Description'),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _areaController,
                      label: 'Area',
                      validator: (value) => Validators.required(value, 'Area'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _city,
                      decoration: const InputDecoration(labelText: 'City'),
                      items: AppConstants.supportedCities
                          .map(
                            (city) => DropdownMenuItem(
                              value: city,
                              child: Text(city),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _city = value ?? _city),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _addressController,
                      label: 'Full address',
                      validator: (value) =>
                          Validators.required(value, 'Full address'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _latitudeController,
                            label: 'Latitude',
                            keyboardType: TextInputType.number,
                            validator: Validators.latitude,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: _longitudeController,
                            label: 'Longitude',
                            keyboardType: TextInputType.number,
                            validator: Validators.longitude,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _themeNameController,
                      label: 'Theme name',
                      validator: (value) =>
                          Validators.required(value, 'Theme name'),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _organizerNameController,
                      label: 'Organizer name',
                      validator: (value) =>
                          Validators.required(value, 'Organizer name'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _openingTimeController,
                            label: 'Opening time',
                            validator: (value) =>
                                Validators.required(value, 'Opening time'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: _closingTimeController,
                            label: 'Closing time',
                            validator: (value) =>
                                Validators.required(value, 'Closing time'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _entryFeeController,
                      label: 'Entry fee',
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          Validators.nonNegativeNumber(value, 'Entry fee'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _crowdLevel,
                      decoration: const InputDecoration(
                        labelText: 'Crowd level',
                      ),
                      items: AppConstants.crowdLevels
                          .map(
                            (level) => DropdownMenuItem(
                              value: level,
                              child: Text(level),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _crowdLevel = value ?? _crowdLevel),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _nearbyTransportController,
                      label: 'Nearby transport, one per line',
                      maxLines: 3,
                      validator: (value) =>
                          Validators.required(value, 'Nearby transport'),
                    ),
                    SwitchListTile(
                      value: _parkingAvailable,
                      title: const Text('Parking available'),
                      onChanged: (value) =>
                          setState(() => _parkingAvailable = value),
                    ),
                    SwitchListTile(
                      value: _isFeatured,
                      title: const Text('Featured pandal'),
                      onChanged: (value) => setState(() => _isFeatured = value),
                    ),
                    SwitchListTile(
                      value: _isActive,
                      title: const Text('Active listing'),
                      onChanged: (value) => setState(() => _isActive = value),
                    ),
                    const SizedBox(height: 12),
                    _MediaSection(
                      title: 'Thumbnail image',
                      uploadLabel: _thumbnailUrl.isEmpty
                          ? 'Upload thumbnail'
                          : 'Replace thumbnail',
                      urls: _thumbnailUrl.isEmpty ? const [] : [_thumbnailUrl],
                      onUpload: admin.isLoading ? null : _uploadThumbnail,
                      onRemove: (_) => setState(() => _thumbnailUrl = ''),
                    ),
                    _MediaSection(
                      title: 'Images',
                      uploadLabel: 'Upload images',
                      urls: _imageUrls,
                      onUpload: admin.isLoading ? null : _uploadImages,
                      onRemove: (url) => setState(() => _imageUrls.remove(url)),
                    ),
                    _MediaSection(
                      title: 'Videos',
                      uploadLabel: 'Upload videos',
                      urls: _videoUrls,
                      onUpload: admin.isLoading ? null : _uploadVideos,
                      onRemove: (url) => setState(() => _videoUrls.remove(url)),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      label: 'Save pandal',
                      icon: Icons.save_outlined,
                      isLoading: admin.isLoading,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
              if (admin.isLoading)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x33FFFFFF),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MediaSection extends StatelessWidget {
  const _MediaSection({
    required this.title,
    required this.uploadLabel,
    required this.urls,
    required this.onUpload,
    required this.onRemove,
  });

  final String title;
  final String uploadLabel;
  final List<String> urls;
  final VoidCallback? onUpload;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              OutlinedButton.icon(
                onPressed: onUpload,
                icon: const Icon(Icons.cloud_upload_outlined),
                label: Text(uploadLabel),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (urls.isEmpty)
            Text(
              'No media uploaded',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final url in urls)
                  InputChip(
                    label: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 220),
                      child: Text(url, overflow: TextOverflow.ellipsis),
                    ),
                    onDeleted: () => onRemove(url),
                  ),
              ],
            ),
        ],
      ),
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
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
      ),
    );
  }
}
