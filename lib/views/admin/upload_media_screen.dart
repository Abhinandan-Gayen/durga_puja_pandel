import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/admin_pandal_controller.dart';
import '../../core/utils/snackbar_helper.dart';
import '../widgets/custom_button.dart';

class UploadMediaScreen extends StatefulWidget {
  const UploadMediaScreen({super.key});

  @override
  State<UploadMediaScreen> createState() => _UploadMediaScreenState();
}

class _UploadMediaScreenState extends State<UploadMediaScreen> {
  String _mediaType = 'image';

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: _mediaType == 'video' ? FileType.video : FileType.image,
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) {
      return;
    }
    if (!mounted) {
      return;
    }

    final file = result.files.single;
    final admin = context.read<AdminPandalController>();
    await admin.uploadMedia(
      bytes: file.bytes!,
      fileName: file.name,
      mediaType: _mediaType,
    );
    if (!mounted) {
      return;
    }
    if (admin.errorMessage != null) {
      SnackbarHelper.showError(context, admin.errorMessage!);
    } else {
      SnackbarHelper.showSuccess(context, 'Media uploaded to Cloudinary');
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminPandalController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Upload media')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'image',
                icon: Icon(Icons.image_outlined),
                label: Text('Image'),
              ),
              ButtonSegment(
                value: 'video',
                icon: Icon(Icons.videocam_outlined),
                label: Text('Video'),
              ),
            ],
            selected: {_mediaType},
            onSelectionChanged: (value) =>
                setState(() => _mediaType = value.single),
          ),
          const SizedBox(height: 16),
          CustomButton(
            label: 'Choose and upload',
            icon: Icons.cloud_upload_outlined,
            isLoading: admin.isLoading,
            onPressed: _pickAndUpload,
          ),
          if (admin.lastUploadedMedia != null) ...[
            const SizedBox(height: 24),
            SelectableText(admin.lastUploadedMedia!.url),
          ],
        ],
      ),
    );
  }
}
