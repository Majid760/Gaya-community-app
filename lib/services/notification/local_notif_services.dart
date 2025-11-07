import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_routes.dart';

class LocalNotificationService {
  // Private named constructor
  LocalNotificationService._();

  static LocalNotificationService? _awesomeNotification;

  static LocalNotificationService get instance => _awesomeNotification ??= LocalNotificationService._();

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'Gaya Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  Future init() async {
    const AndroidInitializationSettings _androidInitializationSettings = AndroidInitializationSettings('ic_launcher');
    const DarwinInitializationSettings _iosInitializationSettings =
        DarwinInitializationSettings(requestAlertPermission: true, requestSoundPermission: true, requestBadgePermission: false);
    const InitializationSettings _initializationSettings =
        InitializationSettings(android: _androidInitializationSettings, iOS: _iosInitializationSettings);

    /// Initialize the [FlutterLocalNotificationsPlugin] package.
    ///
    /// Registers listeners for when notifications are received while the app is in the foreground and background.
    await flutterLocalNotificationsPlugin.initialize(
      _initializationSettings,
      onDidReceiveBackgroundNotificationResponse: NotificationApiController.onActionReceivedMethod,
      onDidReceiveNotificationResponse: NotificationApiController.onActionReceivedMethod,
    );
  }

  /// Show a notification instantly as tray notification
  Future showInstantNotification({int id = 0, String? title, String? body, String? payload}) async {
    return await flutterLocalNotificationsPlugin.show(id, title, body, _notificationDetails(), payload: payload);
  }

  NotificationDetails _notificationDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: channel.importance,
        priority: Priority.high,
        icon: 'ic_launcher',
        playSound: true,
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }
}
