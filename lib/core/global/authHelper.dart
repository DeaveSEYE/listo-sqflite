import 'package:listo/core/global/global_state.dart';

class AuthHelper {
  /// Met à jour les données d'authentification selon l'état fourni (login/logout)
  static Future<void> updateAuthData(
      String state, Map<String, dynamic>? user) async {
    if (state == "login" && user != null) {
      GlobalState().userId = user['id'] ?? '';
      GlobalState().email = user['email'] ?? '';
      GlobalState().user = user['user'] ?? '';
      GlobalState().authId = user['auth']?['id'] ?? '';
      GlobalState().authphotoUrl = user['auth']?['photoUrl'] ?? '';
      GlobalState().authSource = user['auth']?['source'] ?? '';
    } else if (state == "logout") {
      GlobalState().userId = '';
      GlobalState().email = '';
      GlobalState().user = '';
      GlobalState().authId = '';
      GlobalState().authphotoUrl = '';
      GlobalState().authSource = '';
    } else {
      throw ArgumentError("Invalid state or user data");
    }
  }
}
