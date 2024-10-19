import 'package:flutter_local_notifications/flutter_local_notifications.dart' as notifs;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Noti {
  static Future<void> initialize(notifs.FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize = const notifs.AndroidInitializationSettings('mipmap/ic_launcher');
    var iOSInitialize = const notifs.DarwinInitializationSettings();
    var initializationSettings = notifs.InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showScheduledNotification({
    required String title,
    required String body,
    required DateTime plannedTime,
    required notifs.FlutterLocalNotificationsPlugin fln,
  }) async {
    const channelId = 'vienss1';
    const channelName = 'channelName';

    const notifs.AndroidNotificationDetails androidPlatformChannelSpecifics =
    notifs.AndroidNotificationDetails(
      channelId,
      channelName,
      playSound: true,
      sound: notifs.RawResourceAndroidNotificationSound('notification'),
      importance: notifs.Importance.max,
      priority: notifs.Priority.high,
    );

    const notifs.NotificationDetails notificationDetails =
    notifs.NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: notifs.DarwinNotificationDetails());

    tz.initializeTimeZones(); // Initialize time zones

    // Convert the plannedTime to a TZDateTime using the appropriate time zone
    tz.TZDateTime plannedTZTime = tz.TZDateTime.from(plannedTime, tz.local);

    // Ensure that plannedTZTime is in the future
    if (plannedTZTime.isBefore(tz.TZDateTime.now(tz.local))) {
      // If it's not in the future, add a day to it (or adjust as needed)
      plannedTZTime = plannedTZTime.add(const Duration(days: 1));
    }

    await fln.zonedSchedule(
      0,
      title,
      body,
      plannedTZTime,
      notificationDetails,
      androidScheduleMode: notifs.AndroidScheduleMode.exact,
      uiLocalNotificationDateInterpretation: notifs.UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
