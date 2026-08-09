import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:durga_puja_pandel/core/services/local_notification_service.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('favoritePandals');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await _initializeOneSignal();

  // Initialize local notifications service
  final LocalNotificationService localNotificationService =
      LocalNotificationService.instance;
  await localNotificationService.initialize();

  // Manage Puja countdown and testing reminder
  final DateTime now = DateTime.now();
  if (now.isAfter(LocalNotificationService.pujaStartDate)) {
    await localNotificationService.cancelPujaCountdown();
    await localNotificationService.stopTwoMinuteTestReminder();
  } else {
    await localNotificationService.showPujaCountdown();
    if (LocalNotificationService.enableTwoMinuteTestReminder) {
      try {
        await localNotificationService.startTwoMinuteTestReminder();
      } catch (error, stackTrace) {
        debugPrint('Unable to schedule test reminder: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    } else {
      await localNotificationService.stopTwoMinuteTestReminder();
    }
  }

  runApp(const PujoPandalGuideApp());
}

Future<void> _initializeOneSignal() async {
  final bool isMobile =
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  if (!isMobile) return;

  try {
    OneSignal.initialize('32b72fcd-ce88-4875-baca-e7a27ebc4425');

    final bool permissionGranted =
        await OneSignal.Notifications.requestPermission(false);

    debugPrint('OneSignal notification permission: $permissionGranted');

    OneSignal.User.pushSubscription.addObserver((state) {
      debugPrint('OneSignal Subscription ID: ${state.current.id}');

      debugPrint('OneSignal Push Token: ${state.current.token}');

      debugPrint('OneSignal Opted In: ${state.current.optedIn}');
    });

    OneSignal.Notifications.addClickListener((event) {
      debugPrint(
        'Notification clicked: '
        '${event.notification.notificationId}',
      );

      debugPrint(
        'Additional data: '
        '${event.notification.additionalData}',
      );
    });

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      debugPrint(
        'Foreground notification received: '
        '${event.notification.title}',
      );

      // Do not call event.preventDefault().
      // Do not call event.notification.display().
      // OneSignal automatically displays foreground notifications.
    });
  } catch (error, stackTrace) {
    debugPrint('OneSignal initialization failed: $error');

    if (kDebugMode) {
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
