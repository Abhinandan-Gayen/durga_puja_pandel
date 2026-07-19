import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../models/media_model.dart';
import '../constants/cloudinary_constants.dart';

class CloudinaryService {
  Future<MediaModel?> uploadImage(File file) {
    return _uploadFile(file: file, resourceType: 'image');
  }

  Future<MediaModel?> uploadVideo(File file) {
    return _uploadFile(file: file, resourceType: 'video');
  }

  Future<List<MediaModel>> uploadMultipleImages(List<File> files) async {
    final uploadedMedia = <MediaModel>[];
    for (final file in files) {
      final media = await uploadImage(file);
      if (media != null) {
        uploadedMedia.add(media);
      }
    }
    return uploadedMedia;
  }

  Future<List<MediaModel>> uploadMultipleVideos(List<File> files) async {
    final uploadedMedia = <MediaModel>[];
    for (final file in files) {
      final media = await uploadVideo(file);
      if (media != null) {
        uploadedMedia.add(media);
      }
    }
    return uploadedMedia;
  }

  Future<MediaModel> uploadMedia({
    required Uint8List bytes,
    required String fileName,
    required String mediaType,
  }) async {
    final resourceType = mediaType == 'video' ? 'video' : 'image';
    final request = _baseRequest(resourceType)
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: fileName),
      );
    return _sendRequest(request);
  }

  Future<MediaModel?> _uploadFile({
    required File file,
    required String resourceType,
  }) async {
    final request = _baseRequest(resourceType)
      ..files.add(await http.MultipartFile.fromPath('file', file.path));
    return _sendRequest(request);
  }

  http.MultipartRequest _baseRequest(String resourceType) {
    _validateUnsignedUploadConfig();
    return http.MultipartRequest('POST', Uri.parse(_endpointFor(resourceType)))
      ..fields['upload_preset'] = CloudinaryConstants.uploadPreset;
  }

  Future<MediaModel> _sendRequest(http.MultipartRequest request) async {
    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Cloudinary upload failed: $body');
    }

    final data = jsonDecode(body) as Map<String, dynamic>;
    return MediaModel(
      url: data['secure_url'] as String? ?? '',
      publicId: data['public_id'] as String? ?? '',
      type: data['resource_type'] as String? ?? 'image',
      format: data['format'] as String? ?? '',
      uploadedAt: DateTime.now(),
    );
  }

  String _endpointFor(String resourceType) {
    if (resourceType == 'video') {
      return CloudinaryConstants.videoUploadEndpoint;
    }
    return CloudinaryConstants.imageUploadEndpoint;
  }

  void _validateUnsignedUploadConfig() {
    if (CloudinaryConstants.cloudName == 'YOUR_CLOUD_NAME' ||
        CloudinaryConstants.uploadPreset == 'YOUR_UNSIGNED_UPLOAD_PRESET') {
      throw StateError(
        'Cloudinary cloudName and unsigned uploadPreset must be configured.',
      );
    }
  }
}
