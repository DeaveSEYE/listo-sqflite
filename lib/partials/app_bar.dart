import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:listo/core/cubit/taskCubit.dart';
import 'package:listo/core/local_notification.dart';
import 'package:listo/core/theme/colors.dart';
import 'package:listo/core/utils/task.dart';
import 'package:listo/features/profile/ui/profile.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listo/partials/notification.dart';
import 'package:listo/routes.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Function(List<Task>)
      onSearchCallback; // Callback pour mettre à jour l'index

  const CustomAppBar({super.key, required this.onSearchCallback});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Task> _filteredTasks = []; // Liste des tâches filtrées

  // Fonction de recherche
  void onSearch(String query, List<Task> tasks) {
    if (query.isEmpty) {
      setState(() {
        _filteredTasks = tasks;
      });
      NotificationHelper.showFlushbar(
        // ignore: use_build_context_synchronously
        context: context,
        message: "Veuiller saisir la tache a rechercher",
        type: NotificationType.alert,
      );

      // Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        _filteredTasks = tasks
            .where((task) =>
                task.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
      if (_filteredTasks.isEmpty) {
        NotificationHelper.showFlushbar(
          // ignore: use_build_context_synchronously
          context: context,
          message: "Aucune tache trouvé ",
          type: NotificationType.error,
        );
      } else {
        print(_filteredTasks);
        print(_filteredTasks.length);

        // Appeler le callback pour informer MainScaffold de la recherche et mettre à jour l'index
        // widget.onSearchCallback(_filteredTasks);
        // Redirection vers la page '/search' avec _filteredTasks en argument
        // Navigator.pushReplacementNamed(
        //   context,
        //   '/search',
        //   arguments: _filteredTasks,
        // );
        print('REDIRECTION VERS SEARCH AVEC : $_filteredTasks');
        // Navigator.pushReplacementNamed(context, '/search',
        //     arguments: _filteredTasks);
        Navigator.pushReplacementNamed(
          context,
          Routes.searchPage,
          arguments: {
            'tasks': _filteredTasks,
            // 'categories': [], // Assurez-vous de passer les catégories
          },
        );
        // Navigator.pushReplacementNamed(
        //   context,
        //   Routes.searchPage,
        //   arguments: {
        //     'tasks': _filteredTasks, // Liste des tâches filtrées
        //     'categories': [], // Liste des catégories
        //   },
        // );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary, // Fond de l'AppBar
      leading: IconButton(
        icon: const Icon(
          Icons.person,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        },
      ),
      title: BlocBuilder<TaskCubit, Data>(
        builder: (context, taskState) {
          if (taskState.isLoading) {
            return const CircularProgressIndicator(color: Colors.white);
          }

          return _isSearching
              ? TextField(
                  controller: _searchController,
                  onSubmitted: (query) => onSearch(query, taskState.tasks),
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    prefixIcon: const Icon(Icons.search),
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                  ),
                )
              : const Text("Listo", style: TextStyle(color: Colors.white));
        },
      ),
      actions: [
        _isSearching
            ? IconButton(
                icon: const Icon(
                  Icons.cancel,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                    _filteredTasks = []; // Réinitialiser les tâches filtrées
                  });
                },
              )
            : IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isSearching = true;
                  });
                },
              ),
        IconButton(
          color: Colors.white,
          icon: const Icon(Icons.notification_add),
          onPressed: () {
            final payload = {
              'route': '/profile',
              'tasks': [],
              'categories': [],
            };
            final payloadString = jsonEncode(payload);
            NotificationService().showNotification(
              id: 1,
              title: 'Test Notification',
              body: 'Notification de test.',
              payload: payloadString,
            );
          },
        ),
      ],
      elevation: 4,
    );
  }
}
