import 'package:cookingbook_app/screens/DetailRecetteDemo.dart';
import 'package:flutter/material.dart';

import '../models/Recette.dart';
import '../services/Authentication.dart';
import '../services/FireStoreService.dart';

class AllRecetteDemo extends StatefulWidget {
  const AllRecetteDemo({super.key});

  @override
  _AllRecetteDemoState createState() => _AllRecetteDemoState();
}

class _AllRecetteDemoState extends State<AllRecetteDemo> {
  Authentication auth = Authentication();
  FirestoreService firestoreService = FirestoreService();
  late List<Recette> allMyRecettes = []; // Define the variable here

  @override
  void initState() {
    super.initState();
    fetchData();
    //getMyRecettes();
  }

  void refreshData() {
    setState(() {
      fetchData();
    });
  }

  Future<void> fetchData() async {
    await getMyRecettes();
  }

  // 2 methodes pour call des methodes dans FireStoreService

  Future<void> getMyRecettes() async {
    List<Recette> recettes = await firestoreService.getRecettes();
    setState(() {
      allMyRecettes = recettes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("All Recette"),
      ),
      body: allMyRecettes == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: allMyRecettes.length,
              itemBuilder: (BuildContext context, int index) {
                Recette recette = allMyRecettes[index];

                return ListTile(
                  leading: SizedBox(
                    width: 100.0,
                    child: Image.network(
                      recette.image,
                      width: 100,
                    ),
                  ),
                  title: Text(recette.nom),
                  subtitle: Text(recette.categorie),
                  onTap: () {
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) => DetailRecetteDemo(profile: thi,
                    //         recette: recette, refreshAllRecette: refreshData),
                    //   ),
                    // );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // IconButton(
                      //   icon: Icon(Icons.edit),
                      //   onPressed: () {
                      //     Navigator.of(context).push(
                      //       MaterialPageRoute(
                      //         builder: (context) =>
                      //             DetailRecetteDemo(recette: recette),
                      //       ),
                      //     );
                      //   },
                      // ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirmation'),
                                content: Text(
                                    'Are you sure you want to delete this recette?'),
                                actions: [
                                  TextButton(
                                    child: Text('Cancel'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                  TextButton(
                                    child: Text('Confirm'),
                                    onPressed: () async {
                                      firestoreService
                                          .deleteRecette(recette.idRecette);
                                      setState(() {
                                        allMyRecettes.removeAt(index);
                                      });
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
