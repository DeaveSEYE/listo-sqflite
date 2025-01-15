import 'package:flutter/material.dart';
import 'package:listo/core/api/service.dart';
import 'package:listo/core/global/authHelper.dart';
import 'package:listo/database/database_helper.dart';
import 'package:listo/features/parametres/ui/change_password.dart';
import 'package:listo/features/parametres/ui/edit_profile.dart';
import 'package:listo/partials/notification.dart';

class Compte extends StatefulWidget {
  const Compte({super.key});

  @override
  State<Compte> createState() => _CompteState();
}

class _CompteState extends State<Compte> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  Future<void> logout(BuildContext context) async {
    final apiService = ApiService();

    await apiService.logout();
    await AuthHelper.updateAuthData("logout", null, _databaseHelper);
    // Rediriger l'utilisateur vers l'écran de connexion
    Navigator.pushReplacementNamed(context, '/login');
    NotificationHelper.showFlushbar(
      // ignore: use_build_context_synchronously
      context: context,
      message: "Vous etes desormais deconnecté ",
      type: NotificationType.success,
    );
  }

  Future<void> deleteAccount(BuildContext context) async {
    await AuthHelper.updateAuthData("logout", null, _databaseHelper);
    // Rediriger l'utilisateur vers l'écran de connexion
    // Navigator.pushReplacementNamed(context, '/login');
    NotificationHelper.showFlushbar(
      // ignore: use_build_context_synchronously
      context: context,
      message: "Compte supprimé ",
      type: NotificationType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // title: Text('Compte', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          SizedBox(height: 20),
          Text('COMPTE', style: TextStyle(fontWeight: FontWeight.bold)),
          _buildAccountCard(),
          SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Bouton "Se déconnecter"
              OutlinedButton(
                onPressed: () {
                  // Fonction à exécuter lors de la déconnexion
                  logout(context);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.blue, width: 2.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                  backgroundColor: Colors.white,
                ),
                child: const Text(
                  'Se déconnecter',
                  style: TextStyle(
                    color: Colors.blue, // Texte en bleu foncé
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20.0), // Espacement entre les éléments

              // Texte "Supprimer le compte" cliquable
              GestureDetector(
                onTap: () {
                  // Fonction à exécuter lors de la suppression du compte
                  deleteAccount(context);
                },
                child: const Text(
                  'Supprimer le compte',
                  style: TextStyle(
                      color: Color.fromRGBO(255, 82, 82, 1),
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0
                      // decoration: TextDecoration
                      //     .underline, // Soulignement pour indiquer un lien
                      ),
                ),
              ),
              const SizedBox(height: 20.0), // Espacement en bas
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAccountCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAccountRow(
              label: 'Profil Utilisateur',
              value: '***@gmail.com',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditProfile()),
                );
              },
            ),
            Divider(),
            _buildAccountRow(
              label: "Mot de passe",
              value: "********",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChangePassword()),
                );
              },
            ),
            // Divider(),
            // _buildAccountRow(
            //   label: 'Paramètres de l’authentification multi-facteurs',
            //   value: 'Désactivé',
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (_) => EditProfile()),
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountRow({
    required String label,
    required String value,
    required VoidCallback onTap,
    bool showAction = true,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Partie gauche : Label et Valeur
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(value, style: TextStyle(color: Colors.grey)),
          ],
        ),
        // Partie droite : Action (Icon + Texte)
        if (showAction)
          GestureDetector(
            onTap: onTap,
            child: Row(
              children: [
                Icon(Icons.edit, color: Colors.blue), // Icône pencil
                SizedBox(width: 4),
                Text(
                  "Modifier",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
