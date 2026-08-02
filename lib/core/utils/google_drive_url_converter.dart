String? _googleDriveFileId(String url) {
  final trimmed = url.trim();
  final uri = Uri.tryParse(trimmed);
  if (uri == null || !uri.host.toLowerCase().contains('drive.google.com')) {
    return null;
  }

  final fileMatch = RegExp(r'/file/d/([^/]+)').firstMatch(trimmed);
  final pathId = fileMatch?.group(1);
  if (pathId != null && pathId.isNotEmpty) return pathId;

  final queryId = uri.queryParameters['id'] ?? uri.queryParameters['fileId'];
  return queryId == null || queryId.isEmpty ? null : queryId;
}

/// Converts a public Google Drive image link to a displayable thumbnail URL.
/// Non-Drive URLs are returned unchanged.
String convertGoogleDriveUrl(String driveUrl, {int imageWidth = 1000}) {
  final trimmed = driveUrl.trim();
  final fileId = _googleDriveFileId(trimmed);
  if (fileId == null) return trimmed;

  return 'https://drive.google.com/thumbnail?id=$fileId&sz=w$imageWidth';
}

/// Converts a public Google Drive video link to a stream/download URL.
/// Non-Drive URLs are returned unchanged.
String convertGoogleDriveVideoUrl(String driveUrl) {
  final trimmed = driveUrl.trim();
  final fileId = _googleDriveFileId(trimmed);
  if (fileId == null) return trimmed;

  return 'https://drive.google.com/uc?export=download&id=$fileId';
}
