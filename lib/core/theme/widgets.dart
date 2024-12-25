import 'package:flutter/material.dart';
import 'package:listo/core/theme/colors.dart';
import 'package:listo/core/utils/responsive.dart';

class CustomTextFormField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final Responsive responsive;
  final bool isPassword;

  const CustomTextFormField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.responsive,
    this.isPassword = false,
  });

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        // hintStyle: const TextStyle(
        //   color: AppColors.grey, // Couleur personnalisée pour le hintText
        //   fontSize: 16, // Optionnel, pour ajuster la taille du texte du hint
        // ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        prefixIcon: Icon(
          widget.icon,
          color: Colors.grey,
          size: widget.responsive.wp(6), // Taille de l'icône responsive
        ),
      ),
      obscureText: widget.isPassword,
      style: TextStyle(
        fontSize:
            widget.responsive.fontSize(0.04), // Taille du texte responsive
      ),
    );
  }
}

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final Responsive responsive;
  final double
      borderRadius; // Nouveau paramètre pour personnaliser les coins du bouton
  final EdgeInsetsGeometry? padding; // Nouveau paramètre pour le padding

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.color,
    required this.responsive,
    this.borderRadius = 10.0, // Valeur par défaut des coins arrondis
    this.padding, // Utilise EdgeInsets.symmetric par défaut si non spécifié
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        minimumSize: Size(responsive.wp(40), responsive.hp(6)),
      ),
      onPressed: () {
        // Action pour le bouton Connexion
      },
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: responsive.fontSize(0.045),
        ),
      ),
    );
  }
}
