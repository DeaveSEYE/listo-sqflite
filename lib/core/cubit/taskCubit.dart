import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listo/core/api/service.dart';
import 'package:listo/core/local_notification.dart';
import 'package:listo/core/utils/NetworkUtils.dart';
import 'package:listo/core/utils/categorie.dart';
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
  TaskCubit() : super(Data([], isLoading: false)) {
    _getData(
        GlobalState().userId); // Charger les tâches lors de l'initialisation
    _syncLocalTaskWithApi(
        GlobalState().userId); // Start syncing local data to API periodically
  }

  Future<void> _getData(String userId) async {
    if (userId.isNotEmpty) {
      // Si une opération est déjà en cours, on retourne immédiatement
      while (_isFetchingTasks) {
        await Future.delayed(Duration(milliseconds: 100));
      }

      // Activer le verrou
      _isFetchingTasks = true;
      bool isConnected = await NetworkUtils.isInternetAvailable();

      try {
        if (isConnected) {
          print("DEBUT PROCESS : RECUPERATION DES TACHES DEPUIS L'API");
          await _fetchTasksFromApi(userId);
          print("FIN PROCESS : RECUPERATION DES TACHES DEPUIS L'API");
        } else {
          print("DEBUT PROCESS : RECUPERATION DES TACHES DEPUIS BASE LOCAL");
          await _fetchTasksFromLocal(userId);
          print("FIN PROCESS : RECUPERATION DES TACHES DEPUIS BASE LOCAL");
        }
      } catch (e) {
        print("Erreur lors de l'exécution de _fetchTasks : $e");
      } finally {
        // Libérer le verrou
        _isFetchingTasks = false;
      }
    }
  }

  Future<void> _fetchTasksFromApi(String userId) async {
    print("userId");
    print(userId);
    emit(Data([], isLoading: true)); // Indiquer que le chargement commence
    try {
      // Récupérer les tâches depuis l'API
      final fetchedTasks = await apiService.fetchTasks(userId);
      print('Tâches récupérées depuis l’API : ${fetchedTasks.length}');

      // Effacer les anciennes tâches dans la base locale
      await _databaseHelper.clearDatabase("tasks");
      print('Base locale effacée.');

      // Sauvegarder les nouvelles tâches dans la base locale
      for (var task in fetchedTasks) {
        await _databaseHelper.insertTask(task.toJson());
        print('Tâche sauvegardée localement : ${task.toJson()}');
      }
      // Mettre à jour l'état avec les nouvelles tâches
      // emit(Data(fetchedTasks, isLoading: false));
      emit(Data(fetchedTasks, isLoading: false));

      GlobalState().firstInitialize = true; // Mettre à jour l'état global
      print('Toutes les tâches ont été sauvegardées dans la base locale.');

      // Vérifier les tâches enregistrées localement
      final localTasks = await _databaseHelper.fetchTasks(userId);
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

  Future<void> _fetchTasksFromLocal(String userId) async {
    emit(Data([], isLoading: true));
    try {
      final localTasks = await _databaseHelper.fetchTasks(userId);
      // print(localTasks);
      final tasks = localTasks.map((e) => Task.fromJson(e)).toList();
      emit(Data(tasks));
      print('Tâches récupérées depuis la base locale.');
      // print(tasks.toString());
    } catch (e) {
      print('Erreur lors du chargement des tâches depuis la base locale : $e');
      emit(Data([], isLoading: false));
    }
  }

  Future<void> reload() async {
    emit(Data([], isLoading: true));
    await _getData(GlobalState().userId);
    emit(Data(state.tasks, isLoading: false));
  }

  // Sync vers l'api toute les 5minutes
  void _syncLocalTaskWithApi(userId) {
    if (userId.isNotEmpty) {
      Timer.periodic(Duration(minutes: 10), (timer) async {
        // Vérifier les tâches et envoyer des notifications
        final localTasks = await _databaseHelper.fetchTasks(userId);
        final tasks = localTasks.map((e) => Task.fromJson(e)).toList();
        final localCategories = await _databaseHelper.fetchCategories(userId);
        // print(localTasks);
        // final tasks = localTasks.map((e) => Task.fromJson(e)).toList();
        final categories =
            localCategories.map((e) => Categorie.fromJson(e)).toList();
        await checkTasksAndNotify(tasks, categories);
        // Vérifier les tâches et envoyer des notifications
        bool isConnected = await NetworkUtils.isInternetAvailable();
        if (isConnected) {
          print(
              "Internet connecté. Tentative de synchronisation des données locales...");
          GlobalState().apiInitialize = true;
          await _syncTaskToApi();
          GlobalState().apiInitialize = false;
        }
      });
    }
  }

  Future<void> _syncTaskToApi() async {
    // Si une opération est déjà en cours, on retourne immédiatement
    while (_isFetchingTasks) {
      await Future.delayed(Duration(milliseconds: 100));
    }

    // Activer le verrou
    _isFetchingTasks = true;
    try {
      final tasksToSync = await _databaseHelper
          .fetchTasksToSync("tasks"); // recuperer les taches non synchronisés
      print('NOMBRE TACHE A SYNCHRONISER');
      print(tasksToSync.length);
      for (var task in tasksToSync) {
        print(task.toJson());
        if (task.isNew == true) {
          // print(task.toJson());
          if (task.isDeleted == true) {
            print(
                "Tache deja supprimer de la base local donc pas besoin de faire push api distant");
            await deleteTask(task, 'tasks');
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

  Future<void> deleteTask(Task task, String table) async {
    task.isDeleted = true;
    await _databaseHelper.delete(task.id, table);
  }
}

Future<void> checkTasksAndNotify(
    List<Task> tasks, List<Categorie> categories) async {
  // Envoi d'une notification au chargement de l'écran
  final payload = {
    'route': '/task',
    'tasks': [],
    'categories': categories,
  };

  // Filtrer les tâches de la journée
  final tasksForToday =
      tasks.where((task) => task.tachesDeLaJournee()).toList();
  if (tasksForToday.isNotEmpty) {
    payload['tasks'] = tasksForToday;
    final payloadString = jsonEncode(payload); // Convertir en chaîne JSON
    NotificationService().showNotification(
      id: 1,
      title: 'Vos tâches de la journée',
      body: 'Vous avez ${tasksForToday.length} tâches pour aujourd\'hui.',
      payload: payloadString, // La route où rediriger
    );
  }

  // Filtrer les tâches avec échéance dans 4 heures
  final tasksDueIn4Hours =
      tasks.where((task) => task.echeanceDans4Heures()).toList();
  if (tasksDueIn4Hours.isNotEmpty) {
    payload['tasks'] = tasksDueIn4Hours;
    final payloadString = jsonEncode(payload); // Convertir en chaîne JSON
    NotificationService().showNotification(
      id: 1,
      title: 'Tâche à échéance dans 4 heures',
      body:
          'Vous avez ${tasksDueIn4Hours.length} tâche(s) à échéance dans 4 heures.',
      payload: payloadString, // La route où rediriger
    );
  }

  // Filtrer les tâches avec échéance dans 2 heures
  final tasksDueIn2Hours =
      tasks.where((task) => task.echeanceDans2Heures()).toList();
  if (tasksDueIn2Hours.isNotEmpty) {
    payload['tasks'] = tasksDueIn2Hours;
    final payloadString = jsonEncode(payload); // Convertir en chaîne JSON
    NotificationService().showNotification(
      id: 1,
      title: 'Tâche à échéance dans 2 heures',
      body:
          'Vous avez ${tasksDueIn2Hours.length} tâche(s) à échéance dans 2 heures.',
      payload: payloadString, // La route où rediriger
    );
  }

  // Filtrer les tâches avec échéance dans 10 minutes
  final tasksDueIn10Minutes =
      tasks.where((task) => task.echeanceDans30Minutes()).toList();
  if (tasksDueIn10Minutes.isNotEmpty) {
    payload['tasks'] = tasksDueIn10Minutes;
    final payloadString = jsonEncode(payload); // Convertir en chaîne JSON
    NotificationService().showNotification(
      id: 1,
      title: 'Tâche à échéance dans 10 minutes',
      body:
          'Vous avez ${tasksDueIn10Minutes.length} tâche(s) à échéance dans 10 minutes.',
      payload: payloadString, // La route où rediriger
    );
  }
}
