import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class NotificationHelper {
  static void showFlushbar({
    required BuildContext context,
    required String message,
    required NotificationType type,
  }) {
    // Détermine les propriétés en fonction du type de notification
    Color backgroundColor;
    Icon icon;
    String title;

    switch (type) {
      case NotificationType.success:
        backgroundColor = Colors.green;
        // backgroundColor = Colors.black;
        icon = Icon(Icons.check_circle, color: Colors.white);
        title = "Succès";
        break;
      case NotificationType.alert:
        backgroundColor = Colors.red;
        // backgroundColor = Colors.black;
        icon = Icon(Icons.error, color: Colors.white);
        title = "Alerte";
        break;
      default:
        backgroundColor = Colors.blue;
        // backgroundColor = Colors.black;
        icon = Icon(Icons.info, color: Colors.white);
        title = "Info";
    }

    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      duration: const Duration(seconds: 4),
      isDismissible: true,
      title: title,
      message: message,
      icon: icon,
      backgroundColor: backgroundColor,
      boxShadows: const [
        BoxShadow(
          color: Colors.black26,
          // color: Colors.white,
          offset: Offset(0.0, 2.0),
          blurRadius: 3.0,
        )
      ],
    ).show(context);
  }
}

// Enum pour définir les types de notification
enum NotificationType {
  success,
  alert,
  info, error,
}
