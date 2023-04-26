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

  const EditProfile(
      {Key? key, required this.profile})
      : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController _pseudoController = TextEditingController();
  FirestoreService firestoreService = FirestoreService();
  Utils utils = Utils();

  final _formKey = GlobalKey<FormState>();
  File? _imageProfile;

  void _showImageSourceSelection(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Photo Library'),
                  onTap: () {
                    _selectImage(ImageSource.gallery);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
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

        print("this is image path_____________ ${_imageProfile!.path}");
        // _recette.image = pickedFile.path;
        print("Votre image : ${pickedFile.path}");
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25.0),
            child: GestureDetector(
              onTap: () async {
                if (_formKey.currentState!.validate()) {
                  String newImage = '';
                  if (_imageProfile == null) {
                    newImage = widget.profile.imageAvatar;
                  } else {
                    newImage = await firestoreService.uploadImageToFirebase(
                        _imageProfile!, 'profileImages');
                  }
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
                  _showImageSourceSelection(context);
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
                        : Image.file(_imageProfile!),
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
                      decoration: const InputDecoration(
                        labelText: 'Nouveau pseudo',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter nom";
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
