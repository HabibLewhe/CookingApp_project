import 'dart:io';

import 'package:cookingbook_app/Utils/Utils.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:readmore/readmore.dart';

import '../models/Profile.dart';
import '../models/Recette.dart';
import '../services/FireStoreService.dart';

class DetailRecette extends StatefulWidget {
  final Profile profile;
  final Recette recette;
  final Function refreshAllRecette;
  late int? getliked;

    DetailRecette(
      {Key? key,
      required this.profile,
      required this.recette,
      required this.refreshAllRecette,
        this.getliked})
      : super(key: key); // Modify this line

  @override
  _DetailRecetteState createState() => _DetailRecetteState();
}

class _DetailRecetteState extends State<DetailRecette> {
  FirestoreService firestoreService = FirestoreService();
  Utils utils = Utils();

  final _formKey = GlobalKey<FormState>();
  List uniteDeMesures = ["Kg", "g", "L", "mL"];
  List listeCategories = ["Entree", "Plat", "Dessert", "Boisson"];
  TextEditingController _nomController = TextEditingController();
  TextEditingController _instructionController = TextEditingController();
  TextEditingController _tempsPreparationController = TextEditingController();
  TextEditingController _nbPersonneController = TextEditingController();
  TextEditingController _imageController = TextEditingController();

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
  late bool _isLiked ;

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

