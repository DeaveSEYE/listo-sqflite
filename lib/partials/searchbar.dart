import 'package:flutter/material.dart';

class Searchbar extends StatefulWidget {
  const Searchbar({super.key});

  @override
  State<Searchbar> createState() => _SearchbarState();
}

class _SearchbarState extends State<Searchbar> {
  @override
  Widget build(BuildContext context) {
    return const Card(
      child: TextField(
              decoration: InputDecoration(
                hintText: "Rechercher...",
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                filled: true,
                fillColor: Colors
                    .white, // Couleur de fond de la barre de recherche
                contentPadding:
                    EdgeInsets.symmetric(vertical: 17), // Ajuste l'espacement
              ),
            ),
    );
  }
}
