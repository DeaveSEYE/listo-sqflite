import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:listo/core/global/global_state.dart';
import 'package:listo/core/local_notification.dart';
import 'package:listo/features/parametres/ui/compte.dart';
import 'package:listo/features/parametres/ui/preferences.dart';
import 'package:listo/features/profile/ui/edit_user.dart';
import 'package:listo/partials/main_scaffold.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadImage();
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
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

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
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil',
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
                  builder: (context) =>
                      const MainScaffold()), // Retour à la page principale
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            Text(
              GlobalState().user,
              style:
                  const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            Text(
              GlobalState().email,
              style: const TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
            const SizedBox(height: 20.0),
            // Boutons réduits avec texte en blanc
            _buildOptionButton(
              context,
              Icons.sync,
              'Compte',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Compte()),
                );
              },
            ),
            _buildOptionButton(
              context,
              Icons.notifications,
              'Préférences',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Preference()),
                );
              },
            ),
            _buildOptionButton(
              context,
              Icons.share,
              'Partager l\'application',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditUser()),
                );
              },
            ),
            const Spacer(),
            const Text('version 1.0.0', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: onTap, // Appel de la fonction de navigation
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(color: Colors.white), // Libellé en blanc
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          minimumSize: const Size(200, 40), // Réduction de la taille du bouton
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
      ),
    );
  }
}
