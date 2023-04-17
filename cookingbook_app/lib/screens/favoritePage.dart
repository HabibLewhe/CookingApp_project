import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../models/favorite_provider.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

bool isNotConnected() {
  return false;
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  Widget build(BuildContext context) {
    final provider = FavoriteProvider.of(context);
    final recettesFavorites = provider.recettes;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: isNotConnected()
          ? Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(

                      ),
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
              ),
            )
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ListView.builder(
                itemCount: recettesFavorites.length,
                itemBuilder: (context, index) {
                  final recette = recettesFavorites[index];
                  return Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ListTile(
                        leading: AspectRatio(
                          aspectRatio: 1.5,
                          child: Image.network(
                            recette.image,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            scale: 1.0,
                          ),
                        ),
                        title: Text(
                          recette.nom,
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                        trailing: IconButton(
                          onPressed: () {
                            provider.toggleFavorite(recette);
                          },
                          icon: provider.isExist(recette)
                              ? const Icon(Icons.favorite, color: Colors.red)
                              : const Icon(Icons.favorite_border),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
