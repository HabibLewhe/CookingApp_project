import 'dart:io';

import 'package:cookingbook_app/Utils/Utils.dart';
import 'package:cookingbook_app/services/FireStoreService.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/Profile.dart';

class EditProfile extends StatefulWidget {
  final Profile profile;

  const EditProfile({Key? key, required this.profile}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController _pseudoController = TextEditingController();
  FirestoreService firestoreService = FirestoreService();
  Utils utils = Utils();

  final _formKey = GlobalKey<FormState>();
  File? _imageProfile;

  Future<void> _pickImageFromWeb() async {
    final ImagePicker _picked = ImagePicker();
    final image = await _picked.pickImage(source: ImageSource.gallery);
    if (image != null) {
      var selected = File(image.path);
      setState(() {
        _imageProfile = selected;
      });
    } else {
      const text = "Vous n'avez ajouter aucune photo ";
      final snackBar = SnackBar(
        content: const Text(text),
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () {},
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _showImageSourceSelection(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choisir une photo'),
                  onTap: () {
                    _selectImage(ImageSource.gallery);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Prendre une photo'),
                  onTap: () {
                    _selectImage(ImageSource.camera);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        });
  }

  void _selectImage(ImageSource source) async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    late final status;

    if (source == ImageSource.camera) {
      // Demande la permission d'accès à la caméra
      status = await Permission.camera.request();

      if (status != PermissionStatus.granted) {
        // Si la permission est refusée, affichez un message d'erreur
        utils.showCameraPermissionDeniedDialog(context);
        return;
      }
    } else if (source == ImageSource.gallery) {
      // Demande la permission d'accès au stockage
      if (androidInfo.version.sdkInt <= 32) {
        status = await Permission.storage.request();
      } else {
        status = await Permission.photos.request();
      }

      if (status != PermissionStatus.granted) {
        // Si la permission est refusée, affichez un message d'erreur
        utils.showStoragePermissionDeniedDialog(context);
        return;
      }
    }
    final pickedFile =
        await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _imageProfile = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    _pseudoController = TextEditingController(text: widget.profile.pseudo);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text("Modifier Profile"),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25.0),
            child: GestureDetector(
              onTap: () async {
                if (_formKey.currentState!.validate()) {
                  String newImage = '';
                  if (_imageProfile == null) {
                    print("Notre image est nulle, on garde l'ancienne");
                    newImage = widget.profile.imageAvatar;
                  } else {
                    print("Notre image n'est pas nulle, on la change");
                    newImage = await firestoreService.uploadImageToFirebase(
                        _imageProfile!, 'profileImages');
                    print("Affichons le chemin de notre image $newImage");
                  }

                  print("On la balance sur firebase");
                  print("widget.profile.idProfiel ${widget.profile.idProfile}");
                  firestoreService
                      .updateProfile(
                    widget.profile.idProfile,
                    imageAvatar: newImage,
                    pseudo: _pseudoController.text,
                  )
                      .whenComplete(() async {
                    Navigator.pop(context);
                  });
                }
              },
              child: const Icon(
                Icons.done,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              const SizedBox(
                height: 16,
              ),
              GestureDetector(
                onTap: () {
                  if (kIsWeb) {
                    _pickImageFromWeb();
                  } else {
                    _showImageSourceSelection(context);
                  }
                },
                child: Center(
                  child: Column(children: [
                    _imageProfile == null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(26),
                            child: Image.network(
                              widget.profile.imageAvatar,
                              width: 300,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(26),
                            child: Image.file(
                              _imageProfile!,
                              width: 300,
                              height: 200,
                              fit: BoxFit.cover,
                            )
                            /*Image.network(
                              _imageProfile!.path,
                              width: 300,
                              height: 200,
                              fit: BoxFit.cover,
                            ),*/
                            ),
                    const SizedBox(
                      height: 16,
                    ),
                    RichText(
                        text: const TextSpan(
                      text: "Modifier",
                      style: TextStyle(
                          //decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange),
                    )),
                  ]),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _pseudoController,
                      style: const TextStyle(fontSize: 20, color: Colors.black),
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.deepOrange),
                          borderRadius: BorderRadius.circular(5.5),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.deepOrange,
                          ),
                        ),
                        labelStyle: const TextStyle(color: Colors.deepOrange),
                        labelText: 'Nouveau pseudo',
                        prefixIcon:
                            const Icon(Icons.person, color: Colors.deepOrange),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Veuillez entrer votre nom d'utilisateur";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              )
            ]),
          ),
        ),
      ),
    );
  }
}
