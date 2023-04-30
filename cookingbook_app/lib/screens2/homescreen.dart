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
    //random between 2 and 4
    int random = 2 + (new DateTime.now().millisecondsSinceEpoch % 3);
    for (int i = 0; i < random; i++) {
      recettes.add(_recettes[i]);
    }



    setState(() {
      recommandedRecettes = recettes;
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
                  "Stay at home,",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: textColor),
                ),
                RichText(
                    text: const TextSpan(children: [
                  TextSpan(
                      text: "make your own ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: textColor)),
                  TextSpan(
                      text: "food",
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
                  "Popular Recipes",
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
                     InkWell (
                        child: const Popularcart(
                            images:
                                "https://images.unsplash.com/photo-1512058564366-18510be2db19?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=872&q=80",
                            name: "Rice pot",
                            userimage:
                                "https://images.unsplash.com/photo-1557862921-37829c790f19?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8bWFufGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=500&q=60"),
                      ),
                       Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: InkWell(
                          child: const Popularcart(
                              images:
                                  "https://images.unsplash.com/photo-1623595119708-26b1f7300075?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=383&q=80",
                              name: "Ice Cream",
                              userimage:
                                  "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=387&q=80"),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  "Recommended Recipes",
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
