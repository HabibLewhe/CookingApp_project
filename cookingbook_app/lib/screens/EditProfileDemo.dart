import 'dart:io';

import 'package:cookingbook_app/Utils/Utils.dart';
import 'package:cookingbook_app/services/FireStoreService.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/Profile.dart';

class EditProfileDemo extends StatefulWidget {
  final Profile profile;
  final Function refreshDataHomePage;

  const EditProfileDemo(
      {Key? key, required this.profile, required this.refreshDataHomePage})
      : super(key: key);

  @override
  _EditProfileDemoState createState() => _EditProfileDemoState();
}

class _EditProfileDemoState extends State<EditProfileDemo> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Modifier Profile"),
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
                    await widget.refreshDataHomePage();
                    Navigator.pop(context);
                  });
                }
                //save done modifier
                // print("this is _pseudoController: ${_pseudoController.text}");
                // print("this is _imageProfile: ${_imageProfile!.path}");
              },
              child: Icon(
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
            padding: EdgeInsets.all(16),
            child: Column(children: [
              SizedBox(
                height: 16,
              ),
              Center(
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: Stack(children: [
                    _imageProfile == null
                        ? Image.network(widget.profile.imageAvatar)
                        : Image.file(_imageProfile!),
                    GestureDetector(
                      onTap: () {
                        _showImageSourceSelection(context);
                        //click to chose new image
                      },
                      child: Icon(Icons.photo),
                    ),
                  ]),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  Text("Pseudo Nom: "),
                  Container(
                    //nom
                    width: 250,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.grey[300],
                    ),
                    child: TextFormField(
                      controller: _pseudoController,
                      style: TextStyle(fontSize: 20, color: Colors.black),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter nom";
                        }
                        return null;
                      },
                      // onSaved: (value) => _nom = value!,
                      // onFieldSubmitted: (value) {
                      //   setState(() {
                      //     _nom = value;
                      //   });
                      // },
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
