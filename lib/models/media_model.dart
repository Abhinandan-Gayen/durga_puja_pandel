import 'package:cloud_firestore/cloud_firestore.dart';

class MediaModel {
  const MediaModel({
    required this.url,
    required this.publicId,
    required this.type,
    required this.format,
    this.uploadedAt,
  });

  final String url;
  final String publicId;
  final String type;
  final String format;
  final DateTime? uploadedAt;

  bool get isImage => type == 'image';
  bool get isVideo => type == 'video';

  factory MediaModel.fromMap(Map<String, dynamic> map) {
    return MediaModel(
      url: map['url'] as String? ?? '',
      publicId: map['publicId'] as String? ?? '',
      type: map['type'] as String? ?? 'image',
      format: map['format'] as String? ?? '',
      uploadedAt: _dateFromValue(map['uploadedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'publicId': publicId,
      'type': type,
      'format': format,
      'uploadedAt': uploadedAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(uploadedAt!),
    };
  }

  MediaModel copyWith({
    String? url,
    String? publicId,
    String? type,
    String? format,
    DateTime? uploadedAt,
  }) {
    return MediaModel(
      url: url ?? this.url,
      publicId: publicId ?? this.publicId,
      type: type ?? this.type,
      format: format ?? this.format,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  static DateTime? _dateFromValue(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}
