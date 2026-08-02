import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<dynamic>('favoritePandals');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _initializeOneSignal();
  runApp(const PujoPandalGuideApp());
}

Future<void> _initializeOneSignal() async {
  final isMobile = !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  if (!isMobile) return;

  try {
    OneSignal.initialize('32b72fcd-ce88-4875-baca-e7a27ebc4425');

    final permissionGranted =
        await OneSignal.Notifications.requestPermission(false);
    debugPrint('Notification permission: $permissionGranted');

    OneSignal.User.pushSubscription.addObserver((state) {
      debugPrint('OneSignal Subscription ID: ${state.current.id}');
      debugPrint('FCM Push Token: ${state.current.token}');
      debugPrint('Opted In: ${state.current.optedIn}');
    });

    OneSignal.Notifications.addClickListener((event) {
      debugPrint(
        'Notification clicked: ${event.notification.notificationId}',
      );
      debugPrint('Additional data: ${event.notification.additionalData}');
    });

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      debugPrint('Foreground notification: ${event.notification.title}');
      event.notification.display();
    });
  } catch (error, stackTrace) {
    debugPrint('OneSignal initialization skipped: $error');
    if (kDebugMode) debugPrintStack(stackTrace: stackTrace);
  }
}
