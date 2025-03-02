import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listo/core/cubit/categorieCubit.dart';
import 'package:listo/core/cubit/taskCubit.dart';
import 'package:listo/core/global/global_state.dart';
import 'package:listo/core/theme/colors.dart';
import 'package:listo/core/utils/task.dart';
import 'package:listo/features/calendar/ui/calendar.dart';
import 'package:listo/features/home/ui/home.dart';
import 'package:listo/features/profile/ui/profile.dart';
import 'package:listo/features/tasks/ui/tasklist.dart';
import 'package:listo/partials/TaskModal.dart';
import 'package:listo/partials/app_bar.dart';
import 'package:listo/partials/floating_action_button.dart';
import 'package:listo/routes.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  // List<Task> _searchTasks = [];
  void setCurrentIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Vérifie si l'utilisateur est connecté
    if (GlobalState().userId.isEmpty) {
      Future.microtask(
          // ignore: use_build_context_synchronously
          () => Navigator.pushReplacementNamed(context, Routes.loginPage));
    }
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
              onSearchCallback: (filteredTasks) {},
            ),
            body: BlocBuilder<TaskCubit, Data>(
              builder: (context, taskState) {
                return BlocBuilder<CategorieCubit, CatData>(
                  builder: (context, categorieState) {
                    // Affichage d'un indicateur de chargement
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

                    // Pages de contenu
                    return [
                      Home(tasks: tasks, categories: categories),
                      Tasklist(tasks: tasks, categories: categories),
                      CalendarPage(tasks: tasks, categories: categories),
                      const ProfileScreen(),
                      // PageSearch(tasks: _searchTasks, categories: const []),
                    ][_selectedIndex];
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
                // Ajout d'un élément invisible
                // BottomNavigationBarItem(
                //   icon: SizedBox(
                //       width: 0.0,
                //       height:
                //           0.0), // Rendre l'icône invisible en fixant la taille à 0.0
                //   label: '', // Pas de label
                // ),
              ],
              onTap: (index) => setCurrentIndex(index),
            ),
            floatingActionButton: Builder(
              builder: (context) {
                return CustomFloatingActionButton(
                  onPressed: () {
                    TaskModal(
                      context: context,
                      taskCubit: context.read<TaskCubit>(), // Passer TaskCubit
                      categories: context
                          .read<CategorieCubit>()
                          .state
                          .categories, // Passer les catégories
                      task: null, // Tâche vide pour ajouter une nouvelle tâche
                      onTaskAdded: (taskData) async {},
                      // onTaskAdded: (taskData) async {
                      // Ajouter une tâche via TaskCubit
                      // context.read<TaskCubit>().addTask(taskData);
                      // },
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
