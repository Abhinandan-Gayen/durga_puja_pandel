import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

/// Top-level background notification response handler.
/// Annotated with @pragma('vm:entry-point') so the compiler does not remove it.
@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(NotificationResponse response) {
  debugPrint('Background Notification Action: actionId=${response.actionId}, payload=${response.payload}');
  if (response.actionId == 'dismiss_puja_notification') {
    final FlutterLocalNotificationsPlugin localNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    localNotificationsPlugin.cancel(id: 2601);
    localNotificationsPlugin.cancel(id: 2602);
  }
}

/// Service to handle local notifications for Durga Puja countdown and reminders.
class LocalNotificationService {
  LocalNotificationService._privateConstructor();

  /// Singleton instance of LocalNotificationService.
  static final LocalNotificationService instance =
      LocalNotificationService._privateConstructor();

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Central countdown start date.
  static final DateTime countdownStartDate = DateTime(2026, 8, 9, 0, 0);

  /// Central target date for Durga Puja start.
  /// This date can be changed to the required Puja starting date.
  static final DateTime pujaStartDate = DateTime(2026, 10, 17, 0, 0);

  /// Testing mode configuration flag.
  /// Note: Android may suppress repeated sound or heads-up popups, so
  /// two-minute reminders should only be used for testing.
  static const bool enableTwoMinuteTestReminder = false;

