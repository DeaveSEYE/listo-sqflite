// ignore_for_file: equal_keys_in_map
import 'package:flutter/material.dart';

// Task model
class Task {
  late final String id;
  final String title;
  final String categorie;
  final String description;
  final Color categorieColor;
  String priority; // Utilisation d'une chaîne pour remplacer l'enum
  bool isChecked;
  final String createdAt;
  final String updatedAt;
  final String dueDate;
  bool isNew;
  bool isUpdated;
  bool isDeleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.dueDate,
    required this.categorie,
    required this.categorieColor,
    this.isChecked = false, // Valeur par défaut
    this.priority = 'basse', // Valeur par défaut pour la priorité
    this.isNew = false,
    this.isUpdated = false,
    this.isDeleted = false,
  });

  // Convertir un objet Task en une Map compatible avec SQLite
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'categorie': categorie,
      'description': description,
      'priority': priority, // Utilisation d'une chaîne au lieu d'enum
      'isChecked': isChecked ? 1 : 0, // Convertir en entier pour la base
      'categorieColor':
          categorieColor.value.toString(), // Stockage de la couleur
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'dueDate': dueDate,
      'isNew': isNew ? 1 : 0, // Convertir en entier pour la base
      'isUpdated': isUpdated ? 1 : 0, // Convertir en entier pour la base
      'isDeleted': isDeleted ? 1 : 0, // Convertir en entier pour la base
    };
  }

  // Convertir une Map issue de SQLite en un objet Task
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      dueDate: json['dueDate'],
      categorie: json['categorie'],
      categorieColor: getColorFromName(json['categorieColor']),
      isChecked: json['isChecked'] == 1, // Convertir en booléen
      priority: json['priority'], // Utilisation directe de la chaîne
      isNew: json['isNew'] == 1, // Convertir en booléen
      isUpdated: json['isUpdated'] == 1, // Convertir en booléen
      isDeleted: json['isDeleted'] == 1, // Convertir en booléen
    );
  }
}

// Fonction pour récupérer une couleur depuis son nom ou un code hexadécimal
Color getColorFromName(String colorName) {
  Map<String, String> colorMap = {
    'red': '#FF0000',
    'green': '#008000',
    'blue': '#0000FF',
    'yellow': '#FFFF00',
    'purple': '#800080',
    'grey': '#808080',
    // Ajoute d'autres couleurs si nécessaire
  };

  if (colorMap.containsKey(colorName.toLowerCase())) {
    return Color(
        int.parse('0xFF${colorMap[colorName.toLowerCase()]?.substring(1)}'));
  }

  // Si la couleur est déjà en hexadécimal
  if (colorName.startsWith('#')) {
    String hexColor = colorName.substring(1);
    if (hexColor.length == 6) {
      return Color(int.parse('0xFF$hexColor'));
    }
  }

  // Si la couleur n'est pas trouvée, retourne une couleur par défaut (gris)
  return Colors.grey;
}
