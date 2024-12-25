import 'package:flutter/material.dart';

class Categorychip extends StatefulWidget {
  final String label; // Ajout du paramètre label
  final Color color; // Ajout du paramètre color

  const Categorychip(this.label, this.color,
      {super.key}); // Initialisation des paramètres

  @override
  State<Categorychip> createState() => _CategorychipState();
}

class _CategorychipState extends State<Categorychip> {
  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(widget.label), // Accès au label via widget.label
      backgroundColor:
          widget.color.withOpacity(0.2), // Accès au color via widget.color
      labelStyle: TextStyle(color: widget.color),
      padding: const EdgeInsets.all(5),
    );
    // return const Center(
    //   child: Text("test"),
    // );
  }
}