  /// Initializes the local notifications plugin and requests permissions for Android 13+.
  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_stat_puja');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationClick(response);
      },
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
    );

    // Create a new notification channel for v2 rich countdowns
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        // Request Android 13+ permission
        final bool? granted =
            await androidPlugin.requestNotificationsPermission();
        debugPrint('Android local notification permission request result: $granted');

        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'puja_rich_countdown_v2',
          'Puja Countdown & Reminders',
          description:
              'Rich Durga Puja countdown and pandal reminder notifications',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        );
        await androidPlugin.createNotificationChannel(channel);
        debugPrint('Explicitly created notification channel: puja_rich_countdown_v2');
      }
    }
  }

  /// Handles foreground notification actions or notification body click.
  void _handleNotificationClick(NotificationResponse response) {
    final String? actionId = response.actionId;
    final String? payload = response.payload;
    debugPrint('Foreground Notification Response: actionId=$actionId, payload=$payload');

    if (actionId == 'dismiss_puja_notification') {
      cancelPujaCountdown();
      stopTwoMinuteTestReminder();
      return;
    }

    if (payload == 'puja_countdown') {
      try {
        Get.offAllNamed('/home');
      } catch (error) {
        debugPrint('Error navigating on notification click: $error');
      }
    }
  }

  /// Reusable formatter that returns human-friendly remaining duration text.
  String _formatRemainingDuration(DateTime targetDate) {
    final DateTime now = DateTime.now();
    if (now.isAfter(targetDate)) {
      return 'Durga Puja has begun!';
    }
    final Duration difference = targetDate.difference(now);
    final int days = difference.inDays;
    final int hours = difference.inHours % 24;

    if (days == 0 && hours == 0) {
      return 'Puja is starting now!';
    }

    final String daysStr = days == 1 ? '1 day' : '$days days';
    final String hoursStr = hours == 1 ? '1 hour' : '$hours hours';

    if (days == 0) {
      return '$hoursStr remaining';
    } else if (hours == 0) {
      return '$daysStr remaining';
    } else {
      return '$daysStr $hoursStr remaining';
    }
  }

  /// Helper to calculate progress percentage between start date and target date.
  int _calculateProgress() {
    final DateTime now = DateTime.now();
    final double totalMs =
        pujaStartDate.difference(countdownStartDate).inMilliseconds.toDouble();
    final double elapsedMs =
        now.difference(countdownStartDate).inMilliseconds.toDouble();

    if (totalMs <= 0) return 100;
    final double calculated = (elapsedMs / totalMs) * 100;
    return calculated.clamp(0.0, 100.0).round();
  }

  /// Displays or updates the rich Durga Puja live countdown notification.
  /// Cancels the notification if the pujaStartDate has already passed.
  Future<void> showPujaCountdown() async {
    final DateTime now = DateTime.now();
    if (now.isAfter(pujaStartDate)) {
      await cancelPujaCountdown();
      return;
    }

    final String remainingText = _formatRemainingDuration(pujaStartDate);
    final int progress = _calculateProgress();

    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
      const DrawableResourceAndroidBitmap('puja_notification_banner'),
      largeIcon: const DrawableResourceAndroidBitmap('puja_logo'),
      contentTitle: '🌺 PUJA IS COMING 🌺 ($remainingText)',
      summaryText: 'Maa Durga is coming! Explore the best pandals near you.',
      hideExpandedLargeIcon: true,
    );

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'puja_rich_countdown_v2',
      'Puja Countdown & Reminders',
      channelDescription:
          'Rich Durga Puja countdown and pandal reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.reminder,
      color: const Color(0xFFE50914), // App brand color: red
      icon: 'ic_stat_puja',
      when: pujaStartDate.millisecondsSinceEpoch,
      usesChronometer: true,
      chronometerCountDown: true,
      showWhen: true,
      onlyAlertOnce: true,
      autoCancel: false,
      ongoing: false,
      styleInformation: bigPictureStyleInformation,
      largeIcon: const DrawableResourceAndroidBitmap('puja_logo'),
      showProgress: true,
      maxProgress: 100,
      progress: progress,
      indeterminate: false,
      ticker: 'Durga Puja countdown reminder',
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'explore_pandals',
          'Explore Pandals',
          showsUserInterface: true,
        ),
        const AndroidNotificationAction(
          'dismiss_puja_notification',
          'Dismiss',
          showsUserInterface: false,
        ),
      ],
    );

    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    debugPrint('Scheduling Durga Puja countdown:');
    debugPrint('- Notification ID: 2601');
    debugPrint('- Channel ID: puja_rich_countdown_v2');
    debugPrint('- Banner: puja_notification_banner');
    debugPrint('- Target Date: $pujaStartDate');
    debugPrint('- Progress: $progress%');

    await _localNotificationsPlugin.show(
      id: 2601,
      title: 'Durga Puja Countdown 🌺',
      body: '$remainingText - Tap to explore nearby pandals.',
      notificationDetails: notificationDetails,
      payload: 'puja_countdown',
    );
  }

  /// Cancels the Durga Puja countdown notification.
  Future<void> cancelPujaCountdown() async {
    await _localNotificationsPlugin.cancel(id: 2601);
  }

  /// Starts the two-minute periodic test reminder.
  /// Cancels the reminder if the pujaStartDate has already passed.
  Future<void> startTwoMinuteTestReminder() async {
    final DateTime now = DateTime.now();
    if (now.isAfter(pujaStartDate)) {
      await stopTwoMinuteTestReminder();
      return;
    }

    final String remainingText = _formatRemainingDuration(pujaStartDate);
    final int progress = _calculateProgress();

    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
      const DrawableResourceAndroidBitmap('puja_notification_banner'),
      largeIcon: const DrawableResourceAndroidBitmap('puja_logo'),
      contentTitle: '🌺 PUJA IS COMING 🌺 ($remainingText)',
      summaryText: 'Maa Durga is coming! Explore the best pandals near you.',
      hideExpandedLargeIcon: true,
    );

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'puja_rich_countdown_v2',
      'Puja Countdown & Reminders',
      channelDescription:
          'Rich Durga Puja countdown and pandal reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.reminder,
      color: const Color(0xFFE50914), // App brand color: red
      icon: 'ic_stat_puja',
      when: pujaStartDate.millisecondsSinceEpoch,
      usesChronometer: true,
      chronometerCountDown: true,
      showWhen: true,
      onlyAlertOnce: false, // Set onlyAlertOnce: false for this test notification
      autoCancel: false,
      ongoing: false,
      styleInformation: bigPictureStyleInformation,
      largeIcon: const DrawableResourceAndroidBitmap('puja_logo'),
      showProgress: true,
      maxProgress: 100,
      progress: progress,
      indeterminate: false,
      ticker: 'Durga Puja countdown reminder',
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'explore_pandals',
          'Explore Pandals',
          showsUserInterface: true,
        ),
        const AndroidNotificationAction(
          'dismiss_puja_notification',
          'Dismiss',
          showsUserInterface: false,
        ),
      ],
    );

    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    const repeatInterval = Duration(minutes: 2);

    if (repeatInterval < const Duration(minutes: 1)) {
      throw ArgumentError.value(
        repeatInterval,
        'repeatInterval',
        'Local notification interval must be at least one minute',
      );
    }

    debugPrint('Scheduling Durga Puja periodic test reminder:');
    debugPrint('- Notification ID: 2602');
    debugPrint('- Channel ID: puja_rich_countdown_v2');
    debugPrint('- Interval: 2 minutes');
    debugPrint('- Target Date: $pujaStartDate');
    debugPrint('- Progress: $progress%');

    await _localNotificationsPlugin.periodicallyShowWithDuration(
      id: 2602,
      title: 'Durga Puja Reminder 🌺',
      body:
          'The celebration is getting closer. Open the app to explore pandals.',
      repeatDurationInterval: repeatInterval,
      notificationDetails: notificationDetails,
      payload: 'puja_countdown',
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Stops the two-minute periodic test reminder.
  Future<void> stopTwoMinuteTestReminder() async {
    await _localNotificationsPlugin.cancel(id: 2602);
  }
}
