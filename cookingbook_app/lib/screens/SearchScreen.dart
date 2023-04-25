import 'package:flutter/material.dart';

import '../models/Commentaire.dart';
import '../models/Profile.dart';
import '../models/Recette.dart';
import '../services/FireStoreService.dart';
import 'DetailRecetteDemo.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Profile> _profiles = [];
  List<Recette> _recettes = [];
  List<dynamic> _searchResults = [];
  FirestoreService firestoreService = FirestoreService();

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
  }

  void _performSearch(String searchText) {
    List<dynamic> results = [];

    // Search for profiles that match the search text
    for (Profile profile in _profiles) {
      if (profile.pseudo.toLowerCase().contains(searchText.toLowerCase())) {
        results.add(profile);
      }
    }

    // Search for recettes that match the search text
    for (Recette recette in _recettes) {
      if (recette.nom.toLowerCase().contains(searchText.toLowerCase())) {
        results.add(recette);
      } else if (recette.categorie
          .toLowerCase()
          .contains(searchText.toLowerCase())) {
        results.add(recette);
      }
    }

    // Update the search results with the new results
    setState(() {
      _searchResults = results;
    });
  }

  void _showRecetteDetails(Profile profile, Recette recette) async {
    List<String> _listPseudoCmt = [];
    List<Commentaire> listCommentaire = [];
    List<Commentaire> commentaires =
        await firestoreService.getCommentaire(recette.idRecette);

    List<String> idsProfile = [];
    for (Commentaire cmt in commentaires) {
      idsProfile.add(cmt.idUser);
    }
    print("this is ID users : ${idsProfile.toString()}");
    List<String> listPseudoCmt =
        await firestoreService.getPseudosById(idsProfile);
    print("_list listPseudoCmt ${listPseudoCmt.length}");
    print("_list commentaires ${commentaires.length}");
    setState(() {
      _listPseudoCmt = listPseudoCmt;
      listCommentaire = commentaires;
    });

    // Navigate to the DetailRecetteDemo screen with the ID of the selected recette
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailRecetteDemo(
          profile: profile,
          recette: recette,
          listCommentaires: listCommentaire,
          listPseudos: _listPseudoCmt,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search',
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.7),
            ),
            border: InputBorder.none,
          ),
          style: TextStyle(
            color: Colors.white,
          ),
          onChanged: (searchText) {
            _performSearch(searchText);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (BuildContext context, int index) {
          dynamic result = _searchResults[index];

          if (result is Profile) {
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(result.imageAvatar),
              ),
              title: Text(result.pseudo),
              subtitle: Text('Profile'),
              onTap: () {
                //navigate to Profile
              },
            );
          } else if (result is Recette) {
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(result.image),
              ),
              title: Text(result.nom),
              subtitle: Text(result.categorie),
              onTap: () {
                _showRecetteDetails(profile!, result);
              },
            );
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }
}
