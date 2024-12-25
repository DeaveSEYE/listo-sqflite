import 'dart:async';
import 'dart:io' show InternetAddress;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listo/core/api/service.dart';
import 'package:listo/core/utils/task.dart';
import 'package:listo/database/database_helper.dart';

class Data {
  final List<Task> tasks;
  final bool isLoading;

  Data(this.tasks, {this.isLoading = false});
}

class TaskCubit extends Cubit<Data> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  // final StreamController<void> _syncController = StreamController<void>();

  TaskCubit() : super(Data([])) {
    _fetchTasks(); // Charger les tâches lors de l'initialisation
    _syncLocalDataWithApi(); // Start syncing local data to API periodically
  }

  Future<void> _fetchTasks() async {
    print('Vérification de la connexion Internet...');
    final internetAvailable = await isInternetAvailable();

    if (internetAvailable) {
      print('Connexion Internet disponible.');
      await _fetchTasksFromApi();
    } else {
      print('Pas de connexion Internet. Chargement depuis la base locale...');
      await _fetchTasksFromLocal();
    }
  }

  Future<void> _fetchTasksFromApi() async {
    try {
      final fetchedTasks = await ApiService.fetchTasks();
      // Effacer les anciennes tâches dans la base locale
      await _databaseHelper.clearTasks();
      // Sauvegarder les tâches récupérées dans la base locale
      for (var task in fetchedTasks) {
        await _databaseHelper.insertTask(task.toJson());
      }
      emit(Data(fetchedTasks));
      print('Tâches récupérées depuis l’API et sauvegardées localement.');
    } catch (e) {
      print('Erreur lors de la récupération des tâches depuis l’API : $e');
    }
  }

  Future<void> _fetchTasksFromLocal() async {
    try {
      final localTasks = await _databaseHelper.fetchTasks();
      final tasks = localTasks.map((e) => Task.fromJson(e)).toList();
      emit(Data(tasks));
      print('Tâches récupérées depuis la base locale.');
    } catch (e) {
      print('Erreur lors du chargement des tâches depuis la base locale : $e');
    }
  }

  Future<void> reload() async {
    emit(Data([], isLoading: true));
    await _fetchTasks();
    emit(Data(state.tasks, isLoading: false));
  }

  // Sync local data with API periodically
  void _syncLocalDataWithApi() {
    Timer.periodic(Duration(minutes: 5), (timer) async {
      if (await isInternetAvailable()) {
        print(
            "Internet connecté. Tentative de synchronisation des données locales...");
        await _syncDataToApi();
      }
    });
  }

  // Method to sync local changes to the API
  Future<void> _syncDataToApi() async {
    try {
      final tasksToSync =
          await _databaseHelper.fetchTasksToSync(); // Fetch unsynced tasks
      for (var task in tasksToSync) {
        if (task.isNew) {
          await ApiService.addTask(task.toJson()); // Add new task to API
        } else if (task.isUpdated) {
          await ApiService.updateTask(
              task.id, task.toJson()); // Update task on API
        } else if (task.isDeleted) {
          await ApiService.deleteTask(task.id); // Delete task from API
        }
        // Mark the task as synced after successful API sync
        await _databaseHelper.markTaskAsSynced(task.id);
      }
      print('Données locales synchronisées avec l’API.');
    } catch (e) {
      print('Erreur lors de la synchronisation des données locales : $e');
    }
  }

  Future<void> createTask(Task task) async {
    task.isNew = true;
    await _databaseHelper.insertTask(task.toJson());
    // After insertion, you can handle other operations if needed.
  }

  Future<void> updateTask(Task task) async {
    task.isUpdated = true;
    await _databaseHelper.updateTask(task.toJson());
    // After update, you can handle other operations if needed.
  }

  Future<void> deleteTask(Task task) async {
    task.isDeleted = true;
    await _databaseHelper.deleteTask(task.id);
    // After deletion, you can handle other operations if needed.
  }
}

// Check for internet availability
Future<bool> isInternetAvailable() async {
  if (kIsWeb) {
    try {
      final result = Uri.parse("https://google.com").resolveUri(Uri());
      return result.host.isNotEmpty;
    } catch (e) {
      print(
          'Erreur lors de la vérification de la connexion Internet (Web) : $e');
      return false;
    }
  } else {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      print('Erreur lors de la vérification de la connexion Internet : $e');
      return false;
    }
  }
}
