import 'package:flutter/material.dart';
import 'package:listo/core/api/service.dart';
import 'package:listo/partials/main_scaffold.dart';
import 'package:listo/partials/notification.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  Future<void> logout(BuildContext context) async {
    final apiService = ApiService();

    await apiService.logout();

    // Rediriger l'utilisateur vers l'écran de connexion ou l'écran principal
    Navigator.pushReplacementNamed(context, '/login');
    NotificationHelper.showFlushbar(
      // ignore: use_build_context_synchronously
      context: context,
      message: "Vous etes desormais deconnecté ",
      type: NotificationType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(color: Colors.grey),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const MainScaffold()), // Remplacez ProfileScreen par votre widget de profil
            ); // Retour à la page précédente
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, size: 50, color: Colors.grey),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Listo',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const Text(
              'listo@forcen.sn',
              style: TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Appel de la fonction de déconnexion
                logout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 10.0),
              ),
              child: const Text('Déconnexion',
                  style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20.0),
            // Boutons réduits avec texte en blanc
            _buildOptionButton(
                context, Icons.sync, 'Synchronisation du compte'),
            _buildOptionButton(
                context, Icons.notifications, 'Notification de rappel'),
            _buildOptionButton(context, Icons.share, 'Partager l\'application'),
            const Spacer(),
            const Text('version 1.0.0', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(BuildContext context, IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: () {
          // Action du bouton
        },
        icon: Icon(icon, color: Colors.white),
        label: Text(label,
            style: const TextStyle(color: Colors.white)), // Libellé en blanc
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          minimumSize: const Size(200, 40), // Réduction de la taille du bouton
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
      ),
    );
  }
}
