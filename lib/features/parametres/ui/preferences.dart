import 'package:flutter/material.dart';

class Preference extends StatefulWidget {
  const Preference({super.key});

  @override
  State<Preference> createState() => _PreferenceState();
}

class _PreferenceState extends State<Preference> {
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
          Text('NOTIFICATIONS', style: TextStyle(fontWeight: FontWeight.bold)),
          _buildSwitchTile(
            title: 'Notifications',
            subtitle:
                'Activez les notifications et trouvez plus d’opportunités pour gagner !',
          ),
          _buildSwitchTile(
            title: 'Notifications de poke',
            subtitle:
                'Activez les notifications poke et ne ratez jamais de message de vos amis.',
          ),
          _buildSwitchTile(
            title: 'Offres e-mail',
            subtitle:
                'Trouvez ces offres spéciales et ces défis directement dans votre boîte mail.',
          ),
          _buildSwitchTile(
            title: 'Mises à jour du produit',
            subtitle:
                'Soyez informé sur les mises à jour, nouveautés, et faites des retours.',
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({required String title, required String subtitle}) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: true,
      onChanged: (bool value) {},
      activeColor: Colors.blue,
    );
  }
}
