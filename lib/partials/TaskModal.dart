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
  // final CategorieCubit categorieCubit;
  final Function onTaskAdded;
  final Task? task; // Laisser `task` nullable pour gérer le cas de l'ajout
  final List<Categorie> categories; // Liste des tâches passée en paramètre
  TaskModal({
    required this.context,
    required this.taskCubit, // Pass TaskCubit as a parameter
    // required this.categorieCubit,
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

    String? selectedCategoryColor;
    String? selectedCategory;
    String? id;
    int? isNew;
    int? isUpdated;
    int? isDeleted;
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
    if (task != null) {
      id = task!.id;
    }
    if (task != null) {
      isNew = task!.isNew == false ? 0 : 1;
      isUpdated = task!.isUpdated == false ? 0 : 1;
      isDeleted = task!.isDeleted == false ? 0 : 1;
    } else {
      isNew = 0;
      isUpdated = 0;
      isDeleted = 0;
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
                              // String colorName =
                              // colorToString(selectedCategoryColor!);
                              // print("in");
                              // print(
                              //     selectedCategoryColor); // Cela renverra "Orange"

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
                                'id': id,
                                'title': titleController.text,
                                'categorie': selectedCategory,
                                'description': descriptionController.text,
                                'createdAt': selectedDate?.toIso8601String(),
                                'updatedAt': selectedDate?.toIso8601String(),
                                'dueDate': selectedDate?.toIso8601String(),
                                "priority": prior,
                                "isChecked": false,
                                "categorieColor": selectedCategoryColor,
                                'isNew': isNew,
                                'isUpdated': isUpdated,
                                'isDeleted': isDeleted
                              };
                              // print('LA');
                              // print(taskData);
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
                            selectedCategoryColor = colorToString(
                                color); // Convertir la couleur en chaîne;
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
                                backgroundColor: parseColor(
                                    selectedCategoryColor), // Couleur de fond basée sur la catégorie sélectionnée
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

  Color parseColor(String? colorString) {
    // print("parseColor");
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
      default:
        return Colors.black45; // Couleur par défaut si aucune correspondance
    }
  }

  String colorToString(Color color) {
    // print("color de taskModal");
    // print(color);

    // Tolérance pour la comparaison (exemple : 0.01 pour accepter les différences minimes)
    const double tolerance = 0.01;

    // Fonction pour comparer deux valeurs avec tolérance
    bool isCloseTo(double value1, double value2) {
      return (value1 - value2).abs() < tolerance;
    }

    // Vérifie si la couleur est un MaterialColor
    if (color is MaterialColor) {
      if (color == Colors.red) return 'red';
      if (color == Colors.pink) return 'pink';
      if (color == Colors.purple) return 'purple';
      if (color == Colors.deepPurple) return 'deepPurple';
      if (color == Colors.indigo) return 'indigo';
      if (color == Colors.blue) return 'blue';
      if (color == Colors.lightBlue) return 'lightBlue';
      if (color == Colors.cyan) return 'cyan';
      if (color == Colors.teal) return 'teal';
      if (color == Colors.green) return 'green';
      if (color == Colors.lightGreen) return 'lightGreen';
      if (color == Colors.lime) return 'lime';
      if (color == Colors.yellow) return 'yellow';
      if (color == Colors.amber) return 'amber';
      if (color == Colors.orange) return 'orange';
      if (color == Colors.deepOrange) return 'deepOrange';
      if (color == Colors.brown) return 'brown';
      if (color == Colors.grey) return 'grey';
      if (color == Colors.blueGrey) return 'blueGrey';
      return 'unknown material color';
    }

    // Sinon, traite-le comme une couleur normale
    // Extraction des composantes de la couleur
    double red = color.red / 255.0;
    double green = color.green / 255.0;
    double blue = color.blue / 255.0;

    // Vérification des couleurs par correspondance avec tolérance
    if (isCloseTo(red, 1.0) && isCloseTo(green, 0.0) && isCloseTo(blue, 0.0))
      return 'red'; // Red
    if (isCloseTo(red, 0.9137) &&
        isCloseTo(green, 0.1176) &&
        isCloseTo(blue, 0.3882)) return 'pink'; // Pink
    if (isCloseTo(red, 0.6118) &&
        isCloseTo(green, 0.1529) &&
        isCloseTo(blue, 0.6902)) return 'purple'; // Purple
    if (isCloseTo(red, 0.4039) &&
        isCloseTo(green, 0.2314) &&
        isCloseTo(blue, 0.7176)) return 'deep purple'; // Deep Purple
    if (isCloseTo(red, 0.2471) &&
        isCloseTo(green, 0.3176) &&
        isCloseTo(blue, 0.7098)) return 'indigo'; // Indigo
    if (isCloseTo(red, 0.1294) &&
        isCloseTo(green, 0.5882) &&
        isCloseTo(blue, 0.9529)) return 'blue'; // Blue
    if (isCloseTo(red, 0.0157) &&
        isCloseTo(green, 0.6627) &&
        isCloseTo(blue, 0.9569)) return 'light blue'; // Light Blue
    if (isCloseTo(red, 0.0) &&
        isCloseTo(green, 0.7373) &&
        isCloseTo(blue, 0.8314)) return 'cyan'; // Cyan
    if (isCloseTo(red, 0.0) &&
        isCloseTo(green, 0.5882) &&
        isCloseTo(blue, 0.5333)) return 'teal'; // Teal
    if (isCloseTo(red, 0.2980) &&
        isCloseTo(green, 0.6863) &&
        isCloseTo(blue, 0.3137)) return 'green'; // Green
    if (isCloseTo(red, 0.5451) &&
        isCloseTo(green, 0.7647) &&
        isCloseTo(blue, 0.2902)) return 'light green'; // Light Green
    if (isCloseTo(red, 0.8039) &&
        isCloseTo(green, 0.8627) &&
        isCloseTo(blue, 0.2235)) return 'lime'; // Lime
    if (isCloseTo(red, 1.0) &&
        isCloseTo(green, 0.9216) &&
        isCloseTo(blue, 0.2314)) return 'yellow'; // Yellow
    if (isCloseTo(red, 1.0) &&
        isCloseTo(green, 0.7569) &&
        isCloseTo(blue, 0.0275)) return 'amber'; // Amber
    if (isCloseTo(red, 1.0) && isCloseTo(green, 0.5961) && isCloseTo(blue, 0.0))
      return 'orange'; // Orange
    if (isCloseTo(red, 1.0) &&
        isCloseTo(green, 0.3412) &&
        isCloseTo(blue, 0.1333)) return 'deep orange'; // Deep Orange
    if (isCloseTo(red, 0.4745) &&
        isCloseTo(green, 0.3333) &&
        isCloseTo(blue, 0.2824)) return 'brown'; // Brown
    if (isCloseTo(red, 0.6196) &&
        isCloseTo(green, 0.6196) &&
        isCloseTo(blue, 0.6196)) return 'grey'; // Grey
    if (isCloseTo(red, 0.3765) &&
        isCloseTo(green, 0.4902) &&
        isCloseTo(blue, 0.5451)) return 'blue grey'; // Blue Grey

    return 'unknown color';
  }

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

//   void showErrorMessage(String message) {
//   ScaffoldMessenger.of(context).showMaterialBanner(
//     MaterialBanner(
//       content: Text(message),
//       backgroundColor: Colors.red,
//       actions: [
//         TextButton(
//           onPressed: () {
//             ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
//           },
//           child: Text('OK', style: TextStyle(color: Colors.white)),
//         ),
//       ],
//     ),
//   );

//   // Masquer automatiquement après 3 secondes
//   Future.delayed(Duration(seconds: 3), () {
//     ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
//   });
// }
}
