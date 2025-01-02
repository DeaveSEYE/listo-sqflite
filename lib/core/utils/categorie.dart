// ignore_for_file: equal_keys_in_map

import 'package:flutter/material.dart';

// Categorie model
class Categorie {
  final String id;
  final String userId;
  final String categorie;
  final String categorieColor;
  final String createdAt;
  final String updatedAt;
  bool isNew;
  bool isUpdated;
  bool isDeleted;

  Categorie({
    required this.id,
    required this.userId,
    required this.categorie,
    required this.categorieColor,
    required this.createdAt,
    required this.updatedAt,
    this.isNew = false,
    this.isUpdated = false,
    this.isDeleted = false,
  });

  factory Categorie.fromJson(Map<String, dynamic> json) {
    // print("Categorie.fromJson");
    // print(json['categorie']);
    return Categorie(
      id: json['id'],
      userId: json['userId'],
      categorie: json['categorie'],
      categorieColor: json['categorieColor'], // Conversion ici
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      isNew: json['isNew'] == 1, // Convertir en booléen
      isUpdated: json['isUpdated'] == 1, // Convertir en booléen
      isDeleted: json['isDeleted'] == 1, // Convertir en booléen
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'categorie': categorie,
      'categorieColor': categorieColor, // Stockage de la couleur
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isNew': isNew ? 1 : 0, // Convertir en entier pour la base
      'isUpdated': isUpdated ? 1 : 0, // Convertir en entier pour la base
      'isDeleted': isDeleted ? 1 : 0, // Convertir en entier pour la base
    };
  }
}

Color getColorFromName(String colorName) {
  // Mapping des couleurs standard (nom -> code hexadécimal)
  Map<String, String> colorMap = {
    'darkred': '#8B0000',
    'firebrick': '#B22222',
    'crimson': '#DC143C',
    'indianred': '#CD5C5C',
    'lightcoral': '#F08080',
    'darkorange': '#FF8C00',
    'orange': '#FFA500',
    'gold': '#FFD700',
    'lightyellow': '#FFFFE0',
    'lemonchiffon': '#FFFACD',
    'lightgoldenrodyellow': '#FAFAD2',
    'palegoldenrod': '#EEE8AA',
    'yellowgreen': '#9ACD32',
    'darkgreen': '#006400',
    'forestgreen': '#228B22',
    'limegreen': '#32CD32',
    'lightgreen': '#90EE90',
    'palegreen': '#98FB98',
    'springgreen': '#00FF7F',
    'mediumseagreen': '#3CB371',
    'darkseagreen': '#8FBC8F',
    'seagreen': '#2E8B57',
    'turquoise': '#40E0D0',
    'darkturquoise': '#00CED1',
    'mediumturquoise': '#48D1CC',
    'lightseagreen': '#20B2AA',
    'cyan': '#00FFFF',
    'lightcyan': '#E0FFFF',
    'aqua': '#00FFFF',
    'darkcyan': '#008B8B',
    'lightblue': '#ADD8E6',
    'skyblue': '#87CEEB',
    'deepskyblue': '#00BFFF',
    'dodgerblue': '#1E90FF',
    'cornflowerblue': '#6495ED',
    'steelblue': '#4682B4',
    'royalblue': '#4169E1',
    'blue': '#0000FF',
    'mediumblue': '#0000CD',
    'darkblue': '#00008B',
    'navy': '#000080',
    'midnightblue': '#191970',
    'lavender': '#E6E6FA',
    'thistle': '#D8BFD8',
    'plum': '#DDA0DD',
    'violet': '#EE82EE',
    'orchid': '#DA70D6',
    'fuchsia': '#FF00FF',
    'magenta': '#FF00FF',
    'darkviolet': '#9400D3',
    'darkorchid': '#9932CC',
    'blueviolet': '#8A2BE2',
    'purple': '#800080',
    'darkpurple': '#6A0DAD',
    'indigo': '#4B0082',
    'mediumorchid': '#BA55D3',
    'mediumslateblue': '#7B68EE',
    'slateblue': '#6A5ACD',
    'darkslateblue': '#483D8B',
    'pink': '#FFC0CB',
    'lightpink': '#FFB6C1',
    'hotpink': '#FF69B4',
    'deeppink': '#FF1493',
    'palevioletred': '#DB7093',
    'mediumvioletred': '#C71585',
    'brown': '#A52A2A',
    'darkbrown': '#654321',
    'chocolate': '#D2691E',
    'saddlebrown': '#8B4513',
    'rosybrown': '#BC8F8F',
    'moccasin': '#FFE4B5',
    'tan': '#D2B48C',
    'burlywood': '#DEB887',
    'wheat': '#F5DEB3',
    'sandybrown': '#F4A460',
    'peru': '#CD853F',
    'seashell': '#FFF5EE',
    'oldlace': '#FDF5E6',
    'linen': '#FAF0E6',
    'antiquewhite': '#FAEBD7',
    'papayawhip': '#FFEFD5',
    'blanchedalmond': '#FFEBCD',
    'mistyrose': '#FFE4E1',
    'snow': '#FFFAFA',
    'ivory': '#FFFFF0',
    'white': '#FFFFFF',
    'black': '#000000',
    'gray': '#808080',
    'darkgray': '#A9A9A9',
    'silver': '#C0C0C0',
    'lightgray': '#D3D3D3',
    'gainsboro': '#DCDCDC',
    'whitesmoke': '#F5F5F5',
    'darkslategray': '#2F4F4F',
    'dimgray': '#696969',
    'slategray': '#708090',
    'lightslategray': '#778899',
    'lightsteelblue': '#B0C4DE',
    'darkkhaki': '#BDB76B',
    'khaki': '#F0E68C',
    'olive': '#808000',
    'darkolivegreen': '#556B2F',
    'olivedrab': '#6B8E23',
    'mediumolivegreen': '#BDB76B',
    'lightolivegreen': '#9ACD32',
    'lightblue': '#ADD8E6',
    'mediumaquamarine': '#66CDAA',
    'darkgreen': '#006400',
    'forestgreen': '#228B22',
  };

  // Si la couleur est dans le map des couleurs standard, retourne la couleur hexadécimale correspondante
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

  // Si la couleur n'est pas trouvée, retourne une couleur par défaut
  return Colors.grey;
}

bool getIsCheckedFromJson(dynamic value) {
  if (value == "1") {
    return true;
  } else if (value == "0") {
    return false;
  } else {
    throw ArgumentError('Invalid value for isChecked: $value');
  }
}
