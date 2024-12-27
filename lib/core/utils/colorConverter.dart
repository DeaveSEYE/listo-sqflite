import 'dart:ui';

class ColorConverter {
  static Map<String, Color> colorMap = {
    "Red": Color(0xFFFF0000),
    "Green": Color(0xFF00FF00),
    "Blue": Color(0xFF0000FF),
    "Yellow": Color(0xFFFFFF00),
    "Cyan": Color(0xFF00FFFF),
    "Magenta": Color(0xFFFF00FF),
    "White": Color(0xFFFFFFFF),
    "Black": Color(0xFF000000),
  };

  static Color getColorFromName(String colorName) {
    return colorMap[colorName] ?? Color(0xFF000000); // Retourne noir si inconnu
  }

  static String getColorName(int colorInt) {
    Map<int, String> reverseMap = {
      0xFFFF0000: "red",
      0xFF00FF00: "green",
      0xFF0000FF: "blue",
      0xFFFFFF00: "yellow",
      0xFF00FFFF: "cyan",
      0xFFFF00FF: "magenta",
      0xFFFFFFFF: "white",
      0xFF000000: "black",
      0xFFFFA500: "orange",
      0xFF800080: "purple",
    };
    return reverseMap[colorInt] ?? "yellow";
  }
}
