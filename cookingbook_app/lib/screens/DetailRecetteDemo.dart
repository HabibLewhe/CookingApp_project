import 'dart:io';

import 'package:cookingbook_app/Utils/Utils.dart';
import 'package:cookingbook_app/models/Commentaire.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/Profile.dart';
import '../models/Recette.dart';
import '../services/FireStoreService.dart';

class DetailRecetteDemo extends StatefulWidget {
  final Profile profile;
  final Recette recette;
  final Function? refreshAllRecette;

  const DetailRecetteDemo(
      {Key? key,
      required this.profile,
      required this.recette,
      this.refreshAllRecette = null})
      : super(key: key); // Modify this line

  @override
  _DetailRecetteDemoState createState() => _DetailRecetteDemoState();
}

class _DetailRecetteDemoState extends State<DetailRecetteDemo> {
  User? user;
  FirestoreService firestoreService = FirestoreService();
  Utils utils = Utils();
  List<Commentaire> listCommentaire = [];

  final _formKey = GlobalKey<FormState>();
  final _formKeyCmt = GlobalKey<FormState>();
  List uniteDeMesures = ["Kg", "g", "L", "mL"];
  List listeCategories = ["Entree", "Plat", "Dessert", "Boisson"];
  TextEditingController _nomController = TextEditingController();
  TextEditingController _instructionController = TextEditingController();
  TextEditingController _tempsPreparationController = TextEditingController();
  TextEditingController _nbPersonneController = TextEditingController();
  TextEditingController _imageController = TextEditingController();
  TextEditingController _commentaireController = TextEditingController();

  List<String> _nomIngre = [];
  List<String> _quantiteIngre = [];
  List<String> _uniteIngre = [];
  List<TextEditingController> _nomIngredientsController = [];
  List<TextEditingController> _quantiteController = [];
  List<String> _unite = [];

  //new valeur
  late Recette recette;
  // late String _nom;
  late String _instruction;
  late Duration _tempsPreparation;
  late String _nbPersonne;
  late String _categorie = widget.recette.categorie;
  late Map<String, String> _ingredients = {};
  late String _imageFilePath;
  File? _imageFile;
  bool _isEditMode = false;
  bool _isExpanded = false;
  bool _isLiked = false;

  Future<void> updateRecette(
    String idRecette, {
    String? image,
    String? categorie,
    String? nom,
    Duration? tempsPreparation,
    String? nbPersonne,
    String? instruction,
    Map<String, String>? ingredients,
  }) async {
    await firestoreService.updateRecette(idRecette,
        image: image,
        categorie: categorie,
        nom: nom,
        tempsPreparation: tempsPreparation,
        nbPersonne: nbPersonne,
        instruction: instruction,
        ingredients: ingredients);
  }

