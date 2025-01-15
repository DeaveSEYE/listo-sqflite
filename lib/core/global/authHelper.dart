import 'package:listo/core/global/global_state.dart';
import 'package:listo/database/database_helper.dart';

//  final DatabaseHelper _databaseHelper = DatabaseHelper();
class AuthHelper {
  /// Méthode statique avec DatabaseHelper passé comme paramètre
  static Future<void> updateAuthData(String state, Map<String, dynamic>? user,
      DatabaseHelper databaseHelper) async {
    if (state == "login" && user != null) {
      final token =
          await databaseHelper.fetchtokens(); // Utilise l'instance passée
      if (token.isNotEmpty && token[0]['token'].isNotEmpty) {
        GlobalState().firebasePushNotifToken =
            user['firebaseCloudMessagingToken'] ?? '';
      } else {
        // throw ArgumentError("empty firebaseCloudMessagingToken data");
      }
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
      GlobalState().firebasePushNotifToken = '';
    } else {
      throw ArgumentError("Invalid state or user data");
    }
  }
}
