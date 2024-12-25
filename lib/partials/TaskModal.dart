import 'package:flutter/material.dart';
import 'package:listo/core/api/service.dart';
import 'package:listo/core/cubit/taskCubit.dart';
import 'package:listo/core/theme/ListCategories.dart';
import 'package:listo/core/theme/colors.dart';
import 'package:listo/core/utils/categorie.dart';
import 'package:listo/core/utils/task.dart';
import 'package:listo/partials/notification.dart';

class TaskModal {
  final BuildContext context;
  final TaskCubit taskCubit; // Add this line
  final Function onTaskAdded;
  final Task? task; // Laisser `task` nullable pour gérer le cas de l'ajout
  final List<Categorie> categories; // Liste des tâches passée en paramètre
  TaskModal({
    required this.context,
    required this.taskCubit, // Pass TaskCubit as a parameter
    required this.onTaskAdded,
    required this.categories,
    required this.task, // Initialisez avec la tâche existante
  });

  void showAddTaskModal() {
    final apiService = ApiService(); // Instancie ApiService
    final titleController = TextEditingController(text: task?.title ?? '');
    final descriptionController =
        TextEditingController(text: task?.description ?? '');
    // final TextEditingController dateController = TextEditingController();
    // final TextEditingController priorityController = TextEditingController();

    Color? selectedCategoryColor;
    String? selectedCategory;
    DateTime? selectedDate;
    Color selectedFlagColor = Colors.grey;
    String prior = "";
    bool isEditing = task != null;

    if (task != null) {
      //print(task!.priority.name);
      selectedFlagColor = flagFromPriority(task!.priority);
      prior = task!.priority;
    }
    if (task != null) {
      selectedCategory = task!.categorie;
    }
    if (task != null) {
      selectedCategoryColor = task!.categorieColor;
    }
    if (task != null) {
      selectedDate = DateTime.parse(task!.dueDate);
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Row(
                              children: [
                                Icon(Icons.arrow_back),
                                SizedBox(width: 8),
                                Text('Retour', style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () async {
                              String colorName =
                                  getColorName(selectedCategoryColor!);
                              // print(colorName); // Cela renverra "Orange"

                              // Vérifier si les champs sont valides
                              if (titleController.text.isEmpty ||
                                  titleController.text.length < 2) {
                                showErrorMessage(
                                    "Le titre est vide ou trop court (minimum 2 caractères)");
                                return;
                              }

                              if (selectedCategory == null ||
                                  selectedCategory!.isEmpty) {
                                showErrorMessage(
                                    "Veuillez sélectionner une catégorie");
                                return;
                              }

                              if (descriptionController.text.isEmpty ||
                                  descriptionController.text.length < 2) {
                                showErrorMessage(
                                    "La description est vide ou trop courte (minimum 2 caractères)");
                                return;
                              }

                              if (selectedDate == null) {
                                showErrorMessage(
                                    "Veuillez sélectionner une date d'échéance");
                                return;
                              }

                              if (prior.isEmpty) {
                                showErrorMessage(
                                    "Veuillez sélectionner une priorité");
                                return;
                              }

                              final taskData = {
                                'title': titleController.text,
                                'categorie': selectedCategory,
                                'description': descriptionController.text,
                                'createdAt': selectedDate?.toIso8601String(),
                                'updatedAt': selectedDate?.toIso8601String(),
                                'dueDate': selectedDate?.toIso8601String(),
                                "priority": prior,
                                "isChecked": false,
                                "categorieColor": 'red'
                                // "categorieColor": colorName
                              };
                              print(taskData);
                              if (isEditing) {
                                print('EDITION DE TACHE');
                                try {
                                  await apiService.updateTask(
                                      task!.id, taskData);
                                  Navigator.pop(context);
                                  // Mise à jour de la liste des tâches
                                  //  await _fetchTasks();
                                  NotificationHelper.showFlushbar(
                                    // ignore: use_build_context_synchronously
                                    context: context,
                                    message: "Tache Modifié avec success",
                                    type: NotificationType.success,
                                  );
                                } catch (e) {
                                  NotificationHelper.showFlushbar(
                                    // ignore: use_build_context_synchronously
                                    context: context,
                                    message:
                                        "une erreur s'est produite lors de la modification de la tache",
                                    type: NotificationType.alert,
                                  );
                                }
                              } else {
                                try {
                                  await apiService.addTask(taskData);
                                  Navigator.pop(context);
                                  // Mise à jour de la liste des tâches
                                  //  await _fetchTasks();
                                  NotificationHelper.showFlushbar(
                                    // ignore: use_build_context_synchronously
                                    context: context,
                                    message: "Tâche ajoutée avec succès",
                                    type: NotificationType.success,
                                  );
                                } catch (e) {
                                  NotificationHelper.showFlushbar(
                                    // ignore: use_build_context_synchronously
                                    context: context,
                                    message:
                                        "une erreur s'est produite lors de l'ajout de la tache",
                                    type: NotificationType.alert,
                                  );
                                }
                              }
                              await taskCubit
                                  .reload(); // Reload taskCubit to refresh data
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                            child: Text(
                              isEditing ? 'Modifier' : 'Enregistrer',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          hintText: 'Nom de la tâche',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListCategories(
                        //tasks: tasks, // Liste des tâches
                        categories: categories, // Liste des tâches
                        onCategorySelected: (category, color) {
                          setState(() {
                            selectedCategory = category;
                            selectedCategoryColor = color;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              setState(() {
                                selectedDate = picked;
                              });
                            },
                            child: Column(
                              children: [
                                const Icon(Icons.calendar_today, size: 24),
                                if (selectedDate != null)
                                  Text(
                                    "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      for (var color in [
                                        Colors.green,
                                        Colors.yellow,
                                        Colors.red
                                      ])
                                        IconButton(
                                          icon: Icon(Icons.flag, color: color),
                                          onPressed: () {
                                            setState(() {
                                              selectedFlagColor = color;
                                              prior = priorityFromColorString(
                                                  color); // Get priority based on selected color
                                              print('Priorité : $prior');
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Icon(Icons.flag,
                                color: selectedFlagColor, size: 24),
                          ),
                          if (selectedCategory != null)
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Chip(
                                label: Text(
                                  '$selectedCategory',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                                backgroundColor:
                                    selectedCategoryColor, // Couleur de fond basée sur la catégorie sélectionnée
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Description de la tâche',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Utility methods
  String getColorName(Color color) {
    // print(color.value); // Affiche la valeur de la couleur

    // Comparaison avec les couleurs personnalisées en utilisant leurs valeurs hexadécimales
    if (color.value == Color(0xffff0000).value) {
      // Red
      return "Color(0xffff0000)";
    } else if (color.value == Color(0xff008000).value) {
      // Green
      return "green";
    } else if (color.value == Color(0xffffff00).value) {
      // Yellow
      return "yellow";
    } else if (color.value == Color(0xff0000ff).value) {
      // Blue
      return "blue";
    } else if (color.value == Color(0xffffa500).value) {
      // Orange
      return "orange";
    } else if (color.value == Color(0xff800080).value) {
      // Purple
      return "purple";
    } else if (color.value == Color(0xffffc0cb).value) {
      // Pink
      return "pink";
    } else if (color.value == Color(0xffa52a2a).value) {
      // Brown
      return "brown";
    } else if (color.value == Color(0xff808080).value) {
      // Grey
      return "grey";
    } else if (color.value == Color(0xff000000).value) {
      // Black
      return "black";
    } else if (color.value == Color(0xffffffff).value) {
      // White
      return "white";
    } else {
      // Si la couleur ne correspond à aucune des prédéfinies
      return "Unknown";
    }
  }

  String priorityFromColorString(Color color) {
    if (color == Colors.red) {
      return "eleve"; // High priority
    } else if (color == Colors.yellow) {
      return "moyenne"; // Medium priority
    } else if (color == Colors.green) {
      return "basse"; // Low priority
    } else {
      return "inconnue"; // Unknown priority
    }
  }

  Color flagFromPriority(String priority) {
    switch (priority) {
      case 'eleve':
        return Colors.red;
      case 'moyenne':
        return Colors.yellow;
      case 'basse':
        return Colors.green;
      default:
        return Colors.grey; // Default flag color
    }
  }

  String getColorNameFromToString(String colorString) {
    if (colorString.contains('Color(0xff4caf50)')) {
      return "green"; // Colors.green
    }
    if (colorString.contains('Color(0xffffeb3b)')) {
      return "yellow"; // Colors.yellow
    }
    if (colorString.contains('Color(0xfff44336)')) return "red"; // Colors.red
    return "unknown"; // Si la couleur n'est pas reconnue
  }

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