  List<String> _extractIngredientsForDesciprion(
      Map<String, String> ingredients) {
    List<String> lesIngredient = [];
    int counter = 1;
    ingredients.forEach((nom, quantiteUnite) {
      lesIngredient.add("$counter. $nom $quantiteUnite");
    });
    return lesIngredient;
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

  @override
  void initState() {
    super.initState();
    recette = widget.recette;
    _nomController = TextEditingController(text: recette.nom);
    _tempsPreparationController = TextEditingController(
        text: recette.tempsPreparation.inMinutes.toString());
    _instructionController = TextEditingController(text: recette.instruction);
    _nbPersonneController = TextEditingController(text: recette.nbPersonne);

    _ingredients = recette.ingredients;

    _extractIngredientsForDesciprion(_ingredients);

    _extractIngredients(_ingredients);

    _categorie = recette.categorie;

    _isLiked = widget.profile.hasLikedContent(recette);
    print("_isLiked : ${_isLiked}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.deepOrange,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(
          child: Text(
            _isEditMode ? "Modifier" : recette.nom,
            style: const TextStyle(
              color: Colors.deepOrange,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25.0),
            child: GestureDetector(
              onTap: () {
                _toggleEditMode();

                // TODO : traiter appuie sur bouton edit
              },
              child: _isEditMode
                  ? IconButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          var ingredientsList = ingredientsListBuilder();
                          String newImage = '';
                          if (_imageFile == null) {
                            newImage = recette.image;
                          } else {
                            newImage =
                                await firestoreService.uploadImageToFirebase(
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
                            await widget.refreshAllRecette();
                            Navigator.pop(context);
                          });
                        }
                      },
                      color: Colors.deepOrange,
                      icon: const Icon(
                        Icons.done,
                        size: 30,
                      ),
                    )
                  : const Icon(
                      Icons.edit,
                      size: 30,
                      color: Colors.deepOrange,
                    ),
            ),
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
              GestureDetector(
                onTap: () {
                  _showImageSourceSelection(context);
                },
                child: Center(
                  child: Column(children: [
                    _imageFile == null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: Image.network(
                        recette.image,
                        width: 300,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    )
                        : Image.file(_imageFile!),
                    const SizedBox(
                      height: 16,
                    ),
                    RichText(
                        text: const TextSpan(
                          text: "Modifier",
                          style: TextStyle(
                            //decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        )),
                  ]),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              // le nom de la recette
              TextFormField(
                controller: _nomController,
                onTap: (){

                },
                decoration: const InputDecoration(
                    labelText: 'Nom de la  recette ',
                    prefixIcon: Icon(Icons.fastfood),
                    border: OutlineInputBorder()),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              DropdownButtonFormField(
                value: _categorie,
                // The selected category
                onChanged: (value) {
                  setState(() {
                    _categorie = value as String;
                  });
                },
                items: listeCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                dropdownColor: Colors.white,
                decoration: const InputDecoration(
                    labelText: "Catégorie de la recette",
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder()),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: _tempsPreparationController,
                decoration: const InputDecoration(
                    labelText: 'Temps de préparation (minutes)',
                    prefixIcon: Icon(Icons.timelapse),
                    border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onSaved: (value) =>
                    _tempsPreparation = Duration(minutes: int.parse(value!)),
                onFieldSubmitted: (value) {
                  setState(() {
                    _tempsPreparation = Duration(minutes: int.parse(value));
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer un temps de préparation';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: _nbPersonneController,
                decoration: const InputDecoration(
                    labelText: 'Nombre de personnes',
                    prefixIcon: Icon(Icons.people),
                    border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onSaved: (value) => _nbPersonne = value!,
                onFieldSubmitted: (value) {
                  setState(() {
                    _nbPersonne = value;

                    print("this is _nbPersonne $_nbPersonne");
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer un nombre de personnes';
                  }
                  return null;
                },
              ),
              const SizedBox(
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
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField(
                              value: _unite[i],
                              dropdownColor: Colors.white,
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
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: _instructionController,
                decoration: const InputDecoration(
                    labelText: 'Mode préparatoire',
                    prefixIcon: Icon(Icons.text_snippet),
                    border: OutlineInputBorder()),
                maxLines: 5,
                onSaved: (value) => _instruction = value!,
                onFieldSubmitted: (value) {
                  setState(() {
                    _instruction = value;
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer des instructions';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecetteDescription(Map<String, String> ingredients) {
    List<String> lesIngredients = _extractIngredientsForDesciprion(ingredients);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Liste des ingrédients :',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  lesIngredients.map((ingredient) => Text(ingredient)).toList(),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Mode de péparation :',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(recette.instruction),
          )
        ],
      ),
    );
  }

  Widget _buildDetailMode() {
    return ListView(children: [
      Container(
        height: 200, // ajuster la hauteur selon vos préférences
        child: Stack(
          children: [
            Center(
              child: Image.network(
                recette.image,
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                margin: const EdgeInsets.only(right: 16, bottom: 16),
                child: IconButton(
                  onPressed: () async {
                    // Ajouter ici la logique pour gérer les favoris

                    if (_isLiked) {
                      //deja like et re-cliquer pour action unlike
                      setState(() {
                        _isLiked = !_isLiked;
                        /*print(" 1 - Action dislike widget.getliked : ${widget.getliked}");
                        widget.getliked = widget.getliked! - 1 ;
                        print(" 2 - Action dislike widget.getliked : ${widget.getliked}");*/
                      });
                      firestoreService.updateRecetteLikeur(
                          recette.idRecette, false);
                      //unlike : flag = false
                      firestoreService.updateProfileLikedRecette(
                          widget.profile.idProfile, recette.idRecette, false);
                      widget.profile.unlikeContent(recette);
                      recette.unlikeContent(widget.profile.idProfile);

                      await widget.refreshAllRecette();
                    } else  {
                      // action LIKE

                      setState(() {
                        _isLiked = !_isLiked;
                        /*print(" 1 - Action like widget.getliked : ${widget.getliked}");
                        widget.getliked = widget.getliked! + 1 ;
                        print(" 2 - Action like widget.getliked : ${widget.getliked}");*/
                      });

                      firestoreService.updateRecetteLikeur(
                          recette.idRecette, true);
                      // like : flag action = true
                      firestoreService.updateProfileLikedRecette(
                          widget.profile.idProfile, recette.idRecette, true);
                      widget.profile.likeContent(recette);
                      recette.likeContent(widget.profile.idProfile);

                      await widget.refreshAllRecette();
                    }
                  },
                  icon: _isLiked
                      ? const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 30,
                        )
                      : const Icon(
                          Icons.favorite_border,
                          color: Colors.deepOrange,
                          size: 30,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(
        height: 8,
      ),
      Row(
        children: [
          IconButton(
            onPressed: () {
              // load full commentaire
            },
            icon: const Icon(Icons.comment_outlined),
          ),
          const Text("15 commentaires"),
        ],
      ),
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          "Description de la recette",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      _buildRecetteDescription(_ingredients),
    ]);
  }
}
