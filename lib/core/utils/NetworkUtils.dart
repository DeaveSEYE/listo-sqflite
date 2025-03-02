import 'dart:io';
import 'package:flutter/foundation.dart';

class NetworkUtils {
  static Future<bool> isInternetAvailable() async {
    if (kIsWeb) {
      return _checkWebConnectivity();
    } else {
      return _checkMobileConnectivity();
    }
  }

  static Future<bool> _checkWebConnectivity() async {
    try {
      final result = Uri.parse("https://google.com").resolveUri(Uri());
      return result.host.isNotEmpty;
    } catch (e) {
      debugPrint('Erreur Internet (Web) : $e');
      return false;
    }
  }

  static Future<bool> _checkMobileConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      debugPrint('Erreur Internet (Mobile) : $e');
      return false;
    }
  }
}
