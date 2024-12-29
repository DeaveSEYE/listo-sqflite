import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listo/core/api/service.dart';
import 'package:listo/core/cubit/taskCubit.dart';
import 'package:listo/core/theme/colors.dart';
import 'package:listo/core/utils/categorie.dart';
import 'package:listo/features/calendar/ui/calendar.dart';
import 'package:listo/features/home/ui/home.dart';
import 'package:listo/features/profile/ui/profile.dart';
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
  bool isLoading = true;
  List<Categorie> categories = []; // Liste des catégories
  void setCurrentIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _fetchCategories() async {
    try {
      final fetchedCategories = await ApiService.fetchCategories();
      setState(() {
        categories = fetchedCategories;
        isLoading = false; // Fin du chargement
      });
    } catch (e) {
      setState(() {
        isLoading = false; // En cas d'erreur, mettre isLoading à false
      });
      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Impossible de charger la liste des categories : $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Charger les catégories lors de l'initialisation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: BlocListener<TaskCubit, Data>(listener: (context, state) {
        // Ce callback est appelé lorsque l'état du cubit est mis à jour
        // Par exemple, après un appel à reload()
        // if (state.tasks.isEmpty) {
        // print("Aucune tâche disponible");
        // }
      }, child: BlocBuilder<TaskCubit, Data>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.tasks.isEmpty) {
            // Show "No tasks" message when no tasks are available
            return Center(
              child: Text(
                'Aucune tâche disponible.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            );
          }
          final tasks = state.tasks;
          return [
            Home(tasks: tasks, categories: categories),
            Tasklist(tasks: tasks, categories: categories),
            CalendarPage(tasks: tasks),
            const ProfileScreen(),
          ][_selectedIndex];
        },
      )),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.primary,
        selectedItemColor: const Color.fromARGB(255, 240, 244, 247),
        unselectedItemColor: AppColors.background,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Tâches'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Agenda'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        onTap: (index) => setCurrentIndex(index),
      ),
      floatingActionButton: Builder(
        builder: (context) => CustomFloatingActionButton(
          onPressed: () {
            TaskModal(
              context: context,
              taskCubit:
                  context.read<TaskCubit>(), // Pass the TaskCubit instance
              categories: categories,
              task: null, // Tâche vide pour ajouter une nouvelle tâche
              onTaskAdded: (taskData) async {},
            ).showAddTaskModal();
          },
          icon: Icons.add,
        ),
      ),
    );
  }
}
