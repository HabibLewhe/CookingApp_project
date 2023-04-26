import 'package:cookingbook_app/screens/FavoritePage.dart';
import 'package:cookingbook_app/screens/StartingScreen.dart';
import 'package:flutter/material.dart';
import '../models/Profile.dart';
import '../models/Recette.dart';
import '../services/Authentication.dart';
import '../services/FireStoreService.dart';

import 'AddNewRecetteDemo.dart';
import 'DetailRecette.dart';
import 'EditProfileDemo.dart';
import 'TestRealTime.dart';

class UserAccountPage extends StatefulWidget {
  final String signInMethod;

  UserAccountPage({required this.signInMethod});

  @override
  _UserAccountPageState createState() => _UserAccountPageState();
}

class _UserAccountPageState extends State<UserAccountPage> {
  Authentication auth = Authentication();
  late List<Recette> myRecetteRealTime;
  late Profile myProfileRealTime;

  late List<Recette> allMyRecettes = [];
  int nbRecettes = 0;
  int allLikeRealTime = 0;
  late int allLikes;

  late Profile? thisProfile;
  FirestoreService firestoreService = FirestoreService();
  late bool _isLiked;

  Future<void> getCurrentUserProfile() async {
    Profile profile = await firestoreService.getCurrentUserProfile();
    setState(() {
      thisProfile = profile;
    });
  }

  Future<void> getMyRecettesRealTime() async {
    Stream<List<Recette>> stream = firestoreService.getRecettesRealTime();
    stream.listen((List<Recette> recettes) {
      setState(() {
        myRecetteRealTime = recettes;
      });
    });
  }

  Future<void> getMyProfileRealTime() async {
    Stream<Profile> stream = firestoreService.getCurrentUserProfileRealTime();
    stream.listen((Profile profile) {
      setState(() {
        myProfileRealTime = profile;
      });
    });
  }

  Future<void> getMyRecettes() async {
    List<Recette> recettes = await firestoreService.getRecettes();

    int serverLikes = 0;
    setState(() {
      allMyRecettes = recettes;
      for (Recette recette in allMyRecettes) {
        serverLikes += recette.likeur.length;
      }
      allLikes = serverLikes;
    });
    // print("allLikesin getMyrecettes: $allLikes");
    // print(
    //     "thisProfile!.likedRecette.length ${thisProfile!.likedRecette.length}");
  }

  void updateLikesProfileRecette(
      int newAllLikes, Recette recette, String idProfile, bool flag) {
    if (flag) {
      //action like
      setState(() {
        allLikes = newAllLikes;
        thisProfile!.likeContent(recette);
        recette.likeContent(idProfile);
        _isLiked = thisProfile!.hasLikedContent(recette);
      });
    } else {
      setState(() {
        allLikes = newAllLikes;
        thisProfile!.unlikeContent(recette);
        recette.unlikeContent(idProfile);
        _isLiked = thisProfile!.hasLikedContent(recette);
      });
      //action Dislike
    }
  }

