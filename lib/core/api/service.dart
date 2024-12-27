import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:listo/core/utils/categorie.dart';
import 'package:listo/core/utils/task.dart';
import 'package:listo/core/global/global_state.dart';
import 'package:listo/database/database_helper.dart'; // Import du gestionnaire global

class ApiService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  static const String taskApiUrl = 'https://task-api-firebase.vercel.app/tasks';
  static const String categorieApiUrl =
      'https://task-api-firebase.vercel.app/categories';

  Future<List<Task>> fetchTasks() async {
    if (GlobalState().firstInitialize) {
      print("Utilisation de la base de données locale pour les tâches.");
      final localTasks = await _databaseHelper.fetchTasks();
      return localTasks.map((e) => Task.fromJson(e)).toList();
    } else {
      final response = await http.get(Uri.parse(taskApiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> taskData = json.decode(response.body);
        return taskData.map((data) => Task.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load tasks');
      }
    }
  }

  Future<void> addTask(Map<String, dynamic> taskData) async {
    print(GlobalState().firstInitialize);
    if (GlobalState().firstInitialize && GlobalState().apiInitialize == false) {
      print("Ajout de la tâche dans la base locale.");
      taskData['isChecked'] = taskData['isChecked'] == false ? 0 : 1;
      GlobalState().localDBAutoIncrement++;
      String newId = "listo${GlobalState().localDBAutoIncrement}";
      taskData.addAll({
        'id': newId,
        'is_synced': 0,
        'isNew': 1,
        'isUpdated': 0,
        'isDeleted': 0,
      });

      await _databaseHelper.insertTask(taskData);
    } else {
      print("Ajout de la tâche via l'API distante.");
      taskData['isChecked'] = taskData['isChecked'] == false ? false : true;
      List<String> keysToRemove = [
        'is_synced',
        'isNew',
        'isUpdated',
        'isDeleted'
      ];

      for (var key in keysToRemove) {
        taskData.remove(key);
      }
      final response = await http.post(
        Uri.parse(taskApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(taskData),
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to add task: ${response.body}');
      } else {
        final responseData = json.decode(response.body);
        final String idFromApi = responseData['id']; // Récupération de l'ID
        print('Task added successfully with ID: $idFromApi');
        taskData['isChecked'] = taskData['isChecked'] == false ? 0 : 1;
        taskData['id'] = idFromApi;
        GlobalState().newIdFromApi = idFromApi;
        taskData['isNew'] = 0;
        taskData['is_synced'] = 0;
        print("daouda");
        print(taskData);
        await _databaseHelper.updateTask(taskData);
      }
      GlobalState().apiInitialize = false;
    }
  }

  Future<void> deleteTask(Map<String, dynamic> task) async {
    if (GlobalState().firstInitialize && GlobalState().apiInitialize == false) {
      print(
          "FIRST INITIALIZE dans deleteTask : ${GlobalState().firstInitialize}");
      print("Suppression de la tâche de la base locale.");
      // print(taskId);
      task['isChecked'] = task['isChecked'] == false ? 0 : 1;
      task.addAll({
        'is_synced': 0,
        'isNew': 0,
        'isUpdated': 0,
        'isDeleted': 1,
      });
      // await _databaseHelper.deleteTask(task['id']);
      await _databaseHelper.updateTask(task);
    } else {
      print(
          "FIRST INITIALIZE dans deleteTask : ${GlobalState().firstInitialize}");
      print("Suppression de la tâche via l'API distante.");
      final apiUrl = "$taskApiUrl/${task['id']}";
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );
      print(response.statusCode);
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete task: ${response.body}');
      } else {
        print(
            "TACHE AVEC ID  : ${task['id']} SUPPRIMER AVEC SUCCESS VIA L'API'");
        task['isNew'] = 0;
        task['isDeleted'] = 0;
        task.addAll({
          'is_synced': 0,
        });
        await _databaseHelper.updateTask(task);
      }
    }
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> taskData) async {
    print(
        "GlobalState().firstInitialize  : ${GlobalState().firstInitialize}  & GlobalState().apiInitialize ; ${GlobalState().apiInitialize}");
    if (GlobalState().firstInitialize && GlobalState().apiInitialize == false) {
      print("Mise à jour de la tâche dans la base locale.");
      taskData['isChecked'] = taskData['isChecked'] == false ? 0 : 1;
      taskData.addAll({
        'is_synced': 0,
        'isNew': 0,
        'isUpdated': 1,
        'isDeleted': 0,
      });
      // print('ICI');
      // print(taskData);
      await _databaseHelper.updateTask(taskData);
    } else {
      print("Mise à jour de la tâche via l'API distante.");

      List<String> keysToRemove = [
        'is_synced',
        'isNew',
        'isUpdated',
        'isDeleted'
      ];

      for (var key in keysToRemove) {
        taskData.remove(key);
      }
      taskData['isChecked'] = taskData['isChecked'] == false ? false : true;
      // print('LALALA');
      // print(taskData);
      print(taskId);

      final apiUrl = '$taskApiUrl/$taskId';
      print(apiUrl);
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(taskData),
      );
      print(response.statusCode);
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to update task: ${response.body}');
      } else {
        taskData['isUpdated'] = 0;
        taskData['isChecked'] = taskData['isChecked'] == false ? 0 : 1;
        await _databaseHelper.updateTask(taskData);
      }
      // GlobalState().apiInitialize = false;
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
