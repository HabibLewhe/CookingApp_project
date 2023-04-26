import 'package:cookingbook_app/screens/FavoritePage.dart';
import 'package:cookingbook_app/screens/Home.dart';
import 'package:flutter/material.dart';
import '../models/Profile.dart';
import '../models/Recette.dart';
import '../services/Authentication.dart';
import '../services/FireStoreService.dart';

import 'AddNewRecette.dart';
import 'DetailRecette.dart';
import 'EditProfile.dart';

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

  int nbRecettes = 0;
  int allLikeRealTime = 0;
  late int allLikes;

  FirestoreService firestoreService = FirestoreService();

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
    getMyProfileRealTime();
    firestoreService.getRecettesRealTime().listen((List<Recette> recettes) {
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
    return myRecetteRealTime.isNotEmpty
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
                                color: Colors.deepOrange,
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
        backgroundColor: Colors.deepOrange,
        title: const Text("Mon compte"),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                auth.onLogout(widget.signInMethod);
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
                                  color: Colors.deepOrange,
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
                      color: Colors.deepOrange,
                      width: 1,
                    ),
                    bottom: BorderSide(
                      color: Colors.deepOrange,
                      width: 1,
                    ))),
            child: const Center(
              child: Text(
                "Mes recettes",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange),
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          _buildUserRecettes()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.deepOrange,
        selectedFontSize: 19,
        unselectedFontSize: 19,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: GestureDetector(
              child: const Icon(Icons.home),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                );
              },
            ),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              child: const Icon(Icons.search),
              onTap: () {
                /*Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ResearchPage()),
                );*/
              },
            ),
            label: 'Recherche',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              child: const Icon(Icons.favorite_border),
              onTap: () {
                if (myProfileRealTime != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FavoritePage(
                              profile: myProfileRealTime,
                            )),
                  );
                }
              },
            ),
            label: 'Favoris',
          ),
        ],
        iconSize: 40,
        elevation: 5,
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            final route = MaterialPageRoute(
              builder: (context) => const AddNewRecette(),
            );
            Navigator.push(context, route);
          },
          backgroundColor: Colors.deepOrange,
          label: const Text('ajouter une recette ')),
    );
  }
}
