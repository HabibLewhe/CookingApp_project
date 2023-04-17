import 'package:cookingbook_app/models/Recette.dart';
import 'package:cookingbook_app/screens/CreateReceipe.dart';
import 'package:cookingbook_app/screens/favoritePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';

import 'models/favorite_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => FavoriteProvider(),
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const MyHomePage(title: 'Flutter Demo Home Page'),
          debugShowCheckedModeBanner: false,
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Recette> recettes = [];

  @override
  void initState() {
    // TODO: implement initState
    recettes = [
      Recette(
        idRecette: 1,
        image:
            "https://www.finedininglovers.fr/sites/g/files/xknfdk1291/files/2021-04/pates%20carbonara%20iStock.jpg",
        nom: "Pâtes à la carbonara",
        tempsPreparation: const Duration(minutes: 30),
        nbPersonne: 2,
        instruction:
            "Faire cuire les pâtes, mélanger les oeufs et le parmesan, faire revenir le lard puis mélanger le tout.",
        ingredients: {
          'Pâtes': '300g',
          'Oeufs': '2',
          'Parmesan': '50g',
          'Lardons': '150g',
        },
      ),
      Recette(
        idRecette: 2,
        image:
            "https://img.mesrecettesfaciles.fr/wp-content/uploads/2016/09/pizzamargarita-1000x500.jpg",
        nom: "Pizza margherita",
        tempsPreparation: const Duration(minutes: 45),
        nbPersonne: 4,
        instruction:
            "Etaler la pâte à pizza, étaler la sauce tomate, ajouter la mozzarella et les tomates cerises, faire cuire au four.",
        ingredients: {
          'Pâte à pizza': '1',
          'Sauce tomate': '100g',
          'Mozzarella': '125g',
          'Tomates cerises': '8',
        },
      ),
      Recette(
        idRecette: 3,
        image:
            "https://assets.afcdn.com/recipe/20200212/107449_w1024h1024c1cx1060cy707.webp",
        nom: "Salade César",
        tempsPreparation: const Duration(minutes: 20),
        nbPersonne: 2,
        instruction:
            "Mélanger la salade, les croûtons et le poulet, ajouter la sauce César et le parmesan.",
        ingredients: {
          'Salade': '150g',
          'Croûtons': '50g',
          'Poulet': '200g',
          'Sauce César': '50g',
          'Parmesan': '25g',
        },
      ),
      Recette(
        idRecette: 4,
        image:
            "https://cdn.pratico-pratiques.com/app/uploads/sites/3/2018/08/20193130/ratattouille-repas.jpeg",
        nom: "Ratatouille",
        tempsPreparation: const Duration(minutes: 60),
        nbPersonne: 6,
        instruction:
            "Faire revenir les légumes, ajouter les tomates et l'ail, faire mijoter à feu doux.",
        ingredients: {
          'Courgettes': '2',
          'Aubergines': '2',
          'Poivrons': '2',
          'Oignons': '2',
          'Tomates': '4',
          'Ail': '2 gousses',
        },
      ),
      Recette(
        idRecette: 5,
        image: "https://recette.supertoinette.com/155452/b/poulet-roti.jpg",
        nom: "Poulet rôti",
        tempsPreparation: const Duration(minutes: 90),
        nbPersonne: 4,
        instruction: "Assaisonner le poulet, le mettre au four pendant 1h30.",
        ingredients: {
          'Poulet': '1',
          'Sel': '1 pincée',
          'Poivre': '1 pincée',
          'Beurre': '50g',
        },
      ),
      Recette(
        idRecette: 6,
        image:
            "https://www.auxdelicesdupalais.net/wp-content/uploads/2016/11/Tarte-aux-pommesDSC06174.jpg",
        nom: "Tarte aux pommes",
        tempsPreparation: const Duration(minutes: 60),
        nbPersonne: 6,
        instruction:
            "Etaler la pâte, éplucher et couper les pommes, disposer les pommes sur la pâte, enfourner.",
        ingredients: {
          'Pâte brisée': '1',
          'Pommes': '6',
          'Sucre': '100g',
          'Cannelle': '1 cuillère à café',
        },
      ),
      Recette(
        idRecette: 7,
        image:
            "https://www.otodoke.fr/wp-content/uploads/2018/05/sushi-2112350_1920.jpg",
        nom: "Sushi",
        tempsPreparation: const Duration(minutes: 90),
        nbPersonne: 2,
        instruction:
            "Préparer le riz à sushi, découper les poissons et les légumes, rouler le tout dans une feuille de nori.",
        ingredients: {
          'Riz à sushi': '300g',
          'Saumon': '150g',
          'Thon': '150g',
          'Avocat': '1',
          'Concombre': '1',
          'Feuilles de nori': '4',
          'Wasabi': '1 cuillère à café',
          'Sauce soja': '50ml',
        },
      ),
      Recette(
        idRecette: 8,
        image:
            "https://epicetoorecettes.fr/img/recettes/grande/recette-poulet-au-curry.jpg",
        nom: "Poulet curry",
        tempsPreparation: const Duration(minutes: 45),
        nbPersonne: 4,
        instruction:
            "Faire revenir le poulet, ajouter les légumes et le curry, faire mijoter.",
        ingredients: {
          'Poulet': '500g',
          'Curry': '2 cuillères à soupe',
          'Oignons': '2',
          'Carottes': '2',
          'Pommes de terre': '2',
          'Lait de coco': '400ml',
        },
      ),
      Recette(
        idRecette: 9,
        image:
            "https://recette.supertoinette.com/151891/b/riz-cantonais-au-thermomix.jpg",
        nom: "Riz cantonais",
        tempsPreparation: const Duration(minutes: 30),
        nbPersonne: 4,
        instruction:
            "Cuire le riz, faire revenir les oeufs et les légumes, ajouter le riz et la sauce soja.",
        ingredients: {
          'Riz basmati': '250g',
          'Oeufs': '2',
          'Petits pois': '100g',
          'Carottes': '2',
          'Oignons': '2',
          'Sauce soja': '50ml',
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final provider = FavoriteProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ListView.builder(
          itemCount: recettes.length,
          itemBuilder: (context, index) {
            final recette = recettes[index];
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
      /*floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final route = MaterialPageRoute(
            builder: (context) => const FavoritePage(),
          );
          Navigator.push(context, route);
        },
        label: const Text('Favorites'),
      ),*/
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        overlayColor: Colors.black,
        overlayOpacity: 0.4,
        children: [
          SpeedDialChild(
            onTap: () {
              final route = MaterialPageRoute(
                builder: (context) => const FavoritePage(),
              );
              Navigator.push(context, route);
            },
            child: const Icon(Icons.favorite, color: Colors.red,),
            label: 'Favorites',
          ),
          SpeedDialChild(
            onTap: () {
              final route = MaterialPageRoute(
                builder: (context) => CreateRecetteForm(),
              );
              Navigator.push(context, route);
            },
            child: const Icon(Icons.add, color: Colors.blue),
            label: 'New receipe',
          )
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
