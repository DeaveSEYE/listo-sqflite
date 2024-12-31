import 'package:flutter/material.dart';
import 'package:listo/core/utils/categorie.dart';
import 'package:listo/core/utils/task_filter.dart';
import 'package:listo/partials/Listview.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:listo/core/utils/task.dart';

class CalendarPage extends StatefulWidget {
  final List<Task> tasks; // Liste des tâches passée en paramètre
  final List<Categorie> categories;
  const CalendarPage(
      {super.key, required this.tasks, required this.categories});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  List<Task> filteredTasks = []; // Liste des tâches filtrées
  List<Categorie> cat = []; // Liste des tâches filtrées
  @override
  void initState() {
    super.initState();
    // Initialiser avec toutes les tâches
    filteredTasks = widget.tasks;
    cat = widget.categories;
  }

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Récupère les dates ayant des tâches
  Set<DateTime> _taskDates() {
    return widget.tasks.map((task) {
      final taskDate =
          DateTime.parse(task.dueDate); // Utiliser DateTime.parse pour ISO 8601
      return DateTime(taskDate.year, taskDate.month,
          taskDate.day); // Normaliser la date sans l'heure
    }).toSet();
  }

  // Récupère les tâches pour une journée donnée
  List<Task> _getTasksForDay(DateTime day) {
    return widget.tasks.where((task) {
      final taskDate =
          DateTime.parse(task.dueDate); // Utiliser DateTime.parse pour ISO 8601
      return taskDate.year == day.year &&
          taskDate.month == day.month &&
          taskDate.day == day.day;
    }).toList();
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
    final taskDates = _taskDates(); // Liste des dates avec des tâches

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calendrier
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 350,
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                markersAutoAligned: true,
              ),
              eventLoader: (day) {
                // Indique s'il y a des événements pour une journée donnée
                return taskDates
                        .contains(DateTime(day.year, day.month, day.day))
                    ? [
                        true
                      ] // Utilisation d'un tableau pour signaler un marqueur
                    : [];
              },
            ),
          ),
          const SizedBox(height: 20),
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
          // Affichage des tâches pour le jour sélectionné
          if (_selectedDay != null)
            Text(
              "Tâches pour ${_selectedDay!.day}-${_selectedDay!.month}-${_selectedDay!.year}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 10),
          // Affichage des tâches
          _selectedDay != null
              ? _getTasksForDay(_selectedDay!).isNotEmpty
                  ? Listviews(_getTasksForDay(_selectedDay!),
                      cat) // Utiliser Listviews pour afficher les tâches
                  : const Center(child: Text("Aucune tâche pour ce jour"))
              : const Center(child: Text("Veuillez sélectionner une date")),
        ],
      ),
    );
  }
}
