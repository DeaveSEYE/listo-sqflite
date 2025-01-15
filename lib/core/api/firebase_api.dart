import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:listo/core/global/global_state.dart';
import 'package:listo/database/database_helper.dart';

// FirebasePushNotification associe a flutter local notification expliquer ICI
// https://www.youtube.com/watch?v=k0zGEbiDJcQ&t=18s
Future<void> handleMessage(RemoteMessage? message) async {
  if (message == null) return;
  //rediroger vers une page en passant le message en argument
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title :${message.notification?.title}');
  print('body :${message.notification?.body}');
  print('payload :${message.data}');
}

class FirebaseApi {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _androidChannel = const AndroidNotificationChannel(
    'hight_importance_channel',
    'hight importance notifications',
    description: 'this channel is used for important notifications',
    importance: Importance.defaultImportance,
  );
  final _localNotification = FlutterLocalNotificationsPlugin();

  Future<void> initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _localNotification.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
              _androidChannel.id, _androidChannel.name,
              channelDescription: _androidChannel.description,
              icon: '@mipmap/ic_lancher'),
        ),
        payload: jsonEncode(message.toMap()),
      );
    });
  }

  Future<void> initLocalNotifications() async {
    const ios = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const settings = InitializationSettings(android: android, iOS: ios);

    await _localNotification.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null) {
          final message = RemoteMessage.fromMap(jsonDecode(payload));
          handleMessage(message);
        }
      },
    );

    final platform = _localNotification.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final FCMT = await _firebaseMessaging.getToken();
    print('FIREBASE TOKEN :$FCMT');
    GlobalState().firebasePushNotifToken = '$FCMT';

    final token = {
      'source': 'firebaseCloudMessaging',
      'token': FCMT,
    };
    await _databaseHelper.insertToken(token);
    // FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    initPushNotifications();
    initLocalNotifications();
  }
}
