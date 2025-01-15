import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:bcrypt/bcrypt.dart'; // Pour la vérification des mots de passe hachés
import 'package:listo/core/api/service.dart';
import 'package:listo/core/global/authHelper.dart';
import 'package:listo/core/theme/colors.dart';
import 'package:listo/core/utils/responsive.dart';
import 'package:listo/database/database_helper.dart';
import 'package:listo/features/register/ui/register.dart';
import 'package:listo/partials/main_scaffold.dart';
import 'package:listo/partials/notification.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Future<void> _loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Déconnexion explicite pour réinitialiser l'état
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        print('Google log-In annulé par l\'utilisateur.');
        NotificationHelper.showFlushbar(
          // ignore: use_build_context_synchronously
          context: context,
          message: "Connexion Google Sign-In annulé ",
          type: NotificationType.error,
        );
        return;
      }
      print("googleUser");
      print(googleUser);
      final user = await apiService.userData("auth", googleUser.id);
      if (user.isEmpty) {
        NotificationHelper.showFlushbar(
          // ignore: use_build_context_synchronously
          context: context,
          message:
              "Vous n'etes pas encore inscris appuyer sur s'inscrire pour creer un compte ",
          type: NotificationType.info,
        );
        return;
      }
      final requestData = {
        'id': user['id'],
        'user': user['user'],
        'email': user['email'],
        'auth_source': user['auth']['source'],
        'auth_id': user['auth']['id'],
        'photoUrl': user['auth']['photoUrl'],
      };
      await _databaseHelper.insertUser(requestData);
      // GlobalState().userId = user['id'];
      await AuthHelper.updateAuthData("login", user, _databaseHelper);
      NotificationHelper.showFlushbar(
        // ignore: use_build_context_synchronously
        context: context,
        message: "Bienvenue ",
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

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text.trim();
      String password = _passwordController.text;

      if (username.isEmpty || password.isEmpty) {
        // _showErrorMessage("Veuillez remplir tous les champs.");
        NotificationHelper.showFlushbar(
          // ignore: use_build_context_synchronously
          context: context,
          message: "Veuillez remplir tous les champs. ",
          type: NotificationType.info,
        );
        return;
      }

      try {
        final user = await apiService.userData("email", username);
        if (user.isNotEmpty) {
          if (user['auth']['source'] == "normal") {
            // Vérification du mot de passe
            bool isPasswordValid = BCrypt.checkpw(password, user['password']);

            if (!isPasswordValid) {
              NotificationHelper.showFlushbar(
                // ignore: use_build_context_synchronously
                context: context,
                message: "Mot de passe incorect ",
                type: NotificationType.alert,
              );
              return;
            }
            final requestData = {
              'id': user['id'],
              'user': user['user'],
              'email': user['email'],
              'auth_source': user['auth']['source'],
              'auth_id': user['auth']['id'],
              'photoUrl': user['auth']['photoUrl'],
            };
            await _databaseHelper.insertUser(requestData);
            // GlobalState().userId = user['id'];
            await AuthHelper.updateAuthData("login", user, _databaseHelper);
            NotificationHelper.showFlushbar(
              // ignore: use_build_context_synchronously
              context: context,
              message: "Bienvenue ",
              type: NotificationType.success,
            );

            Navigator.pushReplacementNamed(context, '/home');
          } else {
            NotificationHelper.showFlushbar(
              // ignore: use_build_context_synchronously
              context: context,
              message:
                  "Votre compte a été créer avec le google SIGN IN .utiliser le boutton de connexion GOOGLE en bas. ",
              type: NotificationType.info,
            );
            return;
          }
        } else {
          NotificationHelper.showFlushbar(
            // ignore: use_build_context_synchronously
            context: context,
            message: "Cette utilisateur n'existe pas. ",
            type: NotificationType.info,
          );
          return;
        }

        // Connexion réussie
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScaffold()),
        );
      } catch (e) {
        // _showErrorMessage("Une erreur est survenue : $e");
        NotificationHelper.showFlushbar(
          // ignore: use_build_context_synchronously
          context: context,
          message: "Une erreur est survenue. ",
          type: NotificationType.info,
        );
      }
    }
  }

  // void _showErrorMessage(String message) {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text("Erreur"),
  //         content: Text(message),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text("OK"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final bool isCompact = responsive.height < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
      ),
      body: Container(
        color: AppColors.background,
        padding: EdgeInsets.all(responsive.wp(4)),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.lock,
                size: responsive.wp(isCompact ? 20 : 30),
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
              SizedBox(height: responsive.hp(2)),
              Text(
                'Se connecter',
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: responsive.fontSize(0.05),
                ),
              ),
              SizedBox(height: responsive.hp(isCompact ? 1 : 2)),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Nom d\'utilisateur',
                  hintText: 'Entrez votre nom d\'utilisateur',
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
              SizedBox(height: responsive.hp(isCompact ? 2 : 3)),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  hintText: 'Entrez votre mot de passe',
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
              SizedBox(height: responsive.hp(isCompact ? 2 : 3)),
              ElevatedButton(
                onPressed: () async {
                  await _login(); // Appel de la méthode _register
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
                  "Se connecter",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!isCompact) ...[
                SizedBox(height: responsive.hp(3)),
                const Text('Ou'),
                SizedBox(height: responsive.hp(2)),
                if (Platform.isAndroid)
                  SignInButton(
                    Buttons.Google,
                    text: "Connexion avec Google",
                    onPressed: _loginWithGoogle,
                  ),
                SizedBox(height: responsive.hp(3)),
                if (Platform.isIOS)
                  SignInButton(
                    Buttons.Apple,
                    text: "Connexion avec Apple",
                    onPressed: () {
                      // Action pour la connexion avec Apple
                    },
                  ),
                SizedBox(height: responsive.hp(3)),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Vous n\'avez pas de compte? '),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Register(),
                        ),
                      );
                    },
                    child: Text(
                      'S\'inscrire',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: responsive.fontSize(0.04),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
