import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
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
         id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        categorie TEXT,
        description TEXT,
        priority TEXT,
        isChecked BOOLEAN,
        categorieColor TEXT,
        createdAt DATE,
        updatedAt DATE, 
        dueDate DATE,
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
        await db.query('tasks', where: 'is_synced = "false"');
    return List.generate(maps.length, (i) => Task.fromJson(maps[i]));
  }

  // Mark a task as synced after successful API sync
  Future<void> markTaskAsSynced(int taskId) async {
    final db = await database;
    await db.update('tasks', {'is_synced': true},
        where: 'id = ?', whereArgs: [taskId]);
  }

  // Insert a new task
  Future<void> insertTask(Map<String, dynamic> task) async {
    final db = await database;
    await db.insert('tasks', task);
    print("Tâche insérée : $task");
  }

  // Update an existing task
  Future<void> updateTask(Map<String, dynamic> task) async {
    final db = await database;
    await db.update('tasks', task, where: 'id = ?', whereArgs: [task['id']]);
  }

  // Delete a task
  Future<void> deleteTask(int taskId) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [taskId]);
  }
}
