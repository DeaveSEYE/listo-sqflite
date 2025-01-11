import 'dart:io';

import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:listo/core/api/service.dart';
import 'package:listo/core/theme/colors.dart';
import 'package:listo/features/profile/ui/profile.dart';
import 'package:listo/core/utils/responsive.dart';
import 'package:listo/partials/notification.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditUser extends StatefulWidget {
  const EditUser({super.key});

  @override
  State<EditUser> createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  final apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _identifiantController = TextEditingController();
  final TextEditingController _ancienPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _newPasswordConfirmController =
      TextEditingController();

  File? _selectedImage;
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _edit(String selecteur) async {
    if (_formKey.currentState!.validate()) {
      try {
        if (selecteur == "profile") {
          final name = _nameController.text.trim();
          final identifiant = _identifiantController.text.trim();

          // Prepare profile update payload
          final requestData = {
            'name': name,
            'identifiant': identifiant,
          };

          // await apiService.updateUserProfile(requestData);
          NotificationHelper.showFlushbar(
            context: context,
            message: "Profil mis à jour avec succès",
            type: NotificationType.success,
          );
        }

        if (selecteur == "credentials") {
          final oldPassword = _ancienPasswordController.text.trim();
          final newPassword = _newPasswordController.text.trim();

          // Password hashing
          final hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());

          // Prepare credentials update payload
          final requestData = {
            'oldPassword': oldPassword,
            'newPassword': hashedPassword,
          };

          // await apiService.updateUserCredentials(requestData);
          NotificationHelper.showFlushbar(
            context: context,
            message: "Mot de passe mis à jour avec succès",
            type: NotificationType.success,
          );
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

  Future<void> _loadImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('profileImage');
    if (imagePath != null) {
      setState(() {
        _selectedImage = File(imagePath);
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File? croppedImage = await _cropImage(File(image.path));
      if (croppedImage != null) {
        setState(() {
          _selectedImage = croppedImage;
        });
        // Stocker l'image localement
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('profileImage', croppedImage.path);
      }
    }
  }

  Future<File?> _cropImage(File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recadrer l\'image',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Recadrer l\'image',
        ),
      ],
    );
    if (croppedFile != null) {
      return File(croppedFile.path);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final bool isCompact = responsive.height < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Retour',
          style: TextStyle(color: Colors.grey),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : null,
                  child: _selectedImage == null
                      ? const Icon(Icons.person, size: 50, color: Colors.grey)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      padding: const EdgeInsets.all(5),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Prenom & Nom',
                      filled: true,
                      fillColor: AppColors.inputFill,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre nom complet';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _identifiantController,
                    decoration: InputDecoration(
                      labelText: 'Email OU Tel',
                      filled: true,
                      fillColor: AppColors.inputFill,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le champ identifiant est vide';
                      }
                      final emailRegex = RegExp(
                        r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                      );
                      if (!emailRegex.hasMatch(value) &&
                          !RegExp(r'^\d{8,}$').hasMatch(value)) {
                        return 'Identifiant invalide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _ancienPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Ancien Mot de Passe',
                      filled: true,
                      fillColor: AppColors.inputFill,
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Nouveau Mot de Passe',
                      filled: true,
                      fillColor: AppColors.inputFill,
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _newPasswordConfirmController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirmer Nouveau Mot de Passe',
                      filled: true,
                      fillColor: AppColors.inputFill,
                    ),
                    validator: (value) {
                      if (value != _newPasswordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: () => _edit("credentials"),
                    child: const Text('Mettre à jour'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
