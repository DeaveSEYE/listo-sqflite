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
    Key? key,
    required this.task,
    required this.index,
    required this.onDelete,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _BuildTaskItemState createState() => _BuildTaskItemState();
}

class _BuildTaskItemState extends State<BuildTaskItem> {
  late bool isChecked;
  List<Categorie> categories = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    isChecked = widget.task.isChecked;
  }

  Future<void> _fetchCategories() async {
    if (categories.isNotEmpty) return;
    setState(() => isLoading = true);

    try {
      final fetchedCategories = await ApiService.fetchCategories();
      setState(() {
        categories = fetchedCategories;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des catégories : $error'),
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SwipeActionCell(
      key: ValueKey(widget.task.id),
      leadingActions: [
        SwipeAction(
          onTap: (_) async {
            await TaskModal(
              context: context,
              taskCubit: context.read<TaskCubit>(),
              categories: categories,
              task: widget.task,
              onTaskAdded: (taskData) async {
                await ApiService.addTask(taskData);
              },
            )
              ..showAddTaskModal(); // Notice the double-dot operator for method chaining.
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
            await handler(true);
            try {
              await ApiService.deleteTask(widget.task.id);
              widget.onDelete(widget.index);
              NotificationHelper.showFlushbar(
                context: context,
                message: "Tâche supprimée avec succès",
                type: NotificationType.success,
              );
              context.read<TaskCubit>().reload();
            } catch (error) {
              NotificationHelper.showFlushbar(
                context: context,
                message:
                    "Une erreur est survenue lors de la suppression de la tâche",
                type: NotificationType.error,
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
              setState(() => isChecked = !isChecked);
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
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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
            showTaskDetails(
                context, widget.task, categories, context.read<TaskCubit>());
          },
        ),
      ),
    );
  }
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

void showTaskDetails(
  BuildContext context,
  Task task,
  List<Categorie> categories,
  TaskCubit taskCubit,
) {
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  task.description,
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.flag,
                      color: _getPriorityColor(task.priority),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Priorité : ${task.priority}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Date : ${task.dueDate}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
