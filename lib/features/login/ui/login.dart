// Import pour détecter la plateforme
//import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart'; //permet dafficher et gerer les boutton google et apple
import 'package:listo/core/theme/colors.dart'; // class des couleur utiliser dans lapplication
import 'package:listo/core/theme/widgets.dart'; //class des widgets reutilisable
import 'package:listo/core/utils/responsive.dart'; //class pour rebdre les pages responsive
import 'package:listo/features/register/ui/register.dart'; //page d'inscription
import 'package:listo/partials/main_scaffold.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    // Vérifiez si l'écran est "compact" (par exemple, hauteur inférieure à 600 pixels)
    final bool isCompact = responsive.height < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset:
          false, // Désactive le redimensionnement automatique lié au clavier
      appBar: AppBar(
        automaticallyImplyLeading: false, // Désactive la flèche de retour
        backgroundColor: AppColors.background,
      ),
      body: Container(
        color: AppColors.background,
        padding: EdgeInsets.all(responsive.wp(4)),
        child: Form(
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
              ),
              SizedBox(height: responsive.hp(isCompact ? 2 : 3)),
              TextFormField(
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
                obscureText: true,
              ),
              SizedBox(height: responsive.hp(isCompact ? 2 : 3)),
              GestureDetector(
                onTap: () {
                  // Naviguer vers la page Home lorsque le bouton est tapé
                  // Navigator.pushNamed(context, Routes.homePage);
                  MaterialPageRoute(
                    builder: (context) => const MainScaffold(),
                  );
                },
                child: CustomElevatedButton(
                  text: "Se connecter",
                  onPressed: () {
                    // Navigator.pushNamed(context, Routes.homePage);
                    MaterialPageRoute(
                      builder: (context) => const MainScaffold(),
                    );
                    // Cela peut rester vide si vous ne voulez pas utiliser onPressed ici
                    // Le GestureDetector s'occupe de la navigation
                  },
                  color: Colors.blue, // Couleur du bouton
                  responsive: responsive, // Instance de Responsive
                  borderRadius: 20.0, // Coins arrondis
                  padding: EdgeInsets.symmetric(
                    vertical: responsive.hp(2),
                    horizontal: responsive.wp(10),
                  ), // Padding personnalisé
                ),
              ),
              if (!isCompact) ...[
                SizedBox(height: responsive.hp(3)),
                const Text('Ou'),
                SizedBox(height: responsive.hp(2)),
                // if (Platform.isAndroid)
                SignInButton(
                  Buttons.Google,
                  text: "Connexion avec Google",
                  onPressed: () {
                    // Action pour la connexion avec Google
                  },
                ),
                SizedBox(height: responsive.hp(3)),
                // if (Platform.isIOS)
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
