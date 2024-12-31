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
  // final Categorie categories;
   final List<Categorie> categories ;
  final int index;
  final Function(int) onDelete;
  final Function(int) onUpdate;

  const BuildTaskItem({
    super.key,
    required this.task,
    required this.categories,
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

  @override
  void initState() {
    super.initState();
    isChecked = widget.task.isChecked;
    categories = widget.categories;
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
                // print("widget.task.categorieColor");
                // print(widget.task.categorieColor);
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
              await apiService.deleteTask(widget.task.toJson());
              // await apiService.deleteTask(widget.task.id);
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
            onPressed: () async {
              // Exécution de la logique asynchrone
              bool newCheckedState = !isChecked;

              try {
                await apiService.check(newCheckedState, widget.task.toJson());
                NotificationHelper.showFlushbar(
                  // ignore: use_build_context_synchronously
                  context: context,
                  message:
                      "Tâche marqué comme ${newCheckedState ? 'Terminée' : 'En Attente'}",
                  type: NotificationType.success,
                );
                // context.read<TaskCubit>().reload();
              } catch (error) {
                print("Erreur lors de la mise à jour de l'état : $error");
                NotificationHelper.showFlushbar(
                  // ignore: use_build_context_synchronously
                  context: context,
                  message: "Erreur lors de la mise à jour de l'état",
                  type: NotificationType.error,
                );
                // context.read<TaskCubit>().reload();
                return; // Si une erreur se produit, on ne met pas à jour l'état
              }

              // Mise à jour de l'état après le succès de la logique asynchrone
              setState(() {
                isChecked = newCheckedState;
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
                  color: parseColor(widget.task.categorieColor),
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

Color parseColor(String? colorString) {
  // print("colorString FROM buidtaskitem");
  // print(colorString);
  // Couleur par défaut si `colorString` est null
  if (colorString == null) return Colors.black;

  // Correspondance des noms de couleur avec leurs valeurs hexadécimales
  switch (colorString.toLowerCase()) {
    case 'red': // Red
      return Colors.red;
    case 'pink': // Pink
      return Colors.pink;
    case 'purple': // Purple
      return Colors.purple;
    case 'deep purple': // Deep Purple
      return Colors.deepPurple;
    case 'indigo': // Indigo
      return Colors.indigo;
    case 'blue': // Blue
      return Colors.blue;
    case 'light blue': // Light Blue
      return Colors.lightBlue;
    case 'cyan': // Cyan
      return Colors.cyan;
    case 'teal': // Teal
      return Colors.teal;
    case 'green': // Green
      return Colors.green;
    case 'light green': // Light Green
      return Colors.lightGreen;
    case 'lime': // Lime
      return Colors.lime;
    case 'yellow': // Yellow
      return Colors.yellow;
    case 'amber': // Amber
      return Colors.amber;
    case 'orange': // Orange
      return Colors.orange;
    case 'deep orange': // Deep Orange
      return Colors.deepOrange;
    case 'brown': // Brown
      return Colors.brown;
    case 'grey': // Grey
      return Colors.grey;
    case 'blue grey': // Blue Grey
      return Colors.blueGrey;
  }
  // Si colorString est un code hexadécimal
  if (colorString.startsWith('#')) {
    return _colorFromHex(colorString);
  }

  // Si aucun des cas ne correspond, lève une exception ou retourne une couleur par défaut
  throw ArgumentError('Invalid color string: $colorString');
}

// Fonction utilitaire pour convertir un code hexadécimal en une couleur
Color _colorFromHex(String hexColor) {
  hexColor = hexColor.replaceFirst('#', '');
  if (hexColor.length == 6) {
    hexColor = 'FF' + hexColor; // Ajoute un alpha par défaut (FF = opaque)
  }
  int colorInt = int.parse(hexColor, radix: 16);
  return Color(colorInt);
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
