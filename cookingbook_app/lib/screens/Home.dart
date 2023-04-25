import 'package:cookingbook_app/services/FireStoreService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cookingbook_app/screens/LoginScreenDemo.dart';
import 'package:page_transition/page_transition.dart';

import '../models/Profile.dart';
import '../models/Recette.dart';

//import 'ResearchPage.dart';
//import 'CataloguePage.dart';
//import 'RecipeDescription.dart';

class MyHomePage extends StatefulWidget {
  String? signInMethod;

   MyHomePage({super.key,this.signInMethod=null});
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List categories = ["Entrée", "Plat", "Déssert", "Boisson"];
  User? user = FirebaseAuth.instance.currentUser;

  late List<Recette> allMyRecettes = [];
  late List<Recette> recettesEntree = [];
  late List<Recette> recettesPlat = [];
  late List<Recette> recettesDessert = [];
  late List<Recette> recettesBoisson = [];


  FirestoreService firestoreService = FirestoreService();

  Future<void> getMyRecettes() async {
    List<Recette> recettes = await firestoreService.getAllRecettes();
    setState(() {
      allMyRecettes = recettes;
    });
  }

  Future<void> fetchDataMyRecettes() async {
    await getMyRecettes();

    recettesEntree = allMyRecettes
        .where((recette) => recette.categorie == "Entree")
        .toList();
    recettesPlat = allMyRecettes
        .where((recette) => recette.categorie == "Plat")
        .toList();
    recettesDessert = allMyRecettes
        .where((recette) => recette.categorie == "Dessert")
        .toList();
    recettesBoisson = allMyRecettes
        .where((recette) => recette.categorie == "Boisson")
        .toList();

    print("All recettes : ${allMyRecettes.length}");
    print("All recettesPlat : ${recettesPlat.length}");
    print("All recettesDessert : ${recettesDessert.length}");
    print("All recettesBoisson : ${recettesBoisson.length}");
  }

