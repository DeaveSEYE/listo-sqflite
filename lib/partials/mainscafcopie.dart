import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listo/core/cubit/categorieCubit.dart';
import 'package:listo/core/cubit/taskCubit.dart';
import 'package:listo/core/theme/colors.dart';
import 'package:listo/core/utils/task.dart';
import 'package:listo/features/calendar/ui/calendar.dart';
import 'package:listo/features/home/ui/home.dart';
import 'package:listo/features/profile/ui/profile.dart';
import 'package:listo/features/search/ui/search.dart';
import 'package:listo/features/tasks/ui/tasklist.dart';
import 'package:listo/partials/TaskModal.dart';
import 'package:listo/partials/app_bar.dart';
import 'package:listo/partials/floating_action_button.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  List<Task> _searchTasks = [];

  // Liste des pages
  final List<Widget> _pages = [
    // Home(tasks: tasks, categories: categories),
    // Tasklist(tasks: tasks, categories: categories),
    // CalendarPage(tasks: tasks, categories: categories),
    // const ProfileScreen(),
    // PageSearch(tasks: _searchTasks, categories: const []),
  ];

  void setCurrentIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskCubit>(create: (_) => TaskCubit()),
        BlocProvider<CategorieCubit>(create: (_) => CategorieCubit()),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: CustomAppBar(
              onSearchCallback: (filteredTasks) {
                _searchTasks = filteredTasks;
                // Met à jour l'index pour afficher PageSearch
                setCurrentIndex(4); // Affiche PageSearch
              },
            ),
            body: BlocBuilder<TaskCubit, Data>(
              builder: (context, taskState) {
                return BlocBuilder<CategorieCubit, CatData>(
                  builder: (context, categorieState) {
                    if (taskState.isLoading || categorieState.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Gestion des listes vides
                    if (taskState.tasks.isEmpty ||
                        categorieState.categories.isEmpty) {
                      String msg = '';
                      if (taskState.tasks.isEmpty) msg = 'Aucune tâche ';
                      if (categorieState.categories.isEmpty) {
                        msg +=
                            '${msg.isNotEmpty ? ' & ' : ''} Aucune catégorie';
                      }
                      msg += ' disponible';
                      return Center(
                        child: Text(
                          msg,
                          style:
                              TextStyle(fontSize: 16, color: AppColors.primary),
                        ),
                      );
                    }

                    final tasks = taskState.tasks;
                    final categories = categorieState.categories;

                    // Affichage de la page en fonction de l'index sélectionné
                    return _pages.length > _selectedIndex
                        ? _pages[_selectedIndex]
                        : const SizedBox(); // Ou une page par défaut
                  },
                );
              },
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.primary,
              selectedItemColor: const Color.fromARGB(255, 240, 244, 247),
              unselectedItemColor: AppColors.background,
              elevation: 10,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home), label: 'Accueil'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.list), label: 'Tâches'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_today), label: 'Agenda'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: 'Profil'),
              ],
              onTap: (index) => setCurrentIndex(index),
            ),
            floatingActionButton: Builder(
              builder: (context) {
                return CustomFloatingActionButton(
                  onPressed: () {
                    TaskModal(
                      context: context,
                      taskCubit: context.read<TaskCubit>(),
                      categories:
                          context.read<CategorieCubit>().state.categories,
                      task: null,
                      onTaskAdded: (taskData) async {},
                    ).showAddTaskModal();
                  },
                  icon: Icons.add,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
