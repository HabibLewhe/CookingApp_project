import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tuple/tuple.dart';
import '../color.dart';
import '../models/Profile.dart';
import '../models/Recette.dart';
import '../services/FireStoreService.dart';
import '../utiles/bookmarkcart.dart';
import '../utiles/explorecart2.dart';
import '../utiles/favorieCart.dart';
import 'detailespage.dart';


class Bookmark extends StatefulWidget {
  const Bookmark({ Key? key }) : super(key: key);

  @override
  State<Bookmark> createState() => _BookmarkState();
}

class _BookmarkState extends State<Bookmark> {
  late List<Recette> recettesFavorites = [];
  List<Profile> _profiles = [];


  FirestoreService firestoreService = FirestoreService();
  List<Tuple2<Recette, Profile>> _searchResults = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getMyRecettes();
    _loadData();
  }

  Future<void> _loadData() async {
    _profiles = await firestoreService.getAllProfiles();
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


  Future<void> getMyRecettes() async {
    List<Recette> recettes = await firestoreService.getFavoritesRecettes();
    setState(() {
      recettesFavorites = recettes;
    });
    _performSearch("");
  }

  void _performSearch(String searchText) {
    List<Tuple2<Recette, Profile>> resultsTemps = [];

    // Search for recettes that match the search text
    for (Recette recette in recettesFavorites) {
      //get user
      Profile user =  _trouverProfile(recette.idUser);

      //si search text est vide on affiche tout
      if (searchText.isEmpty || recette.categorie.toLowerCase().contains(searchText.toLowerCase())
          || recette.nom.toLowerCase().contains(searchText.toLowerCase())
          || user.pseudo.toLowerCase().contains(searchText.toLowerCase())) {
        resultsTemps.add(Tuple2(recette, _trouverProfile(recette.idUser)));
      }
    }

    // Update the search results with the new results
    setState(() {
      _searchResults = resultsTemps;
    });
  }

  void _removeRecetteFromFavorites(Recette recette) async {
    setState(() {
      recettesFavorites.remove(recette);
      _performSearch("");
    });
  }

  void _showRecetteDetails(Profile profile, Recette recette) async {
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:  [
                    const Text("Favories",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: primary),),
                    Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: appBgColor,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: const [
                              BoxShadow(
                                color:Colors.white,
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child:  Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: SizedBox(
                    height: 55,
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
                            hintText: "Rechercher",
                            border: InputBorder.none,
                            suffixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              //if (_searchResults.isEmpty) show empty message
              if (_searchResults.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        "assets/icons/empty.svg",
                        height: MediaQuery.of(context).size.height * 0.3,
                        color: primary,
                      ),
                      const Text(
                        "Aucune recette trouvée",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              //show search results
              for (Tuple2<Recette, Profile> tup in _searchResults)
                FavorieCart(
                  profile: tup.item2,
                  recette: tup.item1,
                  onTap: () => _removeRecetteFromFavorites(tup.item1),
                ),
            ],
          ),
        ),
      ),
    );
  }
}