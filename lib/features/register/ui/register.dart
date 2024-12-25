// permet de connaitre le systeme d'exploitation de l'appareil.

//import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:listo/core/theme/colors.dart'; // class des couleur utiliser dans lapplication
import 'package:listo/core/theme/widgets.dart'; //class des widgets reutilisable
import 'package:listo/core/utils/responsive.dart'; //class pour rebdre les pages responsive

import 'package:listo/features/login/ui/login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context); // Initialiser Responsive
    final bool isCompact = responsive.height < 600;
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Désactive le redimensionnement automatique lié au clavier
      backgroundColor: AppColors.background,
      // appBar: PreferredSize(
      //   preferredSize:
      //       const Size.fromHeight(28), // Hauteur standard de l'AppBar
      //   child: AppBar(
      //     backgroundColor: AppColors.background,
      //     iconTheme: const IconThemeData(
      //       color: Color(0xFF6C9FEE), // Couleur bleue pour la flèche de retour
      //     ),
      //     leading: IconButton(
      //       icon: const Icon(Icons.arrow_back), // Icône de la flèche de retour
      //       onPressed: () {
      //         Navigator.pop(context); // Action qui renvoie à la page précédente
      //       },
      //     ),
      //   ),
      // ),

      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: responsive.wp(5)), // Padding horizontal responsive
        child: Column(
          children: <Widget>[
            const Spacer(), // Ajoute de l'espacement pour recentrer les éléments si le clavier est visible
            // Image.asset(
            //   'lib/assets/img/register.png',
            //   width: responsive.wp(60),
            //   height: responsive.wp(50),
            // ),
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
            SizedBox(height: responsive.hp(0)),
            Text(
              'Créer un compte',
              style: TextStyle(
                color: AppColors.grey,
                fontSize: responsive.fontSize(0.05),
              ),
            ),
            SizedBox(height: responsive.hp(1)),
            CustomTextFormField(
              label: 'Prénom & Nom',
              hint: 'Entrez votre nom complet',
              icon: Icons.person,
              responsive: responsive,
            ),
            SizedBox(height: responsive.hp(2)), // Espace vertical responsive
            CustomTextFormField(
              label: 'Email ou Nom utilisateur',
              hint: 'Entrez un identifiant',
              icon: Icons.email,
              responsive: responsive,
            ),
            SizedBox(height: responsive.hp(2)),
            CustomTextFormField(
              label: 'Mot de passe',
              hint: 'Entrez votre mot de passe',
              icon: Icons.lock,
              isPassword: true,
              responsive: responsive,
            ),
            SizedBox(height: responsive.hp(2)),
            CustomTextFormField(
              label: 'Confirmer Mot de passe',
              hint: 'Entrez à nouveau',
              icon: Icons.lock,
              isPassword: true,
              responsive: responsive,
            ),
            SizedBox(height: responsive.hp(3)),
            CustomElevatedButton(
              text: "S'inscrire",
              onPressed: () {
                // Navigator.pushNamed(context, Routes.homePage);
                //MaterialPageRoute(
                //builder: (context) => Home(tasks: tasks),
                //);
                //MaterialPageRoute(
                //builder: (context) => const MainScaffold(),
                //);

                /// Navigator.push(
                //context,
                //MaterialPageRoute(
                //builder: (context) => const Home(),
                //),
                //);
              },
              color: Colors.blue, // Couleur du bouton
              responsive: responsive, // Instance de Responsive
              borderRadius: 20.0, // Coins arrondis
              padding: EdgeInsets.symmetric(
                  vertical: responsive.hp(2),
                  horizontal: responsive.wp(10)), // Padding personnalisé
            ),
            SizedBox(height: responsive.hp(3)),
            const Text('Ou'),
            SizedBox(height: responsive.hp(2)),
            // if (Platform.isAndroid)
            SignInButton(
              Buttons.Google,
              text: "S'inscrire avec Google",
              onPressed: () {},
            ),
            SizedBox(height: responsive.hp(3)),
            // if (Platform.isIOS)
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Login(),
                      ),
                    );
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
    );
  }
}
