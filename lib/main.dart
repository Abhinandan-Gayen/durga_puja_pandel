import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Development log
  if (kDebugMode) {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  }

  // OneSignal initialize
  OneSignal.initialize(
    '32b72fcd-ce88-4875-baca-e7a27ebc4425',
  );

  // Notification permission
  final bool permissionGranted =
      await OneSignal.Notifications.requestPermission(false);

  debugPrint('Notification permission: $permissionGranted');

  // Subscription ID ও FCM token check
  OneSignal.User.pushSubscription.addObserver((state) {
    debugPrint(
      'OneSignal Subscription ID: ${state.current.id}',
    );

    debugPrint(
      'FCM Push Token: ${state.current.token}',
    );

    debugPrint(
      'Opted In: ${state.current.optedIn}',
    );
  });

  // Notification click listener
  OneSignal.Notifications.addClickListener((event) {
    final data = event.notification.additionalData;

    debugPrint(
      'Notification clicked: '
      '${event.notification.notificationId}',
    );

    debugPrint('Additional data: $data');
  });

  // App foreground-এ notification এলে দেখাবে
  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    debugPrint(
      'Foreground notification: '
      '${event.notification.title}',
    );

    event.notification.display();
  });

  runApp(const PujoPandalGuideApp());
}