  @override
  void dispose() {
    allLikeRealTime = 0;
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

  @override
  void initState() {
    myRecetteRealTime = [];

    getMyRecettes();
    getMyProfileRealTime();
    firestoreService.getRecettesRealTime().listen((List<Recette> recettes) {
      setState(() {
        nbRecettes = recettes.length;
        allLikeRealTime = computeTotalLikes(recettes);
      });
    });

    fetchDataProfile();
    fetchDataMyRecettes();

    super.initState();
  }

  int computeTotalLikes(List<Recette> recettes) {
    int totalLikes = 0;
    for (Recette recette in recettes) {
      totalLikes += recette.likeur.length;
    }
    return totalLikes;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          //backgroundColor: Colors.transparent,
          //title: Center(child: Text(thisProfile!.pseudo,)),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (ctx) => MyScreen()));
                },
                child: const Icon(
                  Icons.flag,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: GestureDetector(
                onTap: () {
                  auth.onLogout(widget.signInMethod);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (ctx) => HomeScreenDemo()));
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
                  return CircularProgressIndicator();
                }
                Profile profile = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(16.0),
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
                                width: 100,
                                height: 100,
                                child: InkWell(onTap: () {
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (ctx) => EditProfileDemo(
                                  //             profile: thisProfile!,
                                  //             refreshDataHomePage:
                                  //                 refreshDataProfile)));
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
                                    color: Colors.blue,
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
                              fontWeight: FontWeight.bold, fontSize: 24),
                        ),
                      ]),
                      const SizedBox(
                        width: 24,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          buildButton(
                              context, nbRecettes.toString(), 'Recettes'),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(180, 30),
                  ),
                  onPressed: () {
                    final route = MaterialPageRoute(
                      builder: (context) => AddNewRecetteDemo(),
                    );
                    Navigator.push(context, route);
                  },
                  child: const Text(
                    'Ajouter une recette',
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(180, 30),
                  ),
                  onPressed: () {
                    // final route = MaterialPageRoute(
                    //     builder: (context) =>
                    //         FavoritePage(profile: thisProfile!));
                    // Navigator.push(context, route);
                  },
                  child: const Text(
                    'Mes favoris',
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
            Flexible(
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
                            const Divider(color: Colors.black26),
                        itemCount: recettes.length,
                        itemBuilder: (context, index) {
                          Recette recette = recettes[index];
                          return Padding(
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
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
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
                                  color: Colors.blue,
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
                            ),
                          );
                        });
                  }),
            ),
          ],
        )

        //SingleChildScrollView(
        // child: Column(children: [
        //   FutureBuilder<Profile>(
        //     future: firestoreService.getCurrentUserProfile(),
        //     builder: (context, snapshot) {
        //       if (snapshot.connectionState == ConnectionState.waiting) {
        //         return Center(
        //           child: Container(),
        //         );
        //       } else if (snapshot.hasError) {
        //         return const Center(child: Text('Error fetching profile data'));
        //       } else {
        //         thisProfile = snapshot.data!;
        //         return Padding(
        //           padding: const EdgeInsets.all(16.0),
        //           child: Row(
        //             children: [
        //               Column(children: [
        //                 Stack(children: [
        //                   ClipOval(
        //                     child: Material(
        //                       color: Colors.transparent,
        //                       child: Ink.image(
        //                         image: NetworkImage(thisProfile!.imageAvatar),
        //                         fit: BoxFit.cover,
        //                         width: 100,
        //                         height: 100,
        //                         child: InkWell(onTap: () {
        //                           Navigator.push(
        //                               context,
        //                               MaterialPageRoute(
        //                                   builder: (ctx) => EditProfileDemo(
        //                                       profile: thisProfile!,
        //                                       refreshDataHomePage:
        //                                           refreshDataProfile)));
        //                         }),
        //                       ),
        //                     ),
        //                   ),
        //                   Positioned(
        //                     bottom: 0,
        //                     right: 0,
        //                     child: ClipOval(
        //                       child: Container(
        //                         padding: const EdgeInsets.all(3),
        //                         color: Colors.white,
        //                         child: ClipOval(
        //                           child: Container(
        //                             padding: const EdgeInsets.all(8),
        //                             color: Colors.blue,
        //                             child: const Icon(
        //                               Icons.edit,
        //                               color: Colors.white,
        //                               size: 15,
        //                             ),
        //                           ),
        //                         ),
        //                       ),
        //                     ),
        //                   ),
        //                 ]),
        //                 const SizedBox(height: 8),
        //                 Text(
        //                   thisProfile!.pseudo,
        //                   style: const TextStyle(
        //                       fontWeight: FontWeight.bold, fontSize: 24),
        //                 ),
        //               ]),
        //               const SizedBox(
        //                 width: 24,
        //               ),
        //               Row(
        //                 mainAxisAlignment: MainAxisAlignment.center,
        //                 children: <Widget>[
        //                   buildButton(context, allMyRecettes.length.toString(),
        //                       'Recettes'),
        //                   buildDivider(),
        //                   buildButtonClone(
        //                       context, allLikes.toString(), 'Likes'),
        //                 ],
        //               ),
        //             ],
        //           ),
        //         );
        //       }
        //     },
        //   ),
        //   Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //     children: [
        //       ElevatedButton(
        //         style: ElevatedButton.styleFrom(
        //           minimumSize: const Size(180, 30),
        //         ),
        //         onPressed: () {
        //           final route = MaterialPageRoute(
        //             builder: (context) => AddNewRecetteDemo(
        //               refreshDataAddNewRecette: refreshDataMyRecettes,
        //             ),
        //           );
        //           Navigator.push(context, route);
        //         },
        //         child: const Text(
        //           'Ajouter une recette',
        //           style: TextStyle(fontWeight: FontWeight.w400),
        //         ),
        //       ),
        //       ElevatedButton(
        //         style: ElevatedButton.styleFrom(
        //           minimumSize: const Size(180, 30),
        //         ),
        //         onPressed: () {
        //           final route = MaterialPageRoute(
        //               builder: (context) =>
        //                   FavoritePage(profile: thisProfile!));
        //           Navigator.push(context, route);
        //         },
        //         child: const Text(
        //           'Mes favoris',
        //           style: TextStyle(fontWeight: FontWeight.w400),
        //         ),
        //       ),
        //     ],
        //   ),
        //   const SizedBox(height: 24),
        //   SizedBox(
        //     height: 400,
        //     child: allMyRecettes == null
        //         ? const Center(
        //             child: CircularProgressIndicator(),
        //           )
        //         : ListView.separated(
        //             separatorBuilder: (context, index) =>
        //                 const Divider(color: Colors.black26),
        //             itemCount: allMyRecettes.length,
        //             itemBuilder: (BuildContext context, int index) {
        //               Recette recette = allMyRecettes[index];

        //               return Padding(
        //                 padding: const EdgeInsets.all(8.0),
        //                 child: ListTile(
        //                   leading: AspectRatio(
        //                     aspectRatio: 1.5,
        //                     child: Image.network(
        //                       recette.image,
        //                       width: 100,
        //                       height: 100,
        //                       fit: BoxFit.cover,
        //                     ),
        //                   ),
        //                   title: Text(
        //                     "${recette.nom} - ${recette.categorie}",
        //                     style: const TextStyle(fontWeight: FontWeight.bold),
        //                   ),
        //                   subtitle: Column(
        //                     mainAxisAlignment: MainAxisAlignment.end,
        //                     crossAxisAlignment: CrossAxisAlignment.start,
        //                     children: [
        //                       Text("Portions : ${recette.nbPersonne}"),
        //                       Text(
        //                           "Temps de cuisson : ${(recette.tempsPreparation).inHours}h ${(recette.tempsPreparation).inMinutes % 60}min"),
        //                     ],
        //                   ),
        //                   onTap: () {
        //                     _isLiked = thisProfile!.hasLikedContent(recette);
        //                     Navigator.of(context).push(
        //                       MaterialPageRoute(
        //                         builder: (context) => DetailRecette(
        //                             getliked: allLikes,
        //                             recette: recette,
        //                             refreshAllRecette: refreshDataMyRecettes,
        //                             profile: thisProfile!,
        //                             isLiked: _isLiked,
        //                             updateLikesProfileRecette:
        //                                 updateLikesProfileRecette),
        //                       ),
        //                     );
        //                   },
        //                   trailing: IconButton(
        //                     icon: const Icon(
        //                       Icons.delete,
        //                       color: Colors.blue,
        //                     ),
        //                     onPressed: () {
        //                       showDialog(
        //                         context: context,
        //                         builder: (BuildContext context) {
        //                           return AlertDialog(
        //                             title: const Text('Confirmation'),
        //                             content: const Text(
        //                                 'Are you sure you want to delete this recette?'),
        //                             actions: [
        //                               TextButton(
        //                                 child: const Text('Cancel'),
        //                                 onPressed: () =>
        //                                     Navigator.of(context).pop(),
        //                               ),
        //                               TextButton(
        //                                 child: const Text('Confirm'),
        //                                 onPressed: () async {
        //                                   firestoreService
        //                                       .deleteRecette(recette.idRecette);
        //                                   setState(() {
        //                                     allMyRecettes.removeAt(index);
        //                                   });
        //                                   Navigator.of(context).pop();
        //                                 },
        //                               ),
        //                             ],
        //                           );
        //                         },
        //                       );
        //                     },
        //                   ),
        //                 ),
        //               );
        //             },
        //           ),
        //   ),
        // ]),
        //),
        );
  }
}
