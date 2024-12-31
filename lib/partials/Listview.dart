import 'package:flutter/material.dart';
import 'package:listo/core/utils/categorie.dart';
import 'package:listo/core/utils/task.dart'; // Ensure Task is imported
import 'package:listo/partials/BuildTaskItem.dart'; // Ensure BuildTaskItem is imported

class Listviews extends StatefulWidget {
  final List<Task> tasks; // List of tasks passed as a parameter
  final List<Categorie> categories; // List of tasks passed as a parameter
  const Listviews(this.tasks, this.categories, {super.key});

  @override
  State<Listviews> createState() => _ListviewsState();
}

class _ListviewsState extends State<Listviews> {
  // Function to handle task deletion
  void _onDelete(int index) {
    setState(() {
      widget.tasks.removeAt(index); // Removes the task at the given index
    });
  }

  // Function to handle task update
  void _onUpdate(int index) {
    setState(() {
      widget.tasks[index].isChecked =
          !widget.tasks[index].isChecked; // Toggles isChecked
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: widget.tasks.length,
        itemBuilder: (context, index) {
          return BuildTaskItem(
            key: ValueKey(widget.tasks[index].id), // Pass a unique key
            task: widget.tasks[index],
            categories: widget.categories,
            index: index,
            onDelete: _onDelete, // Provide the onDelete callback
            onUpdate: _onUpdate, // Provide the onUpdate callback
          );
        },
      ),
    );
  }
}
