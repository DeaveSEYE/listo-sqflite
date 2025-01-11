import 'package:flutter/material.dart';
import 'package:listo/features/parametres/ui/compte.dart';

class Parametres extends StatefulWidget {
  const Parametres({super.key});

  @override
  State<Parametres> createState() => _ParametresState();
}

class _ParametresState extends State<Parametres> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.purple),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Paramètres', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSettingsTile(
            title: 'Compte',
            subtitle: 'Ajustez les paramètres de votre compte',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Compte()),
            ),
          ),
          _buildSettingsTile(
            title: 'Préférences',
            subtitle: 'Ajustez vos préférences de l’application',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Compte()),
            ),
          ),
          _buildSettingsTile(
            title: 'Légal',
            subtitle: 'Conditions et vie privée',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Compte()),
            ),
          ),
          _buildSettingsTile(
            title: 'Comment ça marche',
            subtitle: 'Infos sur les fonctionnalités de l’application',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Compte()),
            ),
          ),
          _buildSettingsTile(
            title: 'Service d’aide',
            subtitle: 'Nous contacter, social',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Compte()),
            ),
          ),
          Spacer(),
          Center(
            child: Text('Version 1.33.0', style: TextStyle(color: Colors.grey)),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle),
          trailing: Icon(Icons.chevron_right, color: Colors.black),
          onTap: onTap,
        ),
        Divider(height: 1),
      ],
    );
  }
}
