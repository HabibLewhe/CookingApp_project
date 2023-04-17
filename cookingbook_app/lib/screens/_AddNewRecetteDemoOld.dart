import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/Recette.dart';

class AddNewRecetteDemoOld extends StatefulWidget {
  @override
  _AddNewRecetteDemoState createState() => _AddNewRecetteDemoState();
}

class _AddNewRecetteDemoState extends State<AddNewRecetteDemoOld> {
  List<String> _selectedUnits = [];

  File? _imageFile;
  TextEditingController nomRecetteController = TextEditingController();
  TextEditingController nbPersonneController = TextEditingController();
  TextEditingController instructionController = TextEditingController();
  TextEditingController tempsPreparationController = TextEditingController();
  TextEditingController ingredientsController = TextEditingController();
  String? _selectedUnit;
  List<Map<String, String>> _ingredients = [];

  final List<String> _units = ['Spoon', 'Gram', 'Kg', 'Lb'];
  void _addIngredient() {
    setState(() {
      _ingredients.add({'name': '', 'unit': ''});
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

// Update the name of an ingredient
  void _updateIngredientName(int index, String name) {
    setState(() {
      _ingredients[index]['name'] = name;
    });
  }

// Update the unit of an ingredient
  void _updateIngredientUnit(int index, String unit) {
    setState(() {
      _ingredients[index]['unit'] = unit;
    });
  }

  // Widget _buildIngredientRow({int? index}) {
  //   final ingredient = _ingredients[index!];
  //   final TextEditingController nameController =
  //       TextEditingController(text: ingredient['name']);
  //   final unitItems = _units.map((unit) {
  //     return DropdownMenuItem<String>(
  //       value: unit,
  //       child: Text(unit),
  //     );
  //   }).toList();
  //   return Row(
  //     children: [
  //       Expanded(
  //         flex: 2,
  //         child: TextFormField(
  //           controller: nameController,
  //           decoration: InputDecoration(
  //             labelText: 'Name',
  //           ),
  //           onChanged: (value) {
  //             setState(() {
  //               ingredient['name'] = value;
  //             });
  //           },
  //         ),
  //       ),
  //       SizedBox(width: 16),
  //       Expanded(
  //         child: DropdownButtonFormField<String>(
  //           value: ingredient['unit'],
  //           items: unitItems,
  //           decoration: InputDecoration(
  //             labelText: 'Unit',
  //           ),
  //           onChanged: (value) {
  //             setState(() {
  //               ingredient['unit'] = value!;
  //             });
  //           },
  //         ),
  //       ),
  //       IconButton(
  //         icon: Icon(Icons.remove),
  //         onPressed: () {
  //           setState(() {
  //             _ingredients.removeAt(index);
  //           });
  //         },
  //       ),
  //     ],
  //   );
  // }

  Widget _buildIngredientRow({int? index}) {
    final nameController =
        TextEditingController(); // create a new controller for the name
    final unitController = TextEditingController();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Ingrédients'),
            maxLines: null,
          ),
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: unitController.text.isNotEmpty
                ? unitController.text
                : _units.first,
            decoration: InputDecoration(
              labelText: 'Unit',
              border: OutlineInputBorder(),
            ),
            items: _units.map((unit) {
              return DropdownMenuItem<String>(
                value: unit,
                child: Text(unit),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedUnits[index!] = value!;
                // unitController.text = value!;
              });
            },
          ),
        ),
        // Expanded(
        //   child: DropdownButtonFormField<String>(
        //     value: _selectedUnit ??
        //         _units.first, // initialize to first item in list
        //     decoration: InputDecoration(
        //       labelText: 'Unit',
        //       border: OutlineInputBorder(),
        //     ),
        //     items: _units.map((unit) {
        //       return DropdownMenuItem<String>(
        //         value: unit,
        //         child: Text(unit),
        //       );
        //     }).toList(),
        //     onChanged: (value) {
        //       setState(() {
        //         _selectedUnit = value;
        //       });
        //     },
        //   ),
        // ),
      ],
    );
  }

  // Widget _buildIngredientRow(int index) {
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Expanded(
  //         child: TextField(
  //           decoration: InputDecoration(labelText: 'Ingredient'),
  //           onChanged: (value) => _updateIngredientName(index, value),
  //         ),
  //       ),
  //       SizedBox(width: 16.0),
  //       Expanded(
  //         child: DropdownButtonFormField<String>(
  //           value: _ingredients[index]['unit'],
  //           decoration: InputDecoration(
  //             labelText: 'Unit',
  //             border: OutlineInputBorder(),
  //           ),
  //           items: _units.map((unit) {
  //             return DropdownMenuItem<String>(
  //               value: unit,
  //               child: Text(unit),
  //             );
  //           }).toList(),
  //           onChanged: (value) => _updateIngredientUnit(index, value!),
  //         ),
  //       ),
  //       IconButton(
  //         icon: Icon(Icons.remove),
  //         onPressed: () => _removeIngredient(index),
  //       ),
  //     ],
  //   );
  // }

// Build the list of ingredients
  List<Widget> _buildIngredientsList() {
    return _ingredients
        .asMap()
        .entries
        .map((entry) => _buildIngredientRow(index: entry.key))
        .toList();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource
          .gallery, // You can also use ImageSource.camera to take a picture using the camera
    );
    setState(() {
      _imageFile = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appBarHeight = AppBar().preferredSize.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Add new recette'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Select Image'),
            ),
            if (_imageFile != null)
              Image.file(
                _imageFile!, width: 200, // Change this to the desired width
                height: 200, // Change this to the desired height
                fit: BoxFit.cover,
              ),
            SizedBox(height: 16.0),
            TextField(
              controller: nomRecetteController,
              decoration: InputDecoration(labelText: 'Nom de la recette'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: nbPersonneController,
              decoration: InputDecoration(labelText: 'Nombre de personnes'),
              keyboardType: TextInputType.number,
            ),
            Column(
              children: [
                ..._buildIngredientsList(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: ingredientsController,
                                  decoration:
                                      InputDecoration(labelText: 'Ingrédients'),
                                  maxLines: null,
                                ),
                              ),
                              SizedBox(width: 16.0),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedUnit,
                                  decoration: InputDecoration(
                                    labelText: 'Unit',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _units.map((unit) {
                                    return DropdownMenuItem<String>(
                                      value: unit,
                                      child: Text(unit),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedUnit = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          _ingredients.add({
                            'name': ingredientsController.text,
                            'unit': _selectedUnit ?? '',
                          });

                          // ingredientsController = TextEditingController();
                          // _selectedUnit = _units.first;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     Expanded(
            //       child: TextField(
            //         controller: ingredientsController,
            //         decoration: InputDecoration(labelText: 'Ingrédients'),
            //         maxLines: null,
            //       ),
            //     ),
            //     SizedBox(width: 16.0),
            //     Expanded(
            //       child: DropdownButtonFormField<String>(
            //         value: _selectedUnit,
            //         decoration: InputDecoration(
            //           labelText: 'Unit',
            //           border: OutlineInputBorder(),
            //         ),
            //         items: _units.map((unit) {
            //           return DropdownMenuItem<String>(
            //             value: unit,
            //             child: Text(unit),
            //           );
            //         }).toList(),
            //         onChanged: (value) {
            //           setState(() {
            //             _selectedUnit = value;
            //           });
            //         },
            //       ),
            //     ),
            //   ],
            // ),

            // DropdownButtonFormField<String>(
            //   value: _selectedUnit,
            //   decoration: InputDecoration(
            //     labelText: 'Unit',
            //     contentPadding: EdgeInsets.only(right: 16.0),
            //     border: OutlineInputBorder(),
            //   ),
            //   items: _units.map((unit) {
            //     return DropdownMenuItem<String>(
            //       value: unit,
            //       child: Text(unit),
            //     );
            //   }).toList(),
            //   onChanged: (value) {
            //     setState(() {
            //       _selectedUnit = value;
            //     });
            //   },
            // ),
            // SizedBox(height: 16.0),
            // TextField(
            //   controller: ingredientsController,
            //   decoration: InputDecoration(labelText: 'Ingrédients'),
            //   maxLines: null,
            // ),
            SizedBox(height: 16.0),
            TextField(
              controller: tempsPreparationController,
              decoration: InputDecoration(labelText: 'Temps de préparation'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: instructionController,
              decoration: InputDecoration(labelText: 'Instructions'),
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }
}
