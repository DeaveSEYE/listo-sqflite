import 'package:flutter/material.dart';
import 'package:listo/core/theme/ListCategories.dart';
import 'package:listo/core/utils/categorie.dart';
import 'package:listo/core/utils/task.dart';
import 'package:listo/core/utils/task_filter.dart';
import 'package:listo/partials/Listview.dart';

class Home extends StatefulWidget {
  final List<Task> tasks; // Liste des tâches passée en paramètre
  final List<Categorie> categories; // Liste des tâches passée en paramètre

  const Home({super.key, required this.tasks, required this.categories});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Task> filteredTasks = []; // Liste des tâches filtrées
  bool isCompletedSelected =
      true; // Suivi de la carte sélectionnée (terminée ou en attente)

  @override
  void initState() {
    super.initState();
    // Initialiser avec toutes les tâches
    filteredTasks = widget.tasks;
  }

  // Filtrer les tâches en fonction de leur statut
  void _filterTasks(bool isCompleted) {
    setState(() {
      filteredTasks = widget.tasks.where((task) {
        return task.isChecked == isCompleted;
      }).toList();
      isCompletedSelected = isCompleted; // Mettre à jour la carte sélectionnée
    });
  }

  // Appliquer un filtre (par date ou priorité)
  void _applyFilter(String filter) {
    setState(() {
      TaskFilter.applyFilter(
          filteredTasks, filter); // Utiliser la classe TaskSorter
    });
  }

  Color? selectedCategoryColor;
  String? selectedCategory;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         // const Searchbar(),
          const SizedBox(height: 5),
          // ListCategories utilise toujours widget.tasks
          ListCategories(
            //tasks: widget.tasks, // Liste des tâches
            categories: widget.categories, // Liste des tâches
            onCategorySelected: (category, color) {
              setState(() {
                selectedCategory = category;
                selectedCategoryColor = color;
              });
            },
          ),
          const Text(
            "Aperçu des tâches",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              // Carte Terminés
              _buildStatusCard(
                "Taches Terminés",
                "${widget.tasks.where((task) => task.isChecked).length}",
                isCompletedSelected ? Colors.blue[200]! : Colors.white,
                true,
              ),
              const SizedBox(width: 10),
              // Carte En attente
              _buildStatusCard(
                "Tache En attente",
                "${widget.tasks.where((task) => !task.isChecked).length}",
                isCompletedSelected ? Colors.white : Colors.blue[200]!,
                false,
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Liste des tâches",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              PopupMenuButton<String>(
                icon:
                    const Icon(Icons.filter_list), // Icône du bouton de filtre
                onSelected: (value) {
                  // Gérer la sélection de filtre
                  _applyFilter(value);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: "date",
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 18),
                        SizedBox(width: 8),
                        Text("Date"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: "priority",
                    child: Row(
                      children: [
                        Icon(Icons.flag, size: 18),
                        SizedBox(width: 8),
                        Text("Priorité"),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 05),
          // Listviews utilise filteredTasks
          Listviews(filteredTasks),
        ],
      ),
    );
  }

  // Méthode pour construire les cartes de statut
  Widget _buildStatusCard(
      String title, String count, Color color, bool isCompleted) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Filtrer les tâches selon le statut
          _filterTasks(isCompleted);
        },
        child: Container(
          padding: const EdgeInsets.all(10), // Réduire le padding
          decoration: BoxDecoration(
            color: color,
            borderRadius:
                BorderRadius.circular(6), // Réduire le rayon des coins
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // S'assurer que la carte reste compacte
            children: [
              Text(
                count,
                style: const TextStyle(
                  fontSize: 30, // Taille de police réduite
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4), // Espacement réduit entre les textes
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16, // Taille de police réduite pour le titre
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
