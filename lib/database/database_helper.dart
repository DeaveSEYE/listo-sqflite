import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:listo/core/global/global_state.dart';
import 'package:listo/core/utils/task.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Pour les tests en Desktop
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'; // Pour le Web

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  // Méthode pour récupérer la base de données
  Future<Database> get database async {
    // print(_database);
    if (_database != null) return _database!;
    _database = await _initializeDatabase();
    GlobalState().DBChecker = true;
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    try {
      if (kIsWeb) {
        // Initialisation de la base de données pour le Web
        print("Initialisation de la base de données pour le Web...");
        final factory = databaseFactoryFfiWeb; // Utilisation de sqflite_ffi_web
        return await factory.openDatabase('listo_database_web');
      } else {
        // Initialisation pour Android/iOS/Desktop
        final directory = await getDatabasesPath();
        final dbPath = join(directory, 'listo_database.db');
        print("Chemin de la base de données (mobile/desktop) : $dbPath");

        return await openDatabase(
          dbPath,
          version: 1,
          onCreate: _onCreate,
        );
      }
    } catch (e) {
      print("Erreur lors de l'initialisation de la base de données : $e");
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Création des tables
    await db.execute('''
      CREATE TABLE tasks (
         id TEXT,
         userId TEXT,
        title TEXT NOT NULL,
        categorie TEXT,
        description TEXT,
        priority TEXT,
        isChecked BOOLEAN,
        categorieColor TEXT,
        createdAt DATE DEFAULT (datetime('now')),
        updatedAt DATE DEFAULT (datetime('now')),
        dueDate DATE DEFAULT (datetime('now')),
        is_synced BOOLEAN,
        isNew BOOLEAN,
        isUpdated BOOLEAN,
        isDeleted BOOLEAN
      )
    ''');
    print("Table 'tasks' créée.");

    await db.execute('''
      CREATE TABLE categories (
        id TEXT,
        userId TEXT,
        categorie TEXT,
        categorieColor TEXT,
        createdAt DATE DEFAULT (datetime('now')),
        updatedAt DATE DEFAULT (datetime('now')),
        is_synced BOOLEAN,
        isNew BOOLEAN,
        isUpdated BOOLEAN,
        isDeleted BOOLEAN
      )
    ''');
    print("Table 'categories' créée.");

    await db.execute('''
      CREATE TABLE users (
        id TEXT,
        user TEXT,
        email TEXT,
        password TEXT,
        firebasecloudmessagingtoken TEXT,
        auth_source TEXT,
        auth_id TEXT,
        photoUrl TEXT,
        createdAt DATE DEFAULT (datetime('now')),
        updatedAt DATE DEFAULT (datetime('now')),
        is_synced BOOLEAN DEFAULT 0
      )
    ''');
    print("Table 'users' créée.");

    await db.execute('''
      CREATE TABLE tokens (
        source TEXT,
        token TEXT,
        createdAt DATE DEFAULT (datetime('now'))
      )
    ''');
    print("Table 'tokens' créée.");
  }

  // Méthodes pour interagir avec la base de données
  Future<List<Map<String, dynamic>>> fetchTasks(String userId) async {
    final db = await database;
    return await db.query(
      'tasks',
      where: 'isDeleted = 0 AND userId = ?',
      whereArgs: [userId],
    );
  }

  Future<List<Map<String, dynamic>>> fetchCategories(String userId) async {
    final db = await database;
    return await db.query(
      'categories',
      where: 'isDeleted = 0 AND userId = ?',
      whereArgs: [userId],
    );
  }

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final db = await database;
    return await db.query('users');
  }

  Future<void> clearDatabase(String table) async {
    print("NETTOYAGE DE LA BASE LOCALE ");
    final db = await database;
    await db.delete(table);
    print("NETTOYAGE DE LA BASE LOCALE $table TERMINER");
  }

  Future<void> logout() async {
    final db = await database;
    String table = '';
    // Vider la table sans supprimer la structure
    table = 'users';
    await db.execute('DELETE FROM $table');
    print("SUPPRESSION DES DONNES DE LA TABLE  $table TERMINER");
    table = 'tasks';
    await db.execute('DELETE FROM $table');
    print("SUPPRESSION DES DONNES DE LA TABLE  $table TERMINER");
    table = 'categories';
    await db.execute('DELETE FROM $table');
    print("SUPPRESSION DES DONNES DE LA TABLE  $table TERMINER");
    GlobalState().DBChecker = false;
    GlobalState().firstInitialize = false;
    GlobalState().categorieFirstInitialize = false;
    GlobalState().apiInitialize = false;
    GlobalState().categorieApiInitialize = false;
    GlobalState().localDBAutoIncrement = 0;
    GlobalState().userId = '';
    GlobalState().newIdFromApi = "";
  }

  Future<List<Task>> fetchTasksToSync(String table) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(table, where: 'is_synced = 0');
    return List.generate(maps.length, (i) => Task.fromJson(maps[i]));
  }

  Future<void> markTaskAsSynced(String taskId) async {
    final db = await database;
    await db.update('tasks', {'is_synced': 1},
        where: 'id = ?', whereArgs: [taskId]);
  }

  Future<void> insertTask(Map<String, dynamic> task) async {
    final db = await database;
    await db.insert('tasks', task);
    if (GlobalState().firstInitialize) {
      print(
          "INSERTION NOUVELLE TACHE DANS LA BASE LOCAL EFFECTUER AVEC SUCCESS");
      print(task.toString());
    } else {
      print("Tâche insérée provenant de l'API: $task");
    }
  }

  Future<void> insertUser(Map<String, dynamic> user) async {
    // print(user);
    final db = await database;
    await db.insert('users', user);
  }

  Future<void> insertTaskUpdated(Map<String, dynamic> task) async {
    final db = await database;
    await db.insert('tasks', task);
  }

  Future<void> updateTask(Map<String, dynamic> task) async {
    print(task);
    final db = await database;
    await db.update('tasks', task, where: 'id = ?', whereArgs: [task['id']]);
  }

  Future<void> delete(String taskId, String table) async {
    final db = await database;
    await db.delete(table, where: 'id = ?', whereArgs: [taskId]);
    print("$table AVEC ID  : $taskId SUPPRIMER AVEC SUCCESS DE LA BASE LOCAL");
  }

  Future<void> insertCategorie(Map<String, dynamic> categorie) async {
    // print('insertCategorie');
    // print(categorie);
    final db = await database;
    await db.insert('categories', categorie);
    if (GlobalState().categorieFirstInitialize) {
      print(
          "INSERTION NOUVELLE categorie DANS LA BASE LOCAL EFFECTUER AVEC SUCCESS");
      print(categorie.toString());
    } else {
      print("categorie insérée provenant de l'API: $categorie");
    }
  }

  insertToken(Map<String, dynamic> token) async {
    final db = await database;
    await db.insert('tokens', token);
    print("token $token insérée dans la base loval ");
  }

  Future<List<Map<String, dynamic>>> fetchtokens() async {
    final db = await database;
    return await db.query('tokens');
  }
}
