import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:listo/core/utils/categorie.dart';
import 'package:listo/core/utils/task.dart';
import 'package:listo/core/global/global_state.dart';
import 'package:listo/database/database_helper.dart'; // Import du gestionnaire global

class ApiService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  // static const String taskApiUrl = 'http://localhost:3000/task';
  //static const String categorieApiUrl = 'http://localhost:3000/categorie';

  // static const String taskApiUrl = 'https://taskapi-yz3z.onrender.com/task';
  // static const String categorieApiUrl =
  //     'https://taskapi-yz3z.onrender.com/categorie';
  static const String taskApiUrl = 'https://task-api-firebase.vercel.app/tasks';
  static const String categorieApiUrl =
      'https://task-api-firebase.vercel.app/categories';
  // Fetch tasks from the API
  Future<List<Task>> fetchTasks() async {
    if (GlobalState().firstInitialize) {
      print("Utilisation de la base de données locale pour les tâches.");
      final localTasks = await _databaseHelper.fetchTasks();
      return localTasks.map((e) => Task.fromJson(e)).toList();
    } else {
      print('Connexion Internet disponible.');
      // print("Utilisation de l'API distante pour les tâches.");
      final response = await http.get(Uri.parse(taskApiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> taskData = json.decode(response.body);
        return taskData.map((data) => Task.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load tasks');
      }
    }
  }

  // Add a new task to the API
  Future<void> addTask(Map<String, dynamic> taskData) async {
    if (GlobalState().firstInitialize) {
      print("Ajout de la tâche dans la base locale.");
      taskData['isChecked'] = taskData['isChecked'] == false ? 0 : 1;
      taskData['id'] = "listo";
      await _databaseHelper.insertTask(taskData);
    } else {
      print("Ajout de la tâche via l'API distante.");
      final response = await http.post(
        Uri.parse(taskApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(taskData),
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to add task: ${response.body}');
      }
    }
  }

  // delete task to the API
  Future<void> deleteTask(String taskId) async {
    if (GlobalState().firstInitialize) {
      print(
          "FIRST INITIALIZE dans deleteTask : ${GlobalState().firstInitialize}");
      print("Suppression de la tâche de la base locale.");
      // print(taskId);
      await _databaseHelper.deleteTask(taskId);
    } else {
      print(
          "FIRST INITIALIZE dans deleteTask : ${GlobalState().firstInitialize}");
      print("Suppression de la tâche via l'API distante.");
      final apiUrl = '$taskApiUrl/$taskId';
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete task: ${response.body}');
      } else {
        print("TACHE AVEC ID  : ${taskId} SUPPRIMER AVEC SUCCESS VIA L'API'");
      }
    }
  }

  // update task to the API
  Future<void> updateTask(String taskId, Map<String, dynamic> taskData) async {
    if (GlobalState().firstInitialize) {
      print("Mise à jour de la tâche dans la base locale.");
      taskData['isChecked'] = taskData['isChecked'] == false ? 0 : 1;
      taskData['id'] = "listo";
      // print(taskData);
      await _databaseHelper.updateTask(taskData);
    } else {
      print("Mise à jour de la tâche via l'API distante.");
      final apiUrl = '$taskApiUrl/$taskId';
      final response = await http.patch(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(taskData),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to update task: ${response.body}');
      }
    }
  }

  static Future<List<Categorie>> fetchCategories() async {
    final response = await http.get(Uri.parse(categorieApiUrl));
    if (response.statusCode == 200) {
      // print(json.decode(response.body));
      final List<dynamic> categorieData = json.decode(response.body);
      return categorieData.map((data) => Categorie.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // Add a new category to the API
  static Future<void> addCategory(Map<String, dynamic> categoryData) async {
    final response = await http.post(
      Uri.parse(categorieApiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(categoryData),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add category: ${response.body}');
    }
  }
}
