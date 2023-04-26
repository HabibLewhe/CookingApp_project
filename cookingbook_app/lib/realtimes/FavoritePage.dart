import 'package:cookingbook_app/models/Recette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../models/Profile.dart';
import '../services/FireStoreService.dart';

class FavoritePage extends StatefulWidget {
  final Profile profile;

  const FavoritePage({
    Key? key,
    required this.profile,
  }) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  bool isNotConnected() {
    return false;
  }

  late List<Recette> recettesFavorites = [];

  FirestoreService firestoreService = FirestoreService();

  Future<void> getMyRecettes() async {
    List<Recette> recettes = await firestoreService.getFavoritesRecettes();
    setState(() {
      recettesFavorites = recettes;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getMyRecettes();
  }

  void toggleFavorite(Recette recette) {
    final isExist = recettesFavorites.contains(recette);
    if (isExist) {
      recettesFavorites.remove(recette);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Mes Favoris'),
      ),
      body: isNotConnected()
          ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(),
                  child: const Text(
                    "Pour enregister et créer des recettes tu dois être connecté.",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Colors.red,
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Je me connecte',
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                ),
                const SizedBox(height: 20),
                RichText(
                    text: TextSpan(
                        text: "Je crée un compte",
                        style: const TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.red),
                        recognizer: TapGestureRecognizer()..onTap = () {}))
              ],
            ),
          )
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ListView.builder(
                itemCount: recettesFavorites.length,
                itemBuilder: (context, index) {
                  final recette = recettesFavorites[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      onTap: (){},
                      leading: SizedBox(
                        child: CircleAvatar(
                          radius: 28,
                          backgroundImage: NetworkImage(
                            recette.image,
                            scale: 1.0,
                          ),
                        ),
                      ),
                      title: Text(
                        recette.nom,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          //_isLiked = widget.profile.hasLikedContent(recette);
                          firestoreService.updateRecetteLikeur(
                              recette.idRecette, false);
                          //unlike : flag = false
                          firestoreService.updateProfileLikedRecette(
                              widget.profile.idProfile,
                              recette.idRecette,
                              false);
                          widget.profile.unlikeContent(recette);
                          recette.unlikeContent(widget.profile.idProfile);
                          setState(() {
                            toggleFavorite(recette);
                          });
                        },
                        icon: const Icon(Icons.favorite, color: Colors.red) //provider.isExist(recette)
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
