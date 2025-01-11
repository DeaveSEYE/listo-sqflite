import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:listo/core/api/service.dart';
import 'package:http/http.dart' as http;
import 'package:listo/core/global/global_state.dart';
import 'package:listo/core/theme/colors.dart';
import 'package:listo/partials/notification.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  bool isEnabled = false;

  final apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ancienPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _newPasswordConfirmController =
      TextEditingController();

  void _updateButtonState() {
    setState(() {
      isEnabled = _formKey.currentState?.validate() ?? false;
    });
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        final oldPassword = _ancienPasswordController.text.trim();
        final newPassword = _newPasswordController.text.trim();
        final user = await apiService.userData("id", GlobalState().userId);

        if (user.isNotEmpty) {
          if (user['auth']['source'] == "normal") {
            final password = BCrypt.hashpw(oldPassword, BCrypt.gensalt());
            bool isPasswordValid = BCrypt.checkpw(password, user['password']);

            if (!isPasswordValid) {
              NotificationHelper.showFlushbar(
                context: context,
                message: "Mot de passe incorrect",
                type: NotificationType.alert,
              );
              return;
            }

            final hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());
            final requestData = {'password': hashedPassword};

            final response = await http.put(
              Uri.parse(
                  'https://task-api-firebase.vercel.app/users/${GlobalState().userId}'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(requestData),
            );

            if (response.statusCode == 200) {
              NotificationHelper.showFlushbar(
                context: context,
                message: "Mot de passe mis à jour avec succès",
                type: NotificationType.success,
              );
            } else {
              NotificationHelper.showFlushbar(
                context: context,
                message: "Erreur lors de la mise à jour du mot de passe",
                type: NotificationType.alert,
              );
              throw Exception('Erreur lors de la mise à jour du mot de passe');
            }
          } else {
            NotificationHelper.showFlushbar(
              context: context,
              message:
                  "Vous ne pouvez pas mettre à jour votre mot de passe car votre compte a été créé avec Google Sign-In.",
              type: NotificationType.info,
            );
            return;
          }
        } else {
          NotificationHelper.showFlushbar(
            context: context,
            message: "Cet utilisateur n'existe pas.",
            type: NotificationType.info,
          );
          return;
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
              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/editPassword.jpg',
                  height: 120,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Changer de mot de passe',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextFormField(
                enabled: GlobalState()
                    .authId
                    .isEmpty, // Désactive si inscription via boutton google ou apple
                controller: _ancienPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Ancien mot de passe',
                  hintText: 'Entrez votre ancien mot de passe',
                  filled: true,
                  fillColor: AppColors.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                validator: (value) => value == null || value.length < 6
                    ? 'Le mot de passe doit contenir au moins 6 caractères'
                    : null,
                onChanged: (value) => _updateButtonState(),
              ),
              SizedBox(height: 20),
              TextFormField(
                enabled: GlobalState()
                    .authId
                    .isEmpty, // Désactive si inscription via boutton google ou apple
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Créer un nouveau mot de passe',
                  hintText: 'Entrez votre nouveau mot de passe',
                  filled: true,
                  fillColor: AppColors.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                validator: (value) => value == null || value.length < 6
                    ? 'Le mot de passe doit contenir au moins 6 caractères'
                    : null,
                onChanged: (value) => _updateButtonState(),
              ),
              SizedBox(height: 20),
              TextFormField(
                enabled: GlobalState()
                    .authId
                    .isEmpty, // Désactive si inscription via boutton google ou apple
                controller: _newPasswordConfirmController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirmer mot de passe',
                  hintText: 'Entrez à nouveau',
                  filled: true,
                  fillColor: AppColors.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                validator: (value) => value != _newPasswordController.text
                    ? 'Les mots de passe ne correspondent pas'
                    : null,
                onChanged: (value) => _updateButtonState(),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isEnabled ? _changePassword : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEnabled ? Colors.blue : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text('Enregistrer',
                      style: TextStyle(fontWeight: FontWeight.bold)),
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
