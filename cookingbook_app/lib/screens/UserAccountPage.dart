import 'dart:async';

import 'package:cookingbook_app/Utils/color.dart';
import 'package:cookingbook_app/screens/FavoritePage.dart';
import 'package:cookingbook_app/screens/Home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../models/Profile.dart';
import '../models/Recette.dart';
import '../screens2/detailespage.dart';
import '../services/Authentication.dart';
import '../services/FireStoreService.dart';

import '../utiles/explorecart2.dart';
import 'AddNewRecette.dart';
import 'DetailRecette.dart';
import 'EditProfile.dart';
import 'SearchScreen.dart';

class UserAccountPage extends StatefulWidget {
  @override
  _UserAccountPageState createState() => _UserAccountPageState();
}

class _UserAccountPageState extends State<UserAccountPage> {
  Authentication auth = Authentication();
  late List<Recette> myRecetteRealTime;
  late Profile myProfileRealTime;
  StreamSubscription<Profile>? _myProfileRealTimeSubscription;
  StreamSubscription<List<Recette>>? _myRecetteRealTimeSubscription;

  int nbRecettes = 0;
  int allLikeRealTime = 0;

  FirestoreService firestoreService = FirestoreService();

  Future<void> getMyRecettesRealTime() async {
    Stream<List<Recette>> stream = firestoreService.getRecettesRealTime();
    _myRecetteRealTimeSubscription = stream.listen((List<Recette> recettes) {
      setState(() {
        myRecetteRealTime = recettes;
      });
    });
  }

  Future<void> getMyProfileRealTime() async {
    Stream<Profile> stream = firestoreService.getCurrentUserProfileRealTime();
    _myProfileRealTimeSubscription = stream.listen((Profile profile) {
      setState(() {
        myProfileRealTime = profile;
      });
    });
  }

  int computeTotalLikes(List<Recette> recettes) {
    int totalLikes = 0;
    for (Recette recette in recettes) {
      totalLikes += recette.likeur.length;
    }
    return totalLikes;
  }

  @override
  void initState() {
    myRecetteRealTime = [];
    getMyRecettesRealTime();
    getMyProfileRealTime();
    firestoreService.getRecettesRealTime().listen((List<Recette> recettes) {
      setState(() {
        nbRecettes = recettes.length;
        allLikeRealTime = computeTotalLikes(recettes);
      });
    });

    super.initState();
  }

  void _showRecetteDetails(Recette recette) async {
    // Navigate to the DetailRecetteDemo screen with the ID of the selected recette
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Detailspage(
          recette: recette,
          profile: myProfileRealTime,
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _myProfileRealTimeSubscription?.cancel();
    _myRecetteRealTimeSubscription?.cancel();
    allLikeRealTime = 0;
    nbRecettes = 0;
    myProfileRealTime;
    super.dispose();
  }

  Widget buildDivider() => const SizedBox(
        height: 24,
        child: VerticalDivider(
          color: Colors.black26,
        ),
      );

  Widget buildButton(BuildContext context, String value, String text) =>
      MaterialButton(
        padding: const EdgeInsets.symmetric(vertical: 4),
        onPressed: () {
          print("value : $value");
        },
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(height: 2),
            Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );

  Widget _buildUserRecettes() {
     if(myRecetteRealTime.isEmpty)
       return  Padding(
            padding: EdgeInsets.symmetric(vertical: 120),
            child: Column(
              children: [
                SvgPicture.asset(
                  "assets/icons/empty.svg",
                  height: MediaQuery.of(context).size.height * 0.3,
                  color: primary,
                ),
                 Text(
                  "Aucune recette trouvée",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );

    return Flexible(
            flex: 1,
            child: StreamBuilder<List<Recette>>(
                stream: firestoreService.getRecettesRealTime(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  List<Recette> recettes = snapshot.data!;
                  return ListView.separated(
                      separatorBuilder: (context, index) =>
                           Divider(color: Colors.black26),
                      itemCount: recettes.length,
                      itemBuilder: (context, index) {
                        Recette recette = recettes[index];
                        return ExploreCart2(recette: recette, profile: myProfileRealTime, onTap: () =>_showRecetteDetails(recette),);


                          Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: AspectRatio(
                              aspectRatio: 1.5,
                              child: Image.network(
                                recette.image,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              "${recette.nom} - ${recette.categorie}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Portions : ${recette.nbPersonne}"),
                                Text(
                                    "Temps de cuisson : ${(recette.tempsPreparation).inHours}h ${(recette.tempsPreparation).inMinutes % 60}min"),
                              ],
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => DetailRecette(
                                    profile: myProfileRealTime,
                                    recette: recette,
                                  ),
                                ),
                              );
                            },
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: primary,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Confirmation'),
                                      content: const Text(
                                          'Are you sure you want to delete this recette?'),
                                      actions: [
                                        TextButton(
                                          child: const Text('Cancel'),
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                        TextButton(
                                          child: const Text('Confirm'),
                                          onPressed: () async {
                                            firestoreService.deleteRecette(
                                                recette.idRecette);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      });
                }),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text("Mon compte"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                auth.onLogout();
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (ctx) => Home()));
              },
              child: const Icon(
                Icons.logout,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          StreamBuilder<Profile>(
            stream: firestoreService.getCurrentUserProfileRealTime(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              Profile profile = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Column(children: [
                      Stack(children: [
                        ClipOval(
                          child: Material(
                            color: Colors.transparent,
                            child: Ink.image(
                              image: NetworkImage(profile.imageAvatar),
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                              child: InkWell(onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (ctx) => EditProfile(
                                              profile: myProfileRealTime,
                                            )));
                              }),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: ClipOval(
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              color: Colors.white,
                              child: ClipOval(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  color: primary,
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      Text(
                        profile.pseudo,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ]),
                    const SizedBox(
                      width: 24,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        buildButton(context, nbRecettes.toString(), 'Recettes'),
                        buildDivider(),
                        buildButton(
                            context, allLikeRealTime.toString(), 'Likes'),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 50,
            decoration: BoxDecoration(
                color: Colors.orange[50],
                border: const Border(
                    top: BorderSide(
                      color: primary,
                      width: 1,
                    ),
                    bottom: BorderSide(
                      color: primary,
                      width: 1,
                    ))),
            child: const Center(
              child: Text(
                "Mes recettes",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primary),
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          _buildUserRecettes(),

        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            final route = MaterialPageRoute(
              builder: (context) => const AddNewRecette(),
            );
            Navigator.push(context, route);
          },
          backgroundColor: primary,
          icon: const Icon(Icons.add),
          label: const Text('ajouter une recette ')),
    );
  }
}
