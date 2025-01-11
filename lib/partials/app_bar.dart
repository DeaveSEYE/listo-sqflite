import 'package:flutter/material.dart';
import 'package:listo/core/theme/colors.dart';
import 'package:listo/features/profile/ui/profile.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
//backgroundColor: const Color(0x00000000),
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(
          Icons.person,
          color: Colors.white, // Couleur de l'icône
        ),
        onPressed: () {
          // Naviguer vers la page Profile
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const ProfileScreen()), // Remplacez ProfileScreen par votre widget de profil
          );
        },
      ),
      title: const Padding(
        padding: EdgeInsets.only(top: 8.0), // Abaisser le texte
        child: Text(
          "Listo",
          style: TextStyle(
            color: Colors.white, // Couleur du texte
            fontWeight: FontWeight.bold, // Optionnel : ajustez le style
          ),
        ),
      ),
      actions: [
        IconButton(
          color: Colors.white,
          icon: const Icon(Icons.notification_add),
          onPressed: () {
            // NotificationService()
            //     .showNotification(title: 'Sample title', body: 'It works!');
          },
        ),
      ],
      elevation: 4,
      //bottom: PreferredSize(
      //preferredSize: const Size.fromHeight(4.0), // Hauteur de la ligne
      //child: Container(
      //color: Colors.grey, // Couleur de la bordure inférieure
      //height: 2.0, // Épaisseur de la ligne
      //),
      //),
    );
  }
}
