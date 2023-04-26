import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../color.dart';
import '../models/Profile.dart';
import '../models/Recette.dart';
import '../screens/DetailRecetteDemo.dart';
import '../services/FireStoreService.dart';
import '../utiles/catogories.dart';
import '../utiles/explorecart.dart';
import '../utiles/explorecart2.dart';
import 'package:tuple/tuple.dart';

import 'detailespage.dart';


class Explore extends StatefulWidget {
  const Explore({ Key? key }) : super(key: key);
  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  List<Profile> _profiles = [];
  List<Recette> _recettes = [];
  List<Tuple2<Recette, Profile>> _searchResults = [];
  Set<String> categories = Set<String>();
  String selectedCategory = "";

  TextEditingController _searchController = TextEditingController();
  FirestoreService _firestoreService = FirestoreService();
  Profile? profile;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _profiles = await _firestoreService.getAllProfiles();
    _recettes = await _firestoreService.getAllRecettes();
    profile = await _firestoreService.getCurrentUserProfile();
    //from all recettes get all categories
    for (Recette recette in _recettes) {
      categories.add(recette.categorie);
    }

    //add all recettes to search result
    _performSearch("");
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

  void _performSearch(String searchText) {
    List<Tuple2<Recette, Profile>> resultsTemps = [];
    selectedCategory = searchText;

    // Search for recettes that match the search text
    for (Recette recette in _recettes) {
      //si search text est vide on affiche tout
      if (searchText.isEmpty) {
          resultsTemps.add(Tuple2(recette, _trouverProfile(recette.idUser)));
      } else

      if (recette.nom.toLowerCase().contains(searchText.toLowerCase())) {
        resultsTemps.add(Tuple2(recette, _trouverProfile(recette.idUser)));
      } else if (recette.categorie.toLowerCase().contains(searchText.toLowerCase())) {
        resultsTemps.add(Tuple2(recette, _trouverProfile(recette.idUser)));
      }
    }

    // Update the search results with the new results
    setState(() {
      _searchResults = resultsTemps;
    });
  }

  void _showRecetteDetails(Profile profile, Recette recette) async {
    // Navigate to the DetailRecetteDemo screen with the ID of the selected recette
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Detailspage(
          image: recette.image,
          name: recette.nom,
          username: profile.pseudo,
          userimage: profile.imageAvatar
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: appBgColor,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:  [
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text("Explore",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 35,color: textColor),),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left:10.0),
                child: Row(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: SizedBox(
                         height: 45,
                         width: MediaQuery.of(context).size.width*0.9,
                          child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                _performSearch(value);
                              },
                              decoration: InputDecoration(
                                hintText: "Search",
                                border: InputBorder.none,
                                suffixIcon: Icon(Icons.search),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10,),
                 Padding(
                  padding: const EdgeInsets.only(top: 13.0,left: 10),
                  child: Row(
                    //for all categories, create a category widget
                    children: [
                      for (String category in categories)
                        Catogeries(
                          color: selectedCategory == category ? primary : cardColor,
                          text: category,
                          images: "assets/images/ramen.png",
                          onTap: () {
                            _searchController.text = category;
                            _performSearch(category);  },
                        ),
                    ],


                  ),
                ),
              //for all _searchResults, show a explore cart
              for (Tuple2<Recette, Profile> tup in _searchResults)
                ExploreCart2(
                  profile: tup.item2,
                  recette: tup.item1,
                  onTap: () => _showRecetteDetails(tup.item2, tup.item1),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