  @override
  void initState() {
    fetchDataMyRecettes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
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
              Navigator.pushReplacement(
                  context,
                  PageTransition(
                      child: LoginScreenDemo(),
                      type: PageTransitionType.leftToRight));
            },
            icon: Icon(Icons.person),
            color: Colors.deepOrange,
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Entrée',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
                color: Colors.deepOrange,
              ),
            ),
          ),
          SizedBox(height: 8.0),
          Container(
            height: 200.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recettesEntree.length,
              itemBuilder: (BuildContext context, int index) {
                late bool _isLiked;
                if(user == null) {
                    _isLiked = false;
                } else {
                    _isLiked = recettesEntree[index].isLikedByUser(user!.uid);
                }
                return _buildEntreeItem(context, index, _isLiked);
              },
            ),
          ),
          SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Plat',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
                color: Colors.deepOrange,
              ),
            ),
          ),
          SizedBox(height: 8.0),
          Container(
            height: 200.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recettesPlat.length,
              itemBuilder: (BuildContext context, int index) {
                late bool _isLiked;
                if(user == null) {
                  _isLiked = false;
                } else {
                  _isLiked = recettesPlat[index].isLikedByUser(user!.uid);
                }
                return _buildPlatItem(context, index, _isLiked);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Dessert',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
                color: Colors.deepOrange,
              ),
            ),
          ),
          SizedBox(height: 8.0),
          Container(
            height: 200.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recettesDessert.length,
              itemBuilder: (BuildContext context, int index) {
                late bool _isLiked;
                if(user == null) {
                  _isLiked = false;
                } else {
                  _isLiked = recettesDessert[index].isLikedByUser(user!.uid);
                }
                return _buildDessertItem(context, index, _isLiked);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Boisson',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
                color: Colors.deepOrange,
              ),
            ),
          ),
          SizedBox(height: 8.0),
          Container(
            height: 200.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recettesBoisson.length,
              itemBuilder: (BuildContext context, int index) {
                late bool _isLiked;
                if(user == null) {
                  _isLiked = false;
                } else {
                  _isLiked = recettesBoisson[index].isLikedByUser(user!.uid);
                }
                return _buildBoissonItem(context, index, _isLiked);
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
          BottomNavigationBarItem(
            icon: GestureDetector(
              child: Icon(Icons.home),
              onTap: () {
                //Navigator.pushReplacement(
                  //context,
                  //MaterialPageRoute(builder: (context) => MyHomePage()),
                //);
              },
            ),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              child: Icon(Icons.search),
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
              child: Icon(Icons.favorite_border),
              onTap: () {
                /*Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritePage()),
                );*/
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

  Widget _buildEntreeItem(BuildContext context, int index,bool isLiked) {
    return GestureDetector(
      onTap: () {
        /*Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDescription(recette: recettesEntree[index]),
          ),
        );*/
      },
      child: Container(
        width: 150.0,
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Stack(
          children: [
            recettesEntree.length == 0 ? Container() :
            Container(
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: MaterialButton(
                  padding: EdgeInsets.all(0.0),
                  onPressed: () async {
                    if (user == null) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Confirmation"),
                            content: Text("Voulez-vous être redirigé vers la page de connexion ?"),
                            actions: [
                              TextButton(
                                child: Text("Non"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text("Oui"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.pushReplacement(
                                      context,
                                      PageTransition(
                                          child: LoginScreenDemo(),
                                          type: PageTransitionType.leftToRight
                                      )
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                      /*Navigator.pushReplacement(
                          context,
                          PageTransition(
                              child: LoginScreenDemo(),
                              type: PageTransitionType.leftToRight));*/
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
                        profile.unlikeContent(recettesEntree[index]);
                        recettesEntree[index].unlikeContent(profile.idProfile);
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
                        profile.likeContent(recettesEntree[index]);
                        recettesEntree[index].likeContent(profile.idProfile);
                      }
                    }
                  },
                  child: isLiked
                      ? Icon(Icons.favorite, size: 20, color: Colors.red)
                      : Icon(
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
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recettesEntree[index].nom,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatItem(BuildContext context, int index,bool isLiked) {
    return GestureDetector(
      onTap: () {
        /*Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDescription(recette: recettesPlat[index]),
          ),
        );*/
      },
      child: Container(
        width: 150.0,
        margin: EdgeInsets.symmetric(horizontal: 8.0),
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: MaterialButton(
                  padding: EdgeInsets.all(0.0),
                  onPressed: () async {
                    if (user == null) {
                      Navigator.pushReplacement(
                          context,
                          PageTransition(
                              child: LoginScreenDemo(),
                              type: PageTransitionType.leftToRight));
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
                        profile.unlikeContent(recettesPlat[index]);
                        recettesPlat[index].unlikeContent(profile.idProfile);
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
                        profile.likeContent(recettesPlat[index]);
                        recettesPlat[index].likeContent(profile.idProfile);
                      }
                    }
                  },
                  child: isLiked
                      ? Icon(Icons.favorite, size: 20, color: Colors.red)
                      : Icon(
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
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recettesPlat[index].nom,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDessertItem(BuildContext context, int index,bool isLiked) {
    return GestureDetector(
      onTap: () {
        /*Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDescription(recette: recettesDessert[index]),
          ),
        );*/
      },
      child: Container(
        width: 150.0,
        margin: EdgeInsets.symmetric(horizontal: 8.0),
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: MaterialButton(
                  padding: EdgeInsets.all(0.0),
                  onPressed: () async {
                    if (user == null) {
                      Navigator.pushReplacement(
                          context,
                          PageTransition(
                              child: LoginScreenDemo(),
                              type: PageTransitionType.leftToRight));
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
                        profile.unlikeContent(recettesDessert[index]);
                        recettesDessert[index].unlikeContent(profile.idProfile);
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
                        profile.likeContent(recettesDessert[index]);
                        recettesDessert[index].likeContent(profile.idProfile);
                      }
                    }
                  },
                  child: isLiked
                      ? Icon(Icons.favorite, size: 20, color: Colors.red)
                      : Icon(
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
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recettesDessert[index].nom,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoissonItem(BuildContext context, int index,bool isLiked) {
    return GestureDetector(
      onTap: () {
        /*Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDescription(recette: recettesBoisson[index]),
          ),
        );*/
      },
      child: Container(
        width: 150.0,
        margin: EdgeInsets.symmetric(horizontal: 8.0),
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: MaterialButton(
                  padding: EdgeInsets.all(0.0),
                  onPressed: () async {
                    if (user == null) {
                      Navigator.pushReplacement(
                          context,
                          PageTransition(
                              child: LoginScreenDemo(),
                              type: PageTransitionType.leftToRight));
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
                        profile.unlikeContent(recettesBoisson[index]);
                        recettesBoisson[index].unlikeContent(profile.idProfile);
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
                        profile.likeContent(recettesBoisson[index]);
                        recettesBoisson[index].likeContent(profile.idProfile);
                      }
                    }
                  },
                  child: isLiked
                      ? Icon(Icons.favorite, size: 20, color: Colors.red)
                      : Icon(
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
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recettesBoisson[index].nom,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4.0),
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
