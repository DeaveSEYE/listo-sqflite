import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:listo/core/api/service.dart';
import 'package:listo/core/cubit/taskCubit.dart';
import 'package:listo/core/utils/categorie.dart';
import 'package:listo/core/utils/task.dart';
import 'package:listo/partials/TaskModal.dart';
import 'package:listo/partials/notification.dart';

class BuildTaskItem extends StatefulWidget {
  final Task task;
  final int index;
  final Function(int) onDelete;
  final Function(int) onUpdate;

  const BuildTaskItem({
    super.key,
    required this.task,
    required this.index,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  _BuildTaskItemState createState() => _BuildTaskItemState();
}

class _BuildTaskItemState extends State<BuildTaskItem> {
  final apiService = ApiService(); // Instancie ApiService
  late bool isChecked;
  List<Categorie> categories = []; // Liste des catégories
  bool isLoading = true;

  // Fonction de récupération des catégories
  Future<void> _fetchCategories() async {
    try {
      final fetchedCategories = await ApiService.fetchCategories();
      if (mounted) {
        setState(() {
          categories = fetchedCategories;
          isLoading = false; // Fin du chargement
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false; // En cas d'erreur, mettre isLoading à false
        });
      }
      // Afficher un message d'erreur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible de charger la liste des catégories : $e'),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Charger les catégories lors de l'initialisation
    isChecked = widget.task.isChecked;
  }

  @override
  Widget build(BuildContext context) {
    return SwipeActionCell(
      key: ValueKey(widget.task),
      leadingActions: [
        SwipeAction(
          onTap: (handler) {
            // Gestion de l'action de mise à jour ici si nécessaire
            TaskModal(
              context: context,
              taskCubit:
                  context.read<TaskCubit>(), // Pass the TaskCubit instance
              categories: categories,
              task: widget.task, // Tâche vide pour ajouter une nouvelle tâche
              onTaskAdded: (taskData) async {
                // Call your API to add the task
                await apiService.addTask(taskData);
              },
            ).showAddTaskModal();
          },
          content: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.edit, color: Colors.white),
          ),
          color: Colors.blue,
        ),
      ],
      trailingActions: [
        SwipeAction(
          onTap: (CompletionHandler handler) async {
            await handler(true); // Action de suppression
            try {
              await apiService.deleteTask(widget.task.id);
              setState(() {
                widget.onDelete(widget.index);
              });
              NotificationHelper.showFlushbar(
                // ignore: use_build_context_synchronously
                context: context,
                message: "Tâche Supprimée avec succès",
                type: NotificationType.success,
              );
              context.read<TaskCubit>().reload();
            } catch (e) {
              NotificationHelper.showFlushbar(
                // ignore: use_build_context_synchronously
                context: context,
                message:
                    "Une erreur est survenue lors de la suppression de la tache",
                type: NotificationType.success,
              );
            }
          },
          content: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          color: Colors.red,
        ),
      ],
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: ListTile(
          leading: IconButton(
            icon: Icon(
              isChecked ? Icons.check_box : Icons.check_box_outline_blank,
            ),
            onPressed: () {
              setState(() {
                isChecked = !isChecked;
              });
            },
          ),
          title: Text(
            widget.task.title,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          subtitle: Text(
            widget.task.dueDate,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.task.categorieColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.task.categorie,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.flag,
                color: _getPriorityColor(widget.task.priority),
              ),
            ],
          ),
          onTap: () {
            showTaskDetails(context, widget.task, categories,
                context.read<TaskCubit>()); // Passer les catégories
          },
        ),
      ),
    );
  }
}

void showTaskDetails(
    BuildContext context, Task task, List<Categorie> categories, tCubit) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return FractionallySizedBox(
        alignment: Alignment.bottomCenter,
        heightFactor: 0.7,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Text(
                  task.description,
                  style: TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.flag,
                      color: _getPriorityColor(task.priority),
                    ),
                    SizedBox(width: 8),
                    Text(
                      _getPriorityText(task.priority),
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  'Date: ${task.dueDate}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      task.isChecked ? 'Tâche Terminée' : 'Tâche en Attente',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.grey,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Text('Fermer'),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        TaskModal(
                          context: context,
                          taskCubit: tCubit, // Pass the TaskCubit instance
                          categories: categories,
                          task:
                              task, // Tâche vide pour ajouter une nouvelle tâche
                          onTaskAdded: (taskData) async {},
                        ).showAddTaskModal();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Text('Modifier'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Color _getPriorityColor(String priority) {
  switch (priority) {
    case "moyenne":
      return Colors.yellow;
    case "eleve":
      return Colors.red;
    default:
      return Colors.green;
  }
}

String _getPriorityText(String priority) {
  switch (priority) {
    case "moyenne":
      return 'Pririté : Moyenne';
    case "eleve":
      return 'Pririté : Haute';
    default:
      return 'Pririté : Basse';
  }
}