  void _extractIngredients(Map<String, String> ingredients) {
    ingredients.forEach((nom, quantiteUnite) {
      var quantiteUniteSplit = quantiteUnite.split(' ');
      var quantite = quantiteUniteSplit[0];
      var unite = quantiteUniteSplit[1];

      _nomIngredientsController.add(TextEditingController(text: nom));
      _quantiteController.add(TextEditingController(text: quantite));
      _unite.add(unite);
    });
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
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
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void removeField(int i) {
    setState(() {
      _nomIngredientsController[i].clear();
      _nomIngredientsController[i].dispose();
      _nomIngredientsController.removeAt(i);

      _quantiteController[i].clear();
      _quantiteController[i].dispose();
      _quantiteController.removeAt(i);
      _unite.removeAt(i);
    });
  }

  void addField() {
    setState(() {
      _nomIngredientsController.add(TextEditingController());

      _quantiteController.add(TextEditingController());

      _unite.add(uniteDeMesures[0]);
    });
  }

  Map<String, String> ingredientsListBuilder() {
    String quantite;
    String nomIngredient;
    Map<String, String> ingredientsList = {};
    for (int i = 0; i < _nomIngredientsController.length; i++) {
      quantite = "${_quantiteController[i].text} ${_unite[i]}";

      nomIngredient = _nomIngredientsController[i].text;

      ingredientsList.putIfAbsent(nomIngredient, () => quantite);
    }
    return ingredientsList;
  }

  Future<void> getCommentaire() async {
    List<Commentaire> commentaires =
        await firestoreService.getCommentaire(widget.recette.idRecette);
    setState(() {
      listCommentaire = commentaires;
    });
  }

  @override
  void initState() {
    super.initState();
    recette = widget.recette;
    _nomController = TextEditingController(text: recette.nom);
    _tempsPreparationController = TextEditingController(
        text: recette.tempsPreparation.inMinutes.toString());
    _instructionController = TextEditingController(text: recette.instruction);
    _nbPersonneController = TextEditingController(text: recette.nbPersonne);
    _commentaireController = TextEditingController();

    _ingredients = recette.ingredients;

    _extractIngredients(_ingredients);

    _categorie = recette.categorie;
    // _isLiked = widget.profile.hasLikedContent(recette);
    _isLiked = widget.profile.hasLikedContent(recette);
    getCommentaire();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isEditMode ? "Modify The Information" : recette.nom),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25.0),
            child: GestureDetector(
                onTap: () {
                  _toggleEditMode();

                  // TODO : traiter appuie sur bouton edit
                },
                child: widget.profile.idProfile == recette.idUser
                    ? _isEditMode
                        ? MaterialButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                var ingredientsList = ingredientsListBuilder();
                                String newImage = '';
                                if (_imageFile == null) {
                                  newImage = recette.image;
                                } else {
                                  newImage = await firestoreService
                                      .uploadImageToFirebase(
                                          _imageFile!, 'recetteImages');
                                }

                                updateRecette(
                                  recette.idRecette,
                                  image: newImage,
                                  categorie: _categorie,
                                  nom: _nomController.text,
                                  tempsPreparation: Duration(
                                      minutes: int.parse(
                                          _tempsPreparationController.text)),
                                  nbPersonne: _nbPersonneController.text,
                                  instruction: _instructionController.text,
                                  ingredients: ingredientsList,
                                ).whenComplete(() async {
                                  await widget.refreshAllRecette!();
                                  Navigator.pop(context);
                                });
                              }
                            },
                            child: Icon(
                              Icons.done,
                              size: 30,
                            ),
                          )
                        : Icon(
                            Icons.edit,
                            size: 30,
                          )
                    : Container()),
          ),
        ],
      ),
      body: _isEditMode ? _buildEditMode() : _buildDetailMode(),
    );
  }

  Widget _buildEditMode() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                //image
                child: Stack(children: [
                  AspectRatio(
                    aspectRatio: 1 /
                        0.5, // You can adjust this aspect ratio based on your needs
                    child: _imageFile == null
                        ? Image.network(recette.image)
                        : Image.file(_imageFile!),
                  ),
                  MaterialButton(
                    child: Icon(Icons.picture_in_picture),
                    onPressed: () {
                      //edit image
                      _showImageSourceSelection(context);
                    },
                  )
                ]),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.grey[300],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(children: [
                Text(
                  "nom: ",
                  style: TextStyle(fontSize: 20),
                ),
                Container(
                  //nom
                  width: 250,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.grey[300],
                  ),
                  child: TextFormField(
                    controller: _nomController,
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
              ]),
              SizedBox(
                height: 10,
              ),
              Row(children: [
                Text(
                  "categorie: ",
                  style: TextStyle(fontSize: 20),
                ),
                Container(
                  //categorie
                  width: 250,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.grey[300],
                  ),
                  child: DropdownButton(
                    hint: Text(
                        'Select a category'), // Text to display when no category is selected
                    value: _categorie, // The selected category
                    onChanged: (value) {
                      setState(() {
                        _categorie = value as String;
                        print("_categorie : $_categorie");
                      });
                    },
                    items: listeCategories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                  ),
                ),
              ]),
              SizedBox(
                height: 10,
              ),
              Row(children: [
                Text(
                  "Temps Preparation: ",
                  style: TextStyle(fontSize: 20),
                ),
                Container(
                  //temps
                  width: 150,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.grey[300],
                  ),
                  child: TextFormField(
                    controller: _tempsPreparationController,
                    style: TextStyle(fontSize: 15, color: Colors.black),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter temps";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _tempsPreparation =
                        Duration(minutes: int.parse(value!)),
                    onFieldSubmitted: (value) {
                      setState(() {
                        _tempsPreparation = Duration(minutes: int.parse(value));
                      });
                    },
                  ),
                ),
              ]),
              SizedBox(
                height: 10,
              ),
              Row(children: [
                Text(
                  "nb personne: ",
                  style: TextStyle(fontSize: 20),
                ),
                Container(
                  //temps
                  width: 150,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.grey[300],
                  ),
                  child: TextFormField(
                    controller: _nbPersonneController,
                    style: TextStyle(fontSize: 15, color: Colors.black),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter nb personne";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _nbPersonne = value!,
                    onFieldSubmitted: (value) {
                      setState(() {
                        _nbPersonne = value;

                        print("this is _nbPersonne $_nbPersonne");
                      });
                    },
                  ),
                ),
              ]),
              SizedBox(
                height: 10,
              ),
              Column(
                children: [
                  for (int i = 0; i < _nomIngredientsController.length; i++)
                    ListTile(
                      leading: GestureDetector(
                        onTap: () {
                          removeField(i);
                        },
                        child:
                            const Icon(Icons.remove_circle, color: Colors.red),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              decoration: const InputDecoration(
                                hintText: 'nom',
                              ),
                              controller: _nomIngredientsController[i],
                              validator: (value) {
                                if (value!.isEmpty) {
                                  print("value nom la day isEmpty : ${value}");
                                  return 'Veuillez entrer un nom';
                                }
                                // else if (value!.isNotEmpty) {
                                //   setState(() {
                                //     print("value nom la day : ${value}");
                                //     _nomIngre[i] = value;
                                //   });
                                // }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              decoration: const InputDecoration(
                                hintText: 'quantite',
                              ),
                              controller: _quantiteController[i],
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Veuillez entrer une quantité';
                                }
                                return null;
                              },
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField(
                              value: _unite[i],
                              items: uniteDeMesures
                                  .map((e) => DropdownMenuItem(
                                      value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  _unite[i] = val as String;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
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
              SizedBox(
                height: 10,
              ),
              Row(children: [
                Text(
                  "instruction: ",
                  style: TextStyle(fontSize: 20),
                ),
                Container(
                  //instruction
                  width: 150,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.grey[300],
                  ),
                  child: TextFormField(
                    controller: _instructionController,
                    style: TextStyle(fontSize: 15, color: Colors.black),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter ingredients";
                      }
                      return null;
                    },
                    onSaved: (value) => _instruction = value!,
                    onFieldSubmitted: (value) {
                      setState(() {
                        _instruction = value;

                        print("this is _instruction $_instruction");
                      });
                    },
                  ),
                ),
              ]),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailMode() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 16,
            ),
            Container(
              //image
              child: AspectRatio(
                aspectRatio: 1 /
                    0.5, // You can adjust this aspect ratio based on your needs
                child: Image.network(recette.image),
              ),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.blue[300],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: _toggleExpansion,
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                  ),
                  Text('detail la recette'),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 24,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Visibility(
              visible: _isExpanded,
              child: Column(children: [
                Container(
                  //nom
                  width: 250,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.grey[300],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  //categorie
                  width: 250,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.grey[300],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  //temps
                  width: 250,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.grey[300],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  //nb personne
                  width: 250,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.grey[300],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  //ingredients
                  width: 250,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.grey[300],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  //instruction
                  width: 250,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.grey[300],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
              ]),
            ),
            Row(
              children: [
                MaterialButton(
                    onPressed: () {
                      if (_isLiked) {
                        //deja like et re-cliquer pour action unlike

                        setState(() {
                          _isLiked = !_isLiked;
                        });
                        firestoreService.updateRecetteLikeur(
                            recette.idRecette, false);
                        //unlike : flag = false
                        firestoreService.updateProfileLikedRecette(
                            widget.profile.idProfile, recette.idRecette, false);
                        // widget.profile.unlikeContent(recette);
                        //update firebase
                        //update recette.likeur
                        //update profile.likedRecette
                      } else {
                        // action LIKE

                        setState(() {
                          _isLiked = !_isLiked;
                        });
                        firestoreService.updateRecetteLikeur(
                            recette.idRecette, true);
                        // like : flag action = true
                        firestoreService.updateProfileLikedRecette(
                            widget.profile.idProfile, recette.idRecette, true);
                      }
                    },
                    child: _isLiked
                        ? Icon(
                            Icons.favorite,
                            color: Colors.red,
                          )
                        : Icon(Icons.favorite_border)),
                SizedBox(
                  width: 8,
                ),
                GestureDetector(
                  onTap: () {
                    // load full commentaire
                    print(
                        "this is size of commentaire: ${listCommentaire.length}");
                  },
                  child: Icon(Icons.comment_outlined),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Container(
              //Commentaire
              width: 450,
              height: 45,
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(5)),
              child: Row(children: [
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Form(
                    key: _formKeyCmt,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'ajouter un commentaire ...',
                      ),
                      controller: _commentaireController,
                      style: TextStyle(fontSize: 14, color: Colors.black),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "please enter a comment";
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (_formKeyCmt.currentState!.validate()) {
                      Commentaire cmt = Commentaire(
                          idUser: widget.profile.idProfile,
                          content: _commentaireController.text,
                          idRecette: widget.recette.idRecette,
                          idCommentaire: '',
                          dateTime: DateTime.now());
                      firestoreService.addCommentaire(cmt, recette);
                      print(
                          "this is _commentaireController================== ${_commentaireController.text}");
                    }
                  },
                  child: Icon(
                    Icons.send,
                    size: 25,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(
                  width: 16,
                )
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
