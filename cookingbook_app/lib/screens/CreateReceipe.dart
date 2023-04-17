import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/Recette.dart';

class CreateRecetteForm extends StatefulWidget {
  @override
  _CreateRecetteFormState createState() => _CreateRecetteFormState();
}

class _CreateRecetteFormState extends State<CreateRecetteForm> {
  final _formKey = GlobalKey<FormState>();
  final _recette = Recette(
    idRecette: 0,
    image: "",
    nom: "",
    tempsPreparation: Duration.zero,
    nbPersonne: 0,
    instruction: "",
    ingredients: <String, String>{},
  );

  final _nomController = TextEditingController();
  final _tempsPreparationController = TextEditingController();
  final _nbPersonneController = TextEditingController();
  final _instructionController = TextEditingController();
  final List<TextEditingController> _nomIngredientsController = [];
  final List<TextEditingController> _quantiteController = [];
  final List<DropdownButtonFormField> _uniteController = [];

  //List<TextEditingController> listIngredientController = [];
  List uniteDeMesures = ["Kg", "g", "L", "mL"];
  String? selectedVal = "";

  @override
  void initState() {
    // TODO: implement initState
    selectedVal = uniteDeMesures[0];
  }

  void addField() {
    setState(() {
      _nomIngredientsController.add(TextEditingController());
      _quantiteController.add(TextEditingController());
    });
  }

  void removeField(int i) {
    setState(() {
      _nomIngredientsController[i].clear();
      _nomIngredientsController[i].dispose();
      _nomIngredientsController.removeAt(i);

      _quantiteController[i].clear();
      _quantiteController[i].dispose();
      _quantiteController.removeAt(i);
    });
  }

  File? _imageFile;

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

  Future<void> _showCameraPermissionDeniedDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Camera permission denied'),
          content:
              const Text('Please grant camera permission to use the camera.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showStoragePermissionDeniedDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Storage permission denied'),
          content: const Text(
              'Please grant storage permission to access the photo library.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _selectImage(ImageSource source) async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    late final status;

    if (source == ImageSource.camera) {
      // Demande la permission d'accès à la caméra
      status = await Permission.camera.request();

      if (status != PermissionStatus.granted) {
        // Si la permission est refusée, affichez un message d'erreur
        _showCameraPermissionDeniedDialog();
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
        _showStoragePermissionDeniedDialog();
        return;
      }
    }

    // Charge l'image depuis la galerie ou la caméra
    final pickedFile =
        await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _recette.image = pickedFile.path;
        print("Votre image : ${pickedFile.path}");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créer une recette'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Insérer l'image de la recette
              Container(
                child: Center(
                  child: _imageFile == null
                      ? Column(
                          children: [
                            TextButton(
                              onPressed: () =>
                                  _showImageSourceSelection(context),
                              child: const Icon(
                                Icons.image,
                                color: Colors.blue,
                              ),
                            ),
                            const Text('No image selected'),
                          ],
                        )
                      : Image.file(
                          _imageFile!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.fill,
                        ),
                ),
              ),
              const SizedBox(height: 16.0),

              // le nom de la recette
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                    labelText: 'Nom de la  cette ',
                    prefixIcon: Icon(Icons.fastfood),
                    border: OutlineInputBorder()),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
                //onSaved: (val) => setState(() => _recette.nom = val!),
              ),
              const SizedBox(height: 16.0),

              // le temps de préparation de la recette
              TextFormField(
                controller: _tempsPreparationController,
                decoration: const InputDecoration(
                    labelText: 'Temps de préparation (minutes)',
                    prefixIcon: Icon(Icons.timelapse),
                    border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer un temps de préparation';
                  }
                  return null;
                },
                /*onSaved: (val) => setState(() => _recette.tempsPreparation =
                    Duration(minutes: int.parse(val!))),*/
              ),
              const SizedBox(height: 16.0),

              // le nombre de personne pour la recette
              TextFormField(
                controller: _nbPersonneController,
                decoration: const InputDecoration(
                    labelText: 'Nombre de personnes',
                    prefixIcon: Icon(Icons.people),
                    border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer un nombre de personnes';
                  }
                  return null;
                },
                /*onSaved: (val) =>
                    setState(() => _recette.nbPersonne = int.parse(val!)),*/
              ),
              const SizedBox(height: 16.0),

              // la liste des ingrédients pour la recette
              Column(
                children: [
                  for (int i = 0; i < _nomIngredientsController.length; i++)
                    ListTile(
                      leading: GestureDetector(
                        onTap: () {
                          removeField(i);
                        },
                        child: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                        ),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // nom de l'ingrédient
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: _nomIngredientsController[i],
                              decoration: const InputDecoration(
                                hintText: 'nom',
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Veuillez entrer un nom';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          // quantité
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: _quantiteController[i],
                              decoration:
                                  const InputDecoration(hintText: 'quantite'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Veuillez entrer une quantité';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),

                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField(
                              value: selectedVal,
                              items: uniteDeMesures
                                  .map((e) => DropdownMenuItem(
                                      value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  selectedVal = val as String;
                                });
                              },
                            ),
                          )
                        ],
                      ),
                    )
                  /*ListView(children: [

                    ]),*/
                ],
              ),

              // ajouter un ingrédient
              GestureDetector(
                onTap: () {
                  addField();
                },
                child: const ListTile(
                  leading: Icon(
                    Icons.add_circle,
                    color: Colors.blue,
                  ),
                  title: Text(
                    "ajouter un ingrédient",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),

              // le mode de préparation de la recette
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _instructionController,
                decoration: const InputDecoration(
                    labelText: 'Mode préparatoire',
                    prefixIcon: Icon(Icons.text_snippet),
                    border: OutlineInputBorder()),
                maxLines: 5,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer des instructions';
                  }
                  return null;
                },
                //onSaved: (val) => setState(() => _recette.instruction = val!),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Créer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Created succesufully!"),
      ));

      _formKey.currentState!.save();

      // Enregistrer la recette dans la base de données ou effectuer toute autre action requise
      // Utilisez simplement _recette pour accéder aux attributs de la recette que l'utilisateur vient de créer
    }
  }
}