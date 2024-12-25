import 'package:flutter/material.dart';

// ignore: camel_case_types
class Buildtasksummary extends StatefulWidget {
  final Color bgColor; // Ajout du paramètre label
  final String count; // Ajout du paramètre color
  final String label; // Ajout du paramètre label

  const Buildtasksummary(this.bgColor, this.count, this.label,
      {super.key}); // Initialisation des paramètres

  @override
  State<Buildtasksummary> createState() => _BuildtasksummaryState();
}

// ignore: camel_case_types
class _BuildtasksummaryState extends State<Buildtasksummary> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.bgColor, // Utilisation du paramètre de type Color
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            widget.count,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(widget.label),
        ],
      ),
    );
  }
}
