import 'dart:io'; // Pour vérifier l'existence du fichier
import 'package:flutter/material.dart';
import 'package:listo/core/global/global_state.dart';
import 'package:listo/core/theme/theme.dart';
import 'package:listo/database/database_helper.dart';
import 'package:listo/routes.dart';
import 'package:path/path.dart'; // Pour récupérer le chemin des fichiers locaux
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initialRoute = await _determineInitialRoute();
  runApp(MyApp(initialRoute: initialRoute));
}

Future<String> _determineInitialRoute() async {
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
      if (users.isNotEmpty) {
        final currentUser = users
            .first; // Récupérer le premier utilisateur (ou adapter selon votre logique)
        // GlobalState().currentUser = currentUser; // Sauvegarder les infos dans GlobalState ou autre
        print("Utilisateur trouvé : $currentUser");
        // print(currentUser['id']);
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
      onGenerateRoute: Routes.generateRoute,
    );
  }
}
