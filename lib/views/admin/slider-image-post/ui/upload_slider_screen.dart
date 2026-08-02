import 'package:durga_puja_pandel/core/utils/snackbar_helper.dart';
import 'package:durga_puja_pandel/views/admin/slider-image-post/controller/slider_controller.dart';
import 'package:durga_puja_pandel/views/admin/slider-image-post/model/slider_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UploadSliderScreen extends StatefulWidget {
  const UploadSliderScreen({super.key});

  @override
  State<UploadSliderScreen> createState() => _UploadSliderScreenState();
}

class _UploadSliderScreenState extends State<UploadSliderScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _urlController = TextEditingController();

  String _previewUrl = '';

  @override
  void initState() {
    super.initState();

    // URL লেখার সঙ্গে সঙ্গে নিচে preview দেখাবে।
    _urlController.addListener(_updatePreview);
  }

  void _updatePreview() {
    final String value = _urlController.text.trim();

    if (_previewUrl == value) return;

    setState(() {
      _previewUrl = value;
    });
  }

  bool _isValidUrl(String url) {
    final Uri? uri = Uri.tryParse(url);

    return uri != null &&
        uri.hasScheme &&
        uri.host.isNotEmpty &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }

  String? _validateImageUrl(String? value) {
    final String url = value?.trim() ?? '';

    if (url.isEmpty) {
      return 'Image URL লিখুন';
    }

    if (!_isValidUrl(url)) {
      return 'সঠিক HTTP অথবা HTTPS URL দিন';
    }

    return null;
  }

  Future<void> _uploadImage() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final SliderController controller = context.read<SliderController>();

    final bool success = await controller.addSliderImage(
      _urlController.text.trim(),
    );

    if (!mounted) return;

    if (!success) {
      SnackbarHelper.showError(
        context,
        controller.errorMessage ?? 'Image upload করা যায়নি',
      );
      return;
    }

    SnackbarHelper.showSuccess(context, 'Slider image successfully added');

    _urlController.clear();

    setState(() {
      _previewUrl = '';
    });
  }

  Future<void> _deleteImage(SliderModel slider) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Delete image?'),
          content: const Text(
            'এই slider image-টি Firestore থেকে permanently delete হবে।',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;

    final SliderController controller = context.read<SliderController>();

    final bool success = await controller.deleteSlider(slider.id);

    if (!mounted) return;

    if (success) {
      SnackbarHelper.showSuccess(context, 'Slider image deleted');
    } else {
      SnackbarHelper.showError(
        context,
        controller.errorMessage ?? 'Delete করা যায়নি',
      );
    }
  }

  @override
  void dispose() {
    _urlController.removeListener(_updatePreview);
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EF),
      appBar: AppBar(
        title: const Text(
          'Manage Slider',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFB91419),
        foregroundColor: Colors.white,
      ),
      body: Consumer<SliderController>(
        builder:
            (BuildContext context, SliderController controller, Widget? child) {
              return RefreshIndicator(
                color: const Color(0xFFB91419),
                onRefresh: () async {
                  controller.listenToSliders();
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(18),
                  children: [
                    _buildUploadCard(controller),

                    const SizedBox(height: 26),

                    _buildSectionTitle(controller.sliders.length),

                    const SizedBox(height: 14),

                    if (controller.isLoading && controller.sliders.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 70),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFB91419),
                          ),
                        ),
                      )
                    else if (controller.sliders.isEmpty)
                      _buildEmptyState()
                    else
                      ...controller.sliders.map((SliderModel slider) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildSliderCard(
                            slider: slider,
                            controller: controller,
                          ),
                        );
                      }),
                  ],
                ),
              );
            },
      ),
    );
  }

  Widget _buildUploadCard(SliderController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFB91419).withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB91419).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Icon(
                    Icons.add_photo_alternate_outlined,
                    color: Color(0xFFB91419),
                    size: 29,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add slider image',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2D1A15),
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Image URL paste করে upload করুন',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            TextFormField(
              controller: _urlController,
              validator: _validateImageUrl,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              autocorrect: false,
              enableSuggestions: false,
              onFieldSubmitted: (_) {
                if (!controller.isUploading) {
                  _uploadImage();
                }
              },
              decoration: InputDecoration(
                labelText: 'Image URL',
                hintText: 'https://example.com/banner.jpg',
                prefixIcon: const Icon(Icons.link_rounded),
                suffixIcon: _urlController.text.isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear',
                        onPressed: () {
                          _urlController.clear();
                        },
                        icon: const Icon(Icons.close_rounded),
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFFFFBF6),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 17,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: Color(0xFFB91419),
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                ),
              ),
            ),

            if (_previewUrl.isNotEmpty && _isValidUrl(_previewUrl)) ...[
              const SizedBox(height: 18),

              const Text(
                'Image preview',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D1A15),
                ),
              ),

              const SizedBox(height: 10),

              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 7,
                  child: Image.network(
                    _previewUrl,
                    fit: BoxFit.cover,
                    loadingBuilder:
                        (
                          BuildContext context,
                          Widget child,
                          ImageChunkEvent? progress,
                        ) {
                          if (progress == null) return child;

                          return Container(
                            color: const Color(0xFFF4EEE7),
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(
                              color: Color(0xFFB91419),
                            ),
                          );
                        },
                    errorBuilder:
                        (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                        ) {
                          return _buildImageError();
                        },
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: controller.isUploading ? null : _uploadImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB91419),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(
                    0xFFB91419,
                  ).withValues(alpha: 0.55),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: controller.isUploading
                    ? const SizedBox(
                        width: 21,
                        height: 21,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.3,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.cloud_upload_outlined),
                label: Text(
                  controller.isUploading ? 'Uploading...' : 'Upload Image',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(int totalImages) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Uploaded Images',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D1A15),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFB91419).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            '$totalImages images',
            style: const TextStyle(
              color: Color(0xFFB91419),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliderCard({
    required SliderModel slider,
    required SliderController controller,
  }) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 7,
            child: Image.network(
              slider.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder:
                  (
                    BuildContext context,
                    Widget child,
                    ImageChunkEvent? progress,
                  ) {
                    if (progress == null) return child;

                    return Container(
                      color: const Color(0xFFF4EEE7),
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        color: Color(0xFFB91419),
                      ),
                    );
                  },
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                    return _buildImageError();
                  },
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    slider.imageUrl,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),

                Switch(
                  value: slider.isActive,
                  activeTrackColor: const Color(0xFFB91419),
                  onChanged: (bool value) async {
                    final bool success = await controller.updateSliderStatus(
                      documentId: slider.id,
                      isActive: value,
                    );

                    if (!success && mounted) {
                      SnackbarHelper.showError(
                        context,
                        controller.errorMessage ?? 'Status update করা যায়নি',
                      );
                    }
                  },
                ),

                IconButton(
                  tooltip: 'Delete image',
                  onPressed: () => _deleteImage(slider),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      color: const Color(0xFFF4EEE7),
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image_outlined, size: 42, color: Colors.grey),
          SizedBox(height: 7),
          Text('Image load করা যায়নি', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 55),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 58,
            color: Color(0xFFB91419),
          ),
          SizedBox(height: 15),
          Text(
            'কোনো slider image নেই',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 7),
          Text(
            'Image URL দিয়ে প্রথম slider image upload করুন।',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
