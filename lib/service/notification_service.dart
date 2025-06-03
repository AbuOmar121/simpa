import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage remoteMessage) async {
  await FirebaseMessagingService.instance.setupLocalNotifications();
  final notification = remoteMessage.notification;
  if (notification != null) {
    await FirebaseMessagingService.instance
        .showNotification(notification.title ?? '', notification.body ?? '');
  }
}


// ignore: constant_identifier_names
const NOTIFICATION_CHANNEL_ID = "fcm_default_channel";

class FirebaseMessagingService {
  FirebaseMessagingService._();

  static final FirebaseMessagingService instance = FirebaseMessagingService._();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotification =
  FlutterLocalNotificationsPlugin();
  bool _isFlutterLocalNotificationsInitialized = false;

  Future<void> initialize() async {
    await _requestPermission();
    await setupLocalNotifications();
    await _setupMessageHandlers();
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false);
  }

  Future<void> setupLocalNotifications() async {
    if (_isFlutterLocalNotificationsInitialized) {
      return;
    }
    const channel = AndroidNotificationChannel(
        NOTIFICATION_CHANNEL_ID, "Book Exchange App",
        importance: Importance.high);
    await _localNotification
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    const androidInitializationSettings =
    AndroidInitializationSettings("@mipmap/ic_launcher");
    const initializationSettings =
    InitializationSettings(android: androidInitializationSettings);
    await _localNotification.initialize(initializationSettings);
    _isFlutterLocalNotificationsInitialized = true;
  }

  Future<void> showNotification(String title, String body) async {
    await _localNotification.show(
      1,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
            NOTIFICATION_CHANNEL_ID, "Book Exchange App",
            importance: Importance.high,
            priority: Priority.high,
            icon: "@mipmap/ic_launcher"),),);
  }

  Future<void> _setupMessageHandlers() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
      final notification = remoteMessage.notification;
      if (notification != null) {
        showNotification(notification.title ?? '', notification.body ?? '');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) {
      firebaseMessagingBackgroundHandler(remoteMessage);
    });
  }
}