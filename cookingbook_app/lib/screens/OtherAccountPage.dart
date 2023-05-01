import 'dart:async';

import 'package:cookingbook_app/screens/FavoritePage.dart';
import 'package:cookingbook_app/screens/Home.dart';
import 'package:flutter/material.dart';
import '../Utils/color.dart';
import '../models/Profile.dart';
import '../models/Recette.dart';
import '../screens2/detailespage.dart';
import '../services/Authentication.dart';
import '../services/FireStoreService.dart';

import '../utiles/explorecart2.dart';
import 'DetailRecette.dart';
import 'SearchScreen.dart';

class OtherAccountPage extends StatefulWidget {
  String idProfile;

  OtherAccountPage({required this.idProfile});

  @override
  _OtherAccountPageState createState() => _OtherAccountPageState();
}

class _OtherAccountPageState extends State<OtherAccountPage> {
  Authentication auth = Authentication();
  StreamSubscription<List<Recette>>? _sesRecetteRealTimeSubscription;
  StreamSubscription<Profile>? _myProfileRealTimeSubscription;
  StreamSubscription<Profile>? _sonProfileSubscription;
  late List<Recette> sesRecetteRealTime;
  late Profile myProfileRealTime;
  late Profile sonProfile;
  late String sonIdProfile;

  int nbRecettes = 0;
  int allLikeRealTime = 0;
  late int allLikes;

  FirestoreService firestoreService = FirestoreService();

  Future<void> getSesRecettesRealTime() async {
    Stream<List<Recette>> stream =
        firestoreService.getSesRecettesRealTime(sonIdProfile);
    _sesRecetteRealTimeSubscription = stream.listen((List<Recette> recettes) {
      setState(() {
        sesRecetteRealTime = recettes;
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

  Future<void> getSonProfileRealTime() async {
    Stream<Profile> stream =
        firestoreService.getProfileByIdRealTime(sonIdProfile);
    _sonProfileSubscription = stream.listen((Profile profile) {
      setState(() {
        sonProfile = profile;
      });
    });
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

  int computeTotalLikes(List<Recette> recettes) {
    int totalLikes = 0;
    for (Recette recette in recettes) {
      totalLikes += recette.likeur.length;
    }
    return totalLikes;
  }

  @override
  void initState() {
    sesRecetteRealTime = [];
    sonIdProfile = widget.idProfile;
    getSonProfileRealTime();
    getSesRecettesRealTime();
    getMyProfileRealTime();
    firestoreService
        .getSesRecettesRealTime(sonIdProfile)
        .listen((List<Recette> recettes) {
      setState(() {
        nbRecettes = recettes.length;
        allLikeRealTime = computeTotalLikes(recettes);
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    allLikeRealTime = 0;
    nbRecettes = 0;
    _myProfileRealTimeSubscription?.cancel();
    _sesRecetteRealTimeSubscription?.cancel();
    _sonProfileSubscription?.cancel();
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
    return sesRecetteRealTime.isEmpty
        ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 150),
            child: Center(
              child: Text(
                "Vous n'avez encore aucune recette",
                style: TextStyle(fontSize: 15),
              ),
            ),
          )
        : Flexible(
            flex: 1,
            child: StreamBuilder<List<Recette>>(
                stream: firestoreService
                    .getSesRecettesRealTime(sonProfile.idProfile),
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
                          const Divider(color: Colors.black26),
                      itemCount: recettes.length,
                      itemBuilder: (context, index) {
                        Recette recette = recettes[index];
                        return ExploreCart2(recette: recette, profile: myProfileRealTime, onTap: () =>_showRecetteDetails(recette),);
                      });
                        // return Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: ListTile(
                        //     leading: AspectRatio(
                        //       aspectRatio: 1.5,
                        //       child: Image.network(
                        //         recette.image,
                        //         width: 50,
                        //         height: 50,
                        //         fit: BoxFit.cover,
                        //       ),
                        //     ),
                        //     title: Text(
                        //       "${recette.nom} - ${recette.categorie}",
                        //       style:
                        //           const TextStyle(fontWeight: FontWeight.bold),
                        //     ),
                        //     subtitle: Column(
                        //       mainAxisAlignment: MainAxisAlignment.end,
                        //       crossAxisAlignment: CrossAxisAlignment.start,
                        //       children: [
                        //         Text("Portions : ${recette.nbPersonne}"),
                        //         Text(
                        //             "Temps de cuisson : ${(recette.tempsPreparation).inHours}h ${(recette.tempsPreparation).inMinutes % 60}min"),
                        //       ],
                        //     ),
                        //     onTap: () {
                        //       Navigator.of(context).push(
                        //         MaterialPageRoute(
                        //           builder: (context) => DetailRecette(
                        //             profile: myProfileRealTime,
                        //             recette: recette,
                        //           ),
                        //         ),
                        //       );
                        //     },
                        //   ),
                        // );
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
                Navigator.push(
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
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            color: Colors.transparent,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.soup_kitchen_outlined,
                            color: Colors.orange,
                          ),
                          Text(
                            sonProfile.pseudo,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24),
                          ),
                        ],
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
                "Ses recettes",
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
          _buildUserRecettes()
        ],
      ),
    );
  }
}


