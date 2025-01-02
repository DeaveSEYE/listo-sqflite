import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:bcrypt/bcrypt.dart'; // Pour le hashage des mots de passe
import 'package:listo/core/api/service.dart';
import 'package:listo/core/theme/colors.dart'; // Couleurs personnalisées
import 'package:listo/core/utils/responsive.dart';
import 'package:listo/partials/notification.dart'; // Classe responsive

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Hashage du mot de passe avec bcrypt
      final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

      // Préparer les données pour l'API
      final requestData = {
        'user': name,
        'email': email,
        'password': hashedPassword,
      };

      // Envoyer les données à l'API
      try {
        await apiService.addUser(requestData);
        Navigator.pushReplacementNamed(context, '/home');

        NotificationHelper.showFlushbar(
          // ignore: use_build_context_synchronously
          context: context,
          message: "Inscription réussie ",
          type: NotificationType.success,
        );
      } catch (e) {
        NotificationHelper.showFlushbar(
          // ignore: use_build_context_synchronously
          context: context,
          message: "Verifier votre connextion internet ",
          type: NotificationType.info,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive =
        Responsive(context); // Pour rendre l'interface responsive
    final bool isCompact = responsive.height < 600;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: responsive.wp(5)),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              const Spacer(),
              Icon(
                Icons.supervised_user_circle_rounded,
                size: responsive.wp(isCompact ? 10 : 20),
                color: AppColors.primary,
              ),
              Text(
                'Listo',
                style: TextStyle(
                  color: AppColors.regular,
                  fontWeight: FontWeight.bold,
                  fontSize: responsive.fontSize(0.08),
                ),
              ),
              Text(
                'Créer un compte',
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: responsive.fontSize(0.05),
                ),
              ),
              SizedBox(height: responsive.hp(2)),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Prénom & Nom',
                  hintText: 'Entrez votre nom complet',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
              ),
              SizedBox(height: responsive.hp(2)),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email ou Nom utilisateur',
                  hintText: 'Entrez un identifiant',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un email valide';
                  }

                  // Vérification avec RegExp pour un email valide
                  final emailRegex = RegExp(
                    r"^[a-zA-Z0-9.a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                  );
                  if (!emailRegex.hasMatch(value)) {
                    return 'Format de l\'email incorrect';
                  }

                  return null;
                },
              ),
              SizedBox(height: responsive.hp(2)),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  hintText: 'Entrez votre mot de passe',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Le mot de passe doit contenir au moins 6 caractères';
                  }
                  return null;
                },
              ),
              SizedBox(height: responsive.hp(2)),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirmer Mot de passe',
                  hintText: 'Entrez à nouveau',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Les mots de passe ne correspondent pas';
                  }
                  return null;
                },
              ),
              SizedBox(height: responsive.hp(3)),
              ElevatedButton(
                onPressed: _register,
                child: const Text("S'inscrire"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: responsive.hp(2),
                    horizontal: responsive.wp(10),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              SizedBox(height: responsive.hp(3)),
              const Text('Ou'),
              SizedBox(height: responsive.hp(2)),
              if (Platform.isAndroid)
                SignInButton(
                  Buttons.Google,
                  text: "S'inscrire avec Google",
                  onPressed: () {},
                ),
              if (Platform.isIOS)
                SignInButton(
                  Buttons.Apple,
                  text: "S'inscrire avec Apple",
                  onPressed: () {},
                ),
              SizedBox(height: responsive.hp(3)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Déjà inscrit? '),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Se connecter',
                      style: TextStyle(
                        color: const Color(0xFF6C9FEE),
                        fontWeight: FontWeight.bold,
                        fontSize: responsive.fontSize(0.04),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
