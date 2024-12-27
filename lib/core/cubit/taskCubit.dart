import 'dart:async';
import 'dart:io' show InternetAddress;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listo/core/api/service.dart';
import 'package:listo/core/utils/task.dart';
import 'package:listo/database/database_helper.dart';
import 'package:listo/core/global/global_state.dart'; // Import du gestionnaire global

class Data {
  final List<Task> tasks;
  final bool isLoading;

  Data(this.tasks, {this.isLoading = false});
}

bool _isFetchingTasks = false;

class TaskCubit extends Cubit<Data> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final apiService = ApiService(); // Instancie ApiService
  TaskCubit() : super(Data([])) {
    _fetchTasks(); // Charger les tâches lors de l'initialisation
    _syncLocalDataWithApi(); // Start syncing local data to API periodically
  }

  Future<void> _fetchTasks() async {
    // Si une opération est déjà en cours, on retourne immédiatement
    while (_isFetchingTasks) {
      await Future.delayed(Duration(milliseconds: 100));
    }

    // Activer le verrou
    _isFetchingTasks = true;

    // print('ICI');
    // _syncDataToApi();
    // print('Vérification de la connexion Internet...');
    // final internetAvailable = await isInternetAvailable();

    try {
      // if (internetAvailable) {
      // print('Connexion Internet disponible.');
      if (!GlobalState().firstInitialize) {
        print("DEBUT PROCESS : RECUPERATION DES TACHES DEPUIS L'API");
        // print(
        //     "FIRST INITIALIZE DANS _fetchTasks : ${GlobalState().firstInitialize}");
        await _fetchTasksFromApi();
        print("FIN PROCESS : RECUPERATION DES TACHES DEPUIS L'API");
      } else {
        print("DEBUT PROCESS : RECUPERATION DES TACHES DEPUIS BASE LOCAL");
        await _fetchTasksFromLocal();
        print("FIN PROCESS : RECUPERATION DES TACHES DEPUIS BASE LOCAL");
      }
      // } else {
      // print('Pas de connexion Internet. Chargement depuis la base locale...');

      // }
    } catch (e) {
      print("Erreur lors de l'exécution de _fetchTasks : $e");
    } finally {
      // Libérer le verrou
      _isFetchingTasks = false;
    }
  }

  Future<void> _fetchTasksFromApi() async {
    try {
      final fetchedTasks = await apiService.fetchTasks();
      // Effacer les anciennes tâches dans la base locale
      await _databaseHelper.clearTasks();
      // Sauvegarder les tâches récupérées dans la base locale
      for (var task in fetchedTasks) {
        await _databaseHelper.insertTask(task.toJson());
      }
      emit(Data(fetchedTasks));
      GlobalState().firstInitialize = true; // Mettre à jour l'état global
      print(
          'toutes les Tâches récupérées depuis l’API ont été sauvegardées dans la base local.');
      // Récupérer et afficher les tâches présentes dans la base locale
      final localTasks = await _databaseHelper.fetchTasks();
      print("NOMBRE TACHE RECUPERER DEPUIS L'API : ${localTasks.length}");
      for (var task in localTasks) {
        print("Tâche locale : ${task.toString()}");
      }
    } catch (e) {
      print('Erreur lors de la récupération des tâches depuis l’API : $e');
    }
  }

  Future<void> _fetchTasksFromLocal() async {
    // print(
    //     "FIRST INITIALIZE DANS _fetchTasksFromLocal : ${GlobalState().firstInitialize}");
    try {
      final localTasks = await _databaseHelper.fetchTasks();
      // print(localTasks);
      final tasks = localTasks.map((e) => Task.fromJson(e)).toList();
      emit(Data(tasks));
      print('Tâches récupérées depuis la base locale.');
      print(tasks.toString());
      // print(localTasks);
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
    Timer.periodic(Duration(minutes: 1), (timer) async {
      if (await isInternetAvailable()) {
        print(
            "Internet connecté. Tentative de synchronisation des données locales...");
        GlobalState().apiInitialize = true;
        await _syncDataToApi();
        GlobalState().apiInitialize = false;
      }
    });
  }

  // Method to sync local changes to the API
  Future<void> _syncDataToApi() async {
    // Si une opération est déjà en cours, on retourne immédiatement
    while (_isFetchingTasks) {
      await Future.delayed(Duration(milliseconds: 100));
    }

    // Activer le verrou
    _isFetchingTasks = true;
    try {
      final tasksToSync = await _databaseHelper
          .fetchTasksToSync(); // recuperer les taches non synchronisés unsynced tasks
      print('NOMBRE TACHE A SYNC');
      print(tasksToSync.length);
      for (var task in tasksToSync) {
        print(task.toJson());
        if (task.isNew == true) {
          // print(task.toJson());
          await apiService.addTask(task.toJson()); // Add new task to API
        }
        //  else if (task.isNew == true && task.isUpdated == true) {
        //   await apiService.addTask(task.toJson()); // Add new task to API
        //   task.id = GlobalState().newIdFromApi;
        //   await apiService.updateTask(
        //       task.id, task.toJson()); // Update task on API
        //   GlobalState().newIdFromApi = "";
        // }
        else if (task.isUpdated == true) {
          // print(task.toJson());
          await apiService.updateTask(
              task.id, task.toJson()); // Update task on API
        } else if (task.isDeleted == true) {
          await apiService.deleteTask(task.toJson()); // Delete task from API
        }
        // Mark the task as synced after successful API sync
        await _databaseHelper.markTaskAsSynced(task.id);
      }
      print('Données locales synchronisées avec l’API.');
    } catch (e) {
      print('Erreur lors de la synchronisation des données locales : $e');
    } finally {
      // Libérer le verrou
      _isFetchingTasks = false;
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
