import 'package:cookingbook_app/screens/DetailRecette.dart';
import 'package:cookingbook_app/screens/SearchScreen.dart';
import 'package:cookingbook_app/screens/UserAccountPage.dart';
import 'package:cookingbook_app/services/FireStoreService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../models/Profile.dart';
import '../models/Recette.dart';
import 'FavoritePage.dart';
import 'LoginScreenForm.dart';

class Home extends StatefulWidget {
  String? signInMethod;

  Home({super.key, this.signInMethod});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List categories = ["Entrée", "Plat", "Déssert", "Boisson"];
  User? user = FirebaseAuth.instance.currentUser;

  //bool isMounted=false;

  late List<Recette> allRecette;
  late List<Recette> recettesEntree = [];
  late List<Recette> recettesPlat = [];
  late List<Recette> recettesDessert = [];
  late List<Recette> recettesBoisson = [];

  FirestoreService firestoreService = FirestoreService();

  late Profile myProfileRealTime;

  Future<void> getMyProfileRealTime() async {
    Stream<Profile> stream = firestoreService.getCurrentUserProfileRealTime();
    stream.listen((Profile profile) {
      setState(() {
        myProfileRealTime = profile;
      });
    });
  }

  Future<void> getAllRecettesRealTime() async {
    Stream<List<Recette>> stream = firestoreService.getAllRecettesRealTime();
    stream.listen((List<Recette> recettes) {
      setState(() {
        allRecette = recettes;
        recettesEntree = allRecette
            .where((recette) => recette.categorie == "Entree")
            .toList();
        recettesPlat =
            allRecette.where((recette) => recette.categorie == "Plat").toList();
        recettesDessert = allRecette
            .where((recette) => recette.categorie == "Dessert")
            .toList();
        recettesBoisson = allRecette
            .where((recette) => recette.categorie == "Boisson")
            .toList();
      });
    });
  }

