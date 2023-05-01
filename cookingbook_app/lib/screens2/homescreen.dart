import 'package:cookingbook_app/screens/AddNewRecette.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../color.dart';
import '../models/Profile.dart';
import '../models/Recette.dart';
import '../screens/EditProfile.dart';
import '../screens/Home.dart';
import '../services/Authentication.dart';
import '../services/FireStoreService.dart';
import '../utiles/popular.dart';
import '../utiles/recomanded.dart';
import 'detailespage.dart';

class Homescreen extends StatefulWidget {
  final String signInMethod;
  const Homescreen({Key? key,required this.signInMethod}) : super(key: key);

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  Authentication auth = Authentication();
  FirestoreService _firestoreService = FirestoreService();


  List<Profile> _profiles = [];
  List<Recette> _recettes = [];
  List<Recette> recommandedRecettes = [];
  List<Recette> popularRecettes = [];
  Profile? thisProfile;


  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _profiles = await _firestoreService.getAllProfiles();
    _recettes = await _firestoreService.getAllRecettes();
    thisProfile = await _firestoreService.getCurrentUserProfile();

    _recettes.shuffle();

    List<Recette> recettes = [];
    List<Recette> recettesPopular = [];
    //random between 2 and 4
    int random = 2 + (new DateTime.now().millisecondsSinceEpoch % 3);
    for (int i = 0; i < random; i++) {
      recettes.add(_recettes[i]);
    }

    //choisi les recettes les plus populaires
    for (Recette recette in _recettes) {
      if (int.parse(recette.nbPersonne) > 5) {
        recettesPopular.add(recette);
      }
    }



    setState(() {
      recommandedRecettes = recettes;
      popularRecettes = recettesPopular;
    });
  }


  Profile _trouverProfile(String id) {
    Profile profile = Profile(idProfile: "", pseudo: "", imageAvatar: "", likedRecette: []);
    for (Profile profile in _profiles) {
      if (profile.idProfile == id) {
        return profile;
      }
    }
    return profile;
  }

  void _showRecetteDetails(Recette recette) async {
    Profile profile = _trouverProfile(recette.idUser);
    // Navigate to the DetailRecetteDemo screen with the ID of the selected recette
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Detailspage(
          recette: recette,
          profile: profile,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: appBgColor,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: shadowColor.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child:  IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (ctx) => EditProfile(profile: thisProfile!)));
                                    },
                                icon: const Icon(Icons.person,color: primary),
                            ),
                        ),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: appBgColor,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: IconButton(
                          onPressed: () {
                            auth.onLogout();
                            Navigator.push(context,
                                MaterialPageRoute(builder: (ctx) => Home()));
                          },
                          icon: const Icon(Icons.logout,color: primary),
                        ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Restez chez vous,",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: textColor),
                ),
                RichText(
                    text: const TextSpan(children: [
                  TextSpan(
                      text: "cuisinez votre propre ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: textColor)),
                  TextSpan(
                      text: "RECETTE",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primary,
                          fontSize: 30))
                ])),
                Padding(
                  padding: const EdgeInsets.only(top: 13.0),

                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Recettes populaires",
                  style: TextStyle(
                      fontSize: 25,
                      color: textColor,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 250,
                  child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children:  [
                      for (Recette recette in popularRecettes)
                        Popularcart(recette: recette,profile: _trouverProfile(recette.idUser),onTap: () => _showRecetteDetails(recette)),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  "Recettes recommandées",
                  style: TextStyle(
                      fontSize: 25,
                      color: textColor,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 10,
                ),
               SizedBox(
                  height: 120,
                    //show the list of recommandedRecettes
                  child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children: [
                        for (Recette recette in recommandedRecettes)
                          Recommended(recette: recette,onTap: () => _showRecetteDetails(recette)),
                    ]
                  ),
                ),
              ],
            ),

          ),
        ),
      ),
      floatingActionButton:   FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              PageTransition(
                  child:  AddNewRecette(),
                  type: PageTransitionType.bottomToTop,
                  duration: const Duration(milliseconds: 800)));

        },
        backgroundColor: primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
