import 'dart:async';
import 'dart:io' show InternetAddress;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listo/core/api/service.dart';
import 'package:listo/core/utils/categorie.dart';
import 'package:listo/core/utils/task.dart';
import 'package:listo/database/database_helper.dart';
import 'package:listo/core/global/global_state.dart'; // Import du gestionnaire global

class CatData {
  final List<Categorie> categories;
  final bool isLoading;

  CatData(this.categories, {this.isLoading = false});
}

bool _isFetchingCategories = false;

class CategorieCubit extends Cubit<CatData> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final apiService = ApiService(); // Instancie ApiService
  CategorieCubit() : super(CatData([], isLoading: false)) {
    _getCategories(
        GlobalState().userId); // Charger les tâches lors de l'initialisation
    _syncLocalCategorieWithApi(
        GlobalState().userId); // Start syncing local data to API periodically
  }

  Future<void> _getCategories(String userId) async {
    if (userId.isNotEmpty) {
      // Si une opération est déjà en cours, on retourne immédiatement
      while (_isFetchingCategories) {
        await Future.delayed(Duration(milliseconds: 100));
      }

      // Activer le verrou
      _isFetchingCategories = true;

      try {
        if (!GlobalState().categorieFirstInitialize) {
          //   print("DEBUT PROCESS : RECUPERATION DES TACHES DEPUIS L'API");

          await _fetchCategoriesFromApi(userId);
          // print("FIN PROCESS : RECUPERATION DES TACHES DEPUIS L'API");
        } else {
          // print("DEBUT PROCESS : RECUPERATION DES TACHES DEPUIS BASE LOCAL");
          await _fetchCategoriesFromLocal(userId);
          // print("FIN PROCESS : RECUPERATION DES TACHES DEPUIS BASE LOCAL");
        }
      } catch (e) {
        print("Erreur lors de l'exécution de _getCategorie : $e");
      } finally {
        // Libérer le verrou
        _isFetchingCategories = false;
      }
    }
  }

  Future<void> _fetchCategoriesFromApi(String userId) async {
    emit(CatData([], isLoading: true)); // Indiquer que le chargement commence
    try {
      // Récupérer les tâches depuis l'API
      final fetchedCategories = await apiService.fetchCategories(userId);
// Affichage des données récupérées ou du nombre de données
      print('Nombre de catégories récupérées : ${fetchedCategories.length}');

// Vous pouvez aussi afficher chaque catégorie individuellement si vous voulez plus de détails
      for (var categorie in fetchedCategories) {
        print('Catégorie: ${categorie.toJson()}');
      }

      // Effacer les anciennes tâches dans la base locale
      await _databaseHelper.clearDatabase("categories");
      // print(fetchedCategories[0].toJson());
      for (var categorie in fetchedCategories) {
        print(categorie.toJson());
        await _databaseHelper.insertCategorie(categorie.toJson());
      }
      // Mettre à jour l'état avec les nouvelles tâches
      // emit(Data(fetchedTasks, isLoading: false));
      emit(CatData(fetchedCategories, isLoading: false));

      GlobalState().categorieFirstInitialize =
          true; // Mettre à jour l'état global
      // print('Toutes les tâches ont été sauvegardées dans la base locale.');

      // Vérifier les tâches enregistrées localement
      final localTasks = await _databaseHelper.fetchCategories(userId);
      print(
          "Nombre de categories récupérées depuis la base locale : ${localTasks.length}");
      for (var task in localTasks) {
        print("categorie locale : ${task.toString()}");
      }
      // Mettre à jour l'état avec les tâches locales
      // emit(Data(localTasks.cast<Task>(), isLoading: false));
    } catch (e) {
      // Gérer les erreurs et émettre un état vide
      print('Erreur lors de la récupération des categories depuis l’API : $e');
      emit(CatData([], isLoading: false));
    }
  }

  Future<void> _fetchCategoriesFromLocal(String userId) async {
    emit(CatData([], isLoading: true));
    // print(
    //     "FIRST INITIALIZE DANS _fetchTasksFromLocal : ${GlobalState().firstInitialize}");
    try {
      // final localTasks = await _databaseHelper.fetchTasks();
      final localCategories = await _databaseHelper.fetchCategories(userId);
      // print(localTasks);
      // final tasks = localTasks.map((e) => Task.fromJson(e)).toList();
      final categories =
          localCategories.map((e) => Categorie.fromJson(e)).toList();
      emit(CatData(categories));
      print('Categories récupérées depuis la base locale.');
      // print(tasks.toString());
      // print(localTasks);
    } catch (e) {
      print('Erreur lors du chargement des tâches depuis la base locale : $e');
      emit(CatData([], isLoading: false));
    }
  }

  Future<void> reload() async {
    emit(CatData([], isLoading: true));
    await _getCategories(GlobalState().userId);
    emit(CatData(state.categories, isLoading: false));
  }

  // Sync vers l'api toute les 5minutes
  void _syncLocalCategorieWithApi(userId) {
    if (userId.isNotEmpty) {
      Timer.periodic(Duration(minutes: 1), (timer) async {
        if (await isInternetAvailable()) {
          print(
              "Internet connecté. Tentative de synchronisation des données locales...");
          GlobalState().categorieApiInitialize = true;
          await _syncCategorieToApi();
          GlobalState().categorieApiInitialize = false;
        }
      });
    }
  }

  Future<void> _syncCategorieToApi() async {
    // Si une opération est déjà en cours, on retourne immédiatement
    while (_isFetchingCategories) {
      await Future.delayed(Duration(milliseconds: 100));
    }

    // Activer le verrou
    _isFetchingCategories = true;
    try {
      final categoriesToSync = await _databaseHelper.fetchTasksToSync(
          "categories"); // recuperer les taches non synchronisés
      // print('NOMBRE TACHE A SYNCHRONISER');
      print(categoriesToSync.length);
      for (var categorie in categoriesToSync) {
        print(categorie.toJson());
        if (categorie.isNew == true) {
          // print(task.toJson());
          if (categorie.isDeleted == true) {
            print(
                "Tache deja supprimer de la base local donc pas besoin de faire push api distant");
            await delete("categories", categorie);
            return;
          } else if (categorie.isUpdated == true) {
            print(
                "nouvelle tache maos ayant subit modification . donc push cette version modifier a l'api distant");
            await apiService.addTask(categorie.toJson());
            return;
          } else {
            print(
                "nouvelle tache n'ayant subit ni de modification ni ayant ete supprime donc faire push api distant");
            await apiService.addTask(categorie.toJson());
            return;
          }
        } else if (categorie.isUpdated == true) {
          // print(task.toJson());
          if (categorie.isDeleted == true) {
            print(
                "Tache api modifier puis supprimer  de la base local donc supprimer de l'api distant");
            await apiService.deleteTask(categorie.toJson());
            return;
          } else {
            print("Tache api ayant subit modification push vers l'api distant");
            await apiService.updateTask(
                categorie.id, categorie.toJson()); // Update task on API
          }
        } else if (categorie.isDeleted == true) {
          await apiService.deleteTask(categorie.toJson());
        }

        await _databaseHelper.markTaskAsSynced(categorie.id);
      }
      print('Données locales synchronisées avec l’API.');
    } catch (e) {
      print('Erreur lors de la synchronisation des données locales : $e');
    } finally {
      // Libérer le verrou
      _isFetchingCategories = false;
    }
  }

  Future<void> createTask(Task task) async {
    task.isNew = true;
    await _databaseHelper.insertTask(task.toJson());
  }

  Future<void> update(String table, dynamic model) async {
    model.isUpdated = true;
    await _databaseHelper.delete(model.id, table); // Suppression par ID
  }

  Future<void> delete(String table, dynamic model) async {
    model.isDeleted = true;
    // if (model is Task) {
    //   // Marquer comme supprimé pour les tâches
    //   // print("Suppression d'une tâche avec ID : ${model.id}");
    // } else if (model is Categorie) {
    //   // print("Suppression d'une catégorie avec ID : ${model.id}");
    // }
    await _databaseHelper.delete(model.id, 'table'); // Suppression par ID
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
