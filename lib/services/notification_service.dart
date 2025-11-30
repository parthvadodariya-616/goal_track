import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
        
    const InitializationSettings settings = 
        InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings);
    
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'focus_timer_channel',
      'Focus Timer',
      description: 'Active Goal Countdown',
      importance: Importance.max,
      playSound: true,
    );

    final platform = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (platform != null) {
      await platform.createNotificationChannel(channel);
      await platform.requestNotificationsPermission();
    }
  }

  static Future<void> showTimerNotification({
    required String title, 
    required String body, 
    bool isPaused = false
  }) async {
    await _notifications.show(
      888,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'focus_timer_channel',
          'Focus Timer',
          channelDescription: 'Active Goal Countdown',
          importance: Importance.max,
          priority: Priority.high,
          ongoing: true,
          autoCancel: false,
          showWhen: true,
          onlyAlertOnce: true,
        ),
      ),
    );
  }

  static Future<void> cancelNotification() async {
    await _notifications.cancel(888);
  }
}