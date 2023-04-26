import 'package:cookingbook_app/models/Commentaire.dart';

class Recette {
  String idUser;
  String idRecette; // documentID sur firebase
  String image;
  String nom;
  Duration tempsPreparation;
  String nbPersonne;
  String instruction;
  String categorie;
  Map<String, String> ingredients;

  List<String> likeur; //id profile
  List<String> commentaires; // id commentaire

  Recette({
    required this.idUser,
    required this.idRecette,
    required this.image,
    required this.nom,
    required this.tempsPreparation,
    required this.nbPersonne,
    required this.instruction,
    required this.ingredients,
    required this.categorie,
    required this.likeur,
    required this.commentaires,
  });

  void likeContent(String userId) {
    if (!likeur.contains(userId)) {
      likeur.add(userId);
    }
  }

  void unlikeContent(String userId) {
    if (likeur.contains(userId)) {
      likeur.remove(userId);
    }
  }

  bool isLikedByUser(String userId) {
    return likeur.contains(userId);
  }
}