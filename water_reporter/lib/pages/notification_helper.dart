import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static final _notification = FlutterLocalNotificationsPlugin();
  static init() {
    _notification.initialize(InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings()));
  }

  static pushNotification({required String title, required String body}) async {
    var androidDetails = AndroidNotificationDetails(
        'important_channel', 'My Channel',
        importance: Importance.max, priority: Priority.high);
    var iosDetails = const DarwinNotificationDetails();
    var notificationDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notification.show(100, title, body, notificationDetails);
  }
}
