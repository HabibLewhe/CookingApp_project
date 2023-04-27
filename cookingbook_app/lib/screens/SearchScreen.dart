import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import '../Utils/catogories.dart';
import '../Utils/color.dart';
import '../Utils/explorecart2.dart';
import '../models/Profile.dart';
import '../models/Recette.dart';
import '../services/FireStoreService.dart';
import 'DetailRecette.dart';
import 'FavoritePage.dart';
import 'Home.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
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

  Future<void> getMyRecettesRealTime() async {
    Stream<List<Recette>> stream = _firestoreService.getAllRecettesRealTime();
    stream.listen((List<Recette> recettes) {
      setState(() {
        _recettes = recettes;
      });
    });
  }

  Future<void> _loadData() async {
    _profiles = await _firestoreService.getAllProfiles();
    getMyRecettesRealTime();
    profile = await _firestoreService.getCurrentUserProfile();
    //from all recettes get all categories
    for (Recette recette in _recettes) {
      categories.add(recette.categorie);
    }

    //add all recettes to search result
    _performSearch("");
  }

  Profile _trouverProfile(String id) {
    Profile profile =
        Profile(idProfile: "", pseudo: "", imageAvatar: "", likedRecette: []);
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
      } else if (recette.nom.toLowerCase().contains(searchText.toLowerCase())) {
        resultsTemps.add(Tuple2(recette, _trouverProfile(recette.idUser)));
      } else if (recette.categorie
          .toLowerCase()
          .contains(searchText.toLowerCase())) {
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
        builder: (context) => DetailRecette(
          profile: profile,
          recette: recette,
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
            children: [
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "Explorer",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 35,
                      color: textColor),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Row(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: SizedBox(
                        height: 45,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                _performSearch(value);
                              },
                              decoration: const InputDecoration(
                                hintText: "Rechercher",
                                border: InputBorder.none,
                                suffixIcon: Icon(
                                  Icons.search,
                                  color: Colors.deepOrange,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 13.0, left: 10),
                child: Row(
                  //for all categories, create a category widget
                  children: [
                    for (String category in categories)
                      Catogeries(
                        color:
                            selectedCategory == category ? primary : cardColor,
                        text: category,
                        images: "assets/images/ramen.png",
                        onTap: () {
                          _searchController.text = category;
                          _performSearch(category);
                        },
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
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.deepOrange,
          unselectedItemColor: Colors.deepOrange,
          selectedFontSize: 19,
          unselectedFontSize: 19,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                  );
                },
              ),
              label: 'Accueil',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Recherche',
            ),
            BottomNavigationBarItem(
              icon: IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  if (profile != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FavoritePage(
                                profile: profile!,
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
      ),
    );
  }
}
