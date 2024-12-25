import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:listo/core/cubit/taskCubit.dart';
import 'package:listo/core/utils/categorie.dart';
import 'package:listo/core/utils/task.dart';

class ApiService {
  // static const String taskApiUrl = 'http://localhost:3000/task';
  //static const String categorieApiUrl = 'http://localhost:3000/categorie';

  static const String taskApiUrl = 'https://taskapi-yz3z.onrender.com/task';
  static const String categorieApiUrl =
      'https://taskapi-yz3z.onrender.com/categorie';
  // Fetch tasks from the API
  static Future<List<Task>> fetchTasks() async {
    final response = await http.get(Uri.parse(taskApiUrl));
    if (response.statusCode == 200) {
      final List<dynamic> taskData = json.decode(response.body);
      return taskData.map((data) => Task.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  // Add a new task to the API
  static Future<void> addTask(Map<String, dynamic> taskData) async {
    final response = await http.post(
      Uri.parse(taskApiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(taskData),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add task: ${response.body}');
    }
  }

  // delete task to the API
  static Future<void> deleteTask(int taskId) async {
    final apiUrl = '$taskApiUrl/$taskId';

    try {
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      // Vérifie si le code de statut indique une réussite (200 ou 204)
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete task: ${response.body}');
      }
    } catch (e) {
      // Gérer les exceptions, par exemple afficher une erreur ou la journaliser
      print('Error deleting task: $e');
      throw Exception('An error occurred while deleting the task.');
    }
  }

  // update task to the API
  static Future<void> updateTask(
      int taskId, Map<String, dynamic> taskData) async {
    final apiUrl = '$taskApiUrl/$taskId';

    try {
      final response = await http.patch(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(taskData),
      );

      // Vérifie si le code de statut indique une réussite (200 ou 204)
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to update task: ${response.body}');
      }
    } catch (e) {
      // Gérer les exceptions, par exemple afficher une erreur ou la journaliser
      print('Error deleting task: $e');
      throw Exception('An error occurred while updating the task.');
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
