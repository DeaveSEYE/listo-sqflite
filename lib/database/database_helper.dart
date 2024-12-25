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
    if (_database != null) return _database!;
    _database = await _initializeDatabase();
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
        title TEXT NOT NULL,
        categorie TEXT,
        description TEXT,
        priority TEXT,
        isChecked BOOLEAN,
        categorieColor TEXT,
        createdAt DATE,
        updatedAt DATE, 
        dueDate DATE,
        is_synced BOOLEAN,
        isNew BOOLEAN,
        isUpdated BOOLEAN,
        isDeleted BOOLEAN
      )
    ''');
    print("Table 'tasks' créée.");

    await db.execute('''
      CREATE TABLE categorie (
        id TEXT,
        categorie TEXT,
        categorieColor TEXT,
        createdAt DATE,
        updatedAt DATE
      )
    ''');
    print("Table 'categorie' créée.");
  }

  // Méthodes pour interagir avec la base de données
  Future<List<Map<String, dynamic>>> fetchTasks() async {
    final db = await database;
    return await db.query('tasks');
  }

  Future<void> clearTasks() async {
    final db = await database;
    await db.delete('tasks');
    print("Toutes les tâches ont été supprimées.");
  }

  // Fetch tasks that need to be synced (new, updated, or deleted)
  Future<List<Task>> fetchTasksToSync() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('tasks', where: 'is_synced = 0');
    return List.generate(maps.length, (i) => Task.fromJson(maps[i]));
  }

  // Mark a task as synced after successful API sync
  Future<void> markTaskAsSynced(String taskId) async {
    final db = await database;
    await db.update('tasks', {'isUpdated': 1},
        where: 'id = ?', whereArgs: [taskId]);
  }

  // Insert a new task
  Future<void> insertTask(Map<String, dynamic> task) async {
    final db = await database;
    // Avant d'insérer dans la base locale, vérifiez ou générez un ID
    if (task['id'] == null || task['id'].isEmpty) {
      task['id'] = "listo"; // Génère un ID unique
    }
    task['is_synced'] = 0;
    task['isNew'] = 1;
    task['isUpdated'] = 0;
    task['isDeleted'] = 0;
    task['createdAt'] = '2024-12-02T15:00:00.000Z';
    task['updatedAt'] = '2024-12-02T15:00:00.000Z';
    await db.insert('tasks', task);
    if (GlobalState().firstInitialize) {
      print("INSERTION DES TACHES DANS LA BASE LOCAL EFFECTUER AVEC SUCCESS");
    } else {
      // print("Tâche insérée : $task");
    }
  }

  // Update an existing task
  Future<void> updateTask(Map<String, dynamic> task) async {
    print(task);
    final db = await database;
    await db.update('tasks', task, where: 'id = ?', whereArgs: [task['id']]);
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [taskId]);
    print("TACHE AVEC ID  : ${taskId} SUPPRIMER AVEC SUCCESS DE LA BASE LOCAL");
  }
}
