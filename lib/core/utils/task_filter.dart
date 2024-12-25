import 'package:listo/core/utils/task.dart';

class TaskFilter {
  /// Trie les tâches par date ou priorité
  static void applyFilter(List<Task> tasks, String filter) {
    if (filter == "date") {
      // Trier par date d'échéance (dueDate)
      tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    } else if (filter == "priority") {
      // Trier par priorité
      tasks.sort((a, b) => _getPriorityValue(a.priority)
          .compareTo(_getPriorityValue(b.priority)));
    }
  }

  /// Retourne une valeur numérique correspondant à chaque priorité
  static int _getPriorityValue(String priority) {
    switch (priority.toLowerCase()) {
      case 'basse':
        return 1; // Priorité basse
      case 'moyenne':
        return 2; // Priorité moyenne
      case 'eleve':
        return 3; // Priorité élevée
      default:
        return 1; // Valeur par défaut pour les priorités inconnues
    }
  }
}
