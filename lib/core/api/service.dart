import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:listo/core/utils/categorie.dart';
import 'package:listo/core/utils/task.dart';
import 'package:listo/core/global/global_state.dart';
import 'package:listo/database/database_helper.dart'; // Import du gestionnaire global

class ApiService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  static const String taskApiUrl = 'https://task-api-firebase.vercel.app/tasks';
  static const String categorieApiUrl =
      'https://task-api-firebase.vercel.app/categories';
  static const String userApiUrl = 'https://task-api-firebase.vercel.app/users';
  Future<List<Task>> fetchTasks(String userId) async {
    if (GlobalState().firstInitialize) {
      print("Utilisation de la base de données locale pour les tâches.");
      final localTasks = await _databaseHelper.fetchTasks(userId);
      return localTasks.map((e) => Task.fromJson(e)).toList();
    } else {
      final response = await http.get(Uri.parse('$taskApiUrl/$userId'));
      if (response.statusCode == 200) {
        final List<dynamic> taskData = json.decode(response.body);
        return taskData.map((data) => Task.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load tasks');
      }
    }
  }

  Future<Map<String, dynamic>> userData(String item, String value) async {
    try {
      final response = await http
          .get(Uri.parse('https://task-api-firebase.vercel.app/users'));

      if (response.statusCode == 200) {
        final List<dynamic> usersData = json.decode(response.body);

        // Conversion de la liste dynamique en une liste de Map
        final List<Map<String, dynamic>> users =
            usersData.cast<Map<String, dynamic>>();

        // Trouver l'utilisateur avec `item` égal à `value`
        final user = users.firstWhere(
          (user) => user[item] == value,
          orElse: () =>
              <String, dynamic>{}, // Retourne une Map vide si non trouvé
        );
        print(user);
        return user; // Retourne les données de l'utilisateur trouvé ou une Map vide
      } else {
        print('Erreur : Impossible de récupérer les utilisateurs.');
        return <String, dynamic>{}; // Retourne une Map vide en cas d'échec
      }
    } catch (e) {
      print('Erreur : $e');
      return <String, dynamic>{}; // Retourne une Map vide en cas d'exception
    }
  }

  Future<void> addUser(Map<String, dynamic> user) async {
    print(user);
    // GlobalState().localDBAutoIncrement++;
    // String newId = "listo${GlobalState().localDBAutoIncrement}";
    // user['id'] = newId;
    // print(user);
    final response = await http.post(
      Uri.parse(userApiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user),
    );
    if (response.statusCode != 201) {
      print("ICI");
      print(user);
      throw Exception('Failed to add task: ${response.body}');
    } else {
      print("LA 0 ");
      final responseData = json.decode(response.body);
      user['id'] = responseData['id'];
      user.addAll({
        'auth_source': user['auth']['source'],
        'auth_id': user['auth']['id'],
        'photoUrl': user['auth']['photoUrl'],
      });
      user.remove('auth');
      print("LA");
      print(user);
      await _databaseHelper.insertUser(user);
      print("LA1");
      GlobalState().userId = responseData['id'];
      createDefaultData();
    }
  }

  Future<void> logout() async {
    // print(user);
    await _databaseHelper.logout();
  }

  void createDefaultData() async {
    final DateTime currentDate = DateTime.now();
    final DateTime dueDate = currentDate.add(Duration(days: 5));

    // Si vous souhaitez formater la date (par exemple, en ISO 8601)
    final String formattedDueDate =
        DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(dueDate);

    final task = {
      "userId": GlobalState().userId,
      "title": "Tache par defaut",
      "categorie": "Defaut",
      "description": "description de la tache",
      "priority": "basse",
      "isChecked": true,
      "categorieColor": "grey",
      "dueDate": formattedDueDate,
      "isNew": 0,
      "isUpdated": 0,
      "isDeleted": 0,
      "is_synced": 0,
    };
    // task['isChecked'] = task['isChecked'] == false ? false : true;
    final categorie = {
      "userId": GlobalState().userId,
      "categorie": "Defaut",
      "categorieColor": "#9E9E9E"
    };
    // await addTask(task);
    // await addCategory(categorie);
//creer et enregistrer une tache par defaut
    final respTask = await http.post(
      Uri.parse(taskApiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task),
    );
    if (respTask.statusCode != 201) {
      print("task api");
      print(task);
      print('Failed to add default task');
      throw Exception('Failed to add default task: ${respTask.body}');
    } else {
      // final respTaskData = json.decode(respTask.body);
      // task['id'] = respTaskData['id'];
      // task['isChecked'] = task['isChecked'] == false ? 0 : 1;
      // print("task local");
      // print(task);
      // await _databaseHelper.insertTask(task);
    }
//     //creer et enregistrer une categorie par defaut
    final respCategorie = await http.post(
      Uri.parse(categorieApiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(categorie),
    );
    if (respCategorie.statusCode != 201) {
      print("categorie api");
      print(categorie);
      print('Failed to add default categorie');
      throw Exception(
          'Failed to add default categorie : ${respCategorie.body}');
    } else {
      // final respCategorieData = json.decode(respCategorie.body);
      // categorie['id'] = respCategorieData['id'];
      // await _databaseHelper.insertCategorie(categorie);
    }
  }

  Future<void> addTask(Map<String, dynamic> taskData) async {
    print(taskData);
    taskData['userId'] = GlobalState().userId;
    GlobalState().localDBAutoIncrement++;
    String newId = "listo${GlobalState().localDBAutoIncrement}";
    taskData['id'] = newId;
    // print(
    //     "GlobalState().firstInitialize  : ${GlobalState().firstInitialize}  & GlobalState().apiInitialize ; ${GlobalState().apiInitialize}");
    if (GlobalState().firstInitialize && GlobalState().apiInitialize == false) {
      print("Ajout de la tâche dans la base locale.");
      taskData['isChecked'] = taskData['isChecked'] == false ? 0 : 1;
      taskData['isNew'] = 1;
      // GlobalState().localDBAutoIncrement++;
      // String newId = "listo${GlobalState().localDBAutoIncrement}";
      // taskData['id'] = newId;
      taskData.addAll({
        'is_synced': 0,
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
        taskData['isChecked'] = taskData['isChecked'] == false ? 0 : 1;
        final String idFromApi = responseData['id']; // Récupération de l'ID
        print('tache ajouté avec success  ID: $idFromApi');
        await _databaseHelper.delete(taskData['id'], 'tasks');
        taskData['id'] = idFromApi;
        GlobalState().newIdFromApi = idFromApi;
        taskData['isNew'] = 0;
        // print(taskData['isUpdated']);
        if (taskData['isUpdated'] == null || taskData['isUpdated'] == 1) {
          taskData['isUpdated'] = 0;
          taskData['isDeleted'] = 0;
        }
        taskData['is_synced'] = 0;
        print(taskData);
        await _databaseHelper.insertTaskUpdated(taskData);
      }
      GlobalState().apiInitialize = false;
    }
  }

  Future<void> deleteTask(Map<String, dynamic> task) async {
    task['userId'] = GlobalState().userId;
    if (GlobalState().firstInitialize && GlobalState().apiInitialize == false) {
      // print(
      //     "FIRST INITIALIZE dans deleteTask : ${GlobalState().firstInitialize}");
      print("Suppression de la tâche de la base locale.");
      task['isChecked'] = task['isChecked'] == false ? 0 : 1;
      task['isDeleted'] = 1;
      task.addAll({
        'is_synced': 0,
      });

      await _databaseHelper.updateTask(task);
    } else {
      // print(
      //     "FIRST INITIALIZE dans deleteTask : ${GlobalState().firstInitialize}");
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
        task['isUpdated'] = 0;
        task.addAll({
          'is_synced': 0,
        });
        await _databaseHelper.delete(task['id'], 'tasks');
      }
    }
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> taskData) async {
    taskData['userId'] = GlobalState().userId;
    // print(taskData);
    if (GlobalState().firstInitialize && GlobalState().apiInitialize == false) {
      print("Mise à jour de la tâche dans la base locale.");
      taskData['isChecked'] = taskData['isChecked'] == false ? 0 : 1;
      taskData['isUpdated'] = 1;
      taskData.addAll({
        'is_synced': 0,
      });
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
      print(taskId);

      final apiUrl = '$taskApiUrl/$taskId';
      print(apiUrl);
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(taskData),
      );
      // print(response.statusCode);
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to update task: ${response.body}');
      } else {
        taskData['isUpdated'] = 0;
        taskData['isChecked'] = taskData['isChecked'] == false ? 0 : 1;
        await _databaseHelper.updateTask(taskData);
      }
    }
  }

  Future<void> check(bool isChecked, Map<String, dynamic> taskData) async {
    taskData['userId'] = GlobalState().userId;
    // print(taskData);
    if (GlobalState().firstInitialize && GlobalState().apiInitialize == false) {
      print(
          "Mise à jour de la tâche (terminer / en attente) dans la base locale.");
      taskData['isChecked'] = isChecked == false ? 0 : 1;
      taskData['isUpdated'] = 1;
      taskData.addAll({
        'is_synced': 0,
      });
      await _databaseHelper.updateTask(taskData);
    } else {
      print(
          "Mise à jour de la tâche (terminer / en attente) via l'API distante.");

      List<String> keysToRemove = [
        'is_synced',
        'isNew',
        'isUpdated',
        'isDeleted'
      ];

      for (var key in keysToRemove) {
        taskData.remove(key);
      }
      taskData['isChecked'] = isChecked == false ? false : true;

      final apiUrl = "$taskApiUrl/$taskData['id']";
      print(apiUrl);
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(taskData),
      );
      // print(response.statusCode);
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
            'Failed to update task (terminer / en attente) task: ${response.body}');
      } else {
        taskData['isUpdated'] = 0;
        taskData['isChecked'] = isChecked == false ? 0 : 1;
        await _databaseHelper.updateTask(taskData);
      }
    }
  }

  // static Future<List<Categorie>> fetchCategories() async {
  //   final response = await http.get(Uri.parse(categorieApiUrl));
  //   if (response.statusCode == 200) {
  //     final List<dynamic> categorieData = json.decode(response.body);
  //     return categorieData.map((data) => Categorie.fromJson(data)).toList();
  //   } else {
  //     throw Exception('Failed to load categories');
  //   }
  // }

  Future<List<Categorie>> fetchCategories(String userId) async {
    if (GlobalState().categorieFirstInitialize) {
      print("Utilisation de la base de données locale pour les categories.");
      final localCategories = await _databaseHelper.fetchCategories(userId);
      return localCategories.map((e) => Categorie.fromJson(e)).toList();
    } else {
      print("Utilisation API pour les categories.");
      final response = await http.get(Uri.parse('$categorieApiUrl/$userId'));
      if (response.statusCode == 200) {
        final List<dynamic> categoriesData = json.decode(response.body);
        return categoriesData.map((data) => Categorie.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    }
  }

//   static Future<void> addCategory(Map<String, dynamic> categoryData) async {
//     final response = await http.post(
//       Uri.parse(categorieApiUrl),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(categoryData),
//     );
//     if (response.statusCode != 201) {
//       throw Exception('Failed to add category: ${response.body}');
//     }
//   }

  Future<void> addCategory(Map<String, dynamic> categorie) async {
    // print(categorie);
    categorie['userId'] = GlobalState().userId;
    if (GlobalState().categorieFirstInitialize &&
        GlobalState().categorieApiInitialize == false) {
      print("Ajout de la categorie dans la base locale.");
      GlobalState().localDBAutoIncrement++;
      String newId = "listo${GlobalState().localDBAutoIncrement}";
      print(newId);
      categorie['id'] = newId;
      categorie['is_synced'] = "0";
      categorie['isNew'] = "1";
      categorie['isUpdated'] = "0";
      categorie['isDeleted'] = "0";
      print(categorie);
      await _databaseHelper.insertCategorie(categorie);
    } else {
      print("Ajout de la categorie via l'API distante.");
      List<String> keysToRemove = [
        'is_synced',
        'isNew',
        'isUpdated',
        'isDeleted'
      ];

      for (var key in keysToRemove) {
        categorie.remove(key);
      }
      final response = await http.post(
        Uri.parse(taskApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(categorie),
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to add task: ${response.body}');
      } else {
        final responseData = json.decode(response.body);
        final String idFromApi = responseData['id']; // Récupération de l'ID
        print('categorie ajouté avec success  ID: $idFromApi');
        await _databaseHelper.delete(categorie['id'], 'categories');
        categorie['id'] = idFromApi;
        GlobalState().newIdFromApi = idFromApi;
        categorie['isNew'] = 0;
        // print(taskData['isUpdated']);
        if (categorie['isUpdated'] == null || categorie['isUpdated'] == 1) {
          categorie['isUpdated'] = 0;
          categorie['isDeleted'] = 0;
        }
        categorie['is_synced'] = 0;
        print(categorie);
        await _databaseHelper.insertTaskUpdated(categorie);
      }
      GlobalState().categorieFirstInitialize = false;
    }
  }
}
