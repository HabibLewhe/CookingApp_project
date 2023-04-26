import 'package:cookingbook_app/services/FireStoreService.dart';
import 'package:flutter/material.dart';

import '../models/Recette.dart';

class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  late List<Recette> myRecette;
  FirestoreService firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    myRecette = [];
    getMyRecettes();
  }

  Future<void> getMyRecettes() async {
    Stream<List<Recette>> stream = firestoreService.getRecettesRealTime();
    stream.listen((List<Recette> recettes) {
      setState(() {
        myRecette = recettes;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('My Recipes'),
      ),
      body: StreamBuilder<List<Recette>>(
        stream: firestoreService.getRecettesRealTime(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          List<Recette> recettes = snapshot.data!;

          return ListView.builder(
            itemCount: recettes.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(recettes[index].nom),
                subtitle: Text(recettes[index].categorie),
                // add more widgets to display other data
              );
            },
          );
        },
      ),
    );
  }
}
