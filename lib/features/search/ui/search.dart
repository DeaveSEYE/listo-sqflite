import 'package:flutter/material.dart';
import 'package:listo/core/utils/categorie.dart';
import 'package:listo/core/utils/task.dart';
import 'package:listo/core/utils/task_filter.dart';
import 'package:listo/partials/BuildTaskItem.dart';

class PageSearch extends StatefulWidget {
  // final List<Categorie> categories; // Liste des catégories passées en paramètre
  final List<Task> tasks;

  const PageSearch({
    super.key,
    // required this.categories,
    required this.tasks,
  });

  @override
  State<PageSearch> createState() => _PageSearchState();
}

class _PageSearchState extends State<PageSearch> {
  List<Task> filteredTasks = []; // Liste des tâches filtrées

  @override
  void initState() {
    super.initState();
    filteredTasks = widget.tasks; // Récupération des tâches reçues en paramètre
  }

  // Fonction pour supprimer une tâche
  void _onDelete(int index) {
    setState(() {
      filteredTasks.removeAt(index); // Supprimer la tâche à l'index donné
    });
  }

  // Fonction pour mettre à jour une tâche
  void _onUpdate(int index) {
    setState(() {
      filteredTasks[index].isChecked = !filteredTasks[index].isChecked;
    });
  }

  // Appliquer un filtre (par date ou priorité)
  void _applyFilter(String filter) {
    setState(() {
      TaskFilter.applyFilter(filteredTasks, filter);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // automaticallyImplyLeading: false,
          title: const Text("Résultats de la recherche")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Tâches trouvées (${filteredTasks.length})",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (value) {
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
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  return BuildTaskItem(
                    key: ValueKey(filteredTasks[index].id),
                    task: filteredTasks[index],
                    categories: [],
                    // categories: widget.categories,
                    index: index,
                    onDelete: _onDelete,
                    onUpdate: _onUpdate,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
