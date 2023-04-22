import 'package:cookingbook_app/screens/AllRecetteDemo.dart';
import 'package:cookingbook_app/screens/HomeScreenDemo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cookingbook_app/screens/LoginScreenDemo.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../models/Profile.dart';
import '../models/Recette.dart';
import '../services/Authentication.dart';
import '../services/FireStoreService.dart';
import 'package:uuid/uuid.dart';

import 'AddNewRecetteDemo.dart';
import 'DetailRecetteDemo.dart';
import 'EditProfileDemo.dart';

class LoginSuccessTest extends StatefulWidget {
  final String signInMethod;

  LoginSuccessTest({required this.signInMethod});
  @override
  _LoginSuccessTestState createState() => _LoginSuccessTestState();
}

class _LoginSuccessTestState extends State<LoginSuccessTest> {
  Authentication auth = Authentication();
  late List<Recette> allMyRecettes = [];

  late Profile? thisProfile;
  FirestoreService firestoreService = FirestoreService();
  Future<void> getCurrentUserProfile() async {
    Profile profile = await firestoreService.getCurrentUserProfile();
    setState(() {
      thisProfile = profile;
    });
  }

  Future<void> fetchDataProfile() async {
    await getCurrentUserProfile();
  }

  Future<void> fetchDataMyRecettes() async {
    await getMyRecettes();
  }

  void refreshDataProfile() {
    setState(() {
      fetchDataProfile();
    });
  }

  void refreshDataMyRecettes() {
    setState(() {
      fetchDataMyRecettes();
    });
  }

  Future<void> getMyRecettes() async {
    List<Recette> recettes = await firestoreService.getRecettes();
    setState(() {
      allMyRecettes = recettes;
    });
  }

  @override
  void initState() {
    fetchDataProfile();
    fetchDataMyRecettes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Home page"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                auth.onLogout(widget.signInMethod);
                Navigator.push(context,
                    MaterialPageRoute(builder: (ctx) => HomeScreenDemo()));
              },
              child: Icon(Icons.logout),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Row(
            children: [
              FutureBuilder<Profile>(
                future: firestoreService.getCurrentUserProfile(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Container(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error fetching profile data'));
                  } else {
                    thisProfile = snapshot.data!;
                    return Column(children: [
                      Container(
                        child: MaterialButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (ctx) => EditProfileDemo(
                                        profile: thisProfile!,
                                        refreshDataHomePage:
                                            refreshDataProfile)));
                          },
                          child: SizedBox(
                            height: 100,
                            width: 100,
                            child: Image.network(thisProfile!.imageAvatar),
                          ),
                        ),
                      ),
                      Text(thisProfile!.pseudo)
                    ]);
                  }
                },
              ),
            ],
          ),
          Row(children: [
            SizedBox(
              width: 50,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black, // Set the border color here
                  width: 2, // Set the border width here
                ),
                borderRadius:
                    BorderRadius.circular(8), // Set the border radius here
              ),
              child: MaterialButton(
                child: Text(
                  "add new recette",
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (ctx) => AddNewRecetteDemo(
                                refreshDataAddNewRecette: refreshDataMyRecettes,
                              )));
                },
              ),
            ),
            SizedBox(
              width: 50,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black, // Set the border color here
                  width: 2, // Set the border width here
                ),
                borderRadius:
                    BorderRadius.circular(8), // Set the border radius here
              ),
              child: MaterialButton(
                child: Text(
                  "my favoris",
                ),
                onPressed: () {
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (ctx) => AddNewRecetteDemo()));
                },
              ),
            ),
          ]),
          SizedBox(
            height: 10,
          ),
          // Container(
          //   decoration: BoxDecoration(
          //     border: Border.all(
          //       color: Colors.black, // Set the border color here
          //       width: 2, // Set the border width here
          //     ),
          //     borderRadius:
          //         BorderRadius.circular(8), // Set the border radius here
          //   ),
          //   child: MaterialButton(
          //     child: Text(
          //       "my recette",
          //     ),
          //     onPressed: () {
          //       Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //               builder: (ctx) => const AllRecetteDemo()));
          //     },
          //   ),
          // ),
          SizedBox(
            height: 20,
          ),
          Container(
            height: 400,
            child: allMyRecettes == null
                ? Center(
                    child: CircularProgressIndicator(),
                  )
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
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DetailRecetteDemo(
                                  recette: recette,
                                  refreshAllRecette: refreshDataMyRecettes),
                            ),
                          );
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                                            firestoreService.deleteRecette(
                                                recette.idRecette);
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
          ),
        ]),
      ),
    );
  }
}