  @override
  void initState() {
    getAllRecettesRealTime();
    getMyProfileRealTime();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Cooking Book",
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 30,
            color: Colors.deepOrange,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              // Ouvrir le profil utilisateur
              print("user uid ${user?.uid}");
              if (user == null) {
                Navigator.of(context).pop();
                Navigator.push(
                    context,
                    PageTransition(
                        child: LoginScreenForm(),
                        type: PageTransitionType.rightToLeft,
                        childCurrent: widget,
                        duration: const Duration(milliseconds: 300)));
              } else {
                Navigator.push(
                    context,
                    //MaterialPageRoute(builder: (ctx) => UserAccountPage(signInMethod: 'emailAndPassword',)
                    PageTransition(
                        child: UserAccountPage(
                          signInMethod: 'emailAndPassword',
                        ),
                        type: PageTransitionType.rightToLeft,
                        childCurrent: widget,
                        duration: const Duration(milliseconds: 300)));
              }
            },
            icon: const Icon(Icons.person),
            color: Colors.deepOrange,
          ),
        ],
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Entrée',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
                color: Colors.deepOrange,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          SizedBox(
            height: 200.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recettesEntree.length,
              itemBuilder: (BuildContext context, int index) {
                print("user uid : ${user?.uid}");
                late bool _isLiked;
                if (user == null) {
                  _isLiked = false;
                } else {
                  _isLiked = recettesEntree[index].isLikedByUser(user!.uid);
                }
                return _buildEntreeItem(context, index, _isLiked);
              },
            ),
          ),
          const SizedBox(height: 16.0),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Plat',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
                color: Colors.deepOrange,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          SizedBox(
            height: 200.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recettesPlat.length,
              itemBuilder: (BuildContext context, int index) {
                late bool _isLiked;
                if (user == null) {
                  _isLiked = false;
                } else {
                  _isLiked = recettesPlat[index].isLikedByUser(user!.uid);
                }
                return _buildPlatItem(context, index, _isLiked);
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Dessert',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
                color: Colors.deepOrange,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          SizedBox(
            height: 200.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recettesDessert.length,
              itemBuilder: (BuildContext context, int index) {
                late bool _isLiked;
                if (user == null) {
                  _isLiked = false;
                } else {
                  _isLiked = recettesDessert[index].isLikedByUser(user!.uid);
                }
                return _buildDessertItem(context, index, _isLiked);
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Boisson',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
                color: Colors.deepOrange,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          SizedBox(
            height: 200.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recettesBoisson.length,
              itemBuilder: (BuildContext context, int index) {
                late bool isLiked;
                if (user == null) {
                  isLiked = false;
                } else {
                  isLiked = recettesBoisson[index].isLikedByUser(user!.uid);
                }
                return _buildBoissonItem(context, index, isLiked);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.deepOrange,
        selectedFontSize: 19,
        unselectedFontSize: 19,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
            ),
            label: 'Recherche',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () {
                if (myProfileRealTime != null) {
                  Navigator.pushReplacement(
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
    );
  }

  Widget _buildEntreeItem(BuildContext context, int index, bool isLiked) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailRecette(
              recette: recettesEntree[index],
              profile: myProfileRealTime,
            ),
          ),
        );
      },
      child: Container(
        width: 150.0,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Stack(
          children: [
            recettesEntree.isEmpty
                ? Container()
                : Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: NetworkImage(recettesEntree[index].image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
            Positioned(
              top: 8.0,
              right: 8.0,
              child: Container(
                width: 30.0,
                height: 30.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: MaterialButton(
                  padding: const EdgeInsets.all(0.0),
                  onPressed: () async {
                    if (user == null) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirmation"),
                            content: const Text(
                                "Voulez-vous être redirigé vers la page de connexion ?"),
                            actions: [
                              TextButton(
                                child: const Text("Non"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text("Oui"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          child: LoginScreenForm(),
                                          type: PageTransitionType.fade,
                                          childCurrent: widget,
                                          duration: const Duration(
                                              milliseconds: 300)));
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      Profile profile =
                          await firestoreService.getCurrentUserProfile();
                      if (isLiked) {
                        //action unlike
                        setState(() {
                          isLiked = !isLiked;
                        });
                        firestoreService.updateRecetteLikeur(
                            recettesEntree[index].idRecette, false);
                        //unlike : flag = false
                        firestoreService.updateProfileLikedRecette(
                            profile.idProfile,
                            recettesEntree[index].idRecette,
                            false);
                      } else {
                        //action like
                        setState(() {
                          isLiked = !isLiked;
                        });
                        firestoreService.updateRecetteLikeur(
                            recettesEntree[index].idRecette, true);
                        //unlike : flag = false
                        firestoreService.updateProfileLikedRecette(
                            profile.idProfile,
                            recettesEntree[index].idRecette,
                            true);
                      }
                    }
                  },
                  child: isLiked
                      ? const Icon(Icons.favorite, size: 20, color: Colors.red)
                      : const Icon(
                          Icons.favorite_border,
                          color: Colors.deepOrange,
                          size: 20,
                        ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.white.withOpacity(0.8),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recettesEntree[index].nom,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatItem(BuildContext context, int index, bool isLiked) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailRecette(
              recette: recettesPlat[index],
              profile: myProfileRealTime,
            ),
          ),
        );
      },
      child: Container(
        width: 150.0,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  image: NetworkImage(recettesPlat[index].image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 8.0,
              right: 8.0,
              child: Container(
                width: 30.0,
                height: 30.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: MaterialButton(
                  padding: const EdgeInsets.all(0.0),
                  onPressed: () async {
                    if (user == null) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirmation"),
                            content: const Text(
                                "Voulez-vous être redirigé vers la page de connexion ?"),
                            actions: [
                              TextButton(
                                child: const Text("Non"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text("Oui"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          child: LoginScreenForm(),
                                          type: PageTransitionType.fade,
                                          childCurrent: widget,
                                          duration: const Duration(
                                              milliseconds: 300)));
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      Profile profile =
                          await firestoreService.getCurrentUserProfile();
                      if (isLiked) {
                        //action unlike
                        setState(() {
                          isLiked = !isLiked;
                        });
                        firestoreService.updateRecetteLikeur(
                            recettesPlat[index].idRecette, false);
                        //unlike : flag = false
                        firestoreService.updateProfileLikedRecette(
                            profile.idProfile,
                            recettesPlat[index].idRecette,
                            false);
                      } else {
                        //action like
                        setState(() {
                          isLiked = !isLiked;
                        });
                        firestoreService.updateRecetteLikeur(
                            recettesPlat[index].idRecette, true);
                        //unlike : flag = false
                        firestoreService.updateProfileLikedRecette(
                            profile.idProfile,
                            recettesPlat[index].idRecette,
                            true);
                      }
                    }
                  },
                  child: isLiked
                      ? const Icon(Icons.favorite, size: 20, color: Colors.red)
                      : const Icon(
                          Icons.favorite_border,
                          color: Colors.deepOrange,
                          size: 20,
                        ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.white.withOpacity(0.8),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recettesPlat[index].nom,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDessertItem(BuildContext context, int index, bool isLiked) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailRecette(
              recette: recettesDessert[index],
              profile: myProfileRealTime,
            ),
          ),
        );
      },
      child: Container(
        width: 150.0,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  image: NetworkImage(recettesDessert[index].image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 8.0,
              right: 8.0,
              child: Container(
                width: 30.0,
                height: 30.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: MaterialButton(
                  padding: const EdgeInsets.all(0.0),
                  onPressed: () async {
                    if (user == null) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirmation"),
                            content: const Text(
                                "Voulez-vous être redirigé vers la page de connexion ?"),
                            actions: [
                              TextButton(
                                child: const Text("Non"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text("Oui"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          child: LoginScreenForm(),
                                          type: PageTransitionType.fade,
                                          childCurrent: widget,
                                          duration: const Duration(
                                              milliseconds: 300)));
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      Profile profile =
                          await firestoreService.getCurrentUserProfile();
                      if (isLiked) {
                        //action unlike
                        setState(() {
                          isLiked = !isLiked;
                        });
                        firestoreService.updateRecetteLikeur(
                            recettesDessert[index].idRecette, false);
                        //unlike : flag = false
                        firestoreService.updateProfileLikedRecette(
                            profile.idProfile,
                            recettesDessert[index].idRecette,
                            false);
                      } else {
                        //action like
                        setState(() {
                          isLiked = !isLiked;
                        });
                        firestoreService.updateRecetteLikeur(
                            recettesDessert[index].idRecette, true);
                        //unlike : flag = false
                        firestoreService.updateProfileLikedRecette(
                            profile.idProfile,
                            recettesDessert[index].idRecette,
                            true);
                      }
                    }
                  },
                  child: isLiked
                      ? const Icon(Icons.favorite, size: 20, color: Colors.red)
                      : const Icon(
                          Icons.favorite_border,
                          color: Colors.deepOrange,
                          size: 20,
                        ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.white.withOpacity(0.8),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recettesDessert[index].nom,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoissonItem(BuildContext context, int index, bool isLiked) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailRecette(
              recette: recettesBoisson[index],
              profile: myProfileRealTime,
            ),
          ),
        );
      },
      child: Container(
        width: 150.0,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  image: NetworkImage(recettesBoisson[index].image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 8.0,
              right: 8.0,
              child: Container(
                width: 30.0,
                height: 30.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: MaterialButton(
                  padding: const EdgeInsets.all(0.0),
                  onPressed: () async {
                    if (user == null) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirmation"),
                            content: const Text(
                                "Voulez-vous être redirigé vers la page de connexion ?"),
                            actions: [
                              TextButton(
                                child: const Text("Non"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text("Oui"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          child: LoginScreenForm(),
                                          type: PageTransitionType.fade,
                                          childCurrent: widget,
                                          duration: const Duration(
                                              milliseconds: 300)));
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      Profile profile =
                      await firestoreService.getCurrentUserProfile();
                      if (isLiked) {
                        //action unlike
                        setState(() {
                          isLiked = !isLiked;
                        });
                        firestoreService.updateRecetteLikeur(
                            recettesBoisson[index].idRecette, false);
                        //unlike : flag = false
                        firestoreService.updateProfileLikedRecette(
                            profile.idProfile,
                            recettesBoisson[index].idRecette,
                            false);
                      } else {
                        //action like
                        setState(() {
                          isLiked = !isLiked;
                        });
                        firestoreService.updateRecetteLikeur(
                            recettesBoisson[index].idRecette, true);
                        //unlike : flag = false
                        firestoreService.updateProfileLikedRecette(
                            profile.idProfile,
                            recettesBoisson[index].idRecette,
                            true);
                      }
                    }
                  },
                  child: isLiked
                      ? const Icon(Icons.favorite, size: 20, color: Colors.red)
                      : const Icon(
                          Icons.favorite_border,
                          color: Colors.deepOrange,
                          size: 20,
                        ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.white.withOpacity(0.8),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recettesBoisson[index].nom,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
