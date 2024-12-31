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
    // _syncLocalDataWithApi(); // Start syncing local data to API periodically
  }

  Future<void> _fetchTasks() async {
    // Si une opération est déjà en cours, on retourne immédiatement
    while (_isFetchingTasks) {
      await Future.delayed(Duration(milliseconds: 100));
    }

    // Activer le verrou
    _isFetchingTasks = true;

    try {
      if (!GlobalState().firstInitialize) {
        print("DEBUT PROCESS : RECUPERATION DES TACHES DEPUIS L'API");

        await _fetchTasksFromApi();
        print("FIN PROCESS : RECUPERATION DES TACHES DEPUIS L'API");
      } else {
        print("DEBUT PROCESS : RECUPERATION DES TACHES DEPUIS BASE LOCAL");
        await _fetchTasksFromLocal();
        print("FIN PROCESS : RECUPERATION DES TACHES DEPUIS BASE LOCAL");
      }
    } catch (e) {
      print("Erreur lors de l'exécution de _fetchTasks : $e");
    } finally {
      // Libérer le verrou
      _isFetchingTasks = false;
    }
  }

  Future<void> _fetchTasksFromApi() async {
    emit(Data([], isLoading: true)); // Indiquer que le chargement commence
    try {
      // Récupérer les tâches depuis l'API
      final fetchedTasks = await apiService.fetchTasks();
      // final fetchedCategories = await apiService.fetchCategories();
      print('Tâches récupérées depuis l’API : ${fetchedTasks.length}');

      // Effacer les anciennes tâches dans la base locale
      await _databaseHelper.clearTasks();
      print('Base locale effacée.');

      // Sauvegarder les nouvelles tâches dans la base locale
      for (var task in fetchedTasks) {
        await _databaseHelper.insertTask(task.toJson());
        print('Tâche sauvegardée localement : ${task.toJson()}');
      }

      // Mettre à jour l'état avec les nouvelles tâches
      emit(Data(fetchedTasks, isLoading: false));
      GlobalState().firstInitialize = true; // Mettre à jour l'état global
      print('Toutes les tâches ont été sauvegardées dans la base locale.');

      // Vérifier les tâches enregistrées localement
      final localTasks = await _databaseHelper.fetchTasks();
      print(
          "Nombre de tâches récupérées depuis la base locale : ${localTasks.length}");
      for (var task in localTasks) {
        print("Tâche locale : ${task.toString()}");
      }
      // Mettre à jour l'état avec les tâches locales
      // emit(Data(localTasks.cast<Task>(), isLoading: false));
    } catch (e) {
      // Gérer les erreurs et émettre un état vide
      print('Erreur lors de la récupération des tâches depuis l’API : $e');
      emit(Data([], isLoading: false));
    }
  }

  Future<void> _fetchTasksFromLocal() async {
    emit(Data([], isLoading: true));
    // print(
    //     "FIRST INITIALIZE DANS _fetchTasksFromLocal : ${GlobalState().firstInitialize}");
    try {
      final localTasks = await _databaseHelper.fetchTasks();
      // print(localTasks);
      final tasks = localTasks.map((e) => Task.fromJson(e)).toList();
      emit(Data(tasks));
      print('Tâches récupérées depuis la base locale.');
      // print(tasks.toString());
      // print(localTasks);
    } catch (e) {
      print('Erreur lors du chargement des tâches depuis la base locale : $e');
      emit(Data([], isLoading: false));
    }
  }

  Future<void> reload() async {
    emit(Data([], isLoading: true));
    await _fetchTasks();
    emit(Data(state.tasks, isLoading: false));
  }

  // Sync vers l'api toute les 5minutes
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

  Future<void> _syncDataToApi() async {
    // Si une opération est déjà en cours, on retourne immédiatement
    while (_isFetchingTasks) {
      await Future.delayed(Duration(milliseconds: 100));
    }

    // Activer le verrou
    _isFetchingTasks = true;
    try {
      final tasksToSync = await _databaseHelper
          .fetchTasksToSync(); // recuperer les taches non synchronisés
      print('NOMBRE TACHE A SYNCHRONISER');
      print(tasksToSync.length);
      for (var task in tasksToSync) {
        print(task.toJson());
        if (task.isNew == true) {
          // print(task.toJson());
          if (task.isDeleted == true) {
            print(
                "Tache deja supprimer de la base local donc pas besoin de faire push api distant");
            await deleteTask(task);
            return;
          } else if (task.isUpdated == true) {
            print(
                "nouvelle tache maos ayant subit modification . donc push cette version modifier a l'api distant");
            await apiService.addTask(task.toJson());
            return;
          } else {
            print(
                "nouvelle tache n'ayant subit ni de modification ni ayant ete supprime donc faire push api distant");
            await apiService.addTask(task.toJson());
            return;
          }
        } else if (task.isUpdated == true) {
          // print(task.toJson());
          if (task.isDeleted == true) {
            print(
                "Tache api modifier puis supprimer  de la base local donc supprimer de l'api distant");
            await apiService.deleteTask(task.toJson());
            return;
          } else {
            print("Tache api ayant subit modification push vers l'api distant");
            await apiService.updateTask(
                task.id, task.toJson()); // Update task on API
          }
        } else if (task.isDeleted == true) {
          await apiService.deleteTask(task.toJson());
        }

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
  }

  Future<void> updateTask(Task task) async {
    task.isUpdated = true;
    await _databaseHelper.updateTask(task.toJson());
  }

  Future<void> deleteTask(Task task) async {
    task.isDeleted = true;
    await _databaseHelper.deleteTask(task.id);
  }
}

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
