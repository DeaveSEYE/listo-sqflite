import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:listo/core/api/service.dart';
import 'package:listo/core/global/global_state.dart';
import 'package:listo/core/theme/colors.dart';
import 'package:listo/partials/notification.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateButtonState);
    _nameController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _nameController.text.trim().isNotEmpty;
    });
  }

  Future<void> _editProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final name = _nameController.text.trim();

        // Préparer les données pour la mise à jour du profil
        final requestData = {'user': name};
        final response = await http.put(
          Uri.parse(
              'https://task-api-firebase.vercel.app/users/${GlobalState().userId}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestData),
        );
        if (response.statusCode == 200) {
          NotificationHelper.showFlushbar(
            context: context,
            message: "Profil mis à jour avec succès",
            type: NotificationType.success,
          );
        } else {
          NotificationHelper.showFlushbar(
            context: context,
            message: "Erreur lors de la mise à jour",
            type: NotificationType.alert,
          );
          throw Exception('Erreur lors de la mise à jour');
        }
      } catch (e) {
        NotificationHelper.showFlushbar(
          context: context,
          message: "Erreur : ${e.toString()}",
          type: NotificationType.error,
        );
      }
    }
  }

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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              // Section image
              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/editPassword.jpg',
                  height: 120,
                ),
              ),
              SizedBox(height: 20),
              // Titre
              Text(
                GlobalState().email,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              // Champ de texte désactivé
              TextField(
                enabled: false,
                decoration: InputDecoration(
                  labelText: GlobalState().email,
                  suffixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Champ pour le nom complet
              TextFormField(
                controller: _nameController,
                onChanged: (value) => _updateButtonState(),
                decoration: InputDecoration(
                  labelText: 'Prenom & Nom',
                  hintText: GlobalState().user,
                  filled: true,
                  fillColor: AppColors.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  prefixIcon: const Icon(Icons.person, color: Colors.grey),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom complet';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // Bouton d'enregistrement
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isButtonEnabled
                      ? () {
                          if (_formKey.currentState!.validate()) {
                            _editProfile();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isButtonEnabled ? Colors.blue : Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Enregistrer',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
