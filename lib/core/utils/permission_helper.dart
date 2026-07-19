import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  const PermissionHelper._();

  static Future<bool> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted || status.isLimited;
  }

  static Future<bool> requestMediaPermission() async {
    final status = await Permission.photos.request();
    if (status.isGranted || status.isLimited) {
      return true;
    }
    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted || storageStatus.isLimited;
  }
}
