import 'package:flutter/material.dart';
import 'package:listo/core/theme/ListCategories.dart';
import 'package:listo/core/utils/categorie.dart';
import 'package:listo/core/utils/task.dart';
import 'package:listo/core/utils/task_filter.dart';
import 'package:listo/partials/BuildTaskItem.dart';

class PageSearch extends StatefulWidget {
  final List<Task> tasks; // Liste des tâches passées par le parent
  final List<Categorie> categories; // Liste des catégories passées en paramètre
  const PageSearch(
      {super.key,
      required this.tasks, // Passer la liste des tâches
      required this.categories});

  @override
  State<PageSearch> createState() => _PageSearchState();
}

class _PageSearchState extends State<PageSearch> {
  List<Task> filteredTasks = []; // Liste des tâches filtrées
  Color? selectedCategoryColor;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    // Initialiser avec toutes les tâches
    filteredTasks = widget.tasks;
  }

  // Fonction pour supprimer une tâche
  void _onDelete(int index) {
    setState(() {
      widget.tasks.removeAt(index); // Supprimer la tâche à l'index donné
    });
  }

  // Fonction pour mettre à jour une tâche
  void _onUpdate(int index) {
    setState(() {
      widget.tasks[index].isChecked =
          !widget.tasks[index].isChecked; // Bascule la valeur de `isChecked`
    });
  }

  // Appliquer un filtre (par date ou priorité)
  void _applyFilter(String filter) {
    setState(() {
      TaskFilter.applyFilter(
          filteredTasks, filter); // Utiliser la classe TaskSorter
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ListCategories(
          //   categories: widget.categories, // Liste des catégories
          //   onCategorySelected: (category, color) {
          //     setState(() {
          //       selectedCategory = category;
          //       selectedCategoryColor = color;
          //     });
          //   },
          // ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                // "Tâches trouvées (${widget.tasks.length})",
                "Tâches trouvées",
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
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: widget.tasks.length,
              itemBuilder: (context, index) {
                return BuildTaskItem(
                  key:
                      ValueKey(widget.tasks[index].id), // Passage de clé unique
                  task: widget.tasks[index],
                  categories: widget.categories,
                  index: index,
                  onDelete: _onDelete,
                  onUpdate: _onUpdate,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
