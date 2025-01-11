// SYSTEME DE NOFICATION LOCAL

//1 - installer le pacjege flutter_local_notifications
//2 - Placer l'icone de l'application ou l'image de notre choix
//     dans Android/app/src/main/res/drawable
//3 -POUR IOS une etape supplementaire est d'aller dans ios/runner/AppDelegate.swift
// et rajouter ces ligne :
//    import flutter_local_notifications
//        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
//GeneratedPluginRegistrant.register(with: registry)}
//       if #available(iOS 10.0, *) {
//    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
// }

// FICHIER APDELEGATE COMPLET
// import UIKit
// import Flutter

// import flutter_local_notifications

// @UIApplicationMain
// @objc class AppDelegate: FlutterAppDelegate {
//   override func application(
//     _ application: UIApplication,
//     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//   ) -> Bool {

//     FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
//     GeneratedPluginRegistrant.register(with: registry)}

//     GeneratedPluginRegistrant.register(with: self)

//       if #available(iOS 10.0, *) {
//          UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
//       }

//     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//   }
// }

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationService {
//   final FlutterLocalNotificationsPlugin notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   Future<void> initNotification() async {
//     AndroidInitializationSettings initializationSettingsAndroid =
//         const AndroidInitializationSettings('flutter_logo');

//     var initializationSettingsIOS = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );

//     var initializationSettings = InitializationSettings(
//         android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

//     await notificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse:
//           (NotificationResponse notificationResponse) async {
//         // Handle notification tap here
//       },
//     );
//   }

//   notificationDetails() {
//     return const NotificationDetails(
//         android: AndroidNotificationDetails('channelId', 'channelName',
//             importance: Importance.max),
//         iOS: DarwinNotificationDetails());
//   }

//   Future showNotification(
//       {int id = 0, String? title, String? body, String? payLoad}) async {
//     return notificationsPlugin.show(
//         id, title, body, await notificationDetails());
//   }
// }
