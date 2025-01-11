import 'package:flutter/material.dart';

class Preference extends StatefulWidget {
  const Preference({super.key});

  @override
  State<Preference> createState() => _PreferenceState();
}

class _PreferenceState extends State<Preference> {
  // État des interrupteurs
  bool _notificationsEnabled = true;
  bool _pokeNotificationsEnabled = false;
  bool _emailOffersEnabled = true;
  bool _productUpdatesEnabled = false;

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
                'Activez les notifications etre alerter des taches en approches',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          _buildSwitchTile(
            title: 'Mises à jour',
            subtitle: 'Soyez informé sur les mises à jour, nouveautés.',
            value: _productUpdatesEnabled,
            onChanged: (value) {
              setState(() {
                _productUpdatesEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.blue,
      inactiveThumbColor: Colors.grey,
      inactiveTrackColor: Colors.grey.shade300,
    );
  }
}
