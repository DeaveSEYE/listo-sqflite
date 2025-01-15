import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bcrypt/bcrypt.dart'; // Pour le hashage des mots de passe
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:listo/core/api/service.dart';
import 'package:listo/core/global/authHelper.dart';
import 'package:listo/core/theme/colors.dart'; // Couleurs personnalisées
import 'package:listo/core/utils/responsive.dart';
import 'package:listo/database/database_helper.dart';
import 'package:listo/partials/notification.dart'; // Classe responsive

import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final apiService = ApiService();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Déconnexion explicite pour réinitialiser l'état
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        print('Google Sign-In annulé par l\'utilisateur.');
        NotificationHelper.showFlushbar(
          // ignore: use_build_context_synchronously
          context: context,
          message: "Inscription Google Sign-In annulé ",
          type: NotificationType.error,
        );
        return;
      }
      print(googleUser);
      final user = await apiService.userData("auth", googleUser.id);
      if (user.isNotEmpty) {
        NotificationHelper.showFlushbar(
          // ignore: use_build_context_synchronously
          context: context,
          message:
              "Vous etes deja inscris appuyer sur se connecter pour acceder a l'application ",
          type: NotificationType.info,
        );
        return;
      }
      // final token = await _databaseHelper.fetchtokens();
      // token[0]['token'],
      // Préparer les données pour l'API
      final requestData = {
        'user': googleUser.displayName,
        'email': googleUser.email,
        'password': '',
        'firebaseCloudMessagingToken': "test",
        'auth': {
          'source': 'google',
          'id': googleUser.id,
          'photoUrl': googleUser.photoUrl
        },
      };

      // Envoyer les données à l'API
      print(requestData);
      await apiService.addUser(requestData);
      await AuthHelper.updateAuthData("login", requestData, _databaseHelper);
      NotificationHelper.showFlushbar(
        // ignore: use_build_context_synchronously
        context: context,
        message: "Inscription réussie ",
        type: NotificationType.success,
      );

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print('Erreur lors de la connexion avec Google : $e');
      NotificationHelper.showFlushbar(
        // ignore: use_build_context_synchronously
        context: context,
        message: "Erreur lors de la connexion avec Google ",
        type: NotificationType.alert,
      );
    }
  }

  Future<void> _signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final String email = credential.email ?? 'Email non fourni';
      final String displayName =
          '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim();

      // Affiche les informations pour tester
      print('Apple Sign-In réussi : $displayName, $email');
      // Envoyer les données à votre API ou Firebase
    } catch (e) {
      print('Erreur lors de la connexion avec Apple : $e');
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final user = await apiService.userData("email", email);
      if (user.isNotEmpty) {
        NotificationHelper.showFlushbar(
          // ignore: use_build_context_synchronously
          context: context,
          message:
              "Vous etes deja inscris appuyer sur se connecter pour acceder a l'application ",
          type: NotificationType.info,
        );
        return;
      }
      // Hashage du mot de passe avec bcrypt
      final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
      // final token = await _databaseHelper.fetchtokens();
      // Préparer les données pour l'API
      final requestData = {
        'user': name,
        'email': email,
        'password': hashedPassword,
        'firebaseCloudMessagingToken': "test",
        'auth': {'source': 'normal', 'id': '', 'photoUrl': ''},
      };
      print(requestData);
      // Envoyer les données à l'API
      try {
        await apiService.addUser(requestData);
        await AuthHelper.updateAuthData("login", requestData, _databaseHelper);
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
              SizedBox(height: responsive.hp(1)),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Prenom & Nom',
                  hintText: 'Entrez votre nom complet',
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
              SizedBox(height: responsive.hp(2)),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email OU Tel',
                  hintText: 'Entrez votre identifiant',
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
                  prefixIcon: const Icon(Icons.email, color: Colors.grey),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le champ identifiant est vide';
                  }
                  if (num.tryParse(value) != null && value.length > 7) {
                    return 'Veuillez entrer un N° de Tel valide';
                  } else {
                    // Vérification avec RegExp pour un email valide
                    final emailRegex = RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                    );
                    if (!emailRegex.hasMatch(value)) {
                      return 'Format de l\'email incorrect';
                    }
                  }
                  return null;
                },
              ),
              SizedBox(height: responsive.hp(2)),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mot de Passe',
                  hintText: 'Entrez votre Mot de passe',
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
                  prefixIcon: const Icon(Icons.lock, color: Colors.grey),
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
                  labelText: 'Confirmer mot de passe',
                  hintText: 'Entrez a nouveau',
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
                  prefixIcon: const Icon(Icons.lock, color: Colors.grey),
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
                onPressed: () async {
                  await _register(); // Appel de la méthode _register
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, // Couleur du bouton
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: responsive.hp(1),
                    horizontal: responsive.wp(10),
                  ),
                ),
                child: Text(
                  "S'inscrire",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: responsive.hp(1)),
              const Text('Ou'),
              SizedBox(height: responsive.hp(1)),
              if (Platform.isAndroid)
                SignInButton(
                  Buttons.Google,
                  text: "S'inscrire avec Google",
                  onPressed: _signInWithGoogle,
                ),
              if (Platform.isIOS)
                SignInButton(
                  Buttons.Apple,
                  text: "S'inscrire avec Apple",
                  onPressed: _signInWithApple,
                ),
              SizedBox(height: responsive.hp(2)),
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
