class CloudinaryConstants {
  const CloudinaryConstants._();

  static const String cloudName = 'YOUR_CLOUD_NAME';
  static const String uploadPreset = 'YOUR_UNSIGNED_UPLOAD_PRESET';

  static const String imageUploadEndpoint =
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';
  static const String videoUploadEndpoint =
      'https://api.cloudinary.com/v1_1/$cloudName/video/upload';
}
