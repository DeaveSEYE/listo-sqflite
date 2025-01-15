import 'dart:convert';
import 'dart:io'; // Pour vérifier l'existence du fichier
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
//firebase push notitication
// import 'package:listo/core/api/firebase_api.dart';
//firebase push notitication
import 'package:listo/core/global/global_state.dart';
import 'package:listo/core/local_notification.dart';
import 'package:listo/core/theme/theme.dart';
import 'package:listo/database/database_helper.dart';
import 'package:listo/features/profile/ui/profile.dart';
import 'package:listo/features/tasks/ui/tasklist.dart';
import 'package:listo/routes.dart';
import 'package:path/path.dart'; // Pour récupérer le chemin des fichiers locaux
import 'package:sqflite/sqflite.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initialRoute = await _determineInitialRoute();
  //firebase push notitication
  await Firebase.initializeApp();
  // await FirebaseApi().initNotifications();
  //firebase push notitication
  //firebase push notitication
  // Initialisation des notifications local
  final notificationService = NotificationService();
  await notificationService.initialize((payload) {
    if (payload != null) {
      final Map<String, dynamic> data = jsonDecode(payload); // Décoder le JSON

      final route = data['route'];
      final tsk = data['tasks'];
      final categories = data['categories'];
      // final userId = data['userId'];
//  Tasklist(tasks: tasks, categories: categories)
      if (route == '/tasks') {
        // Naviguer vers la page spécifique
        navigatorKey.currentState?.push(
          MaterialPageRoute(
              builder: (context) =>
                  Tasklist(tasks: tsk, categories: categories)),
        );
      }
      if (route == '/profile') {
        // Naviguer vers la page spécifique
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
      }
    }
  });
  //firebase push notitication local
  runApp(MyApp(initialRoute: initialRoute));
}

Future<String> _determineInitialRoute() async {
  // final DatabaseHelper _databaseHelper = DatabaseHelper();
  try {
    // Récupérer le chemin de la base de données
    final directory = await getDatabasesPath();
    final dbPath = join(directory, 'listo_database.db');

    // Vérifier si le fichier de la base de données existe
    if (File(dbPath).existsSync()) {
      print("La base de données existe : $dbPath");

      // Charger les données si la base de données existe
      final dbHelper = DatabaseHelper();
      // Vérifier s'il y a un utilisateur dans la table `users`
      final users = await dbHelper.fetchUsers();
      print(users);
      if (users.isNotEmpty) {
        final currentUser = users
            .first; // Récupérer le premier utilisateur (ou adapter selon votre logique)
        // GlobalState().currentUser = currentUser; // Sauvegarder les infos dans GlobalState ou autre
        print("Utilisateur trouvé : $currentUser");
        // print(currentUser['user']);
        GlobalState().userId = currentUser['id'];
        return Routes.homePage;
      } else {
        print("Aucun utilisateur trouvé, redirection vers login.");
        return Routes.loginPage;
      }
    } else {
      print("La base de données n'existe pas, elle sera créée.");

      // Créer la base de données si elle n'existe pas
      final dbHelper = DatabaseHelper();
      await dbHelper.database; // Cela initialise et crée la base
      print("Base de données créée avec succès !");

      // final token = {
      //   'source': 'firebaseCloudMessaging',
      //   'token': GlobalState().firebasePushNotifToken,
      // };
      // await _databaseHelper.insertToken(token);
    }
  } catch (e) {
    print("Erreur lors de la vérification de la base de données : $e");
  }

  // Si la base n'existe pas ou qu'une erreur se produit, rediriger vers la page login
  return Routes.loginPage;
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      navigatorKey: navigatorKey, // Passer le navigatorKey ici
      onGenerateRoute: Routes.generateRoute,
    );
  }
}